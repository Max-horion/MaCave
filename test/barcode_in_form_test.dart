import 'dart:convert';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/drink/drink_detail_screen.dart';
import 'package:cave/features/drink/drink_form_screen.dart';
import 'package:cave/features/scan/scan_flow.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/scan/open_food_facts.dart';
import 'package:cave/scan/providers.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'helpers.dart';

// Code-barres scanné depuis le formulaire ou la fiche (dans les deux sens :
// étiquette puis code, ou l'inverse). Pas de caméra en test : le lecteur
// rend directement le code.
void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  const code = '3760000000017';

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
  });
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  Future<void> open(
    WidgetTester tester,
    Widget home, {
    Map<String, Object?>? product,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          localSyncEnvironment(db, ctx),
          barcodeScannerProvider.overrideWithValue((_) async => code),
          if (product != null)
            openFoodFactsProvider.overrideWithValue(
              OpenFoodFacts(
                isOnline: () async => true,
                client: MockClient(
                  (_) async => http.Response(
                    jsonEncode({'status': 1, 'product': product}),
                    200,
                    headers: {
                      'content-type': 'application/json; charset=utf-8',
                    },
                  ),
                ),
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

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.runAsync(() async => tester.tap(finder));
    await settle(tester);
  }

  Future<String> beer(
    WidgetTester tester,
    String name, {
    String? barcode,
  }) async => (await tester.runAsync(() async {
    final types = await repo.drinkTypes();
    return (await repo.addNewDrink(
      drink: DrinkInput(name: name, typeId: types[1].id),
      volumeMl: 330,
      quantity: 2,
      barcode: barcode,
    )).drinkId;
  }))!;

  testWidgets('formulaire : code scanné après la saisie, mémorisé', (
    tester,
  ) async {
    await open(tester, const DrinkFormScreen());
    await tester.enterText(find.byKey(const Key('field-name')), 'Ma bière');
    await tap(tester, find.text('Scanner le code-barres'));

    expect(find.text('Code-barres : $code'), findsOneWidget);
    await tap(tester, find.text('Enregistrer'));

    final found = (await tester.runAsync(() => repo.lotsByBarcode(code)))!;
    expect(found.single.drink.name, 'Ma bière');
  });

  testWidgets('formulaire : Open Food Facts ne complète que les champs vides', (
    tester,
  ) async {
    await open(
      tester,
      const DrinkFormScreen(),
      product: {
        'product_name': 'Nom Open Food Facts',
        'brands': 'Brasserie Inventée',
        'categories_tags': ['en:beers'],
      },
    );
    await tester.enterText(find.byKey(const Key('field-name')), 'Mon nom');
    await tap(tester, find.text('Scanner le code-barres'));

    expect(
      find.text('Champs vides complétés avec Open Food Facts'),
      findsOneWidget,
    );
    expect(find.text('Mon nom'), findsOneWidget);
    expect(find.text('Nom Open Food Facts'), findsNothing);
    expect(find.text('Brasserie Inventée'), findsOneWidget);
  });

  testWidgets('formulaire : code déjà dans la cave, on continue quand même', (
    tester,
  ) async {
    await beer(tester, 'Bière existante', barcode: code);
    await open(tester, const DrinkFormScreen());
    await tester.enterText(find.byKey(const Key('field-name')), 'Autre bière');
    await tap(tester, find.text('Scanner le code-barres'));

    expect(find.text('Code déjà dans la cave'), findsOneWidget);
    expect(find.textContaining('« Bière existante »'), findsOneWidget);
    await tap(tester, find.text('Continuer avec ce code'));
    await tap(tester, find.text('Enregistrer'));

    final found = (await tester.runAsync(() => repo.lotsByBarcode(code)))!;
    expect(found.map((m) => m.drink.name), ['Autre bière', 'Bière existante']);
  });

  testWidgets('formulaire : code déjà dans la cave, annuler ne garde rien', (
    tester,
  ) async {
    await beer(tester, 'Bière existante', barcode: code);
    await open(tester, const DrinkFormScreen());
    await tap(tester, find.text('Scanner le code-barres'));
    await tap(tester, find.text('Annuler'));

    expect(find.text('Code-barres : $code'), findsNothing);
  });

  testWidgets('fiche : associer un code à un lot existant', (tester) async {
    final drinkId = await beer(tester, 'Bière importée');
    await open(tester, DrinkDetailScreen(drinkId: drinkId));

    await tap(tester, find.byType(PopupMenuButton<void>).first);
    await tap(tester, find.text('Associer un code-barres'));

    expect(find.text('Code-barres : $code'), findsOneWidget);
    final found = (await tester.runAsync(() => repo.lotsByBarcode(code)))!;
    expect(found.single.drink.id, drinkId);
  });
}
