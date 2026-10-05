import 'package:cave/domain/enums.dart';
import 'package:cave/domain/field_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chaque profil définit une règle pour chaque champ', () {
    for (final profile in FieldProfile.values) {
      for (final field in DrinkField.values) {
        expect(() => ruleFor(profile, field), returnsNormally);
      }
    }
  });

  group('marqueur « à compléter »', () {
    test('vin complet : appellation et région renseignées', () {
      expect(
        needsCompletion(
          profile: FieldProfile.wine,
          appellation: 'Saint-Émilion',
          region: 'Bordeaux',
        ),
        isFalse,
      );
    });

    test('vin sans appellation : complet (appellation facultative)', () {
      expect(
        needsCompletion(profile: FieldProfile.wine, region: 'Bordeaux'),
        isFalse,
      );
    });

    test('vin sans région ni pays', () {
      expect(
        needsCompletion(profile: FieldProfile.wine, appellation: 'AOC Test'),
        isTrue,
      );
    });

    test('vin : le pays suffit à défaut de région', () {
      expect(
        needsCompletion(
          profile: FieldProfile.wine,
          appellation: 'Rioja',
          country: 'Espagne',
        ),
        isFalse,
      );
    });

    test('un texte vide compte comme absent', () {
      expect(
        needsCompletion(
          profile: FieldProfile.wine,
          appellation: 'AOC Test',
          region: '  ',
        ),
        isTrue,
      );
    });

    test('bière, spiritueux et soft : rien d\'obligatoire au-delà du nom', () {
      for (final p in [
        FieldProfile.beer,
        FieldProfile.spirit,
        FieldProfile.soft,
      ]) {
        expect(needsCompletion(profile: p), isFalse, reason: p.name);
      }
    });

    test('sans type (« sans catégorie »)', () {
      expect(needsCompletion(profile: null), isTrue);
    });
  });
}
