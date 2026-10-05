import '../../domain/csv.dart';
import '../database.dart';
import 'exchange_format.dart';

/// Les deux fichiers d'un export CSV.
class CsvExport {
  const CsvExport({required this.stock, required this.history});

  final String stock;
  final String history;
}

/// Produit l'export CSV de la cave (CDC §6.7) : le stock, une ligne par lot
/// (et une ligne sans lot pour une référence qui n'en a plus), et l'historique,
/// une ligne par mouvement. Les éléments supprimés ne sont pas exportés.
Future<CsvExport> exportCsv(CaveDatabase db) async {
  final characteristics = await _characteristicsByDrink(db);

  final stockRows = await db.customSelect('''
    SELECT d.*, t.name AS type_name,
      l.id AS lot_id, l.vintage AS lot_vintage, l.volume_ml AS lot_volume,
      l.barcode AS lot_barcode, l.stock AS lot_stock, l.created_at AS lot_created
    FROM drinks d
    LEFT JOIN drink_types t ON t.id = d.type_id AND t.deleted_at IS NULL
    LEFT JOIN lots l ON l.drink_id = d.id AND l.deleted_at IS NULL
    WHERE d.deleted_at IS NULL
    ORDER BY d.name COLLATE NOCASE, d.id, l.vintage, l.volume_ml
  ''').get();

  final stock = <List<String>>[StockColumns.all];
  for (final row in stockRows) {
    final d = db.drinks.map(row.data);
    final lotId = row.readNullable<String>('lot_id');
    stock.add([
      d.id,
      lotId ?? '',
      row.readNullable<String>('type_name') ?? '',
      d.name,
      d.producer ?? '',
      d.appellation ?? '',
      d.region ?? '',
      d.country ?? '',
      d.grapes ?? '',
      d.abv == null ? '' : formatDecimal(d.abv!),
      d.rating?.toString() ?? '',
      d.favorite ? yes : '',
      d.comment ?? '',
      characteristics[d.id] ?? '',
      row.readNullable<int>('lot_vintage')?.toString() ?? '',
      row.readNullable<int>('lot_volume')?.toString() ?? '',
      row.readNullable<String>('lot_barcode') ?? '',
      lotId == null ? '' : '${row.read<int>('lot_stock')}',
      lotId == null ? '' : formatTimestamp(row.read<int>('lot_created')),
    ]);
  }

  final movementRows = await db.customSelect('''
    SELECT m.*, l.drink_id AS drink_id, l.vintage AS lot_vintage,
      l.volume_ml AS lot_volume, d.name AS drink_name
    FROM movements m
    JOIN lots l ON l.id = m.lot_id AND l.deleted_at IS NULL
    JOIN drinks d ON d.id = l.drink_id AND d.deleted_at IS NULL
    WHERE m.deleted_at IS NULL
    ORDER BY m.occurred_at, m.id
  ''').get();

  final history = <List<String>>[HistoryColumns.all];
  for (final row in movementRows) {
    final m = db.movements.map(row.data);
    history.add([
      m.id,
      m.lotId,
      row.read<String>('drink_id'),
      row.read<String>('drink_name'),
      row.readNullable<int>('lot_vintage')?.toString() ?? '',
      '${row.read<int>('lot_volume')}',
      formatTimestamp(m.occurredAt),
      kindTokens[m.kind]!,
      '${m.quantity}',
      m.reason == null ? '' : reasonTokens[m.reason]!,
      m.comment ?? '',
    ]);
  }

  return CsvExport(stock: encodeCsv(stock), history: encodeCsv(history));
}

/// « Robe : Rouge | Sucre : Sec » pour chaque référence.
Future<Map<String, String>> _characteristicsByDrink(CaveDatabase db) async {
  final rows = await db.customSelect('''
    SELECT dc.drink_id, f.name AS family, c.name AS value
    FROM drink_characteristics dc
    JOIN characteristics c ON c.id = dc.characteristic_id AND c.deleted_at IS NULL
    JOIN characteristic_families f ON f.id = c.family_id AND f.deleted_at IS NULL
    WHERE dc.deleted_at IS NULL
    ORDER BY f.sort_order, c.sort_order
  ''').get();
  final result = <String, List<String>>{};
  for (final r in rows) {
    result
        .putIfAbsent(r.read<String>('drink_id'), () => [])
        .add(
          '${r.read<String>('family')}$familySeparator${r.read<String>('value')}',
        );
  }
  return result.map((k, v) => MapEntry(k, v.join(characteristicSeparator)));
}
