import 'text.dart';

// Ressemblance entre deux références (CDC §6.2, détection des doublons) :
// « Ch. Figeac » ressemble à « Château Figeac », « Leffe Blonde 33cl » à
// « Leffe Blonde ». Elle ne sert qu'à *proposer* une référence existante :
// rien n'est jamais fusionné sans l'accord de l'utilisateur.
//
// Méthode : chaque nom devient un ensemble de mots (sans accents ni
// ponctuation, abréviations courantes développées, petits mots, millésimes
// et volumes retirés). Deux mots sont égaux s'ils sont identiques, ou à une
// faute de frappe près pour les mots d'au moins 5 lettres. Le score est la
// part de mots en commun (coefficient de Dice), de 0 à 1.

/// Score à partir duquel deux références sont proposées comme proches.
const similarityThreshold = 0.66;

/// Abréviations développées avant la comparaison.
const _abbreviations = {
  'ch': 'chateau',
  'chat': 'chateau',
  'chx': 'chateau',
  'dom': 'domaine',
  'dne': 'domaine',
  'st': 'saint',
  'ste': 'sainte',
  'cuv': 'cuvee',
  'gd': 'grand',
  'gds': 'grands',
  'mis': 'mise',
  'brass': 'brasserie',
};

/// Mots trop courants pour distinguer deux références.
const _stopWords = {
  'le', 'la', 'les', 'l', 'de', 'du', 'des', 'd', 'et', 'en', 'a', 'au', //
  'aux', 'the', 'of', 'and',
};

/// Mots d'un nom, prêts à être comparés.
Set<String> similarityWords(String? text) {
  if (text == null) return const {};
  final words = <String>{};
  for (final raw in fold(text).split(RegExp(r'[^a-z0-9]+'))) {
    if (raw.isEmpty || _stopWords.contains(raw)) continue;
    // Millésime ou volume : ne distinguent pas une référence (ils sont sur
    // le lot).
    if (RegExp(r'^(1[89]|20)\d\d$').hasMatch(raw)) continue;
    if (RegExp(r'^\d+(ml|cl|l)$').hasMatch(raw)) continue;
    if (const {'ml', 'cl', 'l', 'vol'}.contains(raw)) continue;
    words.add(_abbreviations[raw] ?? raw);
  }
  // Un nombre seul après un volume retiré (« 75 cl ») : retiré aussi.
  if (RegExp(r'\d+\s*(ml|cl|l)\b').hasMatch(fold(text))) {
    words.removeWhere((w) => RegExp(r'^\d+$').hasMatch(w));
  }
  return words;
}

/// Score de ressemblance entre deux références, de 0 (rien de commun) à 1.
///
/// Compare les noms, et aussi « nom + producteur » : Open Food Facts met
/// souvent la marque à part (« Blonde », marque « Leffe ») quand
/// l'utilisateur l'a écrite dans le nom (« Leffe Blonde »).
double similarityScore({
  required String name,
  String? producer,
  required String otherName,
  String? otherProducer,
}) {
  final a = similarityWords(name), b = similarityWords(otherName);
  final byName = _dice(a, b);
  final withProducer = _dice(
    {...a, ...similarityWords(producer)},
    {...b, ...similarityWords(otherProducer)},
  );
  return byName > withProducer ? byName : withProducer;
}

/// Coefficient de Dice avec mots « presque égaux » (une faute de frappe).
double _dice(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final unmatched = b.toList();
  var common = 0;
  for (final word in a) {
    final i = unmatched.indexWhere((other) => _sameWord(word, other));
    if (i >= 0) {
      common++;
      unmatched.removeAt(i);
    }
  }
  return 2 * common / (a.length + b.length);
}

bool _sameWord(String a, String b) {
  if (a == b) return true;
  if (a.length < 5 || b.length < 5) return false;
  return _withinOneEdit(a, b);
}

/// Les deux mots diffèrent d'au plus une lettre (ajoutée, retirée,
/// remplacée, ou deux lettres voisines inversées).
bool _withinOneEdit(String a, String b) {
  if ((a.length - b.length).abs() > 1) return false;
  var i = 0;
  while (i < a.length && i < b.length && a[i] == b[i]) {
    i++;
  }
  if (a.length == b.length) {
    if (a.substring(i + 1) == b.substring(i + 1)) return true;
    // Inversion de deux lettres voisines : « figaec » / « figeac ».
    return i + 1 < a.length &&
        a[i] == b[i + 1] &&
        a[i + 1] == b[i] &&
        a.substring(i + 2) == b.substring(i + 2);
  }
  final (long, short) = a.length > b.length ? (a, b) : (b, a);
  return long.substring(i + 1) == short.substring(i);
}
