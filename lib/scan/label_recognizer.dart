import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/label_reading.dart';

// Reconnaissance du texte d'une photo d'étiquette, sur le téléphone. Le
// moteur est interchangeable (CDC §10) : ML Kit ici, Tesseract au lot 5d, et
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
