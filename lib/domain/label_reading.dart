import 'drink_draft.dart';
import 'enums.dart';
import 'label_parsing.dart';
import 'text.dart';

// Lecture d'une étiquette (CDC §6.2) à partir des lignes de texte reconnues
// sur la photo (Tesseract ; le moteur est interchangeable, CDC §10) :
// - millésime, degré et volume extraits automatiquement ;
// - appellation comparée à la liste officielle de l'INAO (embarquée) ;
// - type et caractéristiques devinés d'après les mots de l'étiquette ;
// - nom et producteur : des suggestions (la ligne au plus gros texte, « mis
//   en bouteille par… ») que l'utilisateur corrige en touchant les lignes.
// Rien n'est enregistré sans validation.

/// Une ligne de texte reconnue, avec sa taille (hauteur des lettres, en
/// pixels de la photo) : le nom est souvent écrit en plus gros.
class LabelLine {
  const LabelLine(this.text, {this.height = 0});

  final String text;
  final double height;
}

/// Liste des appellations, prête pour la recherche dans un texte.
class AppellationIndex {
  AppellationIndex(Iterable<String> names)
    : _entries = [
        for (final name in names)
          if (_normalize(name).length >= 4) (name: name, key: _normalize(name)),
      ]..sort((a, b) => b.key.length.compareTo(a.key.length));

  /// Du plus long au plus court : la plus précise l'emporte (« Saint-Emilion
  /// grand cru » plutôt que « Saint-Emilion »).
  final List<({String name, String key})> _entries;

  int get length => _entries.length;

  /// Chargée depuis assets/appellations.txt (une par ligne).
  factory AppellationIndex.parse(String text) => AppellationIndex(
    text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty),
  );

  /// Appellation la plus précise présente, en mots entiers, dans [text].
  String? find(String text) {
    final haystack = ' ${_normalize(text)} ';
    for (final e in _entries) {
      if (haystack.contains(' ${e.key} ')) return e.name;
    }
    return null;
  }

  /// Sans accents ni casse, ponctuation remplacée par des espaces :
  /// « SAINT-ÉMILION » → « saint emilion ».
  static String _normalize(String text) =>
      fold(text).replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

/// Ce qui a été lu sur l'étiquette.
class LabelReading {
  const LabelReading({
    required this.lines,
    this.name,
    this.producer,
    this.appellation,
    this.vintage,
    this.abv,
    this.volumeMl,
    this.profile,
    this.characteristics = const {},
  });

  /// Toutes les lignes reconnues, dans l'ordre de lecture.
  final List<String> lines;

  /// Suggestions, modifiables par l'utilisateur.
  final String? name;
  final String? producer;
  final String? appellation;
  final int? vintage;
  final double? abv;
  final int? volumeMl;
  final FieldProfile? profile;
  final Set<String> characteristics;

  LabelReading copyWith({
    String? Function()? name,
    String? Function()? producer,
    String? Function()? appellation,
  }) => LabelReading(
    lines: lines,
    name: name == null ? this.name : name(),
    producer: producer == null ? this.producer : producer(),
    appellation: appellation == null ? this.appellation : appellation(),
    vintage: vintage,
    abv: abv,
    volumeMl: volumeMl,
    profile: profile,
    characteristics: characteristics,
  );

  /// Fiche à valider dans le formulaire. Une appellation de l'INAO est
  /// française : le pays est rempli (la fiche n'est alors pas « à compléter »).
  DrinkDraft toDraft() => DrinkDraft(
    name: name,
    producer: producer,
    appellation: appellation,
    country: appellation != null ? 'France' : null,
    abv: abv,
    volumeMl: volumeMl,
    vintage: vintage,
    profile: profile ?? (appellation != null ? FieldProfile.wine : null),
    characteristics: characteristics,
  );
}

/// Analyse les lignes d'une étiquette. [currentYear] : le millésime ne peut
/// pas être dans le futur.
LabelReading readLabel(
  List<LabelLine> recognized,
  AppellationIndex appellations, {
  required int currentYear,
}) {
  final lines = joinLeadWords(recognized);
  final texts = [
    for (final l in lines)
      if (l.text.trim().isNotEmpty) l.text.trim(),
  ];
  final all = texts.join('\n');
  final words = ' ${fold(all).replaceAll(RegExp(r'[^a-z0-9%]+'), ' ')} ';
  bool has(String pattern) => RegExp(pattern).hasMatch(words);

  final appellation = appellations.find(all);
  final profile = has(r' (biere|beer|bier|brasserie|brewery|ipa|stout|lager) ')
      ? FieldProfile.beer
      : has(
          r' (rhum|rum|whisky|whiskey|gin|vodka|cognac|armagnac|calvados'
          r'|liqueur|eau de vie|spirit) ',
        )
      ? FieldProfile.spirit
      : (appellation != null ||
            has(r' (vin|vins|wine|chateau|domaine|cru|cuvee|vignoble) '))
      ? FieldProfile.wine
      : null;

  return LabelReading(
    lines: texts,
    appellation: appellation,
    vintage: _vintage(texts, currentYear),
    abv: _abv(texts),
    volumeMl: _volume(texts),
    profile: profile,
    characteristics: _characteristics(profile, has),
    name: _name(lines, appellation),
    producer: _producer(texts),
  );
}

/// Millésime : une année plausible, de préférence seule sur sa ligne ou
/// annoncée (« millésime », « vintage ») ; jamais une date de fondation
/// (« depuis 1850 », « since », « fondé en »).
int? _vintage(List<String> lines, int currentYear) {
  int? best;
  var bestScore = -1 << 30;
  for (final line in lines) {
    final folded = fold(line);
    for (final m in RegExp(r'(?<!\d)(19\d\d|20\d\d)(?!\d)').allMatches(line)) {
      final year = int.parse(m.group(1)!);
      if (year < 1900 || year > currentYear) continue;
      var score = 0;
      if (line.trim() == m.group(1)) score += 3;
      if (RegExp(r'millesime|vintage|recolte').hasMatch(folded)) score += 3;
      final before = folded.substring(0, m.start).trimRight();
      if (RegExp(
        r'(depuis|since|founded|established|est\.?|(fonde|fondee|cree|creee) en)$',
      ).hasMatch(before)) {
        score -= 10;
      }
      if (score > bestScore || (score == bestScore && year > (best ?? 0))) {
        best = year;
        bestScore = score;
      }
    }
  }
  return bestScore < 0 ? null : best;
}

/// Degré : « 13 % vol », « 12,5% », « alc. 13.5 % vol ».
double? _abv(List<String> lines) {
  for (final line in lines) {
    final m = RegExp(r'(\d{1,2}(?:[.,]\d{1,2})?)\s*%').firstMatch(line);
    if (m == null) continue;
    final value = parseAbv(m.group(1));
    if (value != null && value >= 0.5 && value <= 80) return value;
  }
  return null;
}

int? _volume(List<String> lines) {
  for (final line in lines) {
    final ml = parseVolumeMl(line);
    if (ml != null) return ml;
  }
  return null;
}

Set<String> _characteristics(FieldProfile? profile, bool Function(String) has) {
  Set<String> pick(Map<String, String> byValue) => {
    for (final MapEntry(key: value, value: pattern) in byValue.entries)
      if (has(pattern)) value,
  };
  return switch (profile) {
    FieldProfile.wine => pick({
      'Rouge': r' (rouge|red|rot|tinto|rosso) ',
      'Blanc': r' (blanc|blancs|white|weiss|bianco) ',
      'Rosé': r' (rose|rosado) ',
      'Effervescent': r' (brut|champagne|cremant|mousseux|petillant|methode traditionnelle) ',
      'Moelleux': r' moelleux ',
      'Liquoreux': r' liquoreux ',
      'Demi-sec': r' demi sec ',
    }),
    FieldProfile.beer => pick({
      'Blonde': r' (blonde|blond) ',
      'Ambrée': r' (ambree|amber) ',
      'Brune': r' (brune|brown|dark) ',
      'Blanche': r' (blanche|white|wit|weizen) ',
      'IPA': r' (ipa|india pale ale) ',
      'Stout': r' stout ',
      'Lager': r' lager ',
    }),
    FieldProfile.spirit => pick({
      'Rhum': r' (rhum|rum) ',
      'Whisky': r' (whisky|whiskey) ',
      'Gin': r' gin ',
      'Calvados': r' calvados ',
      'Liqueur': r' liqueur ',
    }),
    _ => const {},
  };
}

/// Lignes qui ne sont jamais le nom : mentions légales, chiffres, appellation.
bool _isBoilerplate(String line, String? appellation) {
  final f = fold(line);
  if (RegExp(r'[a-z]{3,}').allMatches(f).isEmpty) return true;
  if (RegExp(
    r'mis en bouteille|contient|sulfites|produit de|product of|appellation'
    r'|controlee|protegee|% ?vol|\d+ ?(ml|cl|l)\b|enceinte|recyclage|lot ',
  ).hasMatch(f)) {
    return true;
  }
  if (appellation != null && fold(line).trim() == fold(appellation)) {
    return true;
  }
  return false;
}

/// Nom suggéré : la ligne au plus gros texte, hors mentions légales.
String? _name(List<LabelLine> lines, String? appellation) {
  LabelLine? best;
  for (final l in lines) {
    final text = l.text.trim();
    if (text.length < 3 || _isBoilerplate(text, appellation)) continue;
    if (best == null || l.height > best.height) best = l;
  }
  return best == null ? null : tidyLabelText(best.text);
}

/// Producteur : « mis en bouteille par X », sinon une ligne « Brasserie X ».
String? _producer(List<String> lines) {
  for (final line in lines) {
    final m = RegExp(
      r'mis en bouteilles?\s+par\s+(.+?)(?:\s+(?:à|a|-|–)\s+|,|$)',
      caseSensitive: false,
    ).firstMatch(line);
    if (m != null) return tidyLabelText(m.group(1)!);
  }
  for (final line in lines) {
    if (RegExp(r'^\s*brasserie\b', caseSensitive: false).hasMatch(line)) {
      return tidyLabelText(line);
    }
  }
  return null;
}

/// Mots qui annoncent toujours la suite du nom : « CHÂTEAU » écrit seul en
/// petit au-dessus de « LES TROIS CHÊNES ». Sans accents ni casse.
const leadWords = {
  'abbaye',
  'baron',
  'brasserie',
  'cave',
  'caves',
  'cellier',
  'ch',
  'chateau',
  'clos',
  'comte',
  'comtesse',
  'cuvee',
  'distillerie',
  'dom',
  'domaine',
  'domaines',
  'famille',
  'maison',
  'marquis',
  'mas',
  'moulin',
  'prieure',
  'saint',
  'sainte',
  'st',
  'ste',
  'vignoble',
  'vignobles',
};

/// Petits mots qui peuvent accompagner un mot de [leadWords] sur sa ligne
/// (« DOMAINE DE LA », « CHÂTEAU DU »).
const _leadCompanions = {'de', 'du', 'des', 'la', 'le', 'les', 'l', 'd', 'et'};

/// Colle à la ligne suivante une ligne faite seulement de mots qui ne sont
/// jamais seuls (« CHÂTEAU », « DOMAINE DE LA ») : le nom se lit alors en
/// une ligne. La suivante doit contenir des lettres (pas « 2019 »).
List<LabelLine> joinLeadWords(List<LabelLine> lines) {
  final result = <LabelLine>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final next = i + 1 < lines.length ? lines[i + 1] : null;
    if (next != null &&
        _onlyLeadWords(line.text) &&
        RegExp(r'[a-z]').hasMatch(fold(next.text))) {
      result.add(
        LabelLine(
          '${line.text.trim()} ${next.text.trim()}',
          height: line.height > next.height ? line.height : next.height,
        ),
      );
      i++;
    } else {
      result.add(line);
    }
  }
  return result;
}

bool _onlyLeadWords(String text) {
  final words = fold(text)
      .split(RegExp(r'[^a-z]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  return words.any(leadWords.contains) &&
      words.every((w) => leadWords.contains(w) || _leadCompanions.contains(w));
}

/// « CHÂTEAU FIGEAC » → « Château Figeac » : les étiquettes sont souvent
/// en capitales ; les petits mots restent en minuscules.
String tidyLabelText(String text) {
  final trimmed = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (trimmed != trimmed.toUpperCase()) return trimmed;
  const small = {'de', 'du', 'des', 'la', 'le', 'les', 'et', 'en', 'au', 'aux'};
  // Sigles gardés en capitales.
  const acronyms = {'ipa', 'aoc', 'aop', 'igp', 'vdn', 'xo', 'vsop', 'vs'};
  final words = trimmed.toLowerCase().split(' ');
  return [
    for (final (i, w) in words.indexed)
      if (acronyms.contains(w))
        w.toUpperCase()
      else if (i > 0 && small.contains(w))
        w
      else if (w.isEmpty)
        w
      else
        w
            .split('-')
            .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
            .join('-'),
  ].join(' ');
}
