import '../../domain/csv.dart';
import '../../domain/enums.dart';
import '../cave_queries.dart';
import '../database.dart';
import 'exchange_format.dart';

/// Colonnes du fichier modèle à remplir dans un tableur : celles du fichier
/// de stock, sans les identifiants ni la date d'ajout (remplis par l'appli).
const templateColumns = [
  StockColumns.type,
  StockColumns.name,
  StockColumns.producer,
  StockColumns.appellation,
  StockColumns.region,
  StockColumns.country,
  StockColumns.grapes,
  StockColumns.abv,
  StockColumns.rating,
  StockColumns.favorite,
  StockColumns.comment,
  StockColumns.characteristics,
  StockColumns.vintage,
  StockColumns.volumeMl,
  StockColumns.barcode,
  StockColumns.stock,
];

/// Début du nom des lignes d'exemple : l'utilisateur les reconnaît et les
/// supprime avant l'import.
const templateExamplePrefix = 'EXEMPLE';

/// Fichier modèle pour un import « maison » (CDC §6.7) : l'en-tête et deux
/// lignes d'exemple (un vin, une bière) écrites avec la classification de
/// l'utilisateur, pour qu'elles soient reconnues telles quelles. Même format
/// que l'export (point-virgule, UTF-8).
String importTemplateCsv(Classification classification) {
  final rows = <List<String>>[templateColumns];

  /// « Robe : Rouge | Style : Tranquille » : première valeur de chaque
  /// famille du type (deux familles au plus).
  String characteristicsOf(String typeId) => [
    for (final family in classification.familiesOf(typeId).take(2))
      if (classification.valuesOf(family.id).firstOrNull case final value?)
        '${family.name}$familySeparator${value.name}',
  ].join(characteristicSeparator);

  List<String> row(Map<String, String> cells) => [
    for (final column in templateColumns) cells[column] ?? '',
  ];

  final wine = _typeWithProfile(classification, FieldProfile.wine);
  if (wine != null) {
    rows.add(
      row({
        StockColumns.type: wine.name,
        StockColumns.name: '$templateExamplePrefix ${wine.name} (à supprimer)',
        StockColumns.producer: 'Domaine Imaginaire',
        StockColumns.appellation: 'Bordeaux supérieur',
        StockColumns.region: 'Bordeaux',
        StockColumns.country: 'France',
        StockColumns.grapes: 'Merlot, Cabernet franc',
        StockColumns.abv: '13,5',
        StockColumns.rating: '4',
        StockColumns.favorite: yes,
        StockColumns.characteristics: characteristicsOf(wine.id),
        StockColumns.vintage: '2020',
        StockColumns.volumeMl: '750',
        StockColumns.stock: '6',
      }),
    );
  }
  final beer = _typeWithProfile(classification, FieldProfile.beer);
  if (beer != null) {
    rows.add(
      row({
        StockColumns.type: beer.name,
        StockColumns.name: '$templateExamplePrefix ${beer.name} (à supprimer)',
        StockColumns.producer: 'Brasserie Imaginaire',
        StockColumns.country: 'Belgique',
        StockColumns.abv: '6,5',
        StockColumns.characteristics: characteristicsOf(beer.id),
        StockColumns.volumeMl: '330',
        StockColumns.stock: '12',
      }),
    );
  }
  return encodeCsv(rows);
}

DrinkType? _typeWithProfile(Classification c, FieldProfile profile) =>
    c.types.where((t) => t.fieldProfile == profile).firstOrNull;
