package fr.bouthon.cave

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
        api.setImage(File(imagePath))
        val hocr = api.getHOCRText(0) ?: ""
        api.clear()
        return hocr
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
