import 'enums.dart';

/// Fiche pré-remplie à partir d'une source extérieure (Open Food Facts,
/// étiquette photographiée), proposée dans le formulaire d'ajout : rien n'est
/// enregistré sans validation (CDC §6.2).
///
/// Le type et les caractéristiques sont donnés par leur profil et leur nom,
/// pas par leurs identifiants : le formulaire les retrouve dans la
/// classification de l'utilisateur (qui peut les avoir renommés).
class DrinkDraft {
  const DrinkDraft({
    this.name,
    this.producer,
    this.appellation,
    this.country,
    this.abv,
    this.volumeMl,
    this.vintage,
    this.profile,
    this.characteristics = const {},
  });

  final String? name;
  final String? producer;
  final String? appellation;
  final String? country;
  final double? abv;
  final int? volumeMl;
  final int? vintage;

  /// Profil du type (vin, bière…), si la source permet de le savoir.
  final FieldProfile? profile;

  /// Noms de caractéristiques (« Rouge », « IPA »…), à retrouver dans les
  /// familles du type choisi.
  final Set<String> characteristics;

  bool get isEmpty =>
      name == null &&
      producer == null &&
      appellation == null &&
      abv == null &&
      volumeMl == null &&
      vintage == null &&
      profile == null;

  /// Complète cette fiche avec [other] : seuls les champs vides sont pris
  /// (une fiche d'Open Food Facts complétée par la photo de l'étiquette).
  DrinkDraft fillWith(DrinkDraft other) => DrinkDraft(
    name: name ?? other.name,
    producer: producer ?? other.producer,
    appellation: appellation ?? other.appellation,
    country: country ?? other.country,
    abv: abv ?? other.abv,
    volumeMl: volumeMl ?? other.volumeMl,
    vintage: vintage ?? other.vintage,
    profile: profile ?? other.profile,
    characteristics: characteristics.isEmpty
        ? other.characteristics
        : characteristics,
  );
}
