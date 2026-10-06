import 'dart:io';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/history_purge.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/storage/storage_screen.dart';
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
  late BackupService backups;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    root = Directory.systemTemp.createTempSync('cave_storage_screen');
    backups = BackupService(
      db: db,
      store: MemoryLocalStore(),
      folder: () async => Directory('${root.path}/Sauvegardes'),
      tempFolder: () async => root,
    );
  });
  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  Future<void> settle(WidgetTester tester, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          backupServiceProvider.overrideWithValue(backups),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StorageScreen(),
        ),
      ),
    );
    await settle(tester);
  }

  /// Une bière achetée en 2024 : 6 bouteilles, 2 bues en 2024, puis
  /// [exitLater] bues récemment. Retourne l'ID du lot.
  Future<String> oldBeer(WidgetTester tester, {int exitLater = 0}) async {
    return (await tester.runAsync(() async {
      final repo = CaveRepository(db, ctx);
      ctx.time = DateTime.utc(2024, 3).millisecondsSinceEpoch;
      final types = await repo.drinkTypes();
      final ids = await repo.addNewDrink(
        drink: DrinkInput(name: 'Bière', typeId: types[1].id),
        volumeMl: 330,
        quantity: 6,
      );
      await repo.addExit(ids.lotId, 2);
      if (exitLater > 0) {
        ctx.time = DateTime.now().toUtc().millisecondsSinceEpoch;
        await repo.addExit(ids.lotId, exitLater);
      }
      return ids.lotId;
    }))!;
  }

  testWidgets('rien d\'ancien : purge impossible', (tester) async {
    await open(tester);
    expect(find.text('Historique : aucun mouvement'), findsOneWidget);
    expect(
      find.text('Aucun mouvement de plus d\'un mois : rien à purger.'),
      findsOneWidget,
    );
  });

  testWidgets('purge manuelle : sauvegarde, stocks inchangés', (tester) async {
    final lot = await oldBeer(tester, exitLater: 1);
    await open(tester);
    expect(find.text('Historique : 3 mouvements'), findsOneWidget);

    await tester.tap(find.text('Purger l\'historique…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(find.text('Purger l\'historique ?'), findsOneWidget);
    expect(find.textContaining('2 mouvements antérieurs au'), findsOneWidget);

    await tester.runAsync(() async => tester.tap(find.text('Purger')));
    await settle(tester, rounds: 20);

    expect(find.text('2 mouvements supprimés'), findsOneWidget);
    final (stock, saved) = (await tester.runAsync(() async {
      final l = await CaveRepository(db, ctx).lot(lot);
      return (l!.stock, (await backups.list()).length);
    }))!;
    expect(stock, 3);
    expect(saved, 1);
  });

  testWidgets('purge automatique : activée après confirmation', (tester) async {
    final lot = await oldBeer(tester);
    await tester.runAsync(() async {
      // Lot épuisé en 2024.
      await CaveRepository(db, ctx).addExit(lot, 4);
    });
    await open(tester);

    await tester.tap(find.text('Purge automatique'));
    await settle(tester);
    expect(find.textContaining('1 lot épuisé sera supprimé'), findsOneWidget);

    await tester.runAsync(() async => tester.tap(find.text('Supprimer')));
    await settle(tester, rounds: 20);

    expect(find.text('1 lot supprimé'), findsOneWidget);
    final (enabled, gone) = (await tester.runAsync(() async {
      final settings = await HistoryPurge(db, ctx).autoSettings();
      return (settings.enabled, await CaveRepository(db, ctx).lot(lot));
    }))!;
    expect(enabled, isTrue);
    expect(gone, isNull);
  });
}
