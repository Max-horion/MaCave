import 'dart:io';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/backup/backup_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/sync/backup.dart';
import 'package:cave/sync/providers.dart';
import 'package:cave/sync/storage_access.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late Directory root;
  late BackupService service;
  late DateTime now;

  /// Autorisation de stockage (Android 8 à 10), accordée par défaut.
  late _FakeAccess access;

  setUp(() async {
    access = _FakeAccess(isGranted: true);
    db = memoryDatabase();
    ctx = TestContext();
    root = Directory.systemTemp.createTempSync('cave_backup_screen');
    now = DateTime(2026, 10, 5, 14, 30);
    service = BackupService(
      db: db,
      store: MemoryLocalStore(),
      folder: () async => Directory('${root.path}/Sauvegardes'),
      tempFolder: () async => root,
      clock: () => now,
    );
  });
  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  /// Laisse aboutir les vraies écritures (base, fichiers), puis redessine.
  /// Plusieurs tours : chaque suppression de fichier en demande un.
  Future<void> settle(WidgetTester tester, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> openScreen(WidgetTester tester) async {
    // Écran haut : toute la liste est construite.
    tester.view.physicalSize = const Size(1600, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          localSyncEnvironment(db, ctx),
          backupServiceProvider.overrideWithValue(service),
          storageAccessProvider.overrideWithValue(access),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BackupScreen(),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> addDrink(WidgetTester tester) => tester.runAsync(() async {
    final repo = CaveRepository(db, ctx);
    final types = await repo.drinkTypes();
    await repo.addNewDrink(
      drink: DrinkInput(name: 'Bière Test', typeId: types[1].id),
      volumeMl: 330,
      quantity: 2,
    );
  });

  testWidgets('sauvegarder maintenant ajoute une sauvegarde à la liste', (
    tester,
  ) async {
    await addDrink(tester);
    await openScreen(tester);
    expect(find.text('Aucune sauvegarde pour l\'instant.'), findsOneWidget);

    // Vraies écritures de fichiers : le clic est fait hors de l'horloge
    // simulée du test, puis on laisse le temps à la sauvegarde d'aboutir.
    await tester.runAsync(() async {
      await tester.tap(find.text('Sauvegarder maintenant'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await settle(tester);

    expect(find.text('Sauvegarde enregistrée.'), findsOneWidget);
    expect(find.text('5 octobre 2026 14:30'), findsOneWidget);
    expect(find.text('Aucune sauvegarde pour l\'instant.'), findsNothing);
  });

  testWidgets('réduire le nombre de sauvegardes demande confirmation', (
    tester,
  ) async {
    await addDrink(tester);
    await tester.runAsync(() async {
      for (var i = 0; i < 3; i++) {
        now = now.add(const Duration(hours: 1));
        await service.backupNow();
      }
    });
    await openScreen(tester);
    // Deux réglages (fréquence, nombre conservé) + les sauvegardes.
    expect(find.byType(ListTile), findsNWidgets(2 + 3));

    await tester.tap(find.byType(DropdownButton<int>).last);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('1').last);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);
    expect(
      find.text('Les 2 sauvegardes les plus anciennes seront supprimées.'),
      findsOneWidget,
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Supprimer'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settle(tester, rounds: 40);
    await tester.runAsync(() async {
      expect(await service.keepCount(), 1);
      expect(await service.list(), hasLength(1));
    });
    await settle(tester);
    expect(find.byType(ListTile), findsNWidgets(2 + 1));
    expect(find.text('5 octobre 2026 17:30'), findsOneWidget);
  });

  testWidgets('fréquence de la sauvegarde automatique', (tester) async {
    await openScreen(tester);
    expect(find.text('Chaque jour'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<int>).first);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Chaque semaine').last);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await settle(tester);
    expect(find.text('Chaque semaine'), findsOneWidget);
    expect(await tester.runAsync(service.everyDays), 7);
  });

  testWidgets('Android 8 à 10 : autorisation demandée par « Autoriser »', (
    tester,
  ) async {
    access = _FakeAccess(isGranted: false);
    await openScreen(tester);
    expect(
      find.textContaining('autoriser l\'appli à écrire dans Documents'),
      findsOneWidget,
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Autoriser'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settle(tester);
    expect(access.requests, 1);
    expect(find.text('Autoriser'), findsNothing);
  });
}

class _FakeAccess implements StorageAccess {
  _FakeAccess({required this.isGranted});

  bool isGranted;
  var requests = 0;

  @override
  Future<bool> granted() async => isGranted;

  @override
  Future<bool> request() async {
    requests++;
    return isGranted = true;
  }
}
