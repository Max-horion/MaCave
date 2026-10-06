import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/label_reading.dart';

// Reconnaissance du texte d'une photo d'étiquette, sur le téléphone. Le
// moteur est interchangeable (CDC §10) : ML Kit, Tesseract, et
// un mode comparaison qui affiche les deux.

abstract class LabelRecognizer {
  /// Nom du moteur, affiché en mode comparaison.
  String get name;

  /// Lignes de texte de l'image [imagePath], dans l'ordre de lecture.
  Future<List<LabelLine>> recognize(String imagePath);

  Future<void> close();
}

/// ML Kit de Google (modèle des lettres latines embarqué : hors ligne).
class MlKitLabelRecognizer implements LabelRecognizer {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  String get name => 'ML Kit';

  @override
  Future<List<LabelLine>> recognize(String imagePath) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    return [
      for (final block in result.blocks)
        for (final line in block.lines)
          LabelLine(line.text, height: line.boundingBox.height),
    ];
  }

  @override
  Future<void> close() => _recognizer.close();
}

/// Tesseract 5 (bibliothèque Android Tesseract4Android, appelée par
/// `MainActivity.kt`), dictionnaire français « best » embarqué
/// (assets/tessdata). Plus lent que ML Kit ; comparé pendant la bêta.
class TesseractLabelRecognizer implements LabelRecognizer {
  static const _channel = MethodChannel('fr.bouthon.cave/tesseract');

  /// Dictionnaire embarqué : `assets/tessdata/<langue>.traineddata`.
  static const language = 'fra';

  /// Mode de découpage de la page : 3 = automatique (blocs, colonnes).
  static const pageSegmentation = 3;

  @override
  String get name => 'Tesseract';

  @override
  Future<List<LabelLine>> recognize(String imagePath) async {
    final hocr = await _channel.invokeMethod<String>('hocr', {
      'dataPath': await _dataPath(),
      'language': language,
      'imagePath': imagePath,
      'psm': pageSegmentation,
    });
    return parseHocr(hocr ?? '');
  }

  /// Dossier privé contenant `tessdata/` : Tesseract ne lit pas les
  /// ressources de l'APK, le dictionnaire y est copié au premier usage (ou
  /// recopié s'il a changé avec une mise à jour de l'appli).
  static Future<String> _dataPath() async {
    final root = Directory(
      '${(await getApplicationSupportDirectory()).path}/tesseract',
    );
    final file = File('${root.path}/tessdata/$language.traineddata');
    final bundled = await rootBundle.load(
      'assets/tessdata/$language.traineddata',
    );
    if (!file.existsSync() || file.lengthSync() != bundled.lengthInBytes) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bundled.buffer.asUint8List(), flush: true);
    }
    return root.path;
  }

  @override
  Future<void> close() async {}
}

/// Confiance minimale (0 à 100) d'un mot rendu par Tesseract : en dessous,
/// c'est presque toujours un motif de l'étiquette pris pour du texte.
const tesseractMinConfidence = 40;

/// Lignes d'un résultat hOCR de Tesseract, avec leur hauteur de lettres
/// (`x_size`, à défaut la hauteur du cadre de la ligne). Les mots peu sûrs
/// sont écartés.
List<LabelLine> parseHocr(String hocr) {
  final lineStart = RegExp(
    r'''<span class=['"](ocr_line|ocr_header|ocr_textfloat|ocr_caption)['"][^>]*title=['"]([^'"]*)['"][^>]*>''',
  );
  final word = RegExp(
    r'''<span class=['"]ocrx_word['"][^>]*title=['"]([^'"]*)['"][^>]*>(.*?)</span>''',
    dotAll: true,
  );
  final starts = lineStart.allMatches(hocr).toList();
  final lines = <LabelLine>[];
  for (final (i, start) in starts.indexed) {
    final end = i + 1 < starts.length ? starts[i + 1].start : hocr.length;
    final segment = hocr.substring(start.end, end);
    final words = <String>[];
    for (final w in word.allMatches(segment)) {
      final confidence = int.tryParse(
        RegExp(r'x_wconf (\d+)').firstMatch(w.group(1)!)?.group(1) ?? '',
      );
      if (confidence != null && confidence < tesseractMinConfidence) continue;
      final text = _unescape(w.group(2)!.replaceAll(RegExp(r'<[^>]+>'), ''));
      if (text.trim().isNotEmpty) words.add(text.trim());
    }
    if (words.isEmpty) continue;
    final title = start.group(2)!;
    final size = double.tryParse(
      RegExp(r'x_size ([\d.]+)').firstMatch(title)?.group(1) ?? '',
    );
    final box = RegExp(r'bbox (\d+) (\d+) (\d+) (\d+)').firstMatch(title);
    final height =
        size ??
        (box == null
            ? 0.0
            : double.parse(box.group(4)!) - double.parse(box.group(2)!));
    lines.add(LabelLine(words.join(' '), height: height));
  }
  return lines;
}

String _unescape(String text) => text
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');
