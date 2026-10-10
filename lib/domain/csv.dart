/// Lecture et écriture de fichiers CSV (format des tableurs, RFC 4180).
///
/// Écrit volontairement à la main plutôt qu'avec une bibliothèque : le format
/// est simple et ce module garde la main sur les détails qui comptent pour
/// Excel et LibreOffice en français (séparateur « ; », marque UTF-8).
library;

import 'text.dart';

/// Marque d'ordre des octets UTF-8 : sans elle, Excel affiche mal les accents.
const utf8Bom = '﻿';

/// Écrit un tableau en CSV : séparateur [delimiter], fins de ligne Windows
/// (attendues par Excel), marque UTF-8 en tête.
String encodeCsv(List<List<String>> rows, {String delimiter = ';'}) {
  final buffer = StringBuffer(utf8Bom);
  for (final row in rows) {
    buffer
      ..write(row.map((cell) => _quote(cell, delimiter)).join(delimiter))
      ..write('\r\n');
  }
  return buffer.toString();
}

String _quote(String cell, String delimiter) {
  final needsQuotes =
      cell.contains(delimiter) ||
      cell.contains('"') ||
      cell.contains('\n') ||
      cell.contains('\r') ||
      cell.startsWith(' ') ||
      cell.endsWith(' ');
  return needsQuotes ? '"${cell.replaceAll('"', '""')}"' : cell;
}

/// Lit un CSV. Le séparateur (« ; », « , » ou tabulation) est deviné d'après
/// la première ligne. Gère les guillemets, les guillemets doublés et les
/// retours à la ligne à l'intérieur d'un champ. Les lignes vides sont ignorées.
List<List<String>> decodeCsv(String input) {
  var text = input.startsWith(utf8Bom) ? input.substring(1) : input;
  text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final delimiter = _guessDelimiter(text);

  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;

  void endCell() {
    row.add(cell.toString());
    cell.clear();
  }

  void endRow() {
    endCell();
    if (!(row.length == 1 && row.single.isEmpty)) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(c);
      }
    } else if (c == '"' && cell.isEmpty) {
      inQuotes = true;
    } else if (c == delimiter) {
      endCell();
    } else if (c == '\n') {
      endRow();
    } else {
      cell.write(c);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// Le séparateur le plus fréquent hors guillemets sur la première ligne.
String _guessDelimiter(String text) {
  final counts = {';': 0, ',': 0, '\t': 0};
  var inQuotes = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (c == '"') inQuotes = !inQuotes;
    if (!inQuotes && c == '\n') break;
    if (!inQuotes && counts.containsKey(c)) counts[c] = counts[c]! + 1;
  }
  final best = counts.entries.reduce((a, b) => b.value > a.value ? b : a);
  return best.value == 0 ? ';' : best.key;
}

/// Un tableau CSV dont la première ligne donne les noms de colonnes.
/// Les colonnes sont retrouvées par leur nom, sans tenir compte de la casse,
/// des accents ni des espaces : l'ordre des colonnes n'a pas d'importance.
class CsvTable {
  CsvTable(List<List<String>> rows)
    : header = rows.isEmpty ? const [] : rows.first,
      rows = rows.length <= 1 ? const [] : rows.sublist(1);

  final List<String> header;
  final List<List<String>> rows;

  late final Map<String, int> _index = {
    for (final (i, name) in header.indexed) normalizeHeader(name): i,
  };

  bool has(String column) => _index.containsKey(normalizeHeader(column));

  /// Valeur d'une colonne pour une ligne, sans espaces autour ; vide si la
  /// colonne n'existe pas ou si la ligne est plus courte.
  String cell(List<String> row, String column) {
    final i = _index[normalizeHeader(column)];
    return (i == null || i >= row.length) ? '' : row[i].trim();
  }
}

/// « Volume (ml) » → « volumeml », « Région » → « region » : sans accents,
/// majuscules, espaces ni ponctuation ([compactKey]).
String normalizeHeader(String name) => compactKey(name);
