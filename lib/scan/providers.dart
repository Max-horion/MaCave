import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_preferences.dart';
import '../domain/label_reading.dart';
import '../sync/providers.dart';
import 'label_recognizer.dart';
import 'open_food_facts.dart';

/// Recherche Open Food Facts ; remplacée dans les tests.
final openFoodFactsProvider = Provider<OpenFoodFacts>((ref) {
  final off = OpenFoodFacts(
    // Même détection du réseau que la synchronisation (connectivity_plus).
    isOnline: ref.watch(syncEnvironmentProvider).isOnline,
    isEnabled: () => ref.read(appPreferencesProvider).openFoodFacts,
  );
  ref.onDispose(off.close);
  return off;
});

/// Reconnaissance du texte des étiquettes : Tesseract (libre, CDC §10 ;
/// ML Kit retiré le 2026-10-10) ; remplacée dans les tests.
final labelRecognizerProvider = Provider<LabelRecognizer>((ref) {
  final recognizer = TesseractLabelRecognizer();
  ref.onDispose(recognizer.close);
  return recognizer;
});

/// Appellations officielles (INAO), embarquées dans l'appli
/// (assets/appellations.txt, construit par tool/build_appellations.py).
final appellationIndexProvider = FutureProvider<AppellationIndex>((ref) async {
  return AppellationIndex.parse(
    await rootBundle.loadString('assets/appellations.txt'),
  );
});
