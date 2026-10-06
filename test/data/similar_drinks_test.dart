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

  /// types[0] = Vin, types[1] = Bière (classification initiale).
  Future<String> drink(String name, {int type = 0, int bottles = 0}) async {
    final ids = await repo.addNewDrink(
      drink: DrinkInput(name: name, typeId: types[type].id),
      volumeMl: 750,
      quantity: bottles > 0 ? bottles : 1,
    );
    if (bottles == 0) await repo.addExit(ids.lotId, 1);
    return ids.drinkId;
  }

  test('la plus proche d\'abord, avec son stock', () async {
    await drink('Château Figeac', bottles: 3);
    await drink('Château Pavie');
    await drink('Figeac');
    final found = await queries.similarDrinks(name: 'Ch. Figeac');
    expect(found.map((s) => s.drink.name), ['Château Figeac', 'Figeac']);
    expect(found.first.bottles, 3);
    expect(found.first.score, 1);
  });

  test('autre profil (bière pour un vin) : écartée', () async {
    await drink('Leffe Blonde', type: 1);
    expect(
      await queries.similarDrinks(
        name: 'Leffe Blonde',
        profile: FieldProfile.wine,
      ),
      isEmpty,
    );
    expect(
      await queries.similarDrinks(
        name: 'Leffe Blonde',
        profile: FieldProfile.beer,
      ),
      hasLength(1),
    );
  });

  test('référence supprimée ou elle-même : écartée', () async {
    final kept = await drink('Château Figeac');
    final gone = await drink('Chateau Figeac');
    await repo.deleteDrink(gone);
    expect(await queries.similarDrinks(name: 'Château Figeac'), hasLength(1));
    expect(
      await queries.similarDrinks(name: 'Château Figeac', excludeId: kept),
      isEmpty,
    );
  });

  test('ajouter à la référence existante : lot trouvé ou créé', () async {
    final id = await drink('Château Figeac', bottles: 2);
    await repo.addToExistingDrink(
      drinkId: id,
      volumeMl: 750,
      quantity: 3,
      barcode: '3760000000017',
    );
    await repo.addToExistingDrink(
      drinkId: id,
      volumeMl: 750,
      vintage: 2018,
      quantity: 1,
    );
    final lots = await repo.lotsOf(id);
    expect(lots.map((l) => (l.vintage, l.stock, l.barcode)), [
      (2018, 1, null),
      (null, 5, '3760000000017'),
    ]);
  });
}
