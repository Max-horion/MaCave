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
      'Sans région ni pays, la fiche sera marquée « à compléter ».';

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

  @override
  String get menuTooltip => 'Plus d\'actions';

  @override
  String get menuInventory => 'Inventaire';

  @override
  String get menuStatistics => 'Statistiques';

  @override
  String get menuImport => 'Importer un fichier';

  @override
  String get menuExport => 'Exporter (CSV)';

  @override
  String get historySection => 'Historique';

  @override
  String get historyEmpty => 'Aucun mouvement.';

  @override
  String movementEntry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count bouteilles',
      one: '+1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String movementExit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '−$count bouteilles',
      one: '−1 bouteille',
    );
    return '$_temp0';
  }

  @override
  String movementInventory(int count) {
    return 'Inventaire : $count';
  }

  @override
  String get exportTitle => 'Exporter la cave';

  @override
  String get exportHelp =>
      'Deux fichiers CSV, lisibles dans Excel ou LibreOffice : le stock et l\'historique. Ils servent aussi de sauvegarde.';

  @override
  String get exportShare => 'Partager';

  @override
  String get exportSave => 'Enregistrer sur le téléphone';

  @override
  String exportSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers enregistrés',
      one: '1 fichier enregistré',
    );
    return '$_temp0';
  }

  @override
  String exportFileStock(String date) {
    return 'ma-cave-stock-$date.csv';
  }

  @override
  String exportFileHistory(String date) {
    return 'ma-cave-historique-$date.csv';
  }

  @override
  String get importPreviewTitle => 'Aperçu de l\'import';

  @override
  String get importKindStock => 'Sauvegarde ou tableur : stock';

  @override
  String get importKindHistory => 'Sauvegarde : historique';

  @override
  String get importKindVivino => 'Export Vivino';

  @override
  String importDrinksCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count références créées',
      one: '1 référence créée',
      zero: 'Aucune référence créée',
    );
    return '$_temp0';
  }

  @override
  String importLotsCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots créés',
      one: '1 lot créé',
      zero: 'Aucun lot créé',
    );
    return '$_temp0';
  }

  @override
  String importBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles ajoutées',
      one: '1 bouteille ajoutée',
      zero: 'Aucune bouteille ajoutée',
    );
    return '$_temp0';
  }

  @override
  String importLotsAdjusted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots existants remis au stock du fichier',
      one: '1 lot existant remis au stock du fichier',
    );
    return '$_temp0';
  }

  @override
  String importLotsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots déjà présents, laissés tels quels',
      one: '1 lot déjà présent, laissé tel quel',
    );
    return '$_temp0';
  }

  @override
  String importMovements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mouvements ajoutés',
      one: '1 mouvement ajouté',
      zero: 'Aucun mouvement ajouté',
    );
    return '$_temp0';
  }

  @override
  String importMovementsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mouvements déjà présents',
      one: '1 mouvement déjà présent',
    );
    return '$_temp0';
  }

  @override
  String importNeedsCompletion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fiches seront « à compléter »',
      one: '1 fiche sera « à compléter »',
    );
    return '$_temp0';
  }

  @override
  String importUnknownCharacteristics(String names) {
    return 'Caractéristiques inconnues, ignorées : $names';
  }

  @override
  String importIssuesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes ignorées',
      one: '1 ligne ignorée',
    );
    return '$_temp0';
  }

  @override
  String importIssueLine(int line, String message) {
    return 'Ligne $line : $message';
  }

  @override
  String get importNothing => 'Rien à importer : tout est déjà dans la cave.';

  @override
  String get importConfirm => 'Importer';

  @override
  String get importDone => 'Import terminé';

  @override
  String importUnreadable(String message) {
    return 'Fichier illisible : $message';
  }

  @override
  String get issueUnknownFormat =>
      'fichier non reconnu (ni sauvegarde Ma Cave, ni export Vivino)';

  @override
  String get issueMissingName => 'nom manquant';

  @override
  String issueInvalidVolume(String value) {
    return 'volume invalide « $value »';
  }

  @override
  String issueInvalidVintage(String value) {
    return 'millésime invalide « $value »';
  }

  @override
  String issueInvalidStock(String value) {
    return 'stock invalide « $value »';
  }

  @override
  String issueUnknownLot(String value) {
    return 'lot introuvable « $value »';
  }

  @override
  String issueInvalidDate(String value) {
    return 'date invalide « $value »';
  }

  @override
  String issueInvalidKind(String value) {
    return 'nature invalide « $value »';
  }

  @override
  String issueInvalidQuantity(String value) {
    return 'quantité invalide « $value »';
  }

  @override
  String get inventoryTitle => 'Inventaire';

  @override
  String get inventoryIntro =>
      'Les lots défilent un par un : confirmez le nombre de bouteilles, ou corrigez-le.';

  @override
  String get inventoryIncludeExhausted => 'Inclure les lots épuisés';

  @override
  String inventoryLotCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots à vérifier',
      one: '1 lot à vérifier',
      zero: 'Aucun lot à vérifier',
    );
    return '$_temp0';
  }

  @override
  String get inventoryStart => 'Commencer';

  @override
  String inventoryProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get inventoryRecorded => 'Stock enregistré';

  @override
  String get inventoryConfirm => 'C\'est juste';

  @override
  String get inventoryCorrect => 'Corriger';

  @override
  String get inventoryValidate => 'Valider';

  @override
  String get inventoryPrevious => 'Précédent';

  @override
  String get inventoryDoneTitle => 'Inventaire terminé';

  @override
  String inventorySummary(int confirmed, int corrected) {
    String _temp0 = intl.Intl.pluralLogic(
      confirmed,
      locale: localeName,
      other: '$confirmed lots confirmés',
      one: '1 lot confirmé',
      zero: 'Aucun lot confirmé',
    );
    String _temp1 = intl.Intl.pluralLogic(
      corrected,
      locale: localeName,
      other: '$corrected corrigés',
      one: '1 corrigé',
      zero: 'aucun corrigé',
    );
    return '$_temp0, $_temp1.';
  }

  @override
  String get inventoryFinish => 'Terminer';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsBottles => 'Bouteilles';

  @override
  String get statsDrinks => 'Références';

  @override
  String get statsByType => 'Par type';

  @override
  String get statsByRegion => 'Par région ou pays';

  @override
  String get statsOther => 'Autres';

  @override
  String get statsUnknownRegion => 'Non renseignée';

  @override
  String get statsEmpty => 'Ajoutez des bouteilles pour voir les statistiques.';

  @override
  String statsBarValue(String label, String count) {
    return '$label : $count';
  }

  @override
  String get menuBackups => 'Sauvegardes';

  @override
  String get backupTitle => 'Sauvegardes';

  @override
  String get backupHelp =>
      'Votre cave est enregistrée uniquement sur ce téléphone. Elle est sauvegardée automatiquement, au plus une fois par jour et seulement si elle a changé.';

  @override
  String backupFolder(String path) {
    return 'Dossier : $path';
  }

  @override
  String get backupFolderHelp =>
      'Copiez ce dossier sur un ordinateur ou synchronisez-le avec une autre application pour garder une copie hors du téléphone.';

  @override
  String get backupNow => 'Sauvegarder maintenant';

  @override
  String get backupRestoreFromFile => 'Restaurer depuis un fichier…';

  @override
  String get backupListTitle => 'Sauvegardes sur ce téléphone';

  @override
  String get backupNone => 'Aucune sauvegarde pour l\'instant.';

  @override
  String backupLastError(String message) {
    return 'La dernière sauvegarde automatique a échoué : $message';
  }

  @override
  String get backupDone => 'Sauvegarde enregistrée.';

  @override
  String get backupShare => 'Partager';

  @override
  String get backupRestore => 'Restaurer';

  @override
  String backupSize(String size) {
    return '$size Ko';
  }

  @override
  String get backupRestoreTitle => 'Restaurer cette sauvegarde ?';

  @override
  String backupContents(int drinks, int bottles) {
    String _temp0 = intl.Intl.pluralLogic(
      drinks,
      locale: localeName,
      other: '$drinks références',
      one: '1 référence',
      zero: 'aucune référence',
    );
    String _temp1 = intl.Intl.pluralLogic(
      bottles,
      locale: localeName,
      other: '$bottles bouteilles',
      one: '1 bouteille',
      zero: 'aucune bouteille',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String backupRestoreMessage(String date, String contents) {
    return 'La cave actuelle sera remplacée par celle de la sauvegarde du $date : $contents.\n\nLa cave actuelle est d\'abord sauvegardée : vous pourrez revenir en arrière en restaurant cette sauvegarde de sécurité.';
  }

  @override
  String backupRestoreFileMessage(String contents) {
    return 'La cave actuelle sera remplacée par celle de ce fichier : $contents.\n\nLa cave actuelle est d\'abord sauvegardée : vous pourrez revenir en arrière en restaurant cette sauvegarde de sécurité.';
  }

  @override
  String get backupRestored => 'Cave restaurée.';

  @override
  String get backupProblemUnreadable =>
      'Ce fichier n\'est pas une sauvegarde lisible : il est peut-être endommagé.';

  @override
  String get backupProblemNotACave =>
      'Ce fichier n\'est pas une sauvegarde de Ma Cave. Pour un fichier CSV, utilisez « Importer un fichier ».';

  @override
  String get backupProblemNewer =>
      'Cette sauvegarde vient d\'une version plus récente de Ma Cave. Mettez l\'application à jour pour la restaurer.';

  @override
  String get backupKeepLabel => 'Sauvegardes conservées';

  @override
  String get backupKeepHelp =>
      'Les plus anciennes sont supprimées automatiquement.';

  @override
  String get backupKeepConfirmTitle => 'Supprimer des sauvegardes ?';

  @override
  String backupKeepConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les $count sauvegardes les plus anciennes seront supprimées.',
      one: 'La sauvegarde la plus ancienne sera supprimée.',
    );
    return '$_temp0';
  }

  @override
  String get backupKeepConfirm => 'Supprimer';
}
