import 'dart:convert';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/exchange/cave_import.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/drink/drink_detail_screen.dart';
import 'package:cave/features/exchange/exchange_actions.dart';
import 'package:cave/features/inventory/inventory_screen.dart';
import 'package:cave/features/stats/stats_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
  });
  tearDown(() => db.close());

  /// Un écran seul, branché sur la base en mémoire.
  Widget screen(Widget child) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      writeContextProvider.overrideWithValue(ctx),
      localSyncEnvironment(db, ctx),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  Future<({String drinkId, String lotId})> addWine(
    WidgetTester tester,
    String name,
    int quantity,
  ) async {
    late ({String drinkId, String lotId}) result;
    await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      result = await repo.addNewDrink(
        drink: DrinkInput(name: name, typeId: types.first.id),
        volumeMl: 750,
        vintage: 2018,
        quantity: quantity,
      );
    });
    return result;
  }

  Future<int> stock(WidgetTester tester, String lotId) async {
    late int value;
    await tester.runAsync(() async => value = (await repo.lot(lotId))!.stock);
    return value;
  }

  testWidgets('inventaire : confirmer, corriger, bilan', (tester) async {
    final a = await addWine(tester, 'Alpha', 3);
    final b = await addWine(tester, 'Bêta', 5);
    await tester.pumpWidget(screen(const InventoryScreen()));
    await settle(tester);
    expect(find.text('2 lots à vérifier'), findsOneWidget);

    await tester.tap(find.text('Commencer'));
    await settle(tester);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.text('C\'est juste'));
    await settle(tester);
    expect(find.text('Bêta'), findsOneWidget);

    await tester.tap(find.text('Corriger'));
    await settle(tester);
    await tester.tap(find.byTooltip('Moins'));
    await tester.pump();
    await tester.tap(find.byTooltip('Moins'));
    await tester.pump();
    await tester.tap(find.text('Valider'));
    await settle(tester);

    expect(find.text('Inventaire terminé'), findsOneWidget);
    expect(find.text('1 lot confirmé, 1 corrigé.'), findsOneWidget);
    expect(await stock(tester, a.lotId), 3);
    expect(await stock(tester, b.lotId), 3);
  });

  testWidgets('statistiques : totaux et barres', (tester) async {
    await addWine(tester, 'Alpha', 4);
    await tester.pumpWidget(screen(const StatsScreen()));
    await settle(tester);
    expect(find.text('Bouteilles'), findsOneWidget);
    expect(find.text('4'), findsWidgets);
    expect(find.text('Par type'), findsOneWidget);
    expect(find.byType(HorizontalBars), findsWidgets);
  });

  testWidgets('statistiques : cave vide', (tester) async {
    await tester.pumpWidget(screen(const StatsScreen()));
    await settle(tester);
    expect(
      find.text('Ajoutez des bouteilles pour voir les statistiques.'),
      findsOneWidget,
    );
  });

  testWidgets('fiche : historique des mouvements', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    final a = await addWine(tester, 'Alpha', 3);
    await tester.runAsync(() => repo.addExit(a.lotId, 1));
    await tester.pumpWidget(screen(DrinkDetailScreen(drinkId: a.drinkId)));
    await settle(tester);
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('−1 bouteille · 2018 · 75 cl'), findsOneWidget);
    expect(find.text('+3 bouteilles · 2018 · 75 cl'), findsOneWidget);
  });

  testWidgets('aperçu d\'import : bilan et lignes en erreur', (tester) async {
    late ImportReport report;
    await tester.runAsync(() async {
      report = await CaveImporter(
        db,
        ctx,
      ).preview('Nom;Type;Stock\nVin Test;Vin;3\n;Vin;1\n');
    });
    await tester.pumpWidget(
      screen(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (_) => ImportPreviewDialog(report: report),
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Sauvegarde ou tableur : stock'), findsOneWidget);
    expect(find.text('• 1 référence créée'), findsOneWidget);
    expect(find.text('• 3 bouteilles ajoutées'), findsOneWidget);
    expect(find.text('1 ligne ignorée'), findsOneWidget);
    expect(find.text('Ligne 3 : nom manquant'), findsOneWidget);
    expect(find.text('Importer'), findsOneWidget);
  });

  test('texte d\'un fichier : UTF-8, sinon encodage Windows', () {
    expect(decodeText(utf8.encode('Château')), 'Château');
    expect(decodeText(latin1.encode('Château')), 'Château');
  });
}
