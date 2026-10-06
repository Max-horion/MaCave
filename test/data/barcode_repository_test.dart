import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late CaveDatabase db;
  late CaveRepository repo;

  setUp(() {
    db = memoryDatabase();
    repo = CaveRepository(db, TestContext());
  });
  tearDown(() => db.close());

  Future<String> newDrink(String name) async {
    final types = await repo.drinkTypes();
    return repo.createDrink(DrinkInput(name: name, typeId: types.first.id));
  }

  test('un code, plusieurs lots : ancien millésime d\'abord, sans millésime '
      'en dernier', () async {
    final drink = await newDrink('Vin');
    for (final vintage in [2021, null, 2019]) {
      await repo.findOrCreateLot(
        drinkId: drink,
        volumeMl: 750,
        vintage: vintage,
        barcode: '3760001234567',
      );
    }
    final found = await repo.lotsByBarcode('3760001234567');
    expect(found.map((m) => m.lot.vintage), [2019, 2021, null]);
    expect(found.first.drink.name, 'Vin');
  });

  test(
    'le code est retrouvé quelle que soit sa forme (UPC-A, espaces)',
    () async {
      final drink = await newDrink('Bière');
      await repo.findOrCreateLot(
        drinkId: drink,
        volumeMl: 330,
        barcode: '012345678905',
      );
      expect(await repo.lotsByBarcode('0012345678905'), hasLength(1));
      expect(await repo.lotsByBarcode(' 0123 4567 8905 '), hasLength(1));
    },
  );

  test('lots et références supprimés : ignorés', () async {
    final drink = await newDrink('Bière');
    final lot = await repo.findOrCreateLot(
      drinkId: drink,
      volumeMl: 330,
      barcode: '123',
    );
    await repo.deleteLot(lot);
    expect(await repo.lotsByBarcode('123'), isEmpty);
  });

  test('associer un code à un lot existant', () async {
    final drink = await newDrink('Bière');
    final lot = await repo.findOrCreateLot(drinkId: drink, volumeMl: 330);
    await repo.setLotBarcode(lot, ' 3760001234567 ');
    expect((await repo.lot(lot))!.barcode, '3760001234567');
    expect(await repo.lotsByBarcode('3760001234567'), hasLength(1));
  });

  test('nouvelle référence : le code scanné est mémorisé sur le lot', () async {
    final types = await repo.drinkTypes();
    final ids = await repo.addNewDrink(
      drink: DrinkInput(name: 'Bière', typeId: types[1].id),
      volumeMl: 330,
      quantity: 6,
      barcode: '3760001234567',
    );
    final found = await repo.lotsByBarcode('3760001234567');
    expect(found.single.lot.id, ids.lotId);
    expect(found.single.lot.stock, 6);
  });
}
