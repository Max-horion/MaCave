import 'dart:io';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/sync/cave_file.dart';
import 'package:cave/sync/merge.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

// Deux appareils, « téléphone » et « PC », partent de la même cave puis la
// modifient chacun de leur côté. Chacun a sa base sur disque, pour pouvoir
// fusionner le fichier de l'autre (comme celui du serveur).
void main() {
  late Directory root;
  late Device phone;
  late Device pc;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cave_merge_test');
    phone = Device(
      'telephone',
      CaveDatabase(NativeDatabase(File('${root.path}/telephone.sqlite'))),
    );
    // Le PC part d'une copie du téléphone : même cave, même classification.
    await phone.db.customSelect('SELECT 1').get();
    await snapshotDatabase(phone.db, '${root.path}/pc.sqlite');
    pc = Device(
      'pc',
      CaveDatabase(NativeDatabase(File('${root.path}/pc.sqlite'))),
    );
  });
  tearDown(() async {
    await phone.db.close();
    await pc.db.close();
    await root.delete(recursive: true);
  });

  /// [to] fusionne une copie de la base de [from] (comme reçue du serveur).
  Future<MergeResult> sync(Device from, Device to) async {
    final path = '${root.path}/recu-${from.ctx.deviceId}.sqlite';
    await snapshotDatabase(from.db, path);
    return mergeCaveFile(to.db, to.ctx, path);
  }

  test('fichier identique : rien à fusionner ni à envoyer', () async {
    final r = await sync(pc, phone);
    expect(r.changedLocal, isFalse);
    expect(r.localAhead, isFalse);
  });

  test('une référence créée ailleurs arrive, avec son stock', () async {
    await pc.addBeer('Bière du PC', 6);
    final r = await sync(pc, phone);

    expect(r.applied['drinks'], 1);
    expect(r.applied['lots'], 1);
    expect(r.applied['movements'], 1);
    expect(r.localAhead, isFalse);
    expect(await phone.drinkNames(), ['Bière du PC']);
    expect(await phone.bottles(), 6);
  });

  test(
    'une modification locale non envoyée est conservée et signalée',
    () async {
      await phone.addBeer('Bière du téléphone', 2);
      final r = await sync(pc, phone);

      expect(r.changedLocal, isFalse);
      expect(r.localAhead, isTrue);
      expect(await phone.drinkNames(), ['Bière du téléphone']);
    },
  );

  group('fiches : la plus récente l\'emporte', () {
    late String drinkId;

    setUp(() async {
      await phone.addBeer('Bière', 1);
      await sync(phone, pc);
      drinkId = (await phone.db.select(phone.db.drinks).getSingle()).id;
    });

    Future<void> rename(Device d, String name, int time) async {
      d.ctx.time = time;
      final type = (await d.db.select(d.db.drinks).getSingle()).typeId;
      await d.repo.updateDrink(drinkId, DrinkInput(name: name, typeId: type));
    }

    test('la modification du PC, plus récente, gagne des deux côtés', () async {
      await rename(phone, 'Nom du téléphone', 5000000);
      await rename(pc, 'Nom du PC', 6000000);

      await sync(pc, phone);
      await sync(phone, pc);
      expect(await phone.drinkNames(), ['Nom du PC']);
      expect(await pc.drinkNames(), ['Nom du PC']);
    });

    test('la modification locale, plus récente, n\'est pas écrasée', () async {
      await rename(pc, 'Nom du PC', 5000000);
      await rename(phone, 'Nom du téléphone', 6000000);

      final r = await sync(pc, phone);
      expect(r.applied['drinks'], 0);
      expect(r.localAhead, isTrue);
      expect(await phone.drinkNames(), ['Nom du téléphone']);
    });

    test('même milliseconde : l\'appareil départage, partout pareil', () async {
      await rename(phone, 'Nom du téléphone', 5000000);
      await rename(pc, 'Nom du PC', 5000000);

      await sync(pc, phone);
      await sync(phone, pc);
      // « telephone » > « pc » dans l'ordre alphabétique.
      expect(await phone.drinkNames(), ['Nom du téléphone']);
      expect(await pc.drinkNames(), ['Nom du téléphone']);
    });

    test('une suppression se propage', () async {
      pc.ctx.time = 5000000;
      await pc.repo.deleteDrink(drinkId);
      await sync(pc, phone);

      expect(await phone.repo.drink(drinkId), isNull);
      expect(await phone.bottles(), 0);
    });
  });

  group('mouvements : ils s\'additionnent', () {
    late String lotId;

    setUp(() async {
      lotId = await phone.addBeer('Bière', 6);
      await sync(phone, pc);
    });

    test('une sortie sur chaque appareil : 2 bouteilles en moins', () async {
      await phone.repo.addExit(lotId, 1);
      await pc.repo.addExit(lotId, 1);

      await sync(pc, phone);
      await sync(phone, pc);
      expect(await phone.stockOf(lotId), 4);
      expect(await pc.stockOf(lotId), 4);
    });

    test('pas de doublon si on fusionne deux fois', () async {
      await pc.repo.addEntry(lotId, 3);
      await sync(pc, phone);
      final r = await sync(pc, phone);

      expect(r.changedLocal, isFalse);
      expect(await phone.stockOf(lotId), 9);
    });

    test(
      'une sortie après l\'inventaire de l\'autre appareil est retirée',
      () async {
        pc.ctx.time = 5000000;
        await pc.repo.recordInventory(lotId, 5);
        phone.ctx.time = 6000000;
        await phone.repo.addExit(lotId, 1);

        await sync(pc, phone);
        await sync(phone, pc);
        expect(await phone.stockOf(lotId), 4);
        expect(await pc.stockOf(lotId), 4);
      },
    );

    test(
      'une annulation se propage, même avec une horloge en retard',
      () async {
        phone.ctx.time = 5000000;
        final exit = await phone.repo.addExit(lotId, 1);
        await sync(phone, pc);
        // Le PC annule avec une horloge très en retard sur le téléphone.
        pc.ctx.time = 2000000;
        await pc.repo.undoMovement(exit);

        await sync(pc, phone);
        expect(await phone.stockOf(lotId), 6);
        // Et le fichier du téléphone ne fait pas revenir la sortie sur le PC.
        await sync(phone, pc);
        expect(await pc.stockOf(lotId), 6);
      },
    );

    test('le stock en cache du fichier n\'est pas repris tel quel', () async {
      await pc.repo.addExit(lotId, 2);
      // Cache faux dans le fichier reçu : il doit être recalculé.
      await pc.db.customStatement('UPDATE lots SET stock = 99');
      await sync(pc, phone);
      expect(await phone.stockOf(lotId), 4);
    });
  });

  group('lots en double', () {
    late String drinkId;

    setUp(() async {
      // Une référence connue des deux appareils, sans lot.
      final types = await phone.repo.drinkTypes();
      drinkId = await phone.repo.createDrink(
        DrinkInput(name: 'Vin', typeId: types.first.id),
      );
      await sync(phone, pc);
    });

    Future<String> addLot(Device d, int bottles, {String? barcode}) async {
      final lot = await d.repo.findOrCreateLot(
        drinkId: drinkId,
        volumeMl: 750,
        vintage: 2020,
        barcode: barcode,
      );
      await d.repo.addEntry(lot, bottles);
      return lot;
    }

    test(
      'le même lot créé hors ligne sur deux appareils est regroupé',
      () async {
        phone.ctx.time = 5000000;
        final phoneLot = await addLot(phone, 2);
        pc.ctx.time = 6000000;
        final pcLot = await addLot(pc, 3, barcode: '3760001');

        final r = await sync(pc, phone);
        expect(r.regroupedLots, 1);
        expect(r.localAhead, isTrue);
        await sync(phone, pc);

        for (final d in [phone, pc]) {
          final lots = await d.repo.lotsOf(drinkId);
          // Le plus ancien est conservé, partout ; il prend le code-barres.
          expect(lots.map((l) => l.id), [phoneLot], reason: d.ctx.deviceId);
          expect(lots.single.stock, 5);
          expect(lots.single.barcode, '3760001');
          expect(await d.repo.lot(pcLot), isNull);
        }
      },
    );

    test('les deux appareils finissent avec le même contenu', () async {
      phone.ctx.time = 5000000;
      final lot = await addLot(phone, 2);
      pc.ctx.time = 6000000;
      await addLot(pc, 3);
      await phone.repo.addExit(lot, 1);

      await sync(pc, phone);
      await sync(phone, pc);
      expect(await pc.dump(), await phone.dump());
    });
  });

  test('l\'index de recherche est à jour', () async {
    await pc.addBeer('Brasserie Introuvable', 1);
    await sync(pc, phone);

    final hits = await phone.db
        .customSelect(
          "SELECT drink_id FROM drinks_fts WHERE drinks_fts MATCH 'introuvable'",
        )
        .get();
    expect(hits, hasLength(1));
  });

  test('les réglages : le plus récent l\'emporte', () async {
    await phone.setSetting('theme', '"clair"', 5000000);
    await pc.setSetting('theme', '"sombre"', 6000000);
    await sync(pc, phone);
    final row = await phone.db.select(phone.db.settings).getSingle();
    expect(row.value, '"sombre"');
  });

  test(
    'une autre cave n\'est jamais fusionnée, la base reste intacte',
    () async {
      await phone.addBeer('Bière', 1);
      await pc.addBeer('Autre', 1);
      await pc.db.customStatement(
        "UPDATE meta SET value = 'autre-cave' WHERE key = 'cave_id'",
      );

      await expectLater(sync(pc, phone), throwsA(isA<OtherCaveException>()));
      expect(await phone.drinkNames(), ['Bière']);
    },
  );
}

/// Un appareil de test : sa base, son horloge, son dépôt.
class Device {
  Device(String deviceId, this.db) : ctx = _DeviceContext(deviceId) {
    repo = CaveRepository(db, ctx);
  }

  final CaveDatabase db;
  final TestContext ctx;
  late final CaveRepository repo;

  /// Une bière avec [bottles] bouteilles ; retourne l'ID du lot. Les ID sont
  /// préfixés par l'appareil pour ne pas se croiser.
  Future<String> addBeer(String name, int bottles) async {
    final types = await repo.drinkTypes();
    final ids = await repo.addNewDrink(
      drink: DrinkInput(name: name, typeId: types[1].id),
      volumeMl: 330,
      quantity: bottles,
    );
    return ids.lotId;
  }

  Future<List<String>> drinkNames() async {
    final drinks = await (db.select(
      db.drinks,
    )..where((t) => t.deletedAt.isNull())).get();
    return drinks.map((d) => d.name).toList()..sort();
  }

  Future<int> stockOf(String lotId) async => (await repo.lot(lotId))!.stock;

  Future<int> bottles() async => (await repo.watchTotals().first).bottles;

  Future<void> setSetting(String key, String value, int time) => db
      .into(db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: key,
          value: value,
          updatedAt: time,
          updatedBy: ctx.deviceId,
        ),
      );

  /// Contenu des tables synchronisées, pour comparer deux appareils. Les
  /// estampilles des lots regroupés diffèrent (chaque appareil a supprimé le
  /// doublon à son heure) : seules les données comptent.
  Future<Map<String, List<String>>> dump() async {
    Future<List<String>> rows(String sql) async =>
        (await db.customSelect(sql).get())
            .map((r) => r.data.values.join('|'))
            .toList();
    return {
      'drinks': await rows(
        'SELECT id, name, updated_at, deleted_at FROM drinks ORDER BY id',
      ),
      'lots': await rows(
        'SELECT id, drink_id, vintage, volume_ml, barcode, stock, '
        'deleted_at IS NOT NULL FROM lots ORDER BY id',
      ),
      'movements': await rows(
        'SELECT id, lot_id, kind, quantity, deleted_at FROM movements '
        'ORDER BY id',
      ),
    };
  }
}

/// Identifiants préfixés par l'appareil (telephone-id-0001…), qui ne se
/// croisent pas d'un appareil à l'autre, comme les vrais UUID.
class _DeviceContext extends TestContext {
  _DeviceContext(String deviceId) : super(deviceId: deviceId);

  @override
  String newId() => '$deviceId-${super.newId()}';
}
