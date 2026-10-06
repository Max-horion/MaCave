import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/drink/drink_form_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

// Doublons à la création d'une référence (CDC §6.2).
void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late String existing;

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

  /// Le formulaire de création, avec « Château Figeac » déjà dans la cave.
  Future<void> open(WidgetTester tester) async {
    existing = (await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      final ids = await repo.addNewDrink(
        drink: DrinkInput(
          name: 'Château Figeac',
          typeId: types.first.id,
          region: 'Bordeaux',
        ),
        volumeMl: 750,
        quantity: 2,
      );
      return ids.drinkId;
    }))!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          localSyncEnvironment(db, ctx),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DrinkFormScreen(),
        ),
      ),
    );
    await settle(tester);
    await tester.enterText(find.byKey(const Key('field-name')), 'Ch. Figeac');
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.text('Enregistrer');
    await tester.ensureVisible(button);
    await tester.runAsync(() async => tester.tap(button));
    await settle(tester);
  }

  Future<List<Drink>> drinks(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.drinks).get()))!;

  testWidgets('référence proche : les bouteilles y sont ajoutées', (
    tester,
  ) async {
    await open(tester);
    await save(tester);

    expect(find.text('Référence proche déjà dans la cave'), findsOneWidget);
    await tester.runAsync(() async => tester.tap(find.text('Château Figeac')));
    await settle(tester);

    expect(await drinks(tester), hasLength(1));
    final lots = (await tester.runAsync(() => repo.lotsOf(existing)))!;
    expect(lots.single.stock, 3);
  });

  testWidgets('« Créer une nouvelle référence » : créée quand même', (
    tester,
  ) async {
    await open(tester);
    await save(tester);
    await tester.runAsync(
      () async => tester.tap(find.text('Créer une nouvelle référence')),
    );
    await settle(tester);

    expect((await drinks(tester)).map((d) => d.name), [
      'Château Figeac',
      'Ch. Figeac',
    ]);
  });

  testWidgets('« Revenir au formulaire » : rien n\'est enregistré', (
    tester,
  ) async {
    await open(tester);
    await save(tester);
    await tester.tap(find.text('Revenir au formulaire'));
    await settle(tester);

    expect(await drinks(tester), hasLength(1));
    expect(find.text('Ch. Figeac'), findsOneWidget);
    // Le bouton est de nouveau actif.
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Enregistrer'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(button.onPressed, isNotNull);
  });
}
