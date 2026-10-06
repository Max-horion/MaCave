import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/exchange/cave_import.dart';
import 'package:cave/data/history_purge.dart';
import 'package:cave/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late HistoryPurge purge;

  // Dates : 1er janvier 2024, 2025, 2026 (UTC).
  final y2024 = DateTime.utc(2024).millisecondsSinceEpoch;
  final y2025 = DateTime.utc(2025).millisecondsSinceEpoch;
  final y2026 = DateTime.utc(2026).millisecondsSinceEpoch;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
    purge = HistoryPurge(db, ctx);
  });
  tearDown(() => db.close());

  /// Une bière, sans bouteille ; retourne l'ID de son lot.
  Future<String> newLot(String name, {int? at}) async {
    if (at != null) ctx.time = at;
    final types = await repo.drinkTypes();
    final drinkId = await repo.createDrink(
      DrinkInput(name: name, typeId: types[1].id),
    );
    return repo.findOrCreateLot(drinkId: drinkId, volumeMl: 330);
  }

  Future<int> stockOf(String lotId) async => (await repo.lot(lotId))!.stock;

  Future<List<Movement>> movements(String lotId) =>
      (db.select(db.movements)..where((t) => t.lotId.equals(lotId))).get();

  group('purge manuelle', () {
    late String lot;

    setUp(() async {
      lot = await newLot('Bière', at: y2024);
      await repo.addEntry(lot, 12);
      await repo.addExit(lot, 2);
      ctx.time = y2024 + 1000000;
      await repo.recordInventory(lot, 9);
      await repo.addExit(lot, 1);
      ctx.time = y2026;
      await repo.addExit(lot, 3);
      await repo.addEntry(lot, 6);
    });

    test('le stock ne change pas, l\'historique ancien disparaît', () async {
      expect(await stockOf(lot), 11);
      expect(await purge.countBefore(y2025), 4);

      final removed = await purge.purgeBefore(y2025);

      expect(removed, 4);
      expect(await stockOf(lot), 11);
      final left = await movements(lot);
      // Le report de stock (8 bouteilles au 1er janvier 2025), puis 2026.
      expect(left.map((m) => (m.kind, m.quantity, m.occurredAt >= y2025)), [
        (MovementKind.inventory, 8, true),
        (MovementKind.exit, 3, true),
        (MovementKind.entry, 6, true),
      ]);
      expect(left.first.occurredAt, y2025);
      expect(left.first.id, HistoryPurge.carryOverId(lot, y2025));
      expect(await purge.purgedBefore(), y2025);
    });

    test('un lot vide à la date de purge n\'a pas de report', () async {
      final empty = await newLot('Vide', at: y2024);
      await repo.addEntry(empty, 1);
      await repo.addExit(empty, 1);
      await purge.purgeBefore(y2025);
      expect(await movements(empty), isEmpty);
      expect(await stockOf(empty), 0);
    });

    test('purger deux fois, ou plus tôt ensuite : sans effet', () async {
      await purge.purgeBefore(y2025);
      expect(await purge.purgeBefore(y2025), 0);
      expect(await purge.purgeBefore(y2024), 0);
      // La date ne recule jamais.
      expect(await purge.purgedBefore(), y2025);
      expect(await stockOf(lot), 11);
    });

    test('un mouvement annulé ancien est supprimé aussi', () async {
      ctx.time = y2024 + 2000000;
      final undone = await repo.addExit(lot, 1);
      await repo.undoMovement(undone);
      await purge.purgeBefore(y2025);
      expect((await movements(lot)).map((m) => m.id), isNot(contains(undone)));
      expect(await stockOf(lot), 11);
    });

    test('l\'import d\'historique ne fait pas revenir l\'ancien', () async {
      await purge.purgeBefore(y2025);
      final report = await CaveImporter(db, ctx).apply(
        'ID mouvement;ID lot;Date;Nature;Quantité\n'
        'ancien;$lot;2024-06-01 10:00;sortie;1\n'
        'recent;$lot;2026-06-01 10:00;sortie;1\n',
      );
      expect(report.movementsAdded, 1);
      expect(report.movementsSkipped, 1);
      expect(await stockOf(lot), 10);
    });
  });

  group('purge automatique', () {
    final now = DateTime.utc(2026, 10, 6);

    test('désactivée par défaut', () async {
      final lot = await newLot('Ancienne', at: y2024);
      await repo.addEntry(lot, 1);
      await repo.addExit(lot, 1);
      expect((await purge.autoSettings()).enabled, isFalse);
      expect(await purge.autoPurge(now), 0);
      expect(await repo.lot(lot), isNotNull);
    });

    test(
      'lots épuisés depuis le délai : supprimés, avec la référence',
      () async {
        // Épuisé depuis 2024 : purgé, et sa référence n'a plus de lot.
        final old = await newLot('Ancienne', at: y2024);
        await repo.addEntry(old, 1);
        await repo.addExit(old, 1);
        // Épuisé récemment : gardé.
        final recent = await newLot('Récente', at: y2024);
        await repo.addEntry(recent, 1);
        ctx.time = DateTime.utc(2026, 6).millisecondsSinceEpoch;
        await repo.addExit(recent, 1);
        // Ancien, mais encore en stock : jamais purgé.
        final stocked = await newLot('En stock', at: y2024);
        await repo.addEntry(stocked, 2);

        await purge.setAutoSettings(
          const AutoPurgeSettings(enabled: true, months: 12),
        );
        expect(await purge.autoPurge(now), 1);

        final oldLot = await (db.select(
          db.lots,
        )..where((t) => t.id.equals(old))).getSingle();
        expect(oldLot.deletedAt, isNotNull);
        expect(await repo.drink(oldLot.drinkId), isNull);
        expect(
          (await movements(old)).every((m) => m.deletedAt != null),
          isTrue,
        );
        expect(await repo.lot(recent), isNotNull);
        expect(await repo.lot(stocked), isNotNull);
      },
    );

    test('la référence est gardée si elle a encore un lot', () async {
      final old = await newLot('Vin', at: y2024);
      await repo.addEntry(old, 1);
      await repo.addExit(old, 1);
      final drinkId = (await repo.lot(old))!.drinkId;
      final other = await repo.findOrCreateLot(drinkId: drinkId, volumeMl: 750);
      await repo.addEntry(other, 1);

      await purge.setAutoSettings(
        const AutoPurgeSettings(enabled: true, months: 12),
      );
      expect(await purge.autoPurge(now), 1);
      expect(await repo.drink(drinkId), isNotNull);
    });

    test('lot jamais utilisé : compté depuis sa création', () async {
      await newLot('Jamais', at: y2024);
      await newLot('Neuf', at: DateTime.utc(2026, 9).millisecondsSinceEpoch);
      final candidates = await purge.autoPurgeCandidates(now, 12);
      expect(candidates, hasLength(1));
    });
  });
}
