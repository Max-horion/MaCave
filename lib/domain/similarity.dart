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

// ─────────────────────── Texte lu sur une étiquette ───────────────────────
//
// La reconnaissance de texte fait d'autres erreurs que la saisie : lettres
// confondues (« 0 » pour « o », « 1 » pour « l »), plusieurs lettres fausses
// dans un mot, mots collés ou coupés, nom réparti sur plusieurs lignes. Pour
// la photo, on cherche donc chaque référence de la cave dans **tout** le
// texte lu, avec une tolérance plus grande. La saisie à la main garde la
// comparaison stricte ci-dessus.

/// Part des mots de la référence retrouvés sur l'étiquette à partir de
/// laquelle elle est proposée.
const labelMatchThreshold = 0.75;

/// Mots trop fréquents sur les étiquettes pour reconnaître une référence à
/// eux seuls.
const _genericWords = {
  'chateau', 'domaine', 'clos', 'maison', 'brasserie', 'cuvee', 'grand', //
  'vin', 'vins', 'cru', 'reserve', 'saint', 'sainte', 'cave', 'caves',
  'vignobles', 'famille', 'blanc', 'rouge', 'rose', 'biere', 'blonde',
};

/// Caractères que la reconnaissance confond : ramenés à une même forme.
String _ocrCanonical(String word) => word
    .replaceAll('rn', 'm')
    .replaceAll('vv', 'w')
    .replaceAll(RegExp('[0]'), 'o')
    .replaceAll(RegExp('[1il|]'), 'l')
    .replaceAll('5', 's')
    .replaceAll('8', 'b')
    .replaceAll('6', 'g')
    .replaceAll('2', 'z');

/// Mots d'un texte lu, sans retirer les chiffres pris pour des lettres
/// (« F1GEAC »), avec en plus les paires de mots voisins collées : un mot
/// coupé en deux par la reconnaissance (« FIG EAC ») se retrouve ainsi.
List<String> _labelTokens(String text) {
  final words = [
    for (final w in fold(text).split(RegExp(r'[^a-z0-9|]+')))
      if (w.isNotEmpty && !_stopWords.contains(w)) w,
  ];
  return [
    ...words,
    for (var i = 0; i + 1 < words.length; i++) words[i] + words[i + 1],
  ];
}

/// Distance d'édition (Levenshtein) entre deux mots déjà canoniques.
int _distance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
    previous = current;
  }
  return previous[b.length];
}

/// Le mot [word] de la référence se retrouve-t-il, approximativement, dans
/// les mots lus ? Tolérance : aucune lettre fausse sous 5 lettres, une
/// jusqu'à 7, deux au-delà.
bool _foundIn(String word, List<String> tokens) {
  final target = _ocrCanonical(word);
  final allowed = target.length < 5 ? 0 : (target.length < 8 ? 1 : 2);
  for (final token in tokens) {
    final candidate = _ocrCanonical(token);
    if ((candidate.length - target.length).abs() > allowed) continue;
    if (_distance(candidate, target) <= allowed) return true;
  }
  return false;
}

/// Ressemblance entre une référence de la cave et le texte lu sur une
/// étiquette : part des mots du nom de la référence (et de son producteur,
/// s'il aide) retrouvés quelque part dans le texte, de 0 à 1. Il faut au
/// moins un mot distinctif (pas « Château », « Domaine »…) retrouvé.
double labelMatchScore({
  required String labelText,
  required String drinkName,
  String? drinkProducer,
}) {
  final tokens = _labelTokens(labelText);
  if (tokens.isEmpty) return 0;
  double score(Set<String> set) {
    final words = set.toList();
    if (words.isEmpty) return 0;
    var found = 0;
    var distinctive = false;
    void count(Iterable<String> ws) {
      found += ws.length;
      if (ws.any((w) => !_genericWords.contains(w))) distinctive = true;
    }

    for (var i = 0; i < words.length; i++) {
      if (_foundIn(words[i], tokens)) {
        count([words[i]]);
      } else if (i + 1 < words.length &&
          _foundIn(words[i] + words[i + 1], tokens)) {
        // Deux mots collés par la reconnaissance (« CHATEAUFIGEAC »).
        count([words[i], words[i + 1]]);
        i++;
      }
    }
    return distinctive ? found / words.length : 0;
  }

  final name = similarityWords(drinkName);
  final byName = score(name);
  final withProducer = score({...name, ...similarityWords(drinkProducer)});
  return byName > withProducer ? byName : withProducer;
}
