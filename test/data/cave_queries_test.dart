import 'package:cave/data/cave_queries.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/domain/drink_filter.dart';
import 'package:cave/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  late CaveQueries queries;
  late Classification classification;
  late String wine;
  late String beer;

  String characteristic(String name) => classification.types
      .expand((t) => classification.familiesOf(t.id))
      .expand((f) => classification.valuesOf(f.id))
      .firstWhere((c) => c.name == name)
      .id;

  /// Crée une référence avec un lot de [stock] bouteilles.
  Future<String> add(
    String name, {
    required String typeId,
    String? appellation,
    String? region,
    int? vintage,
    int stock = 1,
    bool favorite = false,
    Set<String> characteristics = const {},
  }) async {
    final id = await repo.createDrink(
      DrinkInput(
        name: name,
        typeId: typeId,
        appellation: appellation,
        region: region,
        favorite: favorite,
      ),
    );
    await repo.setDrinkCharacteristics(id, characteristics);
    final lot = await repo.findOrCreateLot(
      drinkId: id,
      volumeMl: 750,
      vintage: vintage,
    );
    if (stock > 0) await repo.addEntry(lot, stock);
    return id;
  }

  Future<List<String>> names(DrinkFilter filter) async =>
      (await queries.watchDrinkList(filter).first)
          .map((i) => i.drink.name)
          .toList();

  setUp(() async {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
    queries = CaveQueries(db);
    classification = await queries.watchClassification().first;
    wine = classification.types
        .firstWhere((t) => t.fieldProfile == FieldProfile.wine)
        .id;
    beer = classification.types
        .firstWhere((t) => t.fieldProfile == FieldProfile.beer)
        .id;

    await add(
      'Château Exemple',
      typeId: wine,
      appellation: 'Saint-Émilion',
      region: 'Bordeaux',
      vintage: 2015,
      stock: 3,
      characteristics: {characteristic('Rouge'), characteristic('Sec')},
    );
    await add(
      'Échezeaux Test',
      typeId: wine,
      appellation: 'Échezeaux',
      region: 'Bourgogne',
      vintage: 2019,
      stock: 1,
      favorite: true,
      characteristics: {characteristic('Rouge')},
    );
    await add(
      'Blanc Fictif',
      typeId: wine,
      region: 'Alsace',
      vintage: 2010,
      stock: 6,
      characteristics: {characteristic('Blanc')},
    );
    await add('Bière Imaginaire', typeId: beer, stock: 2);
    await add('Vin Bu', typeId: wine, appellation: 'X', region: 'Y', stock: 0);
  });
  tearDown(() => db.close());

  group('recherche plein texte', () {
    test('insensible aux accents et à la casse', () async {
      expect(await names(const DrinkFilter(query: 'saint emilion')), [
        'Château Exemple',
      ]);
      expect(await names(const DrinkFilter(query: 'ECHEZ')), [
        'Échezeaux Test',
      ]);
    });

    test('début de mot, plusieurs mots combinés', () async {
      expect(await names(const DrinkFilter(query: 'chat ex')), [
        'Château Exemple',
      ]);
      expect(await names(const DrinkFilter(query: 'chat bourg')), isEmpty);
    });

    test('cherche aussi dans la région', () async {
      expect(await names(const DrinkFilter(query: 'alsace')), ['Blanc Fictif']);
    });

    test('caractères spéciaux sans erreur', () async {
      expect(await names(const DrinkFilter(query: '"*-:(')), hasLength(4));
    });

    test('suit les modifications de la fiche', () async {
      final id =
          (await queries
                  .watchDrinkList(const DrinkFilter(query: 'imaginaire'))
                  .first)
              .single
              .drink
              .id;
      await repo.updateDrink(
        id,
        DrinkInput(name: 'Bière Renommée', typeId: beer),
      );
      expect(await names(const DrinkFilter(query: 'imaginaire')), isEmpty);
      expect(await names(const DrinkFilter(query: 'renommee')), [
        'Bière Renommée',
      ]);
    });
  });

  group('filtres', () {
    test(
      'par défaut : les épuisés sont masqués, tri par nom sans accents',
      () async {
        expect(await names(const DrinkFilter()), [
          'Bière Imaginaire',
          'Blanc Fictif',
          'Château Exemple',
          'Échezeaux Test',
        ]);
      },
    );

    test('afficher les épuisés', () async {
      expect(
        await names(const DrinkFilter(showExhausted: true)),
        contains('Vin Bu'),
      );
    });

    test('par type', () async {
      expect(await names(DrinkFilter(typeId: beer)), ['Bière Imaginaire']);
    });

    test('par caractéristiques (toutes exigées)', () async {
      expect(
        await names(DrinkFilter(characteristicIds: {characteristic('Rouge')})),
        ['Château Exemple', 'Échezeaux Test'],
      );
      expect(
        await names(
          DrinkFilter(
            characteristicIds: {characteristic('Rouge'), characteristic('Sec')},
          ),
        ),
        ['Château Exemple'],
      );
    });

    test('par région, favoris, « à compléter »', () async {
      expect(await names(const DrinkFilter(region: 'Bourgogne')), [
        'Échezeaux Test',
      ]);
      expect(await names(const DrinkFilter(favoritesOnly: true)), [
        'Échezeaux Test',
      ]);
      expect(await names(const DrinkFilter(needsCompletionOnly: true)), [
        'Blanc Fictif',
      ]);
    });

    test('liste des régions', () async {
      expect(await queries.watchRegions().first, [
        'Alsace',
        'Bordeaux',
        'Bourgogne',
        'Y',
      ]);
    });
  });

  group('tris', () {
    test(
      'par millésime, le plus ancien d\'abord, sans millésime en dernier',
      () async {
        expect(await names(const DrinkFilter(sort: DrinkSort.vintage)), [
          'Blanc Fictif',
          'Château Exemple',
          'Échezeaux Test',
          'Bière Imaginaire',
        ]);
      },
    );

    test('par stock', () async {
      expect(
        (await names(const DrinkFilter(sort: DrinkSort.stock))).first,
        'Blanc Fictif',
      );
    });

    test('derniers ajouts', () async {
      expect(
        (await names(const DrinkFilter(sort: DrinkSort.recentlyAdded))).first,
        'Bière Imaginaire',
      );
    });
  });

  test('la liste se met à jour après une sortie', () async {
    final stream = queries.watchDrinkList(
      const DrinkFilter(query: 'echezeaux'),
    );
    final item = (await stream.first).single;
    expect(item.stock, 1);
    await repo.addExit(item.lotsInStock.single.id, 1);
    expect(await stream.first, isEmpty, reason: 'épuisée donc masquée');
  });

  group('ftsQuery', () {
    test('mots en préfixes entre guillemets', () {
      expect(ftsQuery('Saint-Émilion 2015'), '"Saint"* "Émilion"* "2015"*');
    });

    test('rien à chercher', () {
      expect(ftsQuery('  '), isNull);
      expect(ftsQuery('-*'), isNull);
    });
  });
}
