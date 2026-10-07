import 'dart:io';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/sync/sync_indicator.dart';
import 'package:cave/features/sync/sync_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/sync/backup.dart';
import 'package:cave/sync/cave_file.dart';
import 'package:cave/sync/providers.dart';
import 'package:cave/sync/sync_controller.dart';
import 'package:cave/sync/sync_settings.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';
import 'sync/fake_webdav_server.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late Directory root;
  late FakeWebDavServer server;
  late MemoryLocalStore store;
  late MemorySecretStore secrets;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    // Les tests d'écran remplacent le réseau par un faux qui répond toujours
    // « 400 » : ici, il faut joindre le faux serveur WebDAV local.
    HttpOverrides.global = null;
    db = memoryDatabase();
    ctx = TestContext();
    root = Directory.systemTemp.createTempSync('cave_sync_screen');
    store = MemoryLocalStore();
    secrets = MemorySecretStore();
  });
  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  /// Laisse aboutir les vraies entrées-sorties (base, réseau), puis redessine.
  Future<void> settle(WidgetTester tester, {int rounds = 15}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> open(WidgetTester tester, Widget home) async {
    final temp = Directory('${root.path}/tmp')..createSync();
    final backups = BackupService(
      db: db,
      store: store,
      folder: () async => Directory('${root.path}/Sauvegardes'),
      tempFolder: () async => temp,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          backupServiceProvider.overrideWithValue(backups),
          syncEnvironmentProvider.overrideWithValue(
            SyncEnvironment(
              db: db,
              ctx: ctx,
              store: store,
              settings: SyncSettingsStore(store, secrets),
              backups: backups,
              tempFolder: () async => temp,
              isOnline: () async => true,
              retryDelays: const [],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await settle(tester);
  }

  /// Remplit le formulaire pour le faux serveur (« autre serveur WebDAV »).
  Future<void> fillForm(WidgetTester tester, {String? password}) async {
    await tester.tap(find.text('Autre serveur WebDAV'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse du dossier WebDAV'),
      '${server.folderUri}',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Identifiant'),
      FakeWebDavServer.user,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, "Mot de passe d'application"),
      password ?? FakeWebDavServer.password,
    );
  }

  Future<void> tapActivate(WidgetTester tester) async {
    final button = find.text('Activer la synchronisation');
    await tester.ensureVisible(button);
    await tester.runAsync(() async => tester.tap(button));
    await settle(tester);
  }

  testWidgets('activation : la cave part sur le serveur', (tester) async {
    await tester.runAsync(() async {
      server = await FakeWebDavServer.start();
    });
    addTearDown(() => tester.runAsync(server.close));
    await open(tester, const SyncScreen());

    await fillForm(tester);
    await tapActivate(tester);

    expect(find.text('Synchronisation activée'), findsOneWidget);
    expect(find.text('Synchronisé'), findsOneWidget);
    expect(find.text('Synchroniser maintenant'), findsOneWidget);
    expect(server.files, contains('/cave/cave.sqlite'));
    // Le mot de passe est dans le coffre, pas dans les préférences.
    expect(secrets.values.values, [FakeWebDavServer.password]);
  });

  testWidgets('mot de passe refusé : message, rien d\'activé', (tester) async {
    await tester.runAsync(() async {
      server = await FakeWebDavServer.start();
    });
    addTearDown(() => tester.runAsync(server.close));
    await open(tester, const SyncScreen());

    await fillForm(tester, password: 'faux');
    await tapActivate(tester);

    expect(
      find.text('Identifiant ou mot de passe refusé par le serveur.'),
      findsOneWidget,
    );
    expect(find.text('Activer la synchronisation'), findsOneWidget);
    expect(secrets.values, isEmpty);
  });

  /// Met sur le faux serveur la cave d'un autre appareil (une bière).
  Future<void> putOtherCave() async {
    final other = memoryDatabase();
    final repo = CaveRepository(other, TestContext(deviceId: 'pc'));
    final types = await repo.drinkTypes();
    await repo.addNewDrink(
      drink: DrinkInput(name: 'Bière du serveur', typeId: types[1].id),
      volumeMl: 330,
      quantity: 3,
    );
    final path = '${root.path}/autre.sqlite';
    await snapshotDatabase(other, path);
    await other.close();
    server.put('/cave/cave.sqlite', File(path).readAsBytesSync());
  }

  Future<List<String>> localNames(WidgetTester tester) async =>
      (await tester.runAsync(
        () async => (await db.select(db.drinks).get())
            .where((d) => d.deletedAt == null)
            .map((d) => d.name)
            .toList(),
      ))!;

  testWidgets('autre cave sur le serveur : on choisit celle du serveur', (
    tester,
  ) async {
    await tester.runAsync(() async {
      server = await FakeWebDavServer.start();
      await putOtherCave();
      // Une cave déjà remplie sur ce téléphone : il faut choisir.
      final repo = CaveRepository(db, ctx);
      final types = await repo.drinkTypes();
      await repo.addNewDrink(
        drink: DrinkInput(name: 'Bière du téléphone', typeId: types[1].id),
        volumeMl: 330,
        quantity: 1,
      );
    });
    addTearDown(() => tester.runAsync(server.close));
    await open(tester, const SyncScreen());

    await fillForm(tester);
    await tapActivate(tester);
    expect(find.text('Une autre cave est sur le serveur'), findsOneWidget);

    await tester.runAsync(
      () async => tester.tap(find.text('Utiliser la cave du serveur')),
    );
    await settle(tester, rounds: 25);

    expect(find.text('Synchronisé'), findsOneWidget);
    expect(await localNames(tester), ['Bière du serveur']);
  });

  testWidgets(
    'cave neuve (nouvel appareil) : celle du serveur, sans question',
    (tester) async {
      await tester.runAsync(() async {
        server = await FakeWebDavServer.start();
        await putOtherCave();
      });
      addTearDown(() => tester.runAsync(server.close));
      await open(tester, const SyncScreen());

      await fillForm(tester);
      await tapActivate(tester);
      await settle(tester, rounds: 25);

      expect(find.text('Une autre cave est sur le serveur'), findsNothing);
      expect(find.text('Synchronisé'), findsOneWidget);
      expect(await localNames(tester), ['Bière du serveur']);
    },
  );

  testWidgets('indicateur : invisible en mode local, puis « Réessayer »', (
    tester,
  ) async {
    await tester.runAsync(() async {
      server = await FakeWebDavServer.start();
    });
    addTearDown(() => tester.runAsync(server.close));
    await open(
      tester,
      Scaffold(appBar: AppBar(actions: const [SyncIndicator()])),
    );
    expect(find.byType(IconButton), findsNothing);

    // Synchronisation active, puis serveur en panne.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    final controller = container.read(syncControllerProvider.notifier);
    await tester.runAsync(() async {
      await controller.activate(
        SyncSettings(
          kind: ServerKind.other,
          server: '${server.folderUri}',
          user: FakeWebDavServer.user,
        ),
        FakeWebDavServer.password,
      );
      server.forcedStatus = 507;
      await controller.syncNow();
    });
    await settle(tester);

    await tester.tap(find.byTooltip('État de la synchronisation'));
    await settle(tester);
    expect(find.text('Erreur de synchronisation'), findsOneWidget);
    expect(
      find.textContaining('Espace insuffisant sur le serveur'),
      findsOneWidget,
    );

    server.forcedStatus = null;
    await tester.runAsync(() async => tester.tap(find.text('Réessayer')));
    await settle(tester);
    expect(container.read(syncControllerProvider).status, SyncStatus.synced);
  });
}
