import 'package:cave/app.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/cellar/cellar_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// L'application branchée sur une base en mémoire.
Widget testApp(CaveDatabase db, TestContext ctx) => ProviderScope(
  overrides: [
    databaseProvider.overrideWithValue(db),
    writeContextProvider.overrideWithValue(ctx),
    localSyncEnvironment(db, ctx),
  ],
  child: const CaveApp(),
);

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

  /// Ajoute une bière fictive avec un lot par volume donné.
  Future<String> addBeer(
    WidgetTester tester,
    String name, {
    Map<int, int> stockByVolume = const {330: 3},
  }) async {
    late String id;
    await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      id = await repo.createDrink(DrinkInput(name: name, typeId: types[1].id));
      for (final MapEntry(key: volume, value: stock) in stockByVolume.entries) {
        final lot = await repo.findOrCreateLot(drinkId: id, volumeMl: volume);
        await repo.addEntry(lot, stock);
      }
    });
    return id;
  }

  /// Laisse la base répondre puis redessine l'écran. Plusieurs tours, car
  /// un écran qui s'ouvre lance ses propres lectures après le premier dessin.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  /// Fait défiler l'écran pour amener l'élément bien en vue.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<int> stockOf(WidgetTester tester, String drinkId) async {
    late int stock;
    await tester.runAsync(() async {
      final lots = await repo.lotsOf(drinkId);
      stock = lots.fold(0, (s, l) => s + l.stock);
    });
    return stock;
  }

  testWidgets('cave vide : message d\'accueil en français', (tester) async {
    await tester.pumpWidget(testApp(db, ctx));
    await settle(tester);

    expect(find.text('Ma Cave'), findsOneWidget);
    expect(find.text('Votre cave est vide'), findsOneWidget);
    expect(
      find.text('Aucune bouteille · Aucune référence en stock'),
      findsOneWidget,
    );
  });

  testWidgets('le thème suit le réglage clair / sombre du système', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(testApp(db, ctx));
    await settle(tester);

    final context = tester.element(find.byType(CellarScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('la liste affiche les références et leur stock', (tester) async {
    await addBeer(tester, 'Bière Imaginaire');
    await tester.pumpWidget(testApp(db, ctx));
    await settle(tester);

    expect(find.text('Bière Imaginaire'), findsOneWidget);
    expect(find.text('3 bouteilles · 1 référence en stock'), findsOneWidget);
    expect(find.textContaining('33 cl'), findsOneWidget);
  });

  testWidgets('« −1 » retire une bouteille, « Annuler » la remet', (
    tester,
  ) async {
    final id = await addBeer(tester, 'Bière Imaginaire');
    await tester.pumpWidget(testApp(db, ctx));
    await settle(tester);

    await tester.tap(find.byTooltip('Retirer une bouteille'));
    await settle(tester);
    expect(await stockOf(tester, id), 2);
    expect(find.text('Bouteille retirée'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await settle(tester);
    expect(await stockOf(tester, id), 3);
  });

  testWidgets('« −1 » avec plusieurs lots : choix du lot', (tester) async {
    final id = await addBeer(
      tester,
      'Bière Imaginaire',
      stockByVolume: {330: 2, 750: 1},
    );
    await tester.pumpWidget(testApp(db, ctx));
    await settle(tester);

    await tester.tap(find.byTooltip('Retirer une bouteille'));
    await settle(tester);
    expect(find.text('Quelle bouteille ?'), findsOneWidget);

    await tester.tap(find.text('Sans millésime · 75 cl'));
    await settle(tester);
    late List<Lot> lots;
    await tester.runAsync(() async => lots = await repo.lotsOf(id));
    expect({for (final l in lots) l.volumeMl: l.stock}, {330: 2, 750: 0});
  });

  testWidgets('la recherche filtre la liste', (tester) async {
    await addBeer(tester, 'Bière Imaginaire');
    await addBeer(tester, 'Ambrée Fictive');
    await tester.pumpWidget(testApp(db, ctx));
    await settle(tester);

    await tester.enterText(find.byType(SearchBar), 'ambree');
    await settle(tester);
    expect(find.text('Ambrée Fictive'), findsOneWidget);
    expect(find.text('Bière Imaginaire'), findsNothing);

    await tester.enterText(find.byType(SearchBar), 'zzz');
    await settle(tester);
    expect(find.text('Aucun résultat'), findsOneWidget);
  });

  testWidgets('ajout d\'une boisson par le formulaire', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(testApp(db, ctx));
    await settle(tester);

    await tester.tap(find.text('Ajouter'));
    await settle(tester);
    expect(find.text('Nouvelle boisson'), findsOneWidget);

    // Enregistrer sans nom : refusé.
    await scrollTo(tester, find.byKey(const Key('save-drink')));
    await tester.tap(find.byKey(const Key('save-drink')));
    await settle(tester);
    await scrollTo(tester, find.byKey(const Key('field-name')));
    expect(find.text('Champ obligatoire'), findsOneWidget);

    await scrollTo(tester, find.byKey(const Key('field-name')));
    await tester.enterText(find.byKey(const Key('field-name')), 'Vin Test');
    await scrollTo(tester, find.byKey(const Key('field-vintage')));
    await tester.enterText(find.byKey(const Key('field-vintage')), '2018');
    await scrollTo(tester, find.byTooltip('Plus'));
    await tester.tap(find.byTooltip('Plus'));
    await tester.pump();
    await scrollTo(tester, find.byKey(const Key('save-drink')));
    await tester.tap(find.byKey(const Key('save-drink')));
    await settle(tester);

    // La fiche créée s'affiche, marquée « à compléter » (vin sans région ni pays).
    expect(find.text('Vin Test'), findsOneWidget);
    expect(find.text('2018 · 75 cl'), findsOneWidget);
    expect(find.text('2 bouteilles'), findsOneWidget);
    expect(
      find.text('Il manque des informations obligatoires sur cette fiche.'),
      findsOneWidget,
    );
  });

  test('le pluriel des bouteilles est accordé', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(l10n.bottleCount(1), '1 bouteille');
    expect(l10n.bottleCount(3), '3 bouteilles');
  });

  test('les boutons font au moins 56 dp de haut', () {
    final size = AppTheme.light.filledButtonTheme.style!.minimumSize!.resolve(
      {},
    );
    expect(size!.height, greaterThanOrEqualTo(AppTheme.minButtonHeight));
  });
}
