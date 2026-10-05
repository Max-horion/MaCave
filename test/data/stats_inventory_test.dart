import 'package:cave/data/cave_queries.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late CaveDatabase db;
  late CaveRepository repo;
  late CaveQueries queries;
  late List<DrinkType> types;

  setUp(() async {
    db = memoryDatabase();
    repo = CaveRepository(db, TestContext());
    queries = CaveQueries(db);
    types = await repo.drinkTypes();
  });
  tearDown(() => db.close());

  Future<String> characteristic(String name) async => (await (db.select(
    db.characteristics,
  )..where((c) => c.name.equals(name))).getSingle()).id;

  Future<({String drinkId, String lotId})> add(
    String name,
    FieldProfile profile, {
    String? region,
    String? country,
    int quantity = 1,
    int? vintage,
    Set<String> characteristics = const {},
  }) => repo.addNewDrink(
    drink: DrinkInput(
      name: name,
      typeId: types.firstWhere((t) => t.fieldProfile == profile).id,
      region: region,
      country: country,
    ),
    characteristicIds: characteristics,
    volumeMl: 750,
    vintage: vintage,
    quantity: quantity,
  );

  group('statistiques', () {
    test('totaux et répartitions, lots épuisés exclus', () async {
      await add(
        'Rouge A',
        FieldProfile.wine,
        region: 'Région 1',
        quantity: 6,
        characteristics: {await characteristic('Rouge')},
      );
      await add(
        'Rouge B',
        FieldProfile.wine,
        country: 'Pays 2',
        quantity: 2,
        characteristics: {await characteristic('Rouge')},
      );
      await add('Bière', FieldProfile.beer, quantity: 3);
      final empty = await add('Vide', FieldProfile.wine, quantity: 1);
      await repo.addExit(empty.lotId, 1);

      final s = await queries.watchStats().first;
      expect(s.bottles, 11);
      expect(s.drinks, 3);
      expect(s.byType, [
        (label: 'Vin', bottles: 8),
        (label: 'Bière', bottles: 3),
      ]);
      expect(s.byFamily.single.typeName, 'Vin');
      expect(s.byFamily.single.familyName, 'Robe');
      expect(s.byFamily.single.values, [(label: 'Rouge', bottles: 8)]);
      // Région, sinon pays, sinon non renseignée.
      expect(s.byRegion, [
        (label: 'Région 1', bottles: 6),
        (label: null, bottles: 3),
        (label: 'Pays 2', bottles: 2),
      ]);
    });

    test('se mettent à jour après une sortie', () async {
      final a = await add('A', FieldProfile.wine, quantity: 2);
      final stream = queries.watchStats();
      expect((await stream.first).bottles, 2);
      await repo.addExit(a.lotId, 1);
      expect((await stream.first).bottles, 1);
    });
  });

  group('inventaire', () {
    test('lots en stock triés par nom puis millésime', () async {
      final b = await add('Bêta', FieldProfile.wine, vintage: 2018);
      await repo
          .findOrCreateLot(drinkId: b.drinkId, volumeMl: 750, vintage: 2012)
          .then((lot) => repo.addEntry(lot, 1));
      await add('Alpha', FieldProfile.wine);
      final empty = await add('Gamma', FieldProfile.wine);
      await repo.addExit(empty.lotId, 1);

      final items = await queries.inventoryLots();
      expect(items.map((i) => (i.drinkName, i.lot.vintage)), [
        ('Alpha', null),
        ('Bêta', 2012),
        ('Bêta', 2018),
      ]);
      expect(await queries.inventoryLots(includeExhausted: true), hasLength(4));
    });
  });

  test('historique d\'une référence, du plus récent au plus ancien', () async {
    final a = await add('A', FieldProfile.wine, quantity: 3);
    await repo.addExit(a.lotId, 1, reason: ExitReason.broken);
    await repo.recordInventory(a.lotId, 1);
    final history = await queries.watchMovementsOfDrink(a.drinkId).first;
    expect(history.map((h) => h.movement.kind), [
      MovementKind.inventory,
      MovementKind.exit,
      MovementKind.entry,
    ]);
    expect(history.first.lot.id, a.lotId);
  });
}
