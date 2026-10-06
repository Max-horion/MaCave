import 'package:cave/domain/similarity.dart';
import 'package:flutter_test/flutter_test.dart';

double score(String a, String b, {String? pa, String? pb}) =>
    similarityScore(name: a, producer: pa, otherName: b, otherProducer: pb);

bool similar(String a, String b, {String? pa, String? pb}) =>
    score(a, b, pa: pa, pb: pb) >= similarityThreshold;

void main() {
  group('proches', () {
    test('abréviations : Ch., Dom., St', () {
      expect(similar('Ch. Figeac', 'Château Figeac'), isTrue);
      expect(similar('Dom. des Lunes', 'Domaine des Lunes'), isTrue);
      expect(similar('St Joseph', 'Saint-Joseph'), isTrue);
    });

    test('accents, casse, ponctuation, ordre des mots', () {
      expect(similar('CHATEAU FIGEAC', 'Château Figeac'), isTrue);
      expect(similar('IPA Imaginaire', 'Imaginaire IPA'), isTrue);
    });

    test('millésime et volume dans le nom : ignorés', () {
      expect(similar('Leffe Blonde 33cl', 'Leffe Blonde'), isTrue);
      expect(similar('Château Figeac 2015', 'Château Figeac'), isTrue);
      expect(similar('Leffe Blonde 75 cl', 'Leffe Blonde'), isTrue);
    });

    test('une faute de frappe', () {
      expect(similar('Chateau Figeak', 'Château Figeac'), isTrue);
      expect(similar('Château Figaec', 'Château Figeac'), isTrue);
    });

    test('marque séparée d\'un côté, dans le nom de l\'autre', () {
      expect(similar('Blonde', 'Leffe Blonde', pa: 'Leffe'), isTrue);
    });
  });

  group('différentes', () {
    test('même appellation, autres châteaux', () {
      expect(similar('Château Figeac', 'Château Pavie'), isFalse);
      expect(similar('Bordeaux', 'Château Lune Bordeaux'), isFalse);
    });

    test('même marque, autres bières', () {
      expect(similar('Chimay Bleue', 'Chimay Grande Réserve'), isFalse);
      expect(similar('Leffe Blonde', 'Leffe Brune'), isFalse);
    });

    test('mots courts : pas de « faute de frappe »', () {
      expect(similar('Gin Bio', 'Gin Rio'), isFalse);
    });

    test('rien en commun', () {
      expect(score('Rhum Agricole', 'Limonade'), 0);
      expect(score('', 'Limonade'), 0);
    });
  });

  group('texte lu sur une étiquette (erreurs de reconnaissance)', () {
    bool onLabel(String drink, List<String> lines, {String? producer}) =>
        labelMatchScore(
          labelText: lines.join('\n'),
          drinkName: drink,
          drinkProducer: producer,
        ) >=
        labelMatchThreshold;

    test('chiffres pris pour des lettres : 0/O, 1/I/l, 5/S', () {
      expect(onLabel('Château Figeac', ['CHATEAU F1GEAC', '2019']), isTrue);
      expect(onLabel('Domaine des Loups', ['D0MAINE DES L0UPS']), isTrue);
      expect(onLabel('Les Sables', ['LES 5ABLES']), isTrue);
    });

    test('« rn » lu pour « m »', () {
      expect(onLabel('Château Marmont', ['CHATEAU MARRNONT']), isTrue);
    });

    test('deux lettres fausses dans un mot long', () {
      expect(
        onLabel('Domaine des Lunes Argentées', [
          'DOMAINE DES LUNES',
          'ARGENIFES',
        ]),
        isTrue,
      );
    });

    test('nom ailleurs que sur la ligne du nom, sur plusieurs lignes', () {
      expect(
        onLabel('Clos des Brumes Hautes', [
          'GRAND VIN',
          'CLOS DES',
          'BRUMES',
          'HAUTES',
          '13% vol',
        ]),
        isTrue,
      );
    });

    test('mots collés ou coupés', () {
      expect(onLabel('Château Figeac', ['CHATEAUFIGEAC']), isTrue);
      expect(onLabel('Château Figeac', ['CHATEAU FIG EAC']), isTrue);
    });

    test('marque dans le producteur', () {
      expect(
        onLabel('Blonde', ['LEFFE', 'BL0NDE', '6,6% vol'], producer: 'Leffe'),
        isTrue,
      );
    });

    test('pas de fausse alerte', () {
      // Même marque, autre bière.
      expect(onLabel('Leffe Blonde', ['LEFFE', 'BRUNE']), isFalse);
      // Seulement les mots courants (« Château », « Grand Vin »).
      expect(
        onLabel('Château Pavie', ['CHATEAU FIGEAC', 'GRAND VIN']),
        isFalse,
      );
      // Un seul mot sur trois.
      expect(
        onLabel('Domaine des Lunes Argentées', ['LUNES', 'BORDEAUX']),
        isFalse,
      );
      // Mot court mal lu : pas de tolérance.
      expect(onLabel('Gin Bio', ['GIN RIO']), isFalse);
    });

    test('la saisie à la main garde la comparaison stricte', () {
      expect(similar('Château F1geac', 'Château Pavie'), isFalse);
      expect(similar('Leffe Blonde', 'Leffe Brune'), isFalse);
    });
  });
}
