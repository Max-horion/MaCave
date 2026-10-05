import 'dart:io';

import 'package:cave/domain/csv.dart';
import 'package:cave/domain/vivino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Faux export Vivino : mêmes colonnes que le vrai, vins inventés.
  final table = CsvTable(
    decodeCsv(File('test/fixtures/vivino_cellar.csv').readAsStringSync()),
  );
  final wines = parseVivino(table);

  VivinoWine byProducer(String producer) =>
      wines.firstWhere((w) => w.producer == producer);

  test('le fichier est reconnu comme export Vivino', () {
    expect(isVivinoExport(table), isTrue);
    expect(wines, hasLength(8));
  });

  test('« nom du vin » identique à la région : c\'est l\'appellation', () {
    final w = wines.first;
    expect(w.name, 'Château Imaginaire');
    expect(w.producer, 'Château Imaginaire');
    expect(w.appellation, 'Appellation Fictive');
    expect(w.vintage, 2015);
    expect(w.quantity, 6);
    expect(w.line, 2);
  });

  test('appellation reconnue malgré traits d\'union et espaces', () {
    final w = byProducer('Château Trait-d\'Union');
    expect(w.name, 'Château Trait-d\'Union');
    expect(w.appellation, 'Côte Imaginaire Village');
  });

  test('sinon : nom = domaine + nom du vin, sans appellation', () {
    final w = byProducer('Domaine Inventé');
    expect(w.name, 'Domaine Inventé Cuvée Exemple, Vieilles Vignes');
    expect(w.appellation, isNull);
    expect(w.vintage, isNull);
  });

  test('pays : code et nom anglais traduits, vide laissé vide', () {
    expect(byProducer('Domaine Inventé').country, 'France');
    expect(byProducer('Maison Factice').country, isNull);
    expect(frenchCountry('Italy'), 'Italie');
    expect(frenchCountry('es'), 'Espagne');
    expect(frenchCountry('Pays Inconnu'), 'Pays Inconnu');
  });

  test('type Vivino → caractéristique', () {
    expect(wines.first.characteristics, {'Robe': 'Rouge'});
    expect(byProducer('Domaine Inventé').characteristics, {'Robe': 'Blanc'});
    expect(byProducer('Maison Factice').characteristics, {'Robe': 'Rosé'});
    expect(byProducer('Cave Fictive').characteristics, {
      'Style': 'Effervescent',
    });
    expect(byProducer('Domaine Doux').characteristics, isEmpty);
    expect(byProducer('Domaine Muté').characteristics, isEmpty);
  });
}
