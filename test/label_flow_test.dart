import 'dart:io';

import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/domain/label_reading.dart';
import 'package:cave/features/drink/drink_form_screen.dart';
import 'package:cave/features/label/label_flow.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/scan/label_recognizer.dart';
import 'package:cave/scan/providers.dart';
import 'package:cave/sync/providers.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Moteur factice : rend toujours les mêmes lignes, et note les photos lues.
class FakeRecognizer implements LabelRecognizer {
  FakeRecognizer(this.lines);

  final List<LabelLine> lines;
  final read = <String>[];

  @override
  Future<List<LabelLine>> recognize(String imagePath) async {
    read.add(imagePath);
    return lines;
  }

  @override
  Future<void> close() async {}
}

// Étiquette inventée.
const _label = [
  LabelLine('GRAND VIN DE BORDEAUX', height: 20),
  LabelLine('CHÂTEAU DES LUNES', height: 80),
  LabelLine('2019', height: 30),
  LabelLine('SAINT-ÉMILION GRAND CRU', height: 25),
  LabelLine('Mis en bouteille par SCEA Lunaire à Saint-Truc', height: 10),
  LabelLine('14% vol.', height: 10),
  LabelLine('750 ml', height: 10),
];

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late Directory root;
  late File photo;
  late FakeRecognizer recognizer;
  late MemoryLocalStore store;

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
    root = Directory.systemTemp.createTempSync('cave_label');
    photo = File('${root.path}/photo.jpg')..writeAsBytesSync([1, 2, 3]);
  });
  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

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
    WidgetTester tester, {
    List<LabelLine> lines = _label,
  }) async {
    recognizer = FakeRecognizer(lines);
    store = MemoryLocalStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          localSyncEnvironment(db, ctx),
          labelRecognizerProvider.overrideWithValue(recognizer),
          localStoreProvider.overrideWithValue(store),
          labelPhotoProvider.overrideWithValue((_) async => photo.path),
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
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    // Une liste ne construit que ce qui est à l'écran : on fait défiler.
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.runAsync(() async => tester.tap(finder));
    await settle(tester);
  }

  testWidgets('la vraie liste INAO est embarquée et utilisable', (
    tester,
  ) async {
    final index = AppellationIndex.parse(
      (await tester.runAsync(
        () => rootBundle.loadString('assets/appellations.txt'),
      ))!,
    );
    expect(index.length, greaterThan(1000));
    expect(
      index.find('APPELLATION SAINT-ÉMILION GRAND CRU CONTRÔLÉE'),
      'Saint-Emilion grand cru',
    );
    expect(index.find('Cotes du Rhone'), 'Côtes du Rhône');
  });

  testWidgets('étiquette lue, corrigée, puis fiche enregistrée', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.text('Lire l\'étiquette'));

    // Lecture : suggestions affichées, photo supprimée.
    expect(find.text('Lecture de l\'étiquette'), findsOneWidget);
    expect(find.text('Château des Lunes'), findsWidgets);
    expect(find.text('Saint-Emilion grand cru'), findsOneWidget);
    expect(find.text('2019'), findsWidgets);
    expect(recognizer.read, [photo.path]);
    expect(photo.existsSync(), isFalse);

    // Le producteur n'a pas été bien coupé : on prend une autre ligne.
    await tap(tester, find.text('Grand Vin de Bordeaux'));
    await tap(tester, find.text('Utiliser comme producteur'));

    await tap(tester, find.text('Continuer avec ces informations'));
    // Formulaire pré-rempli.
    expect(find.text('Château des Lunes'), findsOneWidget);
    expect(find.text('France'), findsOneWidget);
    await tap(tester, find.text('Enregistrer'));

    final drink = (await tester.runAsync(
      () => db.select(db.drinks).getSingle(),
    ))!;
    expect(drink.name, 'Château des Lunes');
    // Ligne en capitales remise en forme.
    expect(drink.producer, 'Grand Vin de Bordeaux');
    expect(drink.appellation, 'Saint-Emilion grand cru');
    expect(drink.country, 'France');
    expect(drink.abv, 14);
    expect(drink.needsCompletion, isFalse);
    final lot = (await tester.runAsync(() => repo.lotsOf(drink.id)))!.single;
    expect(lot.vintage, 2019);
    expect(lot.volumeMl, 750);
  });

  testWidgets('nom en plusieurs lignes : « Ajouter à la suite du nom »', (
    tester,
  ) async {
    await open(
      tester,
      lines: const [
        LabelLine('LES TROIS', height: 80),
        LabelLine('2019', height: 30),
        LabelLine('CHÊNES', height: 60),
      ],
    );
    await tap(tester, find.text('Lire l\'étiquette'));
    expect(find.text('Les Trois'), findsWidgets);
    // Nom suggéré : « Les Trois » (le plus gros) ; pas de producteur, donc
    // rien à quoi ajouter de ce côté.
    await tap(tester, find.text('Chênes'));
    expect(find.text('Ajouter à la suite du nom'), findsOneWidget);
    expect(find.text('Ajouter à la suite du producteur'), findsNothing);
    expect(find.text('Les Trois Chênes'), findsOneWidget); // aperçu
    await tap(tester, find.text('Ajouter à la suite du nom'));

    await tap(tester, find.text('Continuer avec ces informations'));
    expect(find.text('Les Trois Chênes'), findsOneWidget);
  });

  testWidgets('référence déjà dans la cave : bouteilles ajoutées', (
    tester,
  ) async {
    final existing = (await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      return (await repo.addNewDrink(
        drink: DrinkInput(name: 'Château des Lunes', typeId: types.first.id),
        volumeMl: 750,
        vintage: 2018,
        quantity: 2,
      )).drinkId;
    }))!;
    await open(tester);
    await tap(tester, find.text('Lire l\'étiquette'));

    expect(find.text('Déjà dans votre cave ?'), findsOneWidget);
    // La référence existante (sous « Déjà dans votre cave ? »).
    await tap(tester, find.widgetWithIcon(ListTile, Icons.add_circle_outline));
    // Fenêtre « nouveau lot » : millésime lu sur l'étiquette.
    final vintage = tester.widget<TextFormField>(
      find.byKey(const Key('field-vintage')).last,
    );
    expect(vintage.controller!.text, '2019');
    await tap(tester, find.text('Enregistrer').last);

    final lots = (await tester.runAsync(() => repo.lotsOf(existing)))!;
    expect(lots.map((l) => (l.vintage, l.stock)), [(2018, 2), (2019, 1)]);
    expect(
      (await tester.runAsync(() => db.select(db.drinks).get()))!,
      hasLength(1),
    );
  });

  testWidgets('étiquette mal lue : la référence de la cave est proposée', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      await repo.addNewDrink(
        drink: DrinkInput(name: 'Château des Lunes', typeId: types.first.id),
        volumeMl: 750,
        quantity: 2,
      );
    });
    await open(
      tester,
      lines: const [
        // Le plus gros texte n'est pas le nom, et le nom est mal lu.
        LabelLine('GRAND VIN', height: 90),
        LabelLine('CHATEAU DE5 LUNE5', height: 40),
        LabelLine('2019', height: 20),
      ],
    );
    await tap(tester, find.text('Lire l\'étiquette'));

    expect(find.text('Déjà dans votre cave ?'), findsOneWidget);
    expect(find.text('Château des Lunes'), findsOneWidget);
  });

  testWidgets('rien de lu : message, formulaire inchangé', (tester) async {
    await open(tester, lines: const []);
    await tap(tester, find.text('Lire l\'étiquette'));

    expect(find.textContaining('Aucun texte lu'), findsOneWidget);
    expect(photo.existsSync(), isFalse);
  });

  testWidgets('saisie commencée : l\'étiquette ne l\'écrase pas', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byKey(const Key('field-name')), 'Mon nom');
    await tap(tester, find.text('Lire l\'étiquette'));
    await tap(tester, find.text('Continuer avec ces informations'));

    expect(find.text('Mon nom'), findsOneWidget);
    expect(find.text('Saint-Emilion grand cru'), findsOneWidget);
  });
}
