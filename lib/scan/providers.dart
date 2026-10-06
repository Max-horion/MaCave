import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/providers.dart';
import 'open_food_facts.dart';

/// Recherche Open Food Facts ; remplacée dans les tests.
final openFoodFactsProvider = Provider<OpenFoodFacts>((ref) {
  final off = OpenFoodFacts(
    // Même détection du réseau que la synchronisation (connectivity_plus).
    isOnline: ref.watch(syncEnvironmentProvider).isOnline,
  );
  ref.onDispose(off.close);
  return off;
});
