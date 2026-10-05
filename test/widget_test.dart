import 'package:cave/app.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
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
  ],
  child: const CaveApp(),
);

void main() {
  late CaveDatabase db;
  late TestContext ctx;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
  });
  tearDown(() => db.close());

  testWidgets("l'écran d'accueil affiche les textes français", (tester) async {
    await tester.pumpWidget(testApp(db, ctx));
    await tester.pumpAndSettle();

    expect(find.text('Ma Cave'), findsOneWidget);
    expect(find.text('Votre cave est vide'), findsOneWidget);
    expect(find.text('Aucune bouteille'), findsOneWidget);
  });

  testWidgets('le thème suit le réglage clair / sombre du système', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(testApp(db, ctx));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets("l'accueil affiche le nombre de bouteilles de la base", (
    tester,
  ) async {
    await tester.runAsync(() async {
      final repo = CaveRepository(db, ctx);
      final types = await repo.drinkTypes();
      final drinkId = await repo.createDrink(
        DrinkInput(name: 'Bière Test', typeId: types[1].id),
      );
      final lotId = await repo.findOrCreateLot(drinkId: drinkId, volumeMl: 330);
      await repo.addEntry(lotId, 3);
    });
    await tester.pumpWidget(testApp(db, ctx));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text('3 bouteilles'), findsOneWidget);
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
