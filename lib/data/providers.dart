import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cave_repository.dart';
import 'database.dart';
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

/// Totaux de la cave, recalculés automatiquement à chaque modification.
final caveTotalsProvider = StreamProvider<CaveTotals>(
  (ref) => ref.watch(caveRepositoryProvider).watchTotals(),
);
