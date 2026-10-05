/// Format des fichiers CSV d'export et d'import (CDC §6.7).
///
/// Deux fichiers : le stock (une ligne par lot) et l'historique (une ligne par
/// mouvement). Les noms de colonnes et les valeurs codées (nature, motif) font
/// partie du format : ils ne sont pas traduits, pour qu'un fichier exporté
/// reste relisible quelle que soit la langue de l'appareil. Les identifiants
/// permettent une restauration exacte ; ils peuvent être laissés vides dans
/// une saisie préparée dans un tableur.
library;

import '../../domain/enums.dart';

abstract final class StockColumns {
  static const drinkId = 'ID référence';
  static const lotId = 'ID lot';
  static const type = 'Type';
  static const name = 'Nom';
  static const producer = 'Producteur';
  static const appellation = 'Appellation';
  static const region = 'Région';
  static const country = 'Pays';
  static const grapes = 'Cépages';
  static const abv = 'Degré';
  static const rating = 'Note';
  static const favorite = 'Favori';
  static const comment = 'Commentaire';

  /// « Robe : Rouge | Sucre : Sec ».
  static const characteristics = 'Caractéristiques';
  static const vintage = 'Millésime';
  static const volumeMl = 'Volume (ml)';
  static const barcode = 'Code-barres';
  static const stock = 'Stock';
  static const addedOn = 'Ajouté le';

  static const all = [
    drinkId, lotId, type, name, producer, appellation, region, country, //
    grapes, abv, rating, favorite, comment, characteristics, vintage,
    volumeMl, barcode, stock, addedOn,
  ];
}

abstract final class HistoryColumns {
  static const movementId = 'ID mouvement';
  static const lotId = 'ID lot';
  static const drinkId = 'ID référence';
  static const name = 'Nom';
  static const vintage = 'Millésime';
  static const volumeMl = 'Volume (ml)';
  static const date = 'Date';
  static const kind = 'Nature';
  static const quantity = 'Quantité';
  static const reason = 'Motif';
  static const comment = 'Commentaire';

  static const all = [
    movementId, lotId, drinkId, name, vintage, volumeMl, date, kind, //
    quantity, reason, comment,
  ];
}

/// Séparateurs de la colonne « Caractéristiques ».
const characteristicSeparator = ' | ';
const familySeparator = ' : ';

const yes = 'oui';

const kindTokens = {
  MovementKind.entry: 'entrée',
  MovementKind.exit: 'sortie',
  MovementKind.inventory: 'inventaire',
};

const reasonTokens = {
  ExitReason.consumed: 'consommée',
  ExitReason.gifted: 'offerte',
  ExitReason.broken: 'cassée',
};

/// Date d'un mouvement : ISO 8601 en UTC, à la milliseconde près (l'ordre des
/// mouvements compte pour le calcul du stock).
String formatTimestamp(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toIso8601String();

/// Accepte une date ISO complète ou une simple date « 2026-10-05 ».
int? parseTimestamp(String text) =>
    DateTime.tryParse(text.trim())?.toUtc().millisecondsSinceEpoch;

/// Degré : virgule décimale à l'écriture (tableurs français), virgule ou
/// point à la lecture.
String formatDecimal(double value) =>
    (value == value.roundToDouble() ? value.toInt().toString() : '$value')
        .replaceAll('.', ',');

double? parseDecimal(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));
