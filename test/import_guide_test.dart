import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/features/exchange/exchange_actions.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late CaveDatabase db;

  setUp(() => db = memoryDatabase());
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

  testWidgets('Importer → consignes du fichier à préparer', (tester) async {
    // Écran haut : toutes les consignes sont construites.
    tester.view.physicalSize = const Size(1600, 6000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(TestContext()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => startImport(context, ref),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Choisir le fichier'), findsOneWidget);

    await tester.tap(find.text('Préparer un fichier dans un tableur'));
    await settle(tester);
    expect(find.text('Préparer un fichier d\'import'), findsOneWidget);
    expect(find.text('Obtenir le fichier modèle'), findsOneWidget);
    expect(find.text('Volume (ml)'), findsOneWidget);
    // La classification de la cave est listée, avec ses valeurs.
    expect(find.text('Vin'), findsOneWidget);
    expect(find.textContaining('Robe : Rouge, '), findsOneWidget);

    await tester.tap(find.text('Obtenir le fichier modèle'));
    await tester.pumpAndSettle();
    expect(find.text('Fichier modèle'), findsOneWidget);
    expect(find.text('Partager'), findsOneWidget);
  });
}
