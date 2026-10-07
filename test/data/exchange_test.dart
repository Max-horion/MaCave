import 'dart:io';

import 'package:cave/data/cave_queries.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/exchange/cave_import.dart';
import 'package:cave/data/exchange/csv_export.dart';
import 'package:cave/data/exchange/exchange_format.dart';
import 'package:cave/data/exchange/import_template.dart';
import 'package:cave/domain/csv.dart';
import 'package:cave/domain/drink_filter.dart';
import 'package:cave/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

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

  Future<String> characteristic(CaveDatabase db, String name) async =>
      (await (db.select(
        db.characteristics,
      )..where((c) => c.name.equals(name))).getSingle()).id;

  /// Cave fictive : deux vins, des lots, des entrées et sorties.
  Future<void> fillCave() async {
    final types = await repo.drinkTypes();
    final wine = types.firstWhere((t) => t.fieldProfile == FieldProfile.wine);
    final a = await repo.addNewDrink(
      drink: DrinkInput(
        name: 'Château Exemple',
        typeId: wine.id,
        producer: 'SCEA Test',
        appellation: 'Appellation; Test',
        region: 'Région Test',
        abv: 13.5,
        rating: 4,
        favorite: true,
        comment: 'Très bon\n« à garder »',
      ),
      characteristicIds: {
        await characteristic(db, 'Rouge'),
        await characteristic(db, 'Sec'),
      },
      volumeMl: 750,
      vintage: 2015,
      quantity: 6,
    );
    await repo.addExit(a.lotId, 1, reason: ExitReason.gifted, comment: 'Ami');
    final magnum = await repo.findOrCreateLot(
      drinkId: a.drinkId,
      volumeMl: 1500,
      vintage: 2015,
    );
    await repo.addEntry(magnum, 1);
    final b = await repo.addNewDrink(
      drink: DrinkInput(name: 'Bière Fictive', typeId: types[1].id),
      volumeMl: 330,
      quantity: 4,
    );
    await repo.recordInventory(b.lotId, 3);
  }

  List<List<String>> rows(String csv) => decodeCsv(csv);

  group('export', () {
    test('stock : une ligne par lot, en-têtes français', () async {
      await fillCave();
      final export = await exportCsv(db);
      final stock = CsvTable(rows(export.stock));
      expect(stock.header.take(4), ['ID référence', 'ID lot', 'Type', 'Nom']);
      expect(stock.rows, hasLength(3));
      final first = stock.rows.firstWhere(
        (r) => stock.cell(r, 'Volume (ml)') == '750',
      );
      expect(stock.cell(first, 'Nom'), 'Château Exemple');
      expect(
        stock.cell(first, 'Caractéristiques'),
        'Robe : Rouge | Sucre : Sec',
      );
      expect(stock.cell(first, 'Degré'), '13,5');
      expect(stock.cell(first, 'Favori'), 'oui');
      expect(stock.cell(first, 'Stock'), '5');
      expect(export.stock, startsWith(utf8Bom));
    });

    test('historique : nature et motif lisibles', () async {
      await fillCave();
      final history = CsvTable(rows((await exportCsv(db)).history));
      final kinds = history.rows.map((r) => history.cell(r, 'Nature')).toList();
      expect(kinds, containsAll(['entrée', 'sortie', 'inventaire']));
      final exit = history.rows.firstWhere(
        (r) => history.cell(r, 'Nature') == 'sortie',
      );
      expect(history.cell(exit, 'Motif'), 'offerte');
      expect(history.cell(exit, 'Commentaire'), 'Ami');
    });
  });

  group('restauration d\'une sauvegarde', () {
    test(
      'stock puis historique dans une cave vierge : tout est retrouvé',
      () async {
        await fillCave();
        final original = await exportCsv(db);

        final restored = memoryDatabase();
        addTearDown(restored.close);
        final importer = CaveImporter(restored, TestContext(deviceId: 'autre'));
        final stockReport = await importer.apply(original.stock);
        expect(stockReport.kind, ImportKind.stock);
        expect(stockReport.drinksCreated, 2);
        expect(stockReport.lotsCreated, 3);
        expect(stockReport.bottlesAdded, 9);
        expect(stockReport.issues, isEmpty);
        final historyReport = await importer.apply(original.history);
        expect(historyReport.kind, ImportKind.history);
        expect(historyReport.issues, isEmpty);

        final again = await exportCsv(restored);
        // Même stock, mêmes identifiants, mêmes dates d'ajout.
        expect(rows(again.stock), rows(original.stock));
        // Les mouvements d'origine sont tous là (plus les ajustements
        // d'inventaire de la restauration).
        final ids = CsvTable(rows(again.history)).rows
            .map((r) => r.first)
            .toSet();
        expect(
          ids,
          containsAll(
            CsvTable(rows(original.history)).rows.map((r) => r.first),
          ),
        );
      },
    );

    test('réimporter la même sauvegarde ne change rien', () async {
      await fillCave();
      final export = await exportCsv(db);
      final report = await CaveImporter(db, ctx).apply(export.stock);
      expect(report.hasChanges, isFalse);
      final history = await CaveImporter(db, ctx).apply(export.history);
      expect(history.movementsAdded, 0);
      expect(history.movementsSkipped, greaterThan(0));
    });

    test('le stock du fichier remplace celui de la cave', () async {
      await fillCave();
      final export = await exportCsv(db);
      final lot = (await db.select(db.lots).get()).firstWhere(
        (l) => l.volumeMl == 330,
      );
      await repo.addExit(lot.id, 2);
      final report = await CaveImporter(db, ctx).apply(export.stock);
      expect(report.lotsAdjusted, 1);
      expect((await repo.lot(lot.id))!.stock, 3);
    });
  });

  group('saisie préparée dans un tableur', () {
    const sheet =
        'Nom;Type;Millésime;Stock;Caractéristiques;Appellation;Région\n'
        'Vin Préparé;vin;2019;4;Rouge | Pétillant;AOC Test;Région Test\n'
        'Vin Préparé;Vin;2020;2;;AOC Test;Région Test\n'
        ';Vin;2019;1;;;\n'
        'Mauvais millésime;Vin;deux mille;1;;;\n'
        'Sans type;;;1;;;\n';

    test('références et lots créés, erreurs signalées par ligne', () async {
      final report = await CaveImporter(db, ctx).apply(sheet);
      expect(report.kind, ImportKind.stock);
      expect(report.drinksCreated, 2, reason: 'Vin Préparé + Sans type');
      expect(report.lotsCreated, 3);
      expect(report.bottlesAdded, 7);
      expect(report.unknownCharacteristics, {'Pétillant'});
      expect(report.issues.map((i) => (i.line, i.code)), [
        (4, ImportIssueCode.missingName),
        (5, ImportIssueCode.invalidVintage),
      ]);

      final list = await CaveQueries(db)
          .watchDrinkList(const DrinkFilter(query: 'prepare'))
          .first;
      final item = list.single;
      expect(item.lots.map((l) => (l.vintage, l.volumeMl, l.stock)), [
        (2019, 750, 4),
        (2020, 750, 2),
      ]);
      expect(item.drink.needsCompletion, isFalse);
    });

    test('l\'aperçu n\'écrit rien et annonce le même bilan', () async {
      final preview = await CaveImporter(db, ctx).preview(sheet);
      expect(await db.select(db.drinks).get(), isEmpty);
      final applied = await CaveImporter(db, ctx).apply(sheet);
      expect(
        (preview.drinksCreated, preview.lotsCreated, preview.bottlesAdded),
        (applied.drinksCreated, applied.lotsCreated, applied.bottlesAdded),
      );
    });

    test('volume écrit avec son unité', () async {
      final report = await CaveImporter(db, ctx).apply(
        'Nom;Type;Volume (ml);Stock\n'
        'Fût Test;Bière;6 l;1\n'
        'Bouteille Test;Bière;75 cl;2\n'
        'Mauvais Test;Bière;beaucoup;1\n',
      );
      expect(report.lotsCreated, 2);
      expect(report.issues.single.code, ImportIssueCode.invalidVolume);
      final volumes = (await db.select(db.lots).get())
          .map((l) => l.volumeMl)
          .toSet();
      expect(volumes, {6000, 750});
    });

    test('fichier modèle : importé tel quel, sans erreur', () async {
      final classification = await CaveQueries(db).watchClassification().first;
      final template = importTemplateCsv(classification);
      final table = CsvTable(decodeCsv(template));
      expect(table.has(StockColumns.name), isTrue);

      final report = await CaveImporter(db, ctx).apply(template);
      expect(report.kind, ImportKind.stock);
      expect(report.issues, isEmpty);
      expect(report.unknownCharacteristics, isEmpty);
      expect(report.drinksCreated, 2, reason: 'un vin et une bière');
      expect(report.bottlesAdded, 18);
      expect(report.needsCompletion, 0);
      final names = (await db.select(db.drinks).get()).map((d) => d.name);
      expect(names, everyElement(startsWith(templateExamplePrefix)));
      final links = await db.select(db.drinkCharacteristics).get();
      expect(links, isNotEmpty, reason: 'caractéristiques reconnues');
    });

    test('fichier non reconnu', () async {
      final report = await CaveImporter(db, ctx).apply('a;b\n1;2\n');
      expect(report.kind, isNull);
      expect(report.issues.single.code, ImportIssueCode.unknownFormat);
    });
  });

  group('historique', () {
    test('lot inconnu et nature invalide signalés', () async {
      final report = await CaveImporter(db, ctx).apply(
        'ID mouvement;ID lot;Date;Nature;Quantité\n'
        'm1;lot-inconnu;2026-01-01;entrée;3\n',
      );
      expect(report.issues.single.code, ImportIssueCode.unknownLot);
    });
  });

  group('import Vivino', () {
    final vivino = File('test/fixtures/vivino_cellar.csv').readAsStringSync();

    test('références, lots et bouteilles', () async {
      final report = await CaveImporter(db, ctx).apply(vivino);
      expect(report.kind, ImportKind.vivino);
      expect(report.drinksCreated, 7, reason: 'le château a deux millésimes');
      expect(report.lotsCreated, 8);
      expect(report.bottlesAdded, 27);
      // Appellation facultative : toutes les lignes ont une région, aucune
      // fiche n'est « à compléter ».
      expect(report.needsCompletion, 0);

      final list = await CaveQueries(db)
          .watchDrinkList(const DrinkFilter(query: 'appellation fictive rouge'))
          .first;
      expect(list.single.lots.map((l) => (l.vintage, l.stock)), [
        (2015, 6),
        (2018, 2),
      ]);
    });

    test('réimporter le fichier ne double pas le stock', () async {
      await CaveImporter(db, ctx).apply(vivino);
      final again = await CaveImporter(db, ctx).apply(vivino);
      expect(again.drinksCreated, 0);
      expect(again.bottlesAdded, 0);
      expect(again.lotsSkipped, 8);
    });

    test('rapproche une fiche saisie à la main, sans producteur', () async {
      // Saisie manuelle : même vin, sans producteur, nom en minuscules,
      // millésime 2015 déjà en cave.
      final types = await repo.drinkTypes();
      final manual = await repo.addNewDrink(
        drink: DrinkInput(name: 'château imaginaire', typeId: types.first.id),
        volumeMl: 750,
        vintage: 2015,
        quantity: 9,
      );
      final report = await CaveImporter(db, ctx).apply(vivino);
      expect(report.drinksCreated, 6, reason: 'pas de doublon du château');
      expect(report.lotsSkipped, 1, reason: 'le 2015 existait déjà');
      final lots = await repo.lotsOf(manual.drinkId);
      expect(lots.map((l) => (l.vintage, l.stock)), [(2015, 9), (2018, 2)]);
    });

    test('deux producteurs différents : deux références', () async {
      final types = await repo.drinkTypes();
      await repo.createDrink(
        DrinkInput(
          name: 'Château Imaginaire',
          producer: 'Autre Producteur',
          typeId: types.first.id,
        ),
      );
      final report = await CaveImporter(db, ctx).apply(vivino);
      expect(report.drinksCreated, 7);
    });
  });
}
