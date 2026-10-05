import 'dart:io';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/backup/backup_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/sync/backup.dart';
import 'package:cave/sync/providers.dart';
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

  setUp(() async {
    db = memoryDatabase();
    ctx = TestContext();
    root = Directory.systemTemp.createTempSync('cave_backup_screen');
    service = BackupService(
      db: db,
      store: MemoryLocalStore(),
      folder: () async => Directory('${root.path}/Sauvegardes'),
      tempFolder: () async => root,
      clock: () => DateTime(2026, 10, 5, 14, 30),
    );
  });
  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('sauvegarder maintenant ajoute une sauvegarde à la liste', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final repo = CaveRepository(db, ctx);
      final types = await repo.drinkTypes();
      await repo.addNewDrink(
        drink: DrinkInput(name: 'Bière Test', typeId: types[1].id),
        volumeMl: 330,
        quantity: 2,
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          backupServiceProvider.overrideWithValue(service),
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
}
