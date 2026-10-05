// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ma Cave';

  @override
  String get homeEmptyTitle => 'Votre cave est vide';

  @override
  String get homeEmptyMessage =>
      'Touchez « Ajouter » pour enregistrer votre première bouteille.';

  @override
  String bottleCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString bouteilles',
      one: '1 bouteille',
      zero: 'Aucune bouteille',
    );
    return '$_temp0';
  }

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get actionDecrease => 'Moins';

  @override
  String get actionIncrease => 'Plus';

  @override
  String get searchHint => 'Rechercher une boisson';

  @override
  String get filtersTooltip => 'Filtres';

  @override
  String get sortTooltip => 'Trier';

  @override
  String get sortByName => 'Nom';

  @override
  String get sortRecentlyAdded => 'Derniers ajouts';

  @override
  String get sortByVintage => 'Millésime';

  @override
  String get sortByStock => 'Stock';

  @override
  String get addDrinkButton => 'Ajouter';

  @override
  String get noResultsTitle => 'Aucun résultat';

  @override
  String get noResultsMessage => 'Modifiez la recherche ou les filtres.';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String drinkCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString références',
      one: '1 référence',
      zero: 'Aucune référence',
    );
    return '$_temp0';
  }

  @override
  String cellarSummary(String bottles, String drinks) {
    return '$bottles · $drinks';
  }

  @override
  String get quickExitTooltip => 'Retirer une bouteille';

  @override
  String get bottleRemoved => 'Bouteille retirée';

  @override
  String bottlesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles retirées',
      one: '1 bouteille retirée',
    );
    return '$_temp0';
  }

  @override
  String bottlesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles ajoutées',
      one: '1 bouteille ajoutée',
    );
    return '$_temp0';
  }

  @override
  String get stockCorrected => 'Stock corrigé';

  @override
  String get chooseLotTitle => 'Quelle bouteille ?';

  @override
  String get withoutVintage => 'Sans millésime';

  @override
  String get uncategorized => 'Sans catégorie';

  @override
  String get needsCompletionLabel => 'À compléter';

  @override
  String get favoriteLabel => 'Favori';

  @override
  String lotSummary(String vintage, String volume) {
    return '$vintage · $volume';
  }

  @override
  String get filtersTitle => 'Filtres';

  @override
  String get filterType => 'Type';

  @override
  String get filterAllTypes => 'Tous';

  @override
  String get filterRegion => 'Région ou pays';

  @override
  String get filterAnyRegion => 'Toutes';

  @override
  String get filterFavorites => 'Favoris uniquement';

  @override
  String get filterNeedsCompletion => 'Fiches à compléter';

  @override
  String get filterShowExhausted => 'Afficher les épuisés';

  @override
  String get showResults => 'Voir les résultats';

  @override
  String get lotsSection => 'Lots';

  @override
  String get addLot => 'Ajouter un lot';

  @override
  String get addBottles => 'Ajouter des bouteilles';

  @override
  String get removeBottles => 'Retirer des bouteilles';

  @override
  String get correctStock => 'Corriger le stock';

  @override
  String get correctStockHelp => 'Nombre de bouteilles réellement présentes.';

  @override
  String get deleteLot => 'Supprimer le lot';

  @override
  String get deleteDrink => 'Supprimer la référence';

  @override
  String deleteDrinkConfirm(String name) {
    return 'Supprimer « $name » et tous ses lots ?';
  }

  @override
  String deleteLotConfirm(String lot) {
    return 'Supprimer le lot « $lot » ?';
  }

  @override
  String get needsCompletionBanner =>
      'Il manque des informations obligatoires sur cette fiche.';

  @override
  String addedOn(String date) {
    return 'Ajouté le $date';
  }

  @override
  String get drinkNotFound => 'Cette référence n\'existe plus.';

  @override
  String get exhausted => 'Épuisé';

  @override
  String get formNewTitle => 'Nouvelle boisson';

  @override
  String get formEditTitle => 'Modifier la fiche';

  @override
  String get formLotSection => 'Bouteilles';

  @override
  String get characteristicsSection => 'Caractéristiques';

  @override
  String get formIncompleteWarning =>
      'Sans appellation ni région, la fiche sera marquée « à compléter ».';

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldProducer => 'Producteur ou domaine';

  @override
  String get fieldAppellation => 'Appellation';

  @override
  String get fieldRegion => 'Région';

  @override
  String get fieldCountry => 'Pays';

  @override
  String get fieldGrapes => 'Cépages';

  @override
  String get fieldAbv => 'Degré d\'alcool (% vol.)';

  @override
  String get fieldRating => 'Note personnelle';

  @override
  String get fieldComment => 'Commentaire';

  @override
  String get fieldVintage => 'Millésime';

  @override
  String get fieldVolume => 'Volume';

  @override
  String get fieldQuantity => 'Nombre de bouteilles';

  @override
  String get fieldReason => 'Motif';

  @override
  String get requiredFieldError => 'Champ obligatoire';

  @override
  String invalidVintage(int max) {
    return 'Année entre 1800 et $max';
  }

  @override
  String get invalidNumber => 'Nombre invalide';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get reasonConsumed => 'Consommée';

  @override
  String get reasonGifted => 'Offerte';

  @override
  String get reasonBroken => 'Cassée';

  @override
  String volumeCentiliters(String value) {
    return '$value cl';
  }

  @override
  String volumeLiters(String value) {
    return '$value l';
  }

  @override
  String abvValue(String value) {
    return '$value % vol.';
  }

  @override
  String get errorInsufficientStock => 'Stock insuffisant';

  @override
  String errorGeneric(String message) {
    return 'Une erreur est survenue : $message';
  }
}
