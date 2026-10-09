import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../domain/enums.dart';
import '../l10n/app_localizations.dart';

/// Volumes proposés dans les formulaires, en millilitres.
const standardVolumesMl = [
  100, 200, 250, 330, 375, 440, 500, 700, 750, 1000, 1500, 2000, 3000, 5000,
  6000, //
];

/// Mise en forme des valeurs affichées, selon la langue de l'appareil
/// (CDC §9 : dates et nombres au format de la langue).
class Formats {
  Formats.of(BuildContext context)
    : l10n = AppLocalizations.of(context),
      _locale = Localizations.localeOf(context).toString();

  final AppLocalizations l10n;
  final String _locale;

  /// 750 → « 75 cl », 375 → « 37,5 cl », 1500 → « 1,5 l ».
  String volume(int ml) {
    final number = NumberFormat('#,##0.##', _locale);
    return ml >= 1000
        ? l10n.volumeLiters(number.format(ml / 1000))
        : l10n.volumeCentiliters(number.format(ml / 10));
  }

  String vintage(int? vintage) => vintage?.toString() ?? l10n.withoutVintage;

  /// « 2018 · 75 cl », ou seulement le volume s'il n'y a pas de millésime.
  String lot(Lot lot) => lot.vintage == null
      ? volume(lot.volumeMl)
      : l10n.lotSummary('${lot.vintage}', volume(lot.volumeMl));

  /// Comme [lot], mais affiche « Sans millésime » (choix entre plusieurs lots).
  String lotExplicit(Lot lot) =>
      l10n.lotSummary(vintage(lot.vintage), volume(lot.volumeMl));

  String date(int millis) =>
      DateFormat.yMMMMd(_locale)
          .format(DateTime.fromMillisecondsSinceEpoch(millis));

  /// « 5 octobre 2026 14:30 ».
  String dateTime(DateTime value) =>
      DateFormat.yMMMMd(_locale).add_Hm().format(value);

  String abv(double value) =>
      l10n.abvValue(NumberFormat('0.#', _locale).format(value));

  String number(num value) =>
      NumberFormat.decimalPattern(_locale).format(value);

  String reason(ExitReason reason) => switch (reason) {
    ExitReason.consumed => l10n.reasonConsumed,
    ExitReason.gifted => l10n.reasonGifted,
    ExitReason.broken => l10n.reasonBroken,
  };
}
