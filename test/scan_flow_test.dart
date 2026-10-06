import 'dart:convert';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/scan/scan_flow.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:cave/scan/open_food_facts.dart';
import 'package:cave/scan/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'helpers.dart';

// Le déroulé après un scan. La caméra n'existe pas en test : le code « lu »
// est passé directement à handleScannedCode.
void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  const code = '3760001234567';

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

  /// Un écran avec un bouton « Code lu » qui simule le scan de [scanned].
  /// [product] : réponse d'Open Food Facts (sinon : hors ligne).
  Future<void> open(
    WidgetTester tester,
    String scanned, {
    Map<String, Object?>? product,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          localSyncEnvironment(db, ctx),
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
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => handleScannedCode(context, ref, scanned),
                  child: const Text('Code lu'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> scan(WidgetTester tester) async {
    await tester.runAsync(() async => tester.tap(find.text('Code lu')));
    await settle(tester);
  }

  /// Une bière avec un lot de 33 cl portant [code], et [stock] bouteilles.
  Future<({String drinkId, String lotId})> beer(
    WidgetTester tester, {
    String? barcode = code,
    int stock = 3,
  }) async {
    return (await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      return repo.addNewDrink(
        drink: DrinkInput(name: 'Bière Test', typeId: types[1].id),
        volumeMl: 330,
        quantity: stock,
        barcode: barcode,
      );
    }))!;
  }

  Future<int> stockOf(WidgetTester tester, String lotId) async =>
      (await tester.runAsync(() async => (await repo.lot(lotId))!.stock))!;

  testWidgets('code connu : « −1 » retire une bouteille, avec Annuler', (
    tester,
  ) async {
    final ids = await beer(tester);
    await open(tester, code);
    await scan(tester);

    expect(find.text('Bière Test'), findsOneWidget);
    expect(find.textContaining('3 bouteilles'), findsOneWidget);
    await tester.runAsync(() async => tester.tap(find.text('−1')));
    await settle(tester);

    expect(await stockOf(tester, ids.lotId), 2);
    expect(find.text('Annuler'), findsOneWidget);
  });

  testWidgets('code connu : « Ajouter » ajoute des bouteilles', (tester) async {
    final ids = await beer(tester);
    await open(tester, code);
    await scan(tester);

    await tester.runAsync(() async => tester.tap(find.text('Ajouter')));
    await settle(tester);
    await tester.tap(find.byTooltip('Plus'));
    await tester.pump();
    await tester.runAsync(() async => tester.tap(find.text('Enregistrer')));
    await settle(tester);

    expect(await stockOf(tester, ids.lotId), 5);
  });

  testWidgets('lot épuisé : « −1 » impossible, « Ajouter » possible', (
    tester,
  ) async {
    final ids = await beer(tester, stock: 1);
    await tester.runAsync(() => repo.addExit(ids.lotId, 1));
    await open(tester, code);
    await scan(tester);

    final minus = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '−1'),
    );
    expect(minus.onPressed, isNull);
    expect(find.text('Ajouter'), findsOneWidget);
  });

  testWidgets('code inconnu : nouvelle référence, code mémorisé', (
    tester,
  ) async {
    await open(tester, code);
    await scan(tester);
    expect(find.text('Code inconnu'), findsOneWidget);

    await tester.runAsync(
      () async => tester.tap(find.text('Nouvelle référence avec ce code')),
    );
    await settle(tester);
    expect(find.text('Code-barres : $code'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('field-name')),
      'Nouvelle bière',
    );
    // Bière : pas d'appellation ni de région exigées pour l'enregistrement.
    final save = find.text('Enregistrer');
    await tester.ensureVisible(save);
    await tester.runAsync(() async => tester.tap(save));
    await settle(tester);

    final found = (await tester.runAsync(() => repo.lotsByBarcode(code)))!;
    expect(found.single.drink.name, 'Nouvelle bière');
  });

  testWidgets('code inconnu, hors ligne : on le dit, fiche vide', (
    tester,
  ) async {
    await open(tester, code);
    await scan(tester);
    expect(
      find.textContaining('Hors ligne : pas de recherche sur Open Food Facts'),
      findsOneWidget,
    );
  });

  testWidgets('code connu d\'Open Food Facts : fiche pré-remplie', (
    tester,
  ) async {
    await open(
      tester,
      code,
      product: {
        'product_name': 'IPA Imaginaire',
        'brands': 'Brasserie Inventée',
        'quantity': '33 cl',
        'categories_tags': ['en:beers', 'en:india-pale-ales'],
        'nutriments': {'alcohol': 6.5},
      },
    );
    await scan(tester);

    expect(find.text('IPA Imaginaire'), findsOneWidget);
    expect(find.textContaining('Brasserie Inventée'), findsOneWidget);
    await tester.runAsync(
      () async =>
          tester.tap(find.text('Nouvelle référence avec ces informations')),
    );
    await settle(tester);

    // Le formulaire est pré-rempli : il suffit de valider.
    expect(find.text('IPA Imaginaire'), findsOneWidget);
    expect(find.text('6,5'), findsOneWidget);
    final save = find.text('Enregistrer');
    await tester.ensureVisible(save);
    await tester.runAsync(() async => tester.tap(save));
    await settle(tester);

    final found = (await tester.runAsync(() => repo.lotsByBarcode(code)))!;
    final drink = found.single.drink;
    expect(drink.name, 'IPA Imaginaire');
    expect(drink.producer, 'Brasserie Inventée');
    expect(drink.abv, 6.5);
    expect(found.single.lot.volumeMl, 330);
    final types = (await tester.runAsync(() => repo.drinkTypes()))!;
    expect(drink.typeId, types[1].id, reason: 'type Bière');
    final characteristics = (await tester.runAsync(
      () => repo.drinkCharacteristicIds(drink.id),
    ))!;
    expect(characteristics, hasLength(1), reason: 'IPA');
  });

  testWidgets('produit trouvé et référence proche : on lui associe le code', (
    tester,
  ) async {
    final ids = await beer(tester, barcode: null);
    await open(
      tester,
      code,
      product: {
        'product_name': 'Biere test',
        'quantity': '33 cl',
        'categories_tags': ['en:beers'],
      },
    );
    await scan(tester);

    expect(find.text('Déjà dans votre cave ?'), findsOneWidget);
    await tester.runAsync(() async => tester.tap(find.text('Bière Test')));
    await settle(tester);
    // Un seul lot : choisi dans la liste des lots de la référence.
    await tester.runAsync(
      () async => tester.tap(find.textContaining('33 cl').last),
    );
    await settle(tester);

    expect(find.text('−1'), findsOneWidget);
    final lot = (await tester.runAsync(() => repo.lot(ids.lotId)))!;
    expect(lot.barcode, code);
  });

  testWidgets('code inconnu : associé à un lot existant, puis « −1 »', (
    tester,
  ) async {
    final ids = await beer(tester, barcode: null);
    await open(tester, code);
    await scan(tester);

    await tester.runAsync(
      () async => tester.tap(find.text('Associer à une référence existante')),
    );
    await settle(tester);
    await tester.runAsync(() async => tester.tap(find.text('Bière Test')));
    await settle(tester);
    expect(find.text('Associer le code à quel lot ?'), findsOneWidget);
    await tester.runAsync(
      () async => tester.tap(find.textContaining('33 cl').last),
    );
    await settle(tester);

    // Le résultat s'affiche comme pour un code connu.
    expect(find.text('−1'), findsOneWidget);
    final lot = (await tester.runAsync(() => repo.lot(ids.lotId)))!;
    expect(lot.barcode, code);
  });
}
