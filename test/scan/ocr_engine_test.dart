import 'package:cave/data/local_store.dart';
import 'package:cave/scan/ocr_engine.dart';
import 'package:cave/sync/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MemoryLocalStore store;
  late ProviderContainer container;

  setUp(() {
    store = MemoryLocalStore();
    container = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
  });
  tearDown(() => container.dispose());

  Future<OcrPreferences> prefs() =>
      container.read(ocrPreferencesProvider.future);
  OcrPreferencesNotifier notifier() =>
      container.read(ocrPreferencesProvider.notifier);

  test('ML Kit par défaut', () async {
    expect((await prefs()).engine, OcrEngine.mlKit);
  });

  test('le moteur choisi est retenu sur l\'appareil', () async {
    await notifier().setEngine(OcrEngine.compare);
    expect((await prefs()).engine, OcrEngine.compare);
    expect(store.values['ocr_engine'], 'compare');
  });

  test('les choix du mode comparaison sont comptés', () async {
    await notifier().recordChoice(OcrEngine.tesseract);
    await notifier().recordChoice(OcrEngine.tesseract);
    await notifier().recordChoice(OcrEngine.mlKit);
    final p = await prefs();
    expect((p.chosenMlKit, p.chosenTesseract), (1, 2));
  });
}
