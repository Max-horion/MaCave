import 'dart:io';

import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/sync/backup.dart';
import 'package:cave/sync/cave_file.dart';
import 'package:cave/sync/sync_service.dart';
import 'package:cave/sync/webdav.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'device.dart';
import 'fake_webdav_server.dart';

// Le cycle de synchronisation complet, contre un faux serveur WebDAV local.
// « téléphone » et « PC » partent de la même cave (le PC est une copie).
void main() {
  late Directory root;
  late FakeWebDavServer server;
  late SyncedDevice phone;
  late SyncedDevice pc;
  const remote = '/cave/cave.sqlite';

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cave_sync_test');
    server = await FakeWebDavServer.start();
    phone = SyncedDevice.open(root, 'telephone', server.folderUri);
    await phone.db.customSelect('SELECT 1').get();
    await snapshotDatabase(phone.db, '${root.path}/pc.sqlite');
    pc = SyncedDevice.open(root, 'pc', server.folderUri);
  });
  tearDown(() async {
    await phone.close();
    await pc.close();
    await server.close();
    await root.delete(recursive: true);
  });

  /// Contenu d'une base : un fichier SQLite de [device], comme sur le serveur.
  Future<List<int>> fileOf(Device device) async {
    final path = '${root.path}/copie-${device.ctx.deviceId}.sqlite';
    await snapshotDatabase(device.db, path);
    return File(path).readAsBytes();
  }

  test('premier envoi : la cave arrive sur le serveur', () async {
    await phone.addBeer('Bière', 6);
    final report = await phone.sync.sync();

    expect(report.uploaded, isTrue);
    expect(server.files, contains(remote));
    expect(server.requests.last, 'PUT $remote');
  });

  test('rien de changé : un seul GET (« inchangé »), pas d\'envoi', () async {
    await phone.addBeer('Bière', 6);
    await phone.sync.sync();
    server.requests.clear();

    final report = await phone.sync.sync();
    expect(report.uploaded, isFalse);
    expect(report.merge, isNull);
    expect(server.requests, ['GET $remote']);
  });

  test('une modification locale est envoyée sans retéléchargement', () async {
    final lot = await phone.addBeer('Bière', 6);
    await phone.sync.sync();
    await phone.repo.addExit(lot, 1);
    server.requests.clear();

    final report = await phone.sync.sync();
    expect(report.uploaded, isTrue);
    expect(server.requests, ['GET $remote', 'PUT $remote']);
  });

  test('deux appareils : les sorties s\'additionnent', () async {
    final lot = await phone.addBeer('Bière', 6);
    await phone.sync.sync();
    await pc.sync.sync();
    expect(await pc.stockOf(lot), 6);

    await phone.repo.addExit(lot, 1);
    await pc.repo.addExit(lot, 2);
    await phone.sync.sync();
    final report = await pc.sync.sync();
    expect(report.merge, isNotNull);
    expect(report.uploaded, isTrue);
    await phone.sync.sync();

    expect(await phone.stockOf(lot), 3);
    expect(await pc.stockOf(lot), 3);
  });

  test('ce qu\'un autre appareil a envoyé n\'est jamais écrasé', () async {
    await phone.addBeer('Bière du téléphone', 1);
    await phone.sync.sync();
    await pc.sync.sync();

    await phone.addBeer('Autre du téléphone', 1);
    await pc.addBeer('Bière du PC', 1);
    // Le PC envoie pendant que le téléphone synchronise.
    final pcFile = await fileOf(pc);
    server.beforePut = () {
      server.beforePut = null;
      server.put(remote, pcFile);
    };

    final report = await phone.sync.sync();
    expect(report.uploaded, isTrue);
    expect(server.count('PUT'), greaterThanOrEqualTo(3));
    await pc.sync.sync();
    for (final d in [phone, pc]) {
      expect(await d.drinkNames(), [
        'Autre du téléphone',
        'Bière du PC',
        'Bière du téléphone',
      ]);
    }
  });

  test('fichier modifié à chaque essai : conflit, rien d\'écrasé', () async {
    await phone.sync.sync();
    await phone.addBeer('Bière', 1);
    final before = server.files[remote];
    server.beforePut = () => server.put(remote, before!);

    await expectLater(
      phone.sync.sync(),
      throwsA(_problem(SyncProblem.conflict)),
    );
    expect(server.files[remote], before);
    expect(await phone.drinkNames(), ['Bière']);
  });

  test('fichier endommagé : mis de côté puis remplacé', () async {
    await phone.addBeer('Bière', 1);
    await phone.sync.sync();
    server.put(remote, List.filled(4096, 7));

    final report = await phone.sync.sync();
    expect(report.setAsideAs, startsWith('cave.sqlite.endommage-'));
    expect(server.files, contains('/cave/${report.setAsideAs}'));
    expect(
      inspectCaveFile(
        await _download(server, remote, root),
        currentVersion: phone.db.schemaVersion,
      ).drinks,
      1,
    );
    expect(await phone.drinkNames(), ['Bière']);
  });

  test(
    'version plus récente sur le serveur : suspendu, rien d\'envoyé',
    () async {
      await phone.sync.sync();
      final path = '${root.path}/future.sqlite';
      await snapshotDatabase(pc.db, path);
      sqlite3.open(path)
        ..execute('PRAGMA user_version = 99')
        ..close();
      server.put(remote, File(path).readAsBytesSync());
      await phone.addBeer('Bière', 1);
      server.requests.clear();

      await expectLater(
        phone.sync.sync(),
        throwsA(_problem(SyncProblem.newerVersion)),
      );
      expect(server.count('PUT'), 0);
    },
  );

  group('une autre cave sur le serveur', () {
    late SyncedDevice other;

    setUp(() async {
      // Un appareil neuf : sa propre cave, avec un autre cave_id.
      other = SyncedDevice.open(root, 'neuf', server.folderUri);
      await other.addBeer('Bière du neuf', 2);
      await phone.addBeer('Bière du téléphone', 1);
      await phone.sync.sync();
    });
    tearDown(() => other.close());

    test('jamais fusionnée ni écrasée', () async {
      final before = server.files[remote];
      await expectLater(
        other.sync.sync(),
        throwsA(_problem(SyncProblem.otherCave)),
      );
      expect(server.files[remote], before);
      expect(await other.drinkNames(), ['Bière du neuf']);
    });

    test('« Utiliser la cave du serveur », après sauvegarde', () async {
      final safety = await other.sync.useServerCave(other.backups);

      expect(await other.drinkNames(), ['Bière du téléphone']);
      expect(await other.db.caveId(), await phone.db.caveId());
      expect(other.backups.inspect(safety.database.path).drinks, 1);
      // Ensuite, synchronisation normale : rien à refaire.
      server.requests.clear();
      final report = await other.sync.sync();
      expect(report.uploaded, isFalse);
      expect(server.requests, ['GET $remote']);
    });

    test(
      '« Remplacer la cave du serveur », l\'ancienne mise de côté',
      () async {
        final aside = await other.sync.replaceServerCave();

        expect(aside, startsWith('cave.sqlite.remplacee-'));
        expect(server.files, contains('/cave/$aside'));
        expect(
          inspectCaveFile(
            await _download(server, remote, root),
            currentVersion: other.db.schemaVersion,
          ).caveId,
          await other.db.caveId(),
        );
        // Le téléphone découvre alors une autre cave : à lui de choisir.
        await expectLater(
          phone.sync.sync(),
          throwsA(_problem(SyncProblem.otherCave)),
        );
      },
    );
  });

  group('erreurs du serveur', () {
    test('identifiants refusés', () async {
      final intruder = SyncedDevice.open(
        root,
        'intrus',
        server.folderUri,
        password: 'faux',
      );
      addTearDown(intruder.close);
      await expectLater(
        intruder.sync.sync(),
        throwsA(_problem(SyncProblem.unauthorized)),
      );
    });

    test('serveur injoignable', () async {
      await server.close();
      await expectLater(
        phone.sync.sync(),
        throwsA(_problem(SyncProblem.unreachable)),
      );
    });

    test('espace insuffisant : la base locale est intacte', () async {
      await phone.addBeer('Bière', 1);
      server.forcedStatus = 507;
      await expectLater(
        phone.sync.sync(),
        throwsA(_problem(SyncProblem.insufficientStorage)),
      );
      expect(await phone.drinkNames(), ['Bière']);
      // Le serveur revient : la modification part enfin.
      server.forcedStatus = null;
      expect((await phone.sync.sync()).uploaded, isTrue);
    });

    test('redirection : jamais suivie, mot de passe gardé', () async {
      server.redirectTo = '/ailleurs/cave.sqlite';
      server.put('/ailleurs/cave.sqlite', await fileOf(pc));
      await expectLater(
        phone.sync.sync(),
        throwsA(_problem(SyncProblem.server)),
      );
      expect(server.requests, ['GET $remote']);
    });

    test('fichier trop gros : téléchargement arrêté, fichier fermé', () async {
      server.put('/cave/gros.sqlite', List.filled(300000, 1));
      final client = WebDavClient(
        folder: server.folderUri,
        user: FakeWebDavServer.user,
        password: FakeWebDavServer.password,
      );
      addTearDown(client.close);
      final target = File('${root.path}/gros.sqlite');
      await expectLater(
        client.download('gros.sqlite', target, maxBytes: 100000),
        throwsA(
          isA<WebDavException>().having(
            (e) => e.problem,
            'problem',
            WebDavProblem.server,
          ),
        ),
      );
      // Fichier fermé : il peut être supprimé (sous Windows aussi).
      target.deleteSync();
      // Sous la limite, rien ne change.
      final ok = await client.download('gros.sqlite', target, maxBytes: 300000);
      expect(ok.status, DownloadStatus.downloaded);
      expect(target.lengthSync(), 300000);
    });

    test('le dossier est créé au premier envoi', () async {
      server.folders.clear();
      expect((await phone.sync.sync()).uploaded, isTrue);
      expect(server.folders, contains('/cave'));
    });

    test('ETag relu par PROPFIND si l\'envoi ne le donne pas', () async {
      server.etagOnPut = false;
      await phone.addBeer('Bière', 1);
      await phone.sync.sync();
      expect(server.count('PROPFIND'), 1);
      server.requests.clear();
      await phone.sync.sync();
      expect(server.requests, ['GET $remote']);
    });
  });

  test(
    'une modification datée par une horloge en retard est envoyée',
    () async {
      final lot = await phone.addBeer('Bière', 6);
      await phone.sync.sync();
      // Le PC, en avance, modifie : la base du téléphone reçoit sa date.
      pc.ctx.time = 9000000000;
      await pc.sync.sync();
      await pc.repo.addExit(lot, 1);
      await pc.sync.sync();
      await phone.sync.sync();
      // Le téléphone, en retard, modifie à son tour.
      await phone.repo.addExit(lot, 1);
      final report = await phone.sync.sync();

      expect(report.uploaded, isTrue);
      await pc.sync.sync();
      expect(await pc.stockOf(lot), 4);
    },
  );
}

Matcher _problem(SyncProblem problem) =>
    isA<SyncException>().having((e) => e.problem, 'problem', problem);

/// Écrit dans un fichier le contenu de [path] sur le serveur.
Future<String> _download(
  FakeWebDavServer server,
  String path,
  Directory root,
) async {
  final file = File('${root.path}/serveur-${server.requests.length}.sqlite');
  await file.writeAsBytes(server.files[path]!);
  return file.path;
}

/// Un appareil de test relié au faux serveur.
class SyncedDevice extends Device {
  SyncedDevice._(
    super.deviceId,
    super.db,
    Directory dir,
    Uri folder,
    String password,
  ) : store = MemoryLocalStore() {
    final temp = Directory('${dir.path}/tmp')..createSync(recursive: true);
    client = WebDavClient(
      folder: folder,
      user: FakeWebDavServer.user,
      password: password,
    );
    sync = SyncService(
      db: db,
      ctx: ctx,
      store: store,
      client: client,
      tempFolder: () async => temp,
    );
    backups = BackupService(
      db: db,
      store: store,
      folder: () async => Directory('${dir.path}/Sauvegardes'),
      tempFolder: () async => temp,
    );
  }

  /// Base `<root>/<deviceId>.sqlite` (créée si elle n'existe pas).
  factory SyncedDevice.open(
    Directory root,
    String deviceId,
    Uri folder, {
    String password = FakeWebDavServer.password,
  }) {
    final dir = Directory('${root.path}/$deviceId')..createSync();
    return SyncedDevice._(
      deviceId,
      CaveDatabase(NativeDatabase(File('${root.path}/$deviceId.sqlite'))),
      dir,
      folder,
      password,
    );
  }

  final LocalStore store;
  late final WebDavClient client;
  late final SyncService sync;
  late final BackupService backups;

  Future<void> close() async {
    client.close();
    await db.close();
  }
}
