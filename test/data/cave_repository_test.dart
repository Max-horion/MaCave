import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late String wineTypeId;
  late String beerTypeId;

  setUp(() async {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
    final types = await repo.drinkTypes();
    wineTypeId = types
        .firstWhere((t) => t.fieldProfile == FieldProfile.wine)
        .id;
    beerTypeId = types
        .firstWhere((t) => t.fieldProfile == FieldProfile.beer)
        .id;
  });
  tearDown(() => db.close());

  /// Une référence de vin fictive avec un lot de 75 cl.
  Future<String> newWineLot({int? vintage = 2018}) async {
    final drinkId = await repo.createDrink(
      DrinkInput(
        name: 'Château Exemple',
        typeId: wineTypeId,
        appellation: 'Appellation Test',
        region: 'Région Test',
      ),
    );
    return repo.findOrCreateLot(
      drinkId: drinkId,
      volumeMl: 750,
      vintage: vintage,
    );
  }

  group('références', () {
    test('création : champs nettoyés et estampillés', () async {
      final id = await repo.createDrink(
        DrinkInput(name: '  Bière Test  ', typeId: beerTypeId, producer: ' '),
      );
      final d = (await repo.drink(id))!;
      expect(d.name, 'Bière Test');
      expect(d.producer, isNull);
      expect(d.updatedBy, 'appareil-test');
      expect(d.createdAt, d.updatedAt);
      expect(d.needsCompletion, isFalse);
    });

    test('un vin sans appellation est marqué « à compléter »', () async {
      final id = await repo.createDrink(
        DrinkInput(name: 'Vin incomplet', typeId: wineTypeId, region: 'X'),
      );
      expect((await repo.drink(id))!.needsCompletion, isTrue);

      await repo.updateDrink(
        id,
        DrinkInput(
          name: 'Vin incomplet',
          typeId: wineTypeId,
          region: 'X',
          appellation: 'Y',
        ),
      );
      expect((await repo.drink(id))!.needsCompletion, isFalse);
    });

    test('nom vide ou note hors limites refusés', () async {
      expect(
        () => repo.createDrink(DrinkInput(name: ' ', typeId: beerTypeId)),
        throwsArgumentError,
      );
      expect(
        () => repo.createDrink(
          DrinkInput(name: 'X', typeId: beerTypeId, rating: 6),
        ),
        throwsArgumentError,
      );
    });

    test('la modification met à jour la date', () async {
      final id = await repo.createDrink(
        DrinkInput(name: 'A', typeId: beerTypeId),
      );
      final before = (await repo.drink(id))!.updatedAt;
      await repo.updateDrink(id, DrinkInput(name: 'B', typeId: beerTypeId));
      final after = (await repo.drink(id))!;
      expect(after.name, 'B');
      expect(after.updatedAt, greaterThan(before));
    });

    test('suppression : logique, et ses lots avec elle', () async {
      final lotId = await newWineLot();
      final drinkId = (await repo.lot(lotId))!.drinkId;
      await repo.deleteDrink(drinkId);

      expect(await repo.drink(drinkId), isNull);
      expect(await repo.lot(lotId), isNull);
      // La ligne existe toujours, marquée supprimée, pour la synchronisation.
      final raw = await db.select(db.drinks).getSingle();
      expect(raw.deletedAt, isNotNull);
    });

    test('caractéristiques : ajout, retrait et réactivation', () async {
      final drinkId = await repo.createDrink(
        DrinkInput(name: 'A', typeId: wineTypeId),
      );
      final values = await db.select(db.characteristics).get();
      final rouge = values.firstWhere((c) => c.name == 'Rouge').id;
      final sec = values.firstWhere((c) => c.name == 'Sec').id;

      await repo.setDrinkCharacteristics(drinkId, {rouge, sec});
      expect(await repo.drinkCharacteristicIds(drinkId), {rouge, sec});

      await repo.setDrinkCharacteristics(drinkId, {rouge});
      expect(await repo.drinkCharacteristicIds(drinkId), {rouge});

      await repo.setDrinkCharacteristics(drinkId, {rouge, sec});
      expect(await repo.drinkCharacteristicIds(drinkId), {rouge, sec});
      // Toujours deux lignes : le lien retiré a été réactivé, pas dupliqué.
      expect(await db.select(db.drinkCharacteristics).get(), hasLength(2));
    });
  });

  group('lots', () {
    test('même référence, millésime et volume : même lot', () async {
      final lotId = await newWineLot();
      final drinkId = (await repo.lot(lotId))!.drinkId;
      expect(
        await repo.findOrCreateLot(
          drinkId: drinkId,
          volumeMl: 750,
          vintage: 2018,
        ),
        lotId,
      );
      expect(
        await repo.findOrCreateLot(
          drinkId: drinkId,
          volumeMl: 1500,
          vintage: 2018,
        ),
        isNot(lotId),
      );
      expect(
        await repo.findOrCreateLot(drinkId: drinkId, volumeMl: 750),
        isNot(lotId),
        reason: 'sans millésime = autre lot',
      );
      expect(await repo.lotsOf(drinkId), hasLength(3));
    });

    test('un code-barres complète un lot qui n\'en a pas', () async {
      final lotId = await newWineLot();
      final drinkId = (await repo.lot(lotId))!.drinkId;
      await repo.findOrCreateLot(
        drinkId: drinkId,
        volumeMl: 750,
        vintage: 2018,
        barcode: '3012345678901',
      );
      expect((await repo.lot(lotId))!.barcode, '3012345678901');
    });

    test(
      'lots triés du millésime le plus ancien, sans millésime en dernier',
      () async {
        final drinkId = await repo.createDrink(
          DrinkInput(name: 'A', typeId: wineTypeId),
        );
        for (final v in [2020, null, 2015]) {
          await repo.findOrCreateLot(
            drinkId: drinkId,
            volumeMl: 750,
            vintage: v,
          );
        }
        expect((await repo.lotsOf(drinkId)).map((l) => l.vintage), [
          2015,
          2020,
          null,
        ]);
      },
    );

    test('volume du type proposé par défaut', () async {
      expect(await repo.defaultVolumeMl(wineTypeId), 750);
    });
  });

  group('mouvements et stock', () {
    test('entrées, sorties et inventaire mettent à jour le stock', () async {
      final lotId = await newWineLot();
      await repo.addEntry(lotId, 6);
      expect((await repo.lot(lotId))!.stock, 6);

      await repo.addExit(lotId, 1);
      expect((await repo.lot(lotId))!.stock, 5);

      await repo.recordInventory(lotId, 3);
      expect((await repo.lot(lotId))!.stock, 3);

      await repo.addEntry(lotId, 2);
      expect((await repo.lot(lotId))!.stock, 5);
    });

    test(
      'une sortie est « consommée » par défaut, motif et commentaire possibles',
      () async {
        final lotId = await newWineLot();
        await repo.addEntry(lotId, 3);
        await repo.addExit(lotId, 1);
        await repo.addExit(
          lotId,
          1,
          reason: ExitReason.gifted,
          comment: ' Anniversaire ',
        );
        final exits = (await repo.movementsOf(lotId))
            .where((m) => m.kind == MovementKind.exit)
            .toList();
        expect(exits.map((m) => m.reason), [
          ExitReason.consumed,
          ExitReason.gifted,
        ]);
        expect(exits.last.comment, 'Anniversaire');
      },
    );

    test('impossible de retirer plus que le stock', () async {
      final lotId = await newWineLot();
      await repo.addEntry(lotId, 1);
      await expectLater(repo.addExit(lotId, 2), throwsStateError);
      expect((await repo.lot(lotId))!.stock, 1);
      expect(
        await repo.movementsOf(lotId),
        hasLength(1),
        reason: 'rien enregistré',
      );
    });

    test('quantités invalides refusées', () async {
      final lotId = await newWineLot();
      expect(() => repo.addEntry(lotId, 0), throwsArgumentError);
      expect(() => repo.addExit(lotId, -1), throwsArgumentError);
      expect(() => repo.recordInventory(lotId, -1), throwsArgumentError);
    });

    test('mouvement sur un lot supprimé refusé', () async {
      final lotId = await newWineLot();
      await repo.deleteLot(lotId);
      await expectLater(repo.addEntry(lotId, 1), throwsStateError);
    });

    test('annuler une sortie rend la bouteille', () async {
      final lotId = await newWineLot();
      await repo.addEntry(lotId, 2);
      final exitId = await repo.addExit(lotId, 1);
      await repo.undoMovement(exitId);
      expect((await repo.lot(lotId))!.stock, 2);
      // Annuler deux fois ne change rien.
      await repo.undoMovement(exitId);
      expect((await repo.lot(lotId))!.stock, 2);
    });

    test(
      'le stock en cache ne change pas la date de modification du lot',
      () async {
        final lotId = await newWineLot();
        final before = (await repo.lot(lotId))!.updatedAt;
        await repo.addEntry(lotId, 3);
        expect((await repo.lot(lotId))!.updatedAt, before);
      },
    );

    test(
      'recalcul complet après une modification directe des mouvements',
      () async {
        final lotId = await newWineLot();
        await repo.addEntry(lotId, 4);
        // Simule l'arrivée d'un mouvement par synchronisation.
        await db
            .into(db.movements)
            .insert(
              MovementsCompanion.insert(
                id: 'id-sync',
                lotId: lotId,
                occurredAt: ctx.now(),
                kind: MovementKind.exit,
                quantity: 1,
                deviceId: 'autre-appareil',
                updatedAt: ctx.now(),
                updatedBy: 'autre-appareil',
              ),
            );
        expect((await repo.lot(lotId))!.stock, 4);
        await repo.recomputeAllStocks();
        expect((await repo.lot(lotId))!.stock, 3);
      },
    );

    test('date de dernière entrée', () async {
      final lotId = await newWineLot();
      expect(await repo.lastEntryAt(lotId), isNull);
      ctx.time = 5000000;
      await repo.addEntry(lotId, 1);
      final first = await repo.lastEntryAt(lotId);
      await repo.addExit(lotId, 1);
      expect(
        await repo.lastEntryAt(lotId),
        first,
        reason: 'une sortie ne compte pas',
      );
      await repo.addEntry(lotId, 1);
      expect(await repo.lastEntryAt(lotId), greaterThan(first!));
    });
  });

  test('totaux de la cave, mis à jour en direct', () async {
    final totals = repo.watchTotals();
    expect((await totals.first).bottles, 0);

    final lotA = await newWineLot(vintage: 2018);
    final drinkId = (await repo.lot(lotA))!.drinkId;
    final lotB = await repo.findOrCreateLot(
      drinkId: drinkId,
      volumeMl: 750,
      vintage: 2019,
    );
    await repo.addEntry(lotA, 6);
    await repo.addEntry(lotB, 2);
    final t = await totals.first;
    expect(t.bottles, 8);
    expect(t.drinksInStock, 1, reason: 'deux lots de la même référence');

    await repo.deleteLot(lotB);
    expect((await totals.first).bottles, 6);
  });
}
