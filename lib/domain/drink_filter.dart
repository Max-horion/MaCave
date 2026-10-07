/// Critères de la liste de la cave : recherche, filtres et tri (CDC §6.5).
library;

/// Tris proposés dans la liste.
enum DrinkSort {
  /// Par nom, de A à Z (par défaut).
  name,

  /// Les dernières références ajoutées en premier.
  recentlyAdded,

  /// Du millésime le plus ancien au plus récent, sans millésime en dernier.
  vintage,

  /// Les plus gros stocks en premier.
  stock,
}

/// État des filtres de la liste. Immuable : chaque changement crée une copie.
class DrinkFilter {
  const DrinkFilter({
    this.query = '',
    this.typeId,
    this.characteristicIds = const {},
    this.region,
    this.favoritesOnly = false,
    this.needsCompletionOnly = false,
    this.showExhausted = false,
    this.sort = DrinkSort.name,
  });

  /// Texte libre tapé dans la recherche.
  final String query;
  final String? typeId;

  /// Caractéristiques exigées (la référence doit les avoir toutes).
  final Set<String> characteristicIds;

  /// Région ou pays.
  final String? region;
  final bool favoritesOnly;
  final bool needsCompletionOnly;

  /// Afficher aussi les références dont tous les lots sont épuisés (CDC §6.4).
  final bool showExhausted;
  final DrinkSort sort;

  /// Nombre de filtres actifs (hors recherche et tri), pour le badge du bouton.
  int get activeCount =>
      (typeId != null ? 1 : 0) +
      characteristicIds.length +
      (region != null ? 1 : 0) +
      (favoritesOnly ? 1 : 0) +
      (needsCompletionOnly ? 1 : 0) +
      (showExhausted ? 1 : 0);

  DrinkFilter copyWith({
    String? query,
    String? Function()? typeId,
    Set<String>? characteristicIds,
    String? Function()? region,
    bool? favoritesOnly,
    bool? needsCompletionOnly,
    bool? showExhausted,
    DrinkSort? sort,
  }) {
    return DrinkFilter(
      query: query ?? this.query,
      typeId: typeId != null ? typeId() : this.typeId,
      characteristicIds: characteristicIds ?? this.characteristicIds,
      region: region != null ? region() : this.region,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      needsCompletionOnly: needsCompletionOnly ?? this.needsCompletionOnly,
      showExhausted: showExhausted ?? this.showExhausted,
      sort: sort ?? this.sort,
    );
  }

  /// Retire tous les filtres, garde la recherche et le tri ; les épuisés
  /// reviennent à [showExhausted] (réglage par défaut).
  DrinkFilter cleared({bool showExhausted = false}) =>
      DrinkFilter(query: query, sort: sort, showExhausted: showExhausted);
}

/// Transforme le texte tapé en requête FTS5, ou `null` s'il n'y a rien à
/// chercher.
///
/// Chaque mot devient un préfixe entre guillemets : « ch fig » cherche les
/// références contenant un mot commençant par « ch » ET un mot commençant par
/// « fig ». Les guillemets neutralisent les caractères spéciaux de FTS5
/// (`-`, `*`, `:`…) qu'un utilisateur pourrait taper.
///
/// Pluriels : un « s » ou un « x » final est retiré des mots de plus de trois
/// lettres (« vins rouges » → « vin* rouge* »). Comme la recherche se fait par
/// début de mot, « gris » → « gri* » trouve toujours « gris ».
String? ftsQuery(String input) {
  final words = input
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((w) => w.isNotEmpty)
      .map(_singular);
  if (words.isEmpty) return null;
  return words.map((w) => '"$w"*').join(' ');
}

String _singular(String word) {
  if (word.length <= 3) return word;
  final last = word[word.length - 1].toLowerCase();
  return last == 's' || last == 'x' ? word.substring(0, word.length - 1) : word;
}
