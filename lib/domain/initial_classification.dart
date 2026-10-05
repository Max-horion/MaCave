import 'enums.dart';

/// Classification livrée avec l'application (CDC §6.1) et volumes par défaut
/// (CDC §7). L'utilisateur peut ensuite tout modifier dans les paramètres.
///
/// Les noms sont en français : ce sont des *données* de la cave, pas des textes
/// de l'interface (ils seront traduits, si besoin, au moment d'une diffusion).
class SeedType {
  const SeedType(
    this.key,
    this.name,
    this.profile,
    this.defaultVolumeMl,
    this.families,
  );

  /// Clé stable, sert à fabriquer des identifiants identiques sur tous les
  /// appareils (voir `CaveDatabase._seedClassification`).
  final String key;
  final String name;
  final FieldProfile profile;
  final int defaultVolumeMl;
  final List<SeedFamily> families;
}

class SeedFamily {
  const SeedFamily(this.name, this.values);
  final String name;
  final List<String> values;
}

const List<SeedType> initialClassification = [
  SeedType('wine', 'Vin', FieldProfile.wine, 750, [
    SeedFamily('Robe', ['Rouge', 'Blanc', 'Rosé']),
    SeedFamily('Style', ['Tranquille', 'Effervescent']),
    SeedFamily('Sucre', ['Sec', 'Demi-sec', 'Moelleux', 'Liquoreux']),
  ]),
  SeedType('beer', 'Bière', FieldProfile.beer, 750, [
    SeedFamily('Robe', ['Blonde', 'Ambrée', 'Brune', 'Blanche']),
    SeedFamily('Style', ['IPA', 'Stout', 'Lager']),
    SeedFamily('Arôme', ['Fumée', 'Aromatisée']),
  ]),
  SeedType('spirit', 'Spiritueux', FieldProfile.spirit, 700, [
    SeedFamily('Catégorie', ['Rhum', 'Whisky', 'Gin', 'Calvados', 'Liqueur']),
    SeedFamily('Style', ['Single malt', 'Blend']),
    SeedFamily('Parfum', ['Cassis', 'Mûre', 'Violette', 'Plantes', 'Café']),
  ]),
  SeedType('soft', 'Soft', FieldProfile.soft, 1000, [
    SeedFamily('Catégorie', ['Limonade', 'Jus', 'Sirop', 'Soda']),
  ]),
];
