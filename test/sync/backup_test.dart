import 'dart:io';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/sync/backup.dart';
import 'package:cave/sync/cave_file.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../drift/cave/generated/schema.dart';
import '../helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late Directory root;
  late Directory backups;
  late MemoryLocalStore store;
  late DateTime now;

  BackupService service({int keep = 3}) => BackupService(
    db: db,
    store: store,
    folder: () async => backups,
    tempFolder: () async => Directory('${root.path}/tmp')..createSync(),
    defaultKeep: keep,
    clock: () => now,
  );

  setUp(() async {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
    root = await Directory.systemTemp.createTemp('cave_backup_test');
    backups = Directory('${root.path}/Sauvegardes');
    store = MemoryLocalStore();
    now = DateTime(2026, 10, 5, 14, 30);
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  /// Une bière avec [bottles] bouteilles ; retourne l'ID du lot.
  Future<String> addBeer(String name, int bottles) async {
    final types = await repo.drinkTypes();
    final ids = await repo.addNewDrink(
      drink: DrinkInput(name: name, typeId: types[1].id),
      volumeMl: 330,
      quantity: bottles,
    );
    return ids.lotId;
  }

  Future<List<String>> drinkNames() async =>
      (await db.select(db.drinks).get()).map((d) => d.name).toList()..sort();

  test('une sauvegarde = base + stock CSV + historique CSV', () async {
    await addBeer('Bière A', 6);
    final set = await service().backupNow();

    expect(set.database.path, endsWith('cave_2026-10-05_14-30-00.sqlite'));
    expect(set.files.map((f) => f.uri.pathSegments.last), [
      'cave_2026-10-05_14-30-00.sqlite',
      'cave_2026-10-05_14-30-00_stock.csv',
      'cave_2026-10-05_14-30-00_historique.csv',
    ]);
    expect(await set.stockCsv.readAsString(), contains('Bière A'));

    final info = service().inspect(set.database.path);
    expect(info.caveId, await db.caveId());
    expect(info.schemaVersion, db.schemaVersion);
    expect(info.drinks, 1);
    expect(info.bottles, 6);
  });

  test('seules les N dernières sont conservées', () async {
    await addBeer('Bière A', 1);
    final s = service(keep: 3);
    for (var i = 0; i < 5; i++) {
      now = now.add(const Duration(hours: 1));
      await s.backupNow();
    }
    // Un fichier qui n'est pas une sauvegarde n'est jamais touché.
    File('${backups.path}/notes.txt').writeAsStringSync('à moi');

    final sets = await s.list();
    expect(sets.map((b) => b.date.hour), [19, 18, 17]);
    expect(backups.listSync().length, 3 * 3 + 1);
  });

  test(
    '3 sauvegardes par défaut ; le nombre se règle et s\'applique aussitôt',
    () async {
      await addBeer('Bière A', 1);
      final s = BackupService(
        db: db,
        store: store,
        folder: () async => backups,
        tempFolder: () async => Directory('${root.path}/tmp')..createSync(),
        clock: () => now,
      );
      expect(await s.keepCount(), 3);
      for (var i = 0; i < 4; i++) {
        now = now.add(const Duration(hours: 1));
        await s.backupNow();
      }
      expect((await s.list()).length, 3);

      // Plus de sauvegardes : rien n'est supprimé, les suivantes s'ajoutent.
      await s.setKeepCount(5);
      expect(await s.keepCount(), 5);
      for (var i = 0; i < 3; i++) {
        now = now.add(const Duration(hours: 1));
        await s.backupNow();
      }
      expect((await s.list()).length, 5);

      // Moins : les plus anciennes sont supprimées tout de suite.
      expect(await s.excessWith(2), 3);
      await s.setKeepCount(2);
      final sets = await s.list();
      expect(sets.map((b) => b.date.hour), [21, 20]);
      expect(backups.listSync().length, 2 * 3);
    },
  );

  test('deux sauvegardes dans la même seconde ne s\'écrasent pas', () async {
    await addBeer('Bière A', 1);
    final a = await service().backupNow();
    final b = await service().backupNow();
    expect(a.database.path, isNot(b.database.path));
    expect((await service().list()).length, 2);
  });

  group('sauvegarde automatique', () {
    test('rien pour une cave neuve', () async {
      expect(await service().backupIfDue(), isNull);
      expect(backups.existsSync() ? backups.listSync() : [], isEmpty);
    });

    test(
      'au plus une par intervalle, et seulement si la cave a changé',
      () async {
        final lot = await addBeer('Bière A', 6);
        final s = service(keep: 10);
        expect(await s.backupIfDue(), isNotNull);

        // Changement, mais moins d'un jour après : pas de sauvegarde.
        await repo.addExit(lot, 1);
        now = now.add(const Duration(hours: 2));
        expect(await s.backupIfDue(), isNull);

        // Un jour plus tard : la sortie est sauvegardée.
        now = now.add(const Duration(days: 1));
        expect(await s.backupIfDue(), isNotNull);

        // Encore un jour, sans changement : rien.
        now = now.add(const Duration(days: 1));
        expect(await s.backupIfDue(), isNull);

        // L'annulation d'une sortie est un changement.
        final exit = await repo.addExit(lot, 1);
        now = now.add(const Duration(days: 1));
        expect(await s.backupIfDue(), isNotNull);
        await repo.undoMovement(exit);
        now = now.add(const Duration(days: 1));
        expect(await s.backupIfDue(), isNotNull);

        expect((await s.list()).length, 4);
      },
    );

    test('fréquence réglable : chaque semaine', () async {
      final lot = await addBeer('Bière A', 6);
      final s = service(keep: 10);
      expect(await s.everyDays(), 1, reason: 'chaque jour par défaut');
      await s.setEveryDays(7);
      expect(await service().everyDays(), 7, reason: 'réglage enregistré');
      expect(await s.backupIfDue(), isNotNull);

      await repo.addExit(lot, 1);
      now = now.add(const Duration(days: 3));
      expect(await s.backupIfDue(), isNull);
      now = now.add(const Duration(days: 4));
      expect(await s.backupIfDue(), isNotNull);
      expect(() => s.setEveryDays(0), throwsArgumentError);
    });

    test('une erreur est mémorisée, jamais levée', () async {
      await addBeer('Bière A', 1);
      final s = BackupService(
        db: db,
        store: store,
        folder: () async => throw const FileSystemException('refusé'),
        tempFolder: () async => root,
        clock: () => now,
      );
      expect(await s.backupIfDue(), isNull);
      expect(await s.lastError(), contains('refusé'));

      // Une sauvegarde réussie efface l'erreur.
      await service().backupNow();
      expect(await service().lastError(), isNull);
    });
  });

  group('restauration', () {
    test('remet la cave dans l\'état sauvegardé, après une sauvegarde de '
        'sécurité', () async {
      final lot = await addBeer('Bière A', 6);
      final s = service();
      final saved = await s.backupNow();
      final caveId = await db.caveId();

      await repo.addExit(lot, 4);
      await addBeer('Bière B', 2);
      now = now.add(const Duration(minutes: 5));

      final safety = await s.restore(saved.database.path);

      expect(await drinkNames(), ['Bière A']);
      expect((await repo.lot(lot))!.stock, 6);
      expect(await db.caveId(), caveId);
      // La recherche retrouve la cave restaurée, et seulement elle.
      final hits = await db
          .customSelect(
            "SELECT drink_id FROM drinks_fts WHERE drinks_fts "
            "MATCH 'biere'",
          )
          .get();
      expect(hits, hasLength(1));

      // La sauvegarde de sécurité contient l'état d'avant la restauration.
      final before = s.inspect(safety.database.path);
      expect(before.drinks, 2);
      expect(before.bottles, 4);
    });

    test(
      'restaurer le fichier le plus ancien quand le dossier est plein',
      () async {
        await addBeer('Bière A', 1);
        final s = service(keep: 2);
        final oldest = await s.backupNow();
        now = now.add(const Duration(hours: 1));
        await s.backupNow();
        await addBeer('Bière B', 1);
        now = now.add(const Duration(hours: 1));

        // La sauvegarde de sécurité supprime « oldest » : la restauration doit
        // quand même aboutir.
        await s.restore(oldest.database.path);
        expect(await drinkNames(), ['Bière A']);
        expect(oldest.database.existsSync(), isFalse);
      },
    );

    test('une sauvegarde d\'une ancienne version est mise à niveau', () async {
      // Base v1 (lot 1) avec une référence, enregistrée dans un fichier.
      final schema = await SchemaVerifier(GeneratedHelper()).schemaAt(1);
      final raw = schema.rawDatabase;
      raw.execute("INSERT INTO meta VALUES ('cave_id', 'cave-v1')");
      raw.execute(
        "INSERT INTO drink_types VALUES ('t', 0, 'seed', NULL, 'Vin', 'wine', "
        "750, 0)",
      );
      raw.execute(
        "INSERT INTO drinks (id, updated_at, updated_by, type_id, name, "
        "region, created_at) VALUES ('d', 1, 'tel', 't', 'Château V1', "
        "'Bordeaux', 1)",
      );
      final old = '${root.path}/ancienne.sqlite';
      raw.execute('VACUUM INTO ?', [old]);
      raw.close();
      expect(service().inspect(old).schemaVersion, 1);

      await addBeer('Bière A', 1);
      await service().restore(old);

      expect(await drinkNames(), ['Château V1']);
      expect(await db.caveId(), 'cave-v1');
      // Le fichier d'origine n'est pas modifié.
      expect(service().inspect(old).schemaVersion, 1);
      // La recherche (créée en v2) fonctionne sur la cave restaurée.
      final hits = await db
          .customSelect(
            "SELECT drink_id FROM drinks_fts WHERE drinks_fts MATCH 'v1'",
          )
          .get();
      expect(hits, hasLength(1));
    });

    test('un fichier refusé ne touche pas la cave', () async {
      await addBeer('Bière A', 1);
      final bad = File('${root.path}/abime.sqlite')
        ..writeAsStringSync('ceci n\'est pas une base');
      await expectLater(
        service().restore(bad.path),
        throwsA(
          isA<CaveFileException>().having(
            (e) => e.problem,
            'problem',
            CaveFileProblem.unreadable,
          ),
        ),
      );
      expect(await drinkNames(), ['Bière A']);
      expect(backups.existsSync() ? backups.listSync() : [], isEmpty);
    });
  });

  group('vérification d\'un fichier', () {
    test('base SQLite qui n\'est pas une cave', () {
      final path = '${root.path}/autre.sqlite';
      sqlite3.open(path)
        ..execute('CREATE TABLE t (x)')
        ..close();
      expect(
        () => inspectCaveFile(path, currentVersion: 4),
        throwsA(
          isA<CaveFileException>().having(
            (e) => e.problem,
            'problem',
            CaveFileProblem.notACave,
          ),
        ),
      );
    });

    test('base créée par une version plus récente de l\'appli', () async {
      await addBeer('Bière A', 1);
      final set = await service().backupNow();
      sqlite3.open(set.database.path)
        ..userVersion = db.schemaVersion + 1
        ..close();
      expect(
        () => service().inspect(set.database.path),
        throwsA(
          isA<CaveFileException>().having(
            (e) => e.problem,
            'problem',
            CaveFileProblem.newerVersion,
          ),
        ),
      );
    });

    test('fichier absent', () {
      expect(
        () => inspectCaveFile('${root.path}/rien.sqlite', currentVersion: 4),
        throwsA(isA<CaveFileException>()),
      );
    });
  });
}
