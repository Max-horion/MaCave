import 'package:cave/domain/enums.dart';
import 'package:cave/domain/label_reading.dart';
import 'package:flutter_test/flutter_test.dart';

// Étiquettes inventées, telles que la reconnaissance de texte les rend
// (lignes, capitales, accents parfois perdus).
final _appellations = AppellationIndex([
  'Bordeaux',
  'Bordeaux supérieur',
  'Saint-Emilion',
  'Saint-Emilion grand cru',
  'Champagne',
  'Cognac',
  'Alsace',
]);

LabelReading read(List<Object> lines) => readLabel(
  [
    for (final l in lines)
      l is LabelLine ? l : LabelLine(l as String, height: 20),
  ],
  _appellations,
  currentYear: 2026,
);

void main() {
  test('vin de Bordeaux : tout ce qui peut être extrait l\'est', () {
    final r = read([
      'GRAND VIN DE BORDEAUX',
      const LabelLine('CHÂTEAU DES LUNES', height: 80),
      '2019',
      'SAINT-ÉMILION GRAND CRU',
      'APPELLATION SAINT-ÉMILION GRAND CRU CONTRÔLÉE',
      'Mis en bouteille au château',
      '14% vol.',
      '750 ml',
    ]);
    expect(r.name, 'Château des Lunes');
    expect(r.vintage, 2019);
    expect(r.appellation, 'Saint-Emilion grand cru');
    expect(r.abv, 14);
    expect(r.volumeMl, 750);
    expect(r.profile, FieldProfile.wine);
    final draft = r.toDraft();
    expect(draft.country, 'France');
    expect(draft.profile, FieldProfile.wine);
  });

  test('appellation sur deux lignes, sans accents', () {
    final r = read(['BORDEAUX', 'SUPERIEUR', 'Domaine Imaginaire']);
    expect(r.appellation, 'Bordeaux supérieur');
  });

  test('« depuis 1850 » n\'est pas un millésime', () {
    expect(read(['Maison fondée en 1850', 'Millésime 2018']).vintage, 2018);
    expect(read(['Depuis 1850']).vintage, isNull);
    expect(read(['Récolté en 2018']).vintage, 2018);
  });

  test('pas d\'année future ni absurde', () {
    expect(read(['2031']).vintage, isNull);
    expect(read(['Cuvée 1789']).vintage, isNull);
  });

  test('producteur : « mis en bouteille par »', () {
    final r = read([
      'Mis en bouteille par SCEA Les Vignes Inventées à Saint-Truc',
    ]);
    expect(r.producer, 'SCEA Les Vignes Inventées');
  });

  test('champagne : effervescent, blanc de blancs', () {
    final r = read([
      const LabelLine('MAISON IMAGINAIRE', height: 60),
      'CHAMPAGNE',
      'BLANC DE BLANCS',
      'BRUT',
      '12,5 % vol',
      '75 cl',
    ]);
    expect(r.appellation, 'Champagne');
    expect(r.characteristics, {'Blanc', 'Effervescent'});
    expect(r.abv, 12.5);
    expect(r.name, 'Maison Imaginaire');
  });

  test('bière : type, style, brasserie', () {
    final r = read([
      'Brasserie du Test',
      const LabelLine('LA GRANDE IPA', height: 70),
      'Bière blonde',
      '6,5% vol',
      '33 cl',
    ]);
    expect(r.profile, FieldProfile.beer);
    expect(r.characteristics, {'Blonde', 'IPA'});
    expect(r.producer, 'Brasserie du Test');
    expect(r.name, 'La Grande IPA');
    expect(r.volumeMl, 330);
    expect(r.toDraft().country, isNull);
  });

  test('cognac : spiritueux, pas vin, malgré l\'appellation', () {
    final r = read(['COGNAC', 'Fine Champagne', '40% vol', '70 cl']);
    expect(r.profile, FieldProfile.spirit);
    expect(r.toDraft().profile, FieldProfile.spirit);
  });

  test('le nom n\'est jamais une mention légale', () {
    final r = read([
      const LabelLine('CONTIENT DES SULFITES', height: 90),
      const LabelLine('Domaine du Test', height: 40),
    ]);
    expect(r.name, 'Domaine du Test');
  });

  test('« CHÂTEAU » seul sur sa ligne est collé au nom qui suit', () {
    final r = read([
      const LabelLine('CHÂTEAU', height: 30),
      const LabelLine('LES TROIS CHÊNES', height: 90),
      'GRAND VIN DE BORDEAUX',
      '2018',
    ]);
    expect(r.name, 'Château les Trois Chênes');
    expect(r.lines.first, 'CHÂTEAU LES TROIS CHÊNES');
    expect(r.lines, hasLength(3));
  });

  test('mots jamais seuls : petits mots compris, jamais avant un nombre', () {
    List<String> joined(List<String> lines) =>
        joinLeadWords([for (final l in lines) LabelLine(l)])
            .map((l) => l.text)
            .toList();
    expect(joined(['DOMAINE DE LA', 'GRANDE COLLINE']), [
      'DOMAINE DE LA GRANDE COLLINE',
    ]);
    expect(joined(['Brasserie', 'du Test', '33 cl']), [
      'Brasserie du Test',
      '33 cl',
    ]);
    expect(joined(['CUVÉE', '2019']), ['CUVÉE', '2019']);
    // Une ligne qui contient autre chose n'est pas touchée.
    expect(joined(['MIS EN BOUTEILLE AU CHÂTEAU', 'SAINT-TRUC']), [
      'MIS EN BOUTEILLE AU CHÂTEAU',
      'SAINT-TRUC',
    ]);
    // Dernière ligne : rien à quoi la coller.
    expect(joined(['GRAND VIN', 'CHÂTEAU']), ['GRAND VIN', 'CHÂTEAU']);
  });

  test('l\'appellation la plus précise l\'emporte, en mots entiers', () {
    final index = AppellationIndex([
      'Alsace',
      'Bordeaux',
      'Bordeaux supérieur',
    ]);
    expect(index.find('BORDEAUX SUPÉRIEUR rouge'), 'Bordeaux supérieur');
    expect(index.find('Vin d\'Alsace'), 'Alsace');
    expect(index.find('Bordelais'), isNull);
  });
}
