import 'package:cave/domain/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('écriture', () {
    test('séparateur « ; », fins de ligne Windows, marque UTF-8', () {
      expect(
        encodeCsv([
          ['Nom', 'Stock'],
          ['Château Test', '3'],
        ]),
        '﻿Nom;Stock\r\nChâteau Test;3\r\n',
      );
    });

    test('guillemets quand il le faut', () {
      expect(
        encodeCsv([
          ['a;b', 'dit "bonjour"', 'ligne\nsuivante', 'simple'],
        ]),
        '﻿"a;b";"dit ""bonjour""";"ligne\nsuivante";simple\r\n',
      );
    });
  });

  group('lecture', () {
    test('aller-retour sans perte', () {
      final rows = [
        ['Nom', 'Commentaire', 'Degré'],
        ['Château « Test »', 'Très bon ; à garder\n2e ligne', '12,5'],
        ['Autre', 'Il a dit "parfait"', ''],
      ];
      expect(decodeCsv(encodeCsv(rows)), rows);
    });

    test('séparateur « , » deviné (export Vivino)', () {
      expect(decodeCsv('Winery,Wine name\nDomaine Test,"Cuvée, spéciale"\n'), [
        ['Winery', 'Wine name'],
        ['Domaine Test', 'Cuvée, spéciale'],
      ]);
    });

    test('lignes vides ignorées, dernière ligne sans retour', () {
      expect(decodeCsv('a;b\r\n\r\n1;2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
    });

    test('cellules vides conservées', () {
      expect(decodeCsv('a;b;c\n1;;\n'), [
        ['a', 'b', 'c'],
        ['1', '', ''],
      ]);
    });
  });

  group('formules de tableur neutralisées', () {
    test('un début de formule reçoit une apostrophe, pas les nombres', () {
      final text = encodeCsv([
        ['=LIEN("http://x")', '+1+2', '@SOMME', '-moins', '-3', '+2,5', 'Vin'],
      ]);
      const expected =
          r'''"'=LIEN(""http://x"")";'+1+2;'@SOMME;'-moins;-3;+2,5;Vin''';
      expect(text, '$utf8Bom$expected\r\n');
    });

    test('aller-retour export → import : valeurs intactes', () {
      final cells = [
        '=1+1',
        '+33 6 12',
        '@x',
        '-',
        "'=déjà",
        "''=deux",
        "l'apostrophe",
        '-12',
        '\tTab',
      ];
      expect(decodeCsv(encodeCsv([cells])), [cells]);
    });
  });

  group('tableau avec en-tête', () {
    test(
      'colonnes retrouvées sans tenir compte de la casse ni des accents',
      () {
        final table = CsvTable(
          decodeCsv('Région;Volume (ml)\nBordeaux;750\nAlsace\n'),
        );
        expect(table.has('region'), isTrue);
        expect(table.cell(table.rows[0], 'REGION'), 'Bordeaux');
        expect(table.cell(table.rows[0], 'volume (ML)'), '750');
        expect(
          table.cell(table.rows[1], 'Volume (ml)'),
          '',
          reason: 'ligne courte',
        );
        expect(table.cell(table.rows[0], 'Inconnue'), '');
      },
    );
  });
}
