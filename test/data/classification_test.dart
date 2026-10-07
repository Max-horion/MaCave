import 'package:cave/data/cave_queries.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/domain/drink_filter.dart';
import 'package:cave/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Modification de la classification (CDC §6.1, §7).
void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late CaveQueries queries;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
    queries = CaveQueries(db);
  });
  tearDown(() => db.close());

  Future<Classification> classification() =>
      queries.watchClassification().first;

  Future<List<DrinkListItem>> list([String query = '']) => queries
      .watchDrinkList(DrinkFilter(query: query, showExhausted: true))
      .first;

  test('nouveau type, famille et valeur, placés en dernier', () async {
    final before = (await classification()).types.length;
    final cider = await repo.createType(
      name: '  Cidre ',
      profile: FieldProfile.beer,
      defaultVolumeMl: 750,
    );
    final family = await repo.createFamily(cider, 'Style');
    await repo.createCharacteristic(family, 'Brut');
    await repo.createCharacteristic(family, 'Doux');

    final c = await classification();
    expect(c.types.length, before + 1);
    expect(c.types.last.name, 'Cidre', reason: 'espaces retirés, en dernier');
    expect(c.types.last.fieldProfile, FieldProfile.beer);
    expect(c.familiesOf(cider).single.name, 'Style');
    expect(c.valuesOf(family).map((v) => v.name), ['Brut', 'Doux']);
  });

  test('nom vide refusé', () async {
    final type = (await repo.drinkTypes()).first;
    expect(() => repo.createFamily(type.id, '  '), throwsArgumentError);
    expect(() => repo.renameType(type.id, ''), throwsArgumentError);
  });

  test('renommage : la recherche trouve le nouveau nom', () async {
    final c = await classification();
    final beer = c.types.firstWhere((t) => t.fieldProfile == FieldProfile.beer);
    final robe = c.familiesOf(beer.id).first;
    final blonde = c.valuesOf(robe.id).firstWhere((v) => v.name == 'Blonde');
    final id = await repo.createDrink(
      DrinkInput(name: 'Mousse Imaginaire', typeId: beer.id),
    );
    await repo.setDrinkCharacteristics(id, {blonde.id});

    await repo.renameType(beer.id, 'Bière artisanale');
    await repo.renameCharacteristic(blonde.id, 'Dorée');

    expect((await list('artisanale')).map((d) => d.drink.name), [
      'Mousse Imaginaire',
    ]);
    expect((await list('doree')).map((d) => d.drink.name), [
      'Mousse Imaginaire',
    ]);
    expect(await list('blonde'), isEmpty);
    final updated = (await classification()).type(beer.id)!;
    expect(updated.updatedBy, ctx.deviceId);
  });

  test('type supprimé : ses références restent, « sans catégorie »', () async {
    final c = await classification();
    final soft = c.types.firstWhere((t) => t.fieldProfile == FieldProfile.soft);
    final familyIds = c.familiesOf(soft.id).map((f) => f.id).toSet();
    await repo.createDrink(DrinkInput(name: 'Jus Imaginaire', typeId: soft.id));
    expect(await repo.drinkCountOfType(soft.id), 1);

    await repo.deleteType(soft.id);

    final after = await classification();
    expect(after.type(soft.id), isNull);
    expect(
      after.families.where((f) => familyIds.contains(f.id)),
      isEmpty,
      reason: 'ses familles partent avec lui',
    );
    expect(
      after.characteristics.where((v) => familyIds.contains(v.familyId)),
      isEmpty,
    );
    final items = await list();
    expect(items.single.drink.name, 'Jus Imaginaire');
    expect(items.single.typeName, isNull);
    // Suppression logique : la ligne reste pour que la synchro la propage.
    final row = await (db.select(
      db.drinkTypes,
    )..where((t) => t.id.equals(soft.id))).getSingle();
    expect(row.deletedAt, isNotNull);
  });

  test('le dernier type ne peut pas être supprimé', () async {
    final types = await repo.drinkTypes();
    for (final t in types.skip(1)) {
      await repo.deleteType(t.id);
    }
    expect(() => repo.deleteType(types.first.id), throwsStateError);
    expect((await repo.drinkTypes()).single.id, types.first.id);
  });

  test('famille supprimée : ses valeurs aussi, la fiche reste', () async {
    final c = await classification();
    final wine = c.types.firstWhere((t) => t.fieldProfile == FieldProfile.wine);
    final robe = c.familiesOf(wine.id).firstWhere((f) => f.name == 'Robe');
    final red = c.valuesOf(robe.id).firstWhere((v) => v.name == 'Rouge');
    final id = await repo.createDrink(
      DrinkInput(name: 'Château Imaginaire', typeId: wine.id, region: 'Test'),
    );
    await repo.setDrinkCharacteristics(id, {red.id});
    expect(await repo.drinkCountWithCharacteristics([red.id]), 1);

    await repo.deleteFamily(robe.id);

    final after = await classification();
    expect(
      after.familiesOf(wine.id).map((f) => f.name),
      isNot(contains('Robe')),
    );
    expect(after.characteristic(red.id), isNull);
    expect(await list('rouge'), isEmpty, reason: 'index de recherche à jour');
    expect((await list()).single.drink.name, 'Château Imaginaire');
  });

  test('valeur supprimée : retirée des statistiques', () async {
    final c = await classification();
    final beer = c.types.firstWhere((t) => t.fieldProfile == FieldProfile.beer);
    final robe = c.familiesOf(beer.id).first;
    final brune = c.valuesOf(robe.id).firstWhere((v) => v.name == 'Brune');
    await repo.addNewDrink(
      drink: DrinkInput(name: 'Brune Imaginaire', typeId: beer.id),
      volumeMl: 330,
      quantity: 2,
      characteristicIds: {brune.id},
    );
    await repo.deleteCharacteristic(brune.id);

    final stats = await queries.watchStats().first;
    final values = stats.byFamily.expand((f) => f.values);
    expect(values.map((v) => v.label), isNot(contains('Brune')));
    expect(stats.bottles, 2);
  });
}
