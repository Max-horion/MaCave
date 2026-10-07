package fr.bouthon.cave

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.os.Build
import com.googlecode.tesseract.android.TessBaseAPI
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    // Tesseract (lot 5d) : lecture du texte d'une photo d'étiquette, appelée
    // depuis Dart par le canal « fr.bouthon.cave/tesseract »
    // (lib/scan/label_recognizer.dart). Une seule instance, gardée entre deux
    // photos (l'initialisation charge le dictionnaire, quelques Mo), et
    // utilisée sur un seul fil de fond : TessBaseAPI n'est pas thread-safe.
    private val worker = Executors.newSingleThreadExecutor()
    private var tess: TessBaseAPI? = null
    private var tessKey: String? = null

    // Android 8 à 10 : écrire les sauvegardes dans Documents demande
    // l'autorisation « stockage » (Android 11+ : sans autorisation). Canal
    // « fr.bouthon.cave/storage » (lib/sync/storage_access.dart).
    private var storageResult: MethodChannel.Result? = null
    private val storageRequestCode = 4201

    private fun storageGranted(): Boolean =
        Build.VERSION.SDK_INT > Build.VERSION_CODES.Q ||
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
            PackageManager.PERMISSION_GRANTED

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != storageRequestCode) return
        storageResult?.success(storageGranted())
        storageResult = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fr.bouthon.cave/tesseract",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hocr" -> {
                    val dataPath = call.argument<String>("dataPath")!!
                    val language = call.argument<String>("language")!!
                    val imagePath = call.argument<String>("imagePath")!!
                    val psm = call.argument<Int>("psm") ?: TessBaseAPI.PageSegMode.PSM_AUTO
                    worker.execute {
                        try {
                            val hocr = recognize(dataPath, language, imagePath, psm)
                            runOnUiThread { result.success(hocr) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("tesseract", e.message, null) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fr.bouthon.cave/storage",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "granted" -> result.success(storageGranted())
                "request" -> {
                    if (storageGranted()) {
                        result.success(true)
                    } else if (storageResult != null) {
                        result.error("storage", "demande déjà en cours", null)
                    } else {
                        storageResult = result
                        requestPermissions(
                            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                            storageRequestCode,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /// [dataPath] doit contenir un dossier `tessdata` avec `<language>.traineddata`.
    private fun recognize(dataPath: String, language: String, imagePath: String, psm: Int): String {
        val key = "$dataPath|$language"
        var api = tess
        if (api == null || tessKey != key) {
            api?.recycle()
            api = TessBaseAPI()
            if (!api.init(dataPath, language)) {
                api.recycle()
                tess = null
                tessKey = null
                throw IllegalStateException("Initialisation de Tesseract impossible ($language)")
            }
            tess = api
            tessKey = key
        }
        api.pageSegMode = psm
        val image = loadUpright(imagePath)
        try {
            api.setImage(image)
            val hocr = api.getHOCRText(0) ?: ""
            api.clear()
            return hocr
        } finally {
            image.recycle()
        }
    }

    /// Photo remise à l'endroit et réduite. Le téléphone enregistre souvent
    /// l'image « couchée » avec une simple indication de rotation (EXIF) :
    /// ML Kit en tient compte, Tesseract non, et ne lit alors rien d'une
    /// étiquette tournée d'un quart de tour. La réduction (au plus
    /// [MAX_SIDE] pixels de côté) accélère la lecture sans perdre le texte.
    private fun loadUpright(path: String): Bitmap {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        var sample = 1
        while (maxOf(bounds.outWidth, bounds.outHeight) / (sample * 2) >= MAX_SIDE) {
            sample *= 2
        }
        val decoded = BitmapFactory.decodeFile(
            path,
            BitmapFactory.Options().apply { inSampleSize = sample },
        ) ?: throw IllegalArgumentException("Image illisible : $path")

        val matrix = Matrix()
        when (ExifInterface(path).getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_NORMAL,
        )) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.postScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.postScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(270f)
                matrix.postScale(-1f, 1f)
            }
            else -> return decoded
        }
        val upright = Bitmap.createBitmap(
            decoded, 0, 0, decoded.width, decoded.height, matrix, true,
        )
        if (upright !== decoded) decoded.recycle()
        return upright
    }

    companion object {
        private const val MAX_SIDE = 2000
    }

    override fun onDestroy() {
        worker.execute {
            tess?.recycle()
            tess = null
        }
        worker.shutdown()
        super.onDestroy()
    }
}
