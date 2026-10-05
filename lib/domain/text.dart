/// Outils sur les textes.
library;

const _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a', //
  'ç': 'c',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'î': 'i', 'ï': 'i', 'í': 'i', 'ì': 'i',
  'ñ': 'n',
  'ô': 'o', 'ö': 'o', 'ó': 'o', 'ò': 'o', 'õ': 'o',
  'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
  'ÿ': 'y',
  'œ': 'oe', 'æ': 'ae', 'ß': 'ss',
};

/// Minuscules sans accents : « Château Échezeaux » → « chateau echezeaux ».
/// Sert au tri alphabétique (sinon « É » se range après « Z »).
String fold(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString();
}

/// Clé de comparaison : [fold], puis seulement lettres et chiffres.
/// « Montagne-Saint-Émilion » et « Montagne Saint Emilion » donnent la même
/// clé « montagnesaintemilion ».
String compactKey(String input) =>
    fold(input).replaceAll(RegExp(r'[^a-z0-9]'), '');
