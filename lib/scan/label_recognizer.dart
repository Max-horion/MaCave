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

  /// Diagnostic de la dernière lecture, affiché en mode comparaison (bêta),
  /// ou null.
  String? get lastNote;

  Future<void> close();
}

/// ML Kit de Google (modèle des lettres latines embarqué : hors ligne).
class MlKitLabelRecognizer implements LabelRecognizer {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  String get name => 'ML Kit';

  @override
  String? get lastNote => null;

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
  String? lastNote;

  @override
  Future<List<LabelLine>> recognize(String imagePath) async {
    final hocr = await _channel.invokeMethod<String>('hocr', {
      'dataPath': await _dataPath(),
      'language': language,
      'imagePath': imagePath,
      'psm': pageSegmentation,
    });
    final result = readHocr(hocr ?? '');
    lastNote = result.note;
    return result.lines;
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

/// Lecture d'un résultat hOCR : les lignes, et combien de mots ont été
/// gardés ou écartés (diagnostic de la bêta).
class HocrResult {
  const HocrResult(this.lines, {required this.kept, required this.dropped});

  final List<LabelLine> lines;
  final int kept;
  final int dropped;

  /// « 42 mots lus, 7 écartés (confiance < 40) » : ce n'est pas un texte de
  /// l'interface, mais une information technique pour la bêta.
  String get note =>
      'hOCR : $kept mots gardés, $dropped écartés '
      '(confiance < $tesseractMinConfidence)';
}

/// Lignes d'un résultat hOCR de Tesseract (voir [readHocr]).
List<LabelLine> parseHocr(String hocr) => readHocr(hocr).lines;

/// Lignes d'un résultat hOCR de Tesseract, avec leur hauteur de lettres
/// (`x_size`, à défaut la hauteur du cadre de la ligne). Les mots peu sûrs
/// sont écartés ; si **tous** le sont (photo difficile), ils sont gardés
/// quand même : mieux vaut un texte approximatif que rien.
HocrResult readHocr(String hocr) {
  final strict = _readHocr(hocr, tesseractMinConfidence);
  if (strict.kept > 0 || strict.dropped == 0) return strict;
  final all = _readHocr(hocr, 0);
  return HocrResult(all.lines, kept: all.kept, dropped: 0);
}

HocrResult _readHocr(String hocr, int minConfidence) {
  final lineStart = RegExp(
    r'''<span class=['"](ocr_line|ocr_header|ocr_textfloat|ocr_caption)['"][^>]*title=['"]([^'"]*)['"][^>]*>''',
  );
  final word = RegExp(
    r'''<span class=['"]ocrx_word['"][^>]*title=['"]([^'"]*)['"][^>]*>(.*?)</span>''',
    dotAll: true,
  );
  final starts = lineStart.allMatches(hocr).toList();
  final lines = <_HocrLine>[];
  var kept = 0, dropped = 0;
  for (final (i, start) in starts.indexed) {
    final end = i + 1 < starts.length ? starts[i + 1].start : hocr.length;
    final segment = hocr.substring(start.end, end);
    final words = <String>[];
    for (final w in word.allMatches(segment)) {
      final text = _unescape(w.group(2)!.replaceAll(RegExp(r'<[^>]+>'), ''));
      if (text.trim().isEmpty) continue;
      final confidence = int.tryParse(
        RegExp(r'x_wconf (\d+)').firstMatch(w.group(1)!)?.group(1) ?? '',
      );
      if (confidence != null && confidence < minConfidence) {
        dropped++;
        continue;
      }
      kept++;
      words.add(text.trim());
    }
    if (words.isEmpty) continue;
    final title = start.group(2)!;
    final size = double.tryParse(
      RegExp(r'x_size ([\d.]+)').firstMatch(title)?.group(1) ?? '',
    );
    final box = RegExp(r'bbox (\d+) (\d+) (\d+) (\d+)').firstMatch(title);
    final edges = box == null
        ? null
        : [for (var g = 1; g <= 4; g++) double.parse(box.group(g)!)];
    final height = size ?? (edges == null ? 0.0 : edges[3] - edges[1]);
    lines.add(_HocrLine(words, height, edges));
  }
  return HocrResult(
    [
      for (final group in _sideBySide(lines))
        LabelLine(
          group.expand((l) => l.words).join(' '),
          height: group.map((l) => l.height).reduce((a, b) => a > b ? a : b),
        ),
    ],
    kept: kept,
    dropped: dropped,
  );
}

/// Ligne rendue par Tesseract, avec son cadre (gauche, haut, droite, bas)
/// s'il est connu.
class _HocrLine {
  _HocrLine(this.words, this.height, this.box);

  final List<String> words;
  final double height;
  final List<double>? box;
}

/// Regroupe les lignes de Tesseract qui sont côte à côte sur l'étiquette :
/// sur une bouteille, le texte est courbe ou vu en biais, chaque mot un peu
/// plus haut ou plus bas que son voisin, et Tesseract en fait des lignes
/// séparées (« CHÂTEAU » / « LES » / « TROIS CHÊNES »). Deux lignes vont
/// ensemble si elles sont à peu près à la même hauteur, ont des lettres de taille
/// voisine et sont proches sans se chevaucher en largeur ; de proche en
/// proche, un arc entier est regroupé. Chaque groupe est lu de gauche à
/// droite, et les groupes restent dans l'ordre de lecture.
List<List<_HocrLine>> _sideBySide(List<_HocrLine> lines) {
  final groups = <List<_HocrLine>>[];
  for (final line in lines) {
    final group = line.box == null
        ? null
        : groups.where((g) => g.any((m) => _neighbours(m, line))).firstOrNull;
    if (group == null) {
      groups.add([line]);
    } else {
      group
        ..add(line)
        ..sort((a, b) => a.box![0].compareTo(b.box![0]));
    }
  }
  return groups;
}

bool _neighbours(_HocrLine a, _HocrLine b) {
  final x = a.box, y = b.box;
  if (x == null || y == null) return false;
  final heightA = x[3] - x[1], heightB = y[3] - y[1];
  final minHeight = heightA < heightB ? heightA : heightB;
  final maxHeight = heightA > heightB ? heightA : heightB;
  if (minHeight <= 0) return false;
  // À peu près à la même hauteur : centres écartés de moins de 0,9 fois la
  // plus grande hauteur (un texte en pente descend de presque une demi-ligne
  // d'un mot à l'autre ; mesuré sur un vrai résultat de Tesseract).
  final centres = (x[1] + x[3]) / 2 - (y[1] + y[3]) / 2;
  if (centres.abs() > 0.9 * maxHeight) return false;
  // Lettres de taille voisine.
  final small = a.height < b.height ? a.height : b.height;
  final large = a.height > b.height ? a.height : b.height;
  if (large > 0 && small / large < 0.6) return false;
  // Côte à côte : ni l'un sur l'autre, ni trop loin (2,5 hauteurs).
  final left = x[0] > y[0] ? x[0] : y[0];
  final right = x[2] < y[2] ? x[2] : y[2];
  final gap = left - right; // négatif : chevauchement en largeur
  return gap > -0.3 * minHeight && gap <= 2.5 * maxHeight;
}

String _unescape(String text) => text
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');
