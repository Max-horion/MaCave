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
}
