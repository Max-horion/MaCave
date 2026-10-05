import 'enums.dart';

/// Champs facultatifs de la fiche d'une référence dont l'affichage dépend du type.
enum DrinkField { appellation, region, grapes, abv, vintage, foodPairing }

/// Visibilité d'un champ pour un profil (CDC §4.1).
enum FieldRule { required, optional, hidden }

/// Tableau du CDC §4.1, pour les champs qui ne sont pas communs à tous les types.
/// (Nom et type : toujours obligatoires ; producteur, caractéristiques, note,
/// favori, commentaire : toujours facultatifs.)
const Map<FieldProfile, Map<DrinkField, FieldRule>> fieldRules = {
  FieldProfile.wine: {
    DrinkField.appellation: FieldRule.required,
    DrinkField.region: FieldRule.required,
    DrinkField.grapes: FieldRule.optional,
    DrinkField.abv: FieldRule.optional,
    DrinkField.vintage: FieldRule.optional,
    DrinkField.foodPairing: FieldRule.optional,
  },
  FieldProfile.beer: {
    DrinkField.appellation: FieldRule.hidden,
    DrinkField.region: FieldRule.optional,
    DrinkField.grapes: FieldRule.hidden,
    DrinkField.abv: FieldRule.optional,
    DrinkField.vintage: FieldRule.hidden,
    DrinkField.foodPairing: FieldRule.optional,
  },
  FieldProfile.spirit: {
    DrinkField.appellation: FieldRule.optional,
    DrinkField.region: FieldRule.optional,
    DrinkField.grapes: FieldRule.hidden,
    DrinkField.abv: FieldRule.optional,
    DrinkField.vintage: FieldRule.optional,
    DrinkField.foodPairing: FieldRule.optional,
  },
  FieldProfile.soft: {
    DrinkField.appellation: FieldRule.hidden,
    DrinkField.region: FieldRule.hidden,
    DrinkField.grapes: FieldRule.hidden,
    DrinkField.abv: FieldRule.hidden,
    DrinkField.vintage: FieldRule.hidden,
    DrinkField.foodPairing: FieldRule.hidden,
  },
};

FieldRule ruleFor(FieldProfile profile, DrinkField field) =>
    fieldRules[profile]![field]!;

/// Marqueur « à compléter » (CDC §4.1, §6.7) : vrai si la référence n'a plus
/// de type (type supprimé, « sans catégorie ») ou s'il manque un champ
/// obligatoire pour son type. La région est remplie par la région *ou* le pays.
bool needsCompletion({
  required FieldProfile? profile,
  String? appellation,
  String? region,
  String? country,
}) {
  if (profile == null) return true;
  bool missing(String? v) => v == null || v.trim().isEmpty;
  if (ruleFor(profile, DrinkField.appellation) == FieldRule.required &&
      missing(appellation)) {
    return true;
  }
  if (ruleFor(profile, DrinkField.region) == FieldRule.required &&
      missing(region) &&
      missing(country)) {
    return true;
  }
  return false;
}
