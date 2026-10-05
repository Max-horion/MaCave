/// Conversion de l'export Vivino (« cellar.csv ») en références (CDC §6.7).
library;

import 'csv.dart';
import 'text.dart';

/// Colonnes utilisées de l'export Vivino.
abstract final class VivinoColumns {
  static const winery = 'Winery';
  static const wineName = 'Wine name';
  static const vintage = 'Vintage';
  static const region = 'Region';
  static const country = 'Country';
  static const wineType = 'Wine type';
  static const quantity = 'User cellar count';
}

/// Une ligne de l'export Vivino, interprétée.
class VivinoWine {
  const VivinoWine({
    required this.line,
    required this.name,
    required this.producer,
    required this.appellation,
    required this.region,
    required this.country,
    required this.vintage,
    required this.quantity,
    required this.characteristics,
  });

  /// Numéro de ligne dans le fichier (1 = en-têtes).
  final int line;
  final String name;
  final String? producer;
  final String? appellation;
  final String? region;
  final String? country;
  final int? vintage;
  final int quantity;

  /// Caractéristiques déduites du type Vivino, « famille → valeur ».
  final Map<String, String> characteristics;
}

/// Vrai si le fichier ressemble à un export Vivino.
bool isVivinoExport(CsvTable table) =>
    table.has(VivinoColumns.winery) && table.has(VivinoColumns.wineName);

/// Interprète les lignes de l'export. Les lignes sans nom sont ignorées.
///
/// Règles :
/// - Vivino appelle souvent « nom du vin » ce qui est en fait l'appellation
///   (il est alors identique à la région, aux espaces, traits d'union et
///   accents près) : le domaine devient le nom de la
///   référence, ce « nom » devient l'appellation. Sinon, nom = domaine + nom
///   du vin, sans appellation (la fiche sera « à compléter ») ;
/// - pays en code (« fr ») ou en anglais traduit en français ;
/// - type Vivino → caractéristique Robe ou Style ; « Dessert » et « Fortified »
///   n'ont pas d'équivalent sûr et sont laissés sans caractéristique ;
/// - la note moyenne de la communauté n'est pas importée (pas d'aspect
///   social, CDC §2.3), ni le lien vers Vivino.
List<VivinoWine> parseVivino(CsvTable table) {
  final wines = <VivinoWine>[];
  for (final (i, row) in table.rows.indexed) {
    String col(String name) => table.cell(row, name);
    final winery = col(VivinoColumns.winery);
    final wineName = col(VivinoColumns.wineName);
    if (winery.isEmpty && wineName.isEmpty) continue;

    final region = col(VivinoColumns.region);
    final nameIsAppellation =
        wineName.isNotEmpty &&
        region.isNotEmpty &&
        compactKey(wineName) == compactKey(region);
    final String name;
    final String? appellation;
    if (nameIsAppellation && winery.isNotEmpty) {
      name = winery;
      appellation = wineName;
    } else {
      name = [winery, wineName].where((s) => s.isNotEmpty).join(' ');
      appellation = null;
    }

    wines.add(
      VivinoWine(
        line: i + 2,
        name: name,
        producer: winery.isEmpty ? null : winery,
        appellation: appellation,
        region: region.isEmpty ? null : region,
        country: frenchCountry(col(VivinoColumns.country)),
        vintage: _vintage(col(VivinoColumns.vintage)),
        quantity: int.tryParse(col(VivinoColumns.quantity)) ?? 1,
        characteristics: _characteristics(col(VivinoColumns.wineType)),
      ),
    );
  }
  return wines;
}

int? _vintage(String text) {
  final year = int.tryParse(text);
  // Vivino note parfois « 0 » ou « N.V. » pour les non-millésimés.
  return year == null || year < 1800 ? null : year;
}

Map<String, String> _characteristics(String wineType) {
  final type = fold(wineType);
  if (type.startsWith('red')) return {'Robe': 'Rouge'};
  if (type.startsWith('white')) return {'Robe': 'Blanc'};
  if (type.startsWith('rose')) return {'Robe': 'Rosé'};
  if (type.startsWith('sparkling')) return {'Style': 'Effervescent'};
  return const {};
}

/// Pays de l'export Vivino (code ISO ou nom anglais) → nom français.
String? frenchCountry(String text) {
  final key = fold(text.trim());
  if (key.isEmpty) return null;
  const names = {
    'fr': 'France',
    'france': 'France',
    'it': 'Italie',
    'italy': 'Italie',
    'es': 'Espagne',
    'spain': 'Espagne',
    'pt': 'Portugal',
    'portugal': 'Portugal',
    'de': 'Allemagne',
    'germany': 'Allemagne',
    'at': 'Autriche',
    'austria': 'Autriche',
    'ch': 'Suisse',
    'switzerland': 'Suisse',
    'gr': 'Grèce',
    'greece': 'Grèce',
    'hu': 'Hongrie',
    'hungary': 'Hongrie',
    'lb': 'Liban',
    'lebanon': 'Liban',
    'us': 'États-Unis',
    'united states': 'États-Unis',
    'ar': 'Argentine',
    'argentina': 'Argentine',
    'cl': 'Chili',
    'chile': 'Chili',
    'za': 'Afrique du Sud',
    'south africa': 'Afrique du Sud',
    'au': 'Australie',
    'australia': 'Australie',
    'nz': 'Nouvelle-Zélande',
    'new zealand': 'Nouvelle-Zélande',
    'gb': 'Royaume-Uni',
    'united kingdom': 'Royaume-Uni',
  };
  return names[key] ?? text.trim();
}
