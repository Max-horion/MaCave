package fr.bouthon.cave

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.google.zxing.BarcodeFormat
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.LuminanceSource
import com.google.zxing.MultiFormatReader
import com.google.zxing.PlanarYUVLuminanceSource
import com.google.zxing.ReaderException
import com.google.zxing.common.HybridBinarizer
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

    // ZXing (lot 7) : lecteur de codes-barres libre. Canal
    // « fr.bouthon.cave/zxing » (lib/scan/zxing_reader.dart) : reçoit la
    // luminance d'une image de la caméra et rend le code lu, ou null. Fil à
    // part (pas celui de Tesseract) ; MultiFormatReader n'est pas thread-safe.
    private val barcodeWorker = Executors.newSingleThreadExecutor()
    private val barcodeReader = MultiFormatReader().apply {
        setHints(
            mapOf(
                DecodeHintType.POSSIBLE_FORMATS to listOf(
                    BarcodeFormat.EAN_13,
                    BarcodeFormat.EAN_8,
                    BarcodeFormat.UPC_A,
                    BarcodeFormat.UPC_E,
                    BarcodeFormat.CODE_128,
                    BarcodeFormat.CODE_39,
                    BarcodeFormat.CODE_93,
                    BarcodeFormat.ITF,
                    BarcodeFormat.QR_CODE,
                    BarcodeFormat.DATA_MATRIX,
                ),
                // Cherche sur plus de lignes de l'image : plus lent, mais
                // une image prise à main levée dans le noir en a besoin.
                DecodeHintType.TRY_HARDER to true,
            ),
        )
    }

    // Android 8 à 10 : écrire les sauvegardes dans Documents demande
    // l'autorisation « stockage » (Android 11+ : sans autorisation). Canal
    // « fr.bouthon.cave/storage » (lib/sync/storage_access.dart).
    private var storageResult: MethodChannel.Result? = null
    private val storageRequestCode = 4201

    private fun storageGranted(): Boolean =
        Build.VERSION.SDK_INT > Build.VERSION_CODES.Q ||
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
            PackageManager.PERMISSION_GRANTED

    // Refus définitif : après un refus avec « Ne plus demander » (ou un
    // second refus sur certains téléphones, dont les Xiaomi), Android
    // n'affiche plus la fenêtre et répond « refusé » tout seul. Seuls les
    // réglages de l'appli permettent alors d'autoriser. Android ne le dit pas
    // directement : on le note quand une demande est refusée sans que le
    // système propose de redemander (shouldShowRequestPermissionRationale).
    private val storagePrefs by lazy {
        getSharedPreferences("storage_access", MODE_PRIVATE)
    }

    private fun storageBlocked(): Boolean =
        !storageGranted() &&
            storagePrefs.getBoolean("blocked", false) &&
            !shouldShowRequestPermissionRationale(
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
            )

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != storageRequestCode) return
        val granted = storageGranted()
        val blocked = !granted && !shouldShowRequestPermissionRationale(
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
        )
        storagePrefs.edit().putBoolean("blocked", blocked).apply()
        storageResult?.success(granted)
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
            "fr.bouthon.cave/zxing",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "decode" -> {
                    val bytes = call.argument<ByteArray>("bytes")!!
                    val width = call.argument<Int>("width")!!
                    val height = call.argument<Int>("height")!!
                    val rowStride = call.argument<Int>("rowStride")!!
                    barcodeWorker.execute {
                        val found = try {
                            decodeBarcode(bytes, width, height, rowStride)
                        } catch (e: Exception) {
                            null
                        }
                        runOnUiThread {
                            result.success(
                                found?.let {
                                    mapOf("text" to it.text, "format" to it.barcodeFormat.name)
                                },
                            )
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
                "blocked" -> result.success(storageBlocked())
                "openSettings" -> {
                    startActivity(
                        Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.fromParts("package", packageName, null),
                        ),
                    )
                    result.success(null)
                }
                "request" -> {
                    if (storageGranted()) {
                        result.success(true)
                    } else if (storageBlocked()) {
                        // La fenêtre ne s'afficherait pas : inutile de demander.
                        result.success(false)
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

    /// Cherche un code dans l'image telle quelle, puis tournée d'un quart de
    /// tour : le capteur est en paysage, et un code tenu à l'horizontale
    /// téléphone en main y apparaît vertical. Les codes linéaires ne sont lus
    /// que dans le sens des lignes ; les QR codes, dans tous les sens.
    private fun decodeBarcode(data: ByteArray, width: Int, height: Int, rowStride: Int): com.google.zxing.Result? {
        if (rowStride < width || data.size < (height - 1) * rowStride + width) {
            throw IllegalArgumentException("Image incomplète")
        }
        val upright = PlanarYUVLuminanceSource(
            data, rowStride, height, 0, 0, width, height, false,
        )
        return tryDecode(upright) ?: tryDecode(rotated(data, width, height, rowStride))
    }

    private fun tryDecode(source: LuminanceSource): com.google.zxing.Result? =
        try {
            barcodeReader.decodeWithState(BinaryBitmap(HybridBinarizer(source)))
        } catch (e: ReaderException) {
            null
        } finally {
            barcodeReader.reset()
        }

    /// Image tournée d'un quart de tour (sens horaire), sans marge en fin de ligne.
    private fun rotated(data: ByteArray, width: Int, height: Int, rowStride: Int): LuminanceSource {
        val out = ByteArray(width * height)
        for (y in 0 until height) {
            val row = y * rowStride
            val column = height - 1 - y
            for (x in 0 until width) {
                out[x * height + column] = data[row + x]
            }
        }
        return PlanarYUVLuminanceSource(out, height, width, 0, 0, height, width, false)
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
        barcodeWorker.shutdown()
        super.onDestroy()
    }
}
