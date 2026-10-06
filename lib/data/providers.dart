import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/drink_filter.dart';
import 'cave_queries.dart';
import 'cave_repository.dart';
import 'database.dart';
import 'history_purge.dart';
import 'write_context.dart';

// Providers Riverpod : ils fournissent la base et le dépôt aux écrans.
// Dans les tests, on les remplace (`overrides`) par une base en mémoire.

/// La base SQLite du téléphone, fermée proprement à l'arrêt de l'appli.
final databaseProvider = Provider<CaveDatabase>((ref) {
  final db = CaveDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Identité de l'appareil et horloge ; fourni par `main()` au démarrage.
final writeContextProvider = Provider<WriteContext>(
  (ref) => throw UnimplementedError('writeContextProvider non initialisé'),
);

final caveRepositoryProvider = Provider<CaveRepository>(
  (ref) => CaveRepository(
    ref.watch(databaseProvider),
    ref.watch(writeContextProvider),
  ),
);

/// Purges de l'historique (manuelle et automatique).
final historyPurgeProvider = Provider<HistoryPurge>(
  (ref) => HistoryPurge(
    ref.watch(databaseProvider),
    ref.watch(writeContextProvider),
  ),
);

/// Totaux de la cave, recalculés automatiquement à chaque modification.
final caveTotalsProvider = StreamProvider<CaveTotals>(
  (ref) => ref.watch(caveRepositoryProvider).watchTotals(),
);

/// Lectures « en direct » pour les écrans.
final caveQueriesProvider = Provider<CaveQueries>(
  (ref) => CaveQueries(ref.watch(databaseProvider)),
);

/// Types, familles et caractéristiques.
final classificationProvider = StreamProvider<Classification>(
  (ref) => ref.watch(caveQueriesProvider).watchClassification(),
);

/// Régions et pays présents dans la cave.
final regionsProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(caveQueriesProvider).watchRegions(),
);

/// Recherche, filtres et tri de la liste (conservés tant que l'appli est ouverte).
class DrinkFilterNotifier extends Notifier<DrinkFilter> {
  @override
  DrinkFilter build() => const DrinkFilter();

  void change(DrinkFilter Function(DrinkFilter current) edit) {
    state = edit(state);
  }
}

final drinkFilterProvider = NotifierProvider<DrinkFilterNotifier, DrinkFilter>(
  DrinkFilterNotifier.new,
);

/// Liste de la cave selon les filtres en cours.
final drinkListProvider = StreamProvider<List<DrinkListItem>>(
  (ref) => ref
      .watch(caveQueriesProvider)
      .watchDrinkList(ref.watch(drinkFilterProvider)),
);

/// Une référence, ses lots et ses caractéristiques (écran de la fiche).
final drinkProvider = StreamProvider.autoDispose.family<Drink?, String>(
  (ref, id) => ref.watch(caveQueriesProvider).watchDrink(id),
);

final lotsProvider = StreamProvider.autoDispose.family<List<Lot>, String>(
  (ref, drinkId) => ref.watch(caveQueriesProvider).watchLotsOf(drinkId),
);

final drinkCharacteristicsProvider = StreamProvider.autoDispose
    .family<Set<String>, String>(
      (ref, drinkId) =>
          ref.watch(caveQueriesProvider).watchDrinkCharacteristicIds(drinkId),
    );

/// Historique des mouvements d'une référence (fiche).
final drinkMovementsProvider = StreamProvider.autoDispose
    .family<List<MovementWithLot>, String>(
      (ref, drinkId) =>
          ref.watch(caveQueriesProvider).watchMovementsOfDrink(drinkId),
    );

/// Statistiques de la cave.
final statsProvider = StreamProvider.autoDispose<CaveStats>(
  (ref) => ref.watch(caveQueriesProvider).watchStats(),
);
