import 'package:cave/app.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/cellar/cellar_screen.dart';
import 'package:cave/features/welcome/welcome_screen.dart';
import 'package:cave/sync/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late MemoryLocalStore store;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
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

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          localSyncEnvironment(db, ctx),
          localStoreProvider.overrideWithValue(store),
        ],
        child: const CaveApp(firstLaunch: true),
      ),
    );
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.runAsync(() async => tester.tap(find.text(text)));
    await settle(tester);
  }

  testWidgets('cave neuve : les trois étapes, puis la liste', (tester) async {
    await open(tester);
    expect(find.text('Étape 1 sur 3'), findsOneWidget);
    expect(find.text('Où ranger votre cave ?'), findsOneWidget);

    // Mode local : l'alerte « données sur cet appareil » (CDC §8.4).
    await tap(tester, 'Sur cet appareil uniquement');
    expect(find.text('Données sur cet appareil seulement'), findsOneWidget);
    await tap(tester, "J'ai compris");

    expect(find.text('Étape 2 sur 3'), findsOneWidget);
    expect(find.text('Votre cave est encore vide.'), findsOneWidget);
    await tap(tester, 'Passer');

    // Volumes par défaut : la bière passe à 33 cl.
    expect(find.text('Étape 3 sur 3'), findsOneWidget);
    await tap(tester, 'Bière');
    expect(find.text('Volume par défaut : Bière'), findsOneWidget);
    await tap(tester, '33 cl');
    final beer = await tester.runAsync(
      () async =>
          (await repo.drinkTypes()).firstWhere((t) => t.name == 'Bière'),
    );
    expect(beer!.defaultVolumeMl, 330);
    expect(find.text('33 cl'), findsOneWidget);

    await tap(tester, 'Commencer');
    expect(find.byType(CellarScreen), findsOneWidget);
    expect(store.values[welcomeDoneKey], isNotNull);
  });

  testWidgets('retour arrière, alerte du mode local montrée une seule fois', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'Passer');
    expect(find.text('Données sur cet appareil seulement'), findsOneWidget);
    await tap(tester, "J'ai compris");
    expect(find.text('Étape 2 sur 3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    expect(find.text('Étape 1 sur 3'), findsOneWidget);
    await tap(tester, 'Passer');
    expect(find.text('Étape 2 sur 3'), findsOneWidget);
  });

  testWidgets('cave déjà remplie (mise à jour) : directement la liste', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      await repo.createDrink(DrinkInput(name: 'Bière', typeId: types[1].id));
    });
    await open(tester);
    expect(find.byType(CellarScreen), findsOneWidget);
    expect(find.text('Étape 1 sur 3'), findsNothing);
    expect(store.values[welcomeDoneKey], isNotNull);
  });
}
