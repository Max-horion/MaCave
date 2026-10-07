import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/settings/classification_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
  });
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.runAsync(() async => tester.tap(finder));
    await settle(tester);
  }

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClassificationScreen(),
        ),
      ),
    );
    await settle(tester);
  }

  /// Tape un nom dans la fenêtre ouverte et valide.
  Future<void> enterName(WidgetTester tester, String name) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      name,
    );
    await tap(tester, find.text('Valider'));
  }

  Future<List<String>> typeNames(WidgetTester tester) async =>
      (await tester.runAsync(
        () async => (await db.select(db.drinkTypes).get())
            .where((t) => t.deletedAt == null)
            .map((t) => t.name)
            .toList(),
      ))!;

  testWidgets('créer un type, une famille et une valeur, puis supprimer', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Vin'), findsOneWidget);

    await tap(tester, find.text('Ajouter un type'));
    await tap(tester, find.text('Comme une bière'));
    await enterName(tester, 'Cidre');
    expect(await typeNames(tester), contains('Cidre'));
    expect(find.text('Comme une bière · 75 cl'), findsWidgets);

    await tap(tester, find.text('Cidre'));
    expect(find.text('Aucune famille pour ce type.'), findsOneWidget);
    await tap(tester, find.text('Ajouter une famille'));
    await enterName(tester, 'Style');
    expect(find.text('Style'), findsOneWidget);
    expect(find.text('Aucune valeur'), findsOneWidget);

    await tap(tester, find.text('Ajouter'));
    await enterName(tester, 'Brut');
    expect(find.text('Brut'), findsOneWidget);

    // Même nom dans la même famille, aux accents et majuscules près : refusé.
    await tap(tester, find.text('Ajouter'));
    await enterName(tester, 'BRUT');
    expect(find.text('Ce nom existe déjà ici'), findsOneWidget);
    await tap(tester, find.text('Annuler'));

    await tap(tester, find.byTooltip('Supprimer'));
    expect(find.text('Supprimer le type « Cidre » ?'), findsOneWidget);
    expect(
      find.textContaining('Aucune référence n\'est concernée.'),
      findsOneWidget,
    );
    await tap(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Supprimer'),
      ),
    );
    expect(find.text('Ajouter un type'), findsOneWidget);
    expect(find.text('Cidre'), findsNothing);
    expect(await typeNames(tester), isNot(contains('Cidre')));
  });

  testWidgets('renommer une valeur existante', (tester) async {
    await open(tester);
    await tap(tester, find.text('Bière'));
    final blonde = find.ancestor(
      of: find.text('Blonde'),
      matching: find.byType(ListTile),
    );
    await tap(
      tester,
      find.descendant(
        of: blonde,
        matching: find.byType(PopupMenuButton<VoidCallback>),
      ),
    );
    await tap(tester, find.text('Renommer'));
    await enterName(tester, 'Dorée');
    expect(find.text('Dorée'), findsOneWidget);
    expect(find.text('Blonde'), findsNothing);
  });
}
