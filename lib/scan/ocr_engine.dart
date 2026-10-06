import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';
import '../sync/providers.dart';

// Choix du moteur de reconnaissance de texte (CDC §7 « Reconnaissance »,
// bêta du CDC §10) : propre à l'appareil (préférences locales).

enum OcrEngine {
  mlKit,
  tesseract,

  /// Les deux moteurs sur la même photo, résultats côte à côte : l'utilisateur
  /// garde le meilleur, et ses choix sont comptés pour décider du moteur
  /// définitif après la bêta (CDC §12).
  compare,
}

/// Moteur choisi, et nombre de fois où chaque moteur a été préféré en mode
/// comparaison.
class OcrPreferences {
  const OcrPreferences({
    this.engine = OcrEngine.mlKit,
    this.chosenMlKit = 0,
    this.chosenTesseract = 0,
  });

  final OcrEngine engine;
  final int chosenMlKit;
  final int chosenTesseract;
}

final ocrPreferencesProvider =
    AsyncNotifierProvider<OcrPreferencesNotifier, OcrPreferences>(
      OcrPreferencesNotifier.new,
    );

class OcrPreferencesNotifier extends AsyncNotifier<OcrPreferences> {
  static const _engineKey = 'ocr_engine';
  static const _mlKitKey = 'ocr_chosen_mlkit';
  static const _tesseractKey = 'ocr_chosen_tesseract';

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  Future<OcrPreferences> build() async {
    final store = ref.watch(localStoreProvider);
    int count(String? v) => int.tryParse(v ?? '') ?? 0;
    return OcrPreferences(
      engine:
          OcrEngine.values.asNameMap()[await store.getString(_engineKey)] ??
          OcrEngine.mlKit,
      chosenMlKit: count(await store.getString(_mlKitKey)),
      chosenTesseract: count(await store.getString(_tesseractKey)),
    );
  }

  Future<void> setEngine(OcrEngine engine) async {
    await _store.setString(_engineKey, engine.name);
    ref.invalidateSelf();
    await future;
  }

  /// En mode comparaison, l'utilisateur a gardé le résultat de [engine].
  Future<void> recordChoice(OcrEngine engine) async {
    final current = await future;
    switch (engine) {
      case OcrEngine.mlKit:
        await _store.setString(_mlKitKey, '${current.chosenMlKit + 1}');
      case OcrEngine.tesseract:
        await _store.setString(_tesseractKey, '${current.chosenTesseract + 1}');
      case OcrEngine.compare:
        return;
    }
    ref.invalidateSelf();
    await future;
  }
}
