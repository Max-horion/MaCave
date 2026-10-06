// Lecture des informations écrites sur un produit : volume (« 75 cl »),
// degré (« 12,5 % vol »)… Utilisée pour Open Food Facts (lot 5b) et pour le
// texte reconnu sur une étiquette (lot 5c).

/// Volume en millilitres d'un texte comme « 75 cl », « 0,75 L », « 330ml »,
/// « 1,5 litre ». Pour un lot (« 6 x 33 cl »), le volume d'une bouteille.
/// Null si aucun volume plausible (entre 2 cl et 20 l) n'est trouvé.
int? parseVolumeMl(String? text) {
  if (text == null) return null;
  final pattern = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(ml|cl|dl|l|litres?|liters?)\b',
    caseSensitive: false,
  );
  int? result;
  for (final match in pattern.allMatches(text)) {
    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null) continue;
    final unit = match.group(2)!.toLowerCase();
    final ml = switch (unit) {
      'ml' => value,
      'cl' => value * 10,
      'dl' => value * 100,
      _ => value * 1000,
    };
    if (ml >= 20 && ml <= 20000) {
      // Le dernier volume du texte : « 6 x 33 cl » → 33 cl.
      result = ml.round();
    }
  }
  return result;
}

/// Degré d'alcool d'un nombre ou d'un texte (« 12,5 », « 13 % vol »), s'il
/// est plausible (0 à 100 % vol).
double? parseAbv(Object? value) {
  final number = switch (value) {
    num n => n.toDouble(),
    String s => double.tryParse(
      RegExp(r'\d+(?:[.,]\d+)?')
              .firstMatch(s)
              ?.group(0)
              ?.replaceAll(',', '.') ??
          '',
    ),
    _ => null,
  };
  if (number == null || number < 0 || number > 100) return null;
  return number;
}
