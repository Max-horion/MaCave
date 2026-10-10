import 'dart:async';
import 'dart:io';

import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/sync/backup.dart';
import 'package:cave/sync/cave_file.dart';
import 'package:cave/sync/providers.dart';
import 'package:cave/sync/server_backups.dart';
import 'package:cave/sync/sync_controller.dart';
import 'package:cave/sync/sync_service.dart';
import 'package:cave/sync/sync_settings.dart';
import 'package:cave/sync/webdav.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'device.dart';
import 'fake_webdav_server.dart';

void main() {
  late Directory root;
  late FakeWebDavServer server;
  late Device phone;
  late MemoryLocalStore store;
  late MemorySecretStore secrets;
  late BackupService backups;
  late bool online;
  late StreamController<bool> onlineChanges;
  late DateTime now;
  late ProviderContainer container;
  const remote = '/cave/cave.sqlite';

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cave_sync_controller');
    server = await FakeWebDavServer.start();
    phone = Device(
      'telephone',
      CaveDatabase(NativeDatabase(File('${root.path}/telephone.sqlite'))),
    );
    store = MemoryLocalStore();
    secrets = MemorySecretStore();
    final temp = Directory('${root.path}/tmp')..createSync();
    now = DateTime(2026, 10, 6, 10);
    backups = BackupService(
      db: phone.db,
      store: store,
      folder: () async => Directory('${root.path}/Sauvegardes'),
      tempFolder: () async => temp,
      clock: () => now,
    );
    online = true;
    onlineChanges = StreamController<bool>.broadcast();
    container = ProviderContainer(
      overrides: [
        syncEnvironmentProvider.overrideWithValue(
          SyncEnvironment(
            db: phone.db,
            ctx: phone.ctx,
            store: store,
            settings: SyncSettingsStore(store, secrets),
            backups: backups,
            tempFolder: () async => temp,
            isOnline: () async => online,
            onlineChanges: onlineChanges.stream,
            clock: () => now,
            debounce: const Duration(milliseconds: 10),
            retryDelays: const [Duration(milliseconds: 10)],
          ),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await onlineChanges.close();
    await phone.db.close();
    await server.close();
    await root.delete(recursive: true);
  });

  SyncController controller() =>
      container.read(syncControllerProvider.notifier);
  SyncState state() => container.read(syncControllerProvider);

  SyncSettings settings() => SyncSettings(
    kind: ServerKind.other,
    server: '${server.folderUri}',
    user: FakeWebDavServer.user,
  );

  Future<void> activate() async {
    final result = await controller().activate(
      settings(),
      FakeWebDavServer.password,
    );
    expect(result, ActivationResult.done);
  }

  /// Laisse passer les délais (regroupement, nouvel essai).
  Future<void> wait() => Future<void>.delayed(const Duration(milliseconds: 80));

  test('mode local : rien ne se passe', () async {
    await controller().start();
    expect(state().status, SyncStatus.off);
    expect(server.requests, isEmpty);
  });

  test('activation : la cave et sa dernière sauvegarde partent', () async {
    await phone.addBeer('Bière', 6);
    await backups.backupNow();
    await activate();

    expect(state().status, SyncStatus.synced);
    expect(state().lastSuccess, now);
    expect(server.files, contains(remote));
    expect(
      server.files.keys.where((f) => f.startsWith('/cave/Sauvegardes/')),
      hasLength(3),
    );
    // Les paramètres sont enregistrés : la synchro reprend à l'ouverture.
    expect(await SyncSettingsStore(store, secrets).load(), isNotNull);
  });

  test('identifiants refusés : rien n\'est enregistré', () async {
    await expectLater(
      controller().activate(settings(), 'faux'),
      throwsA(
        isA<SyncException>().having(
          (e) => e.problem,
          'problem',
          SyncProblem.unauthorized,
        ),
      ),
    );
    expect(state().status, SyncStatus.off);
    expect(await SyncSettingsStore(store, secrets).load(), isNull);
  });

  test('autre cave sur le serveur : « Utiliser la cave du serveur »', () async {
    // Un autre appareil a déjà sa cave sur le serveur.
    final other = Device(
      'pc',
      CaveDatabase(NativeDatabase(File('${root.path}/pc.sqlite'))),
    );
    await other.addBeer('Bière du serveur', 2);
    final path = '${root.path}/autre.sqlite';
    await snapshotDatabase(other.db, path);
    await other.db.close();
    server.put(remote, File(path).readAsBytesSync());
    await phone.addBeer('Bière du téléphone', 1);

    final result = await controller().activate(
      settings(),
      FakeWebDavServer.password,
    );
    expect(result, ActivationResult.otherCave);
    expect(await SyncSettingsStore(store, secrets).load(), isNull);

    await controller().resolveOtherCave(useServer: true);
    expect(await phone.drinkNames(), ['Bière du serveur']);
    expect(state().status, SyncStatus.synced);
    expect(await SyncSettingsStore(store, secrets).load(), isNotNull);
    // La cave du téléphone a été sauvegardée avant d'être remplacée.
    expect(await backups.list(), isNotEmpty);
  });

  test(
    'pas de réseau : en attente, puis synchro au retour du réseau',
    () async {
      await activate();
      await phone.addBeer('Bière', 1);
      online = false;
      server.requests.clear();

      await controller().syncNow();
      expect(state().status, SyncStatus.waiting);
      expect(state().problem, isNull);
      expect(server.requests, isEmpty);

      online = true;
      onlineChanges.add(true);
      await wait();
      expect(state().status, SyncStatus.synced);
      expect(server.count('PUT'), 1);
    },
  );

  test('erreur : journal, puis nouvel essai automatique', () async {
    await activate();
    await phone.addBeer('Bière', 1);
    server.forcedStatus = 500;

    await controller().syncNow();
    expect(state().status, SyncStatus.error);
    expect(state().problem, SyncProblem.server);
    expect(state().errorSince, now);
    final log = await controller().log();
    expect(log.single.problem, SyncProblem.server);

    server.forcedStatus = null;
    await wait();
    expect(state().status, SyncStatus.synced);
    expect(state().errorSince, isNull);
  });

  test('erreur depuis plus de 24 heures : signalée', () async {
    await activate();
    server.forcedStatus = 500;
    await controller().syncNow();
    expect(state().longError(now.add(const Duration(hours: 23))), isFalse);
    expect(state().longError(now.add(const Duration(hours: 25))), isTrue);
  });

  test('identifiants refusés plus tard : pas de nouvel essai', () async {
    await activate();
    server.forcedStatus = 401;
    await controller().syncNow();
    server.requests.clear();
    await wait();
    expect(state().problem, SyncProblem.unauthorized);
    expect(server.requests, isEmpty);
  });

  test('une modification est envoyée après un court délai', () async {
    await activate();
    await phone.addBeer('Bière', 1);
    controller().localChanged();
    controller().localChanged();
    await wait();
    expect(server.count('PUT'), 2);
  });

  test(
    'modification pendant une synchronisation : envoyée juste après',
    () async {
      await activate();
      await phone.addBeer('Bière', 1);
      server.requests.clear();
      Future<void>? during;
      server.beforePut = () {
        server.beforePut = null;
        // La copie envoyée est déjà prise : cette bière n'y est pas.
        during = phone.addBeer('Bière du milieu', 2);
        controller().localChanged();
      };
      await controller().syncNow();
      await during;
      await wait();
      expect(server.requests.where((r) => r == 'PUT $remote'), hasLength(2));
      expect(state().status, SyncStatus.synced);
      // Plus rien à envoyer : pas de troisième envoi.
      server.requests.clear();
      await controller().syncNow();
      expect(server.requests.where((r) => r == 'PUT $remote'), isEmpty);
    },
  );

  test('synchro automatique désactivée : seulement sur demande', () async {
    await activate();
    await controller().setAutomatic(false);
    server.requests.clear();

    // Ni modification, ni retour au premier plan, ni ouverture ne
    // synchronisent.
    await phone.addBeer('Bière', 1);
    controller().localChanged();
    await controller().resumed();
    await wait();
    expect(server.requests, isEmpty);
    expect(state().status, SyncStatus.pending);
    expect(state().automatic, isFalse);

    await controller().start();
    expect(server.requests, isEmpty, reason: 'réglage gardé');
    expect(state().automatic, isFalse);

    // Pas de nouvel essai automatique après une erreur.
    server.forcedStatus = 500;
    await controller().syncNow();
    server.requests.clear();
    await wait();
    expect(server.requests, isEmpty);
    server.forcedStatus = null;

    await controller().syncNow();
    expect(state().status, SyncStatus.synced);
    expect(state().automatic, isFalse);
    expect(server.count('PUT'), 1);
  });

  test('synchro automatique réactivée : synchronise aussitôt', () async {
    await activate();
    await controller().setAutomatic(false);
    await phone.addBeer('Bière', 1);
    controller().localChanged();
    server.requests.clear();

    await controller().setAutomatic(true);
    expect(state().status, SyncStatus.synced);
    expect(server.count('PUT'), 1);
    // Désactiver la synchro remet le réglage par défaut.
    await controller().setAutomatic(false);
    await controller().deactivate();
    await activate();
    expect(state().automatic, isTrue);
  });

  test('désactivation : mode local, le fichier du serveur reste', () async {
    await activate();
    await controller().deactivate();

    expect(state().status, SyncStatus.off);
    expect(await SyncSettingsStore(store, secrets).load(), isNull);
    expect(server.files, contains(remote));
    // À l'ouverture suivante : mode local.
    await controller().start();
    expect(state().status, SyncStatus.off);
  });

  test('sauvegardes du serveur : seules les N plus récentes restent', () async {
    // Trois anciennes sauvegardes déjà sur le serveur (d'un autre appareil).
    server.folders.add('/cave/Sauvegardes');
    for (final day in ['01', '02', '03']) {
      for (final name in BackupService.fileNamesOf(
        'cave_2026-10-${day}_08-00-00.sqlite',
      )) {
        server.put('/cave/Sauvegardes/$name', [1]);
      }
    }
    await backups.setKeepCount(2);
    await phone.addBeer('Bière', 1);
    await backups.backupNow();
    final client = WebDavClient(
      folder: server.folderUri,
      user: FakeWebDavServer.user,
      password: FakeWebDavServer.password,
    );
    addTearDown(client.close);

    final copied = await mirrorLatestBackup(
      backups,
      client.child(serverBackupFolder),
    );
    expect(copied, 'cave_2026-10-06_10-00-00.sqlite');
    final names =
        server.files.keys
            .where((f) => f.endsWith('.sqlite'))
            .map((f) => f.split('/').last)
            .toList()
          ..sort();
    expect(names, [
      'cave_2026-10-03_08-00-00.sqlite',
      'cave_2026-10-06_10-00-00.sqlite',
    ]);
    // Les CSV des sauvegardes supprimées sont partis avec elles.
    expect(server.files.keys.where((f) => f.contains('10-01')), isEmpty);
    expect(server.files.keys.where((f) => f.contains('10-03')), hasLength(3));
  });
}
