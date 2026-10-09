import 'package:cave/app.dart';
import 'package:cave/data/app_preferences.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/domain/drink_filter.dart';
import 'package:cave/features/cellar/cellar_screen.dart';
import 'package:cave/sync/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('préférences de l\'appareil', () {
    test('valeurs par défaut quand rien n\'est enregistré', () async {
      final prefs = await AppPreferences.load(MemoryLocalStore());
      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.textScale, 1.0);
      expect(prefs.defaultSort, DrinkSort.name);
      expect(prefs.showExhausted, isFalse);
      expect(prefs.undoDuration, const Duration(seconds: 6));
      expect(prefs.openFoodFacts, isTrue);
    });

    test('enregistrées puis relues', () async {
      final store = MemoryLocalStore();
      await const AppPreferences(
        themeMode: ThemeMode.dark,
        textScale: 1.3,
        defaultSort: DrinkSort.vintage,
        showExhausted: true,
        undoSeconds: 15,
        openFoodFacts: false,
      ).save(store);
      final prefs = await AppPreferences.load(store);
      expect(prefs.themeMode, ThemeMode.dark);
      expect(prefs.textScale, 1.3);
      expect(prefs.defaultSort, DrinkSort.vintage);
      expect(prefs.showExhausted, isTrue);
      expect(prefs.undoSeconds, 15);
      expect(prefs.openFoodFacts, isFalse);
    });

    test('valeur illisible : valeur par défaut', () async {
      final store = MemoryLocalStore()
        ..values.addAll({
          'pref_theme': 'violet',
          'pref_text_scale': '7',
          'pref_undo_seconds': 'abc',
        });
      final prefs = await AppPreferences.load(store);
      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.textScale, 1.0);
      expect(prefs.undoSeconds, 6);
    });

    test('la liste s\'ouvre avec le tri et les épuisés réglés', () {
      final container = ProviderContainer(
        overrides: [
          initialAppPreferencesProvider.overrideWithValue(
            const AppPreferences(
              defaultSort: DrinkSort.stock,
              showExhausted: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final filter = container.read(drinkFilterProvider);
      expect(filter.sort, DrinkSort.stock);
      expect(filter.showExhausted, isTrue);

      final notifier = container.read(drinkFilterProvider.notifier);
      notifier.change((f) => f.copyWith(showExhausted: false));
      notifier.clearFilters();
      expect(
        container.read(drinkFilterProvider).showExhausted,
        isTrue,
        reason: '« Effacer les filtres » revient au réglage',
      );
    });
  });

  group('écran', () {
    late CaveDatabase db;
    late TestContext ctx;
    late MemoryLocalStore store;

    setUp(() {
      db = memoryDatabase();
      ctx = TestContext();
      store = MemoryLocalStore();
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
      // Écran en ListView : les lignes hors écran ne sont pas construites.
      if (finder.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          finder,
          200,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('settings-list')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
      }
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.runAsync(() async => tester.tap(finder));
      await settle(tester);
    }

    Future<void> openSettings(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            writeContextProvider.overrideWithValue(ctx),
            localSyncEnvironment(db, ctx),
            localStoreProvider.overrideWithValue(store),
          ],
          child: const CaveApp(),
        ),
      );
      await settle(tester);
      await tap(tester, find.byTooltip("Plus d'actions"));
      await tap(tester, find.text('Paramètres'));
      expect(find.text('Apparence'), findsOneWidget);
    }

    testWidgets('thème sombre : appliqué tout de suite et enregistré', (
      tester,
    ) async {
      await openSettings(tester);
      await tap(tester, find.text('Thème'));
      await tap(tester, find.text('Sombre'));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      final context = tester.element(find.text('Thème'));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(store.values['pref_theme'], 'dark');
    });

    testWidgets('tri par millésime, Open Food Facts désactivé', (tester) async {
      await openSettings(tester);
      await tap(tester, find.text("Tri à l'ouverture"));
      await tap(tester, find.text('Millésime'));
      expect(store.values['pref_default_sort'], 'vintage');

      await tap(tester, find.text('Recherche sur Open Food Facts'));
      expect(store.values['pref_open_food_facts'], 'false');
    });

    testWidgets('lecteur de codes-barres : ML Kit retenu sur l\'appareil', (
      tester,
    ) async {
      await openSettings(tester);
      await tap(tester, find.text('Lecteur de codes-barres (essai)'));
      await tap(tester, find.text('ML Kit'));
      expect(store.values['barcode_engine'], 'mlKit');
    });

    testWidgets('volume par défaut changé depuis les paramètres', (
      tester,
    ) async {
      await openSettings(tester);
      await tap(tester, find.text('Bière'));
      await tap(tester, find.text('33 cl'));
      final beer = await tester.runAsync(
        () async => (await db.select(db.drinkTypes).get()).firstWhere(
          (t) => t.name == 'Bière',
        ),
      );
      expect(beer!.defaultVolumeMl, 330);
    });

    testWidgets('liens : synchronisation, puis retour', (tester) async {
      await openSettings(tester);
      await tap(tester, find.text('Synchronisation'));
      expect(find.text('Activer la synchronisation'), findsOneWidget);
      await tap(tester, find.byTooltip('Retour'));
      expect(find.text('Activer la synchronisation'), findsNothing);
      expect(find.text('Sauvegardes'), findsOneWidget);
      expect(find.byType(CellarScreen), findsNothing);
    });
  });
}
