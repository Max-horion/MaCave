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

  @override
  String get backupHelpSynced =>
      'Votre cave est synchronisée avec le serveur. Elle est sauvegardée automatiquement, au plus une fois par jour et seulement si elle a changé : sur ce téléphone, et une copie dans le dossier « Sauvegardes » du serveur.';

  @override
  String get menuSync => 'Synchronisation';

  @override
  String get syncTitle => 'Synchronisation';

  @override
  String get syncIntro =>
      'Votre cave est enregistrée uniquement sur ce téléphone. Avec la synchronisation, elle est aussi copiée sur votre serveur (Nextcloud ou autre serveur WebDAV) et partagée avec vos autres appareils. Tout reste utilisable sans réseau.';

  @override
  String get syncKindNextcloud => 'Nextcloud';

  @override
  String get syncKindOther => 'Autre serveur WebDAV';

  @override
  String get syncServerLabel => 'Adresse du serveur';

  @override
  String get syncServerHint => 'cloud.exemple.fr';

  @override
  String get syncUrlLabel => 'Adresse du dossier WebDAV';

  @override
  String get syncUrlHint => 'https://nas.exemple.fr/webdav/cave';

  @override
  String get syncUserLabel => 'Identifiant';

  @override
  String get syncPasswordLabel => 'Mot de passe d\'application';

  @override
  String get syncPasswordHelp =>
      'Dans Nextcloud : Paramètres personnels › Sécurité › Créer un nouveau mot de passe d\'application. Il est rangé dans le coffre sécurisé du téléphone.';

  @override
  String get syncPasswordKeep =>
      'Laisser vide pour garder le mot de passe actuel.';

  @override
  String get syncFolderLabel => 'Dossier sur le serveur';

  @override
  String get syncFolderHelp => 'Créé automatiquement s\'il n\'existe pas.';

  @override
  String get syncFieldRequired => 'Obligatoire';

  @override
  String get syncInvalidAddress => 'Adresse invalide';

  @override
  String get syncActivate => 'Activer la synchronisation';

  @override
  String get syncSave => 'Enregistrer';

  @override
  String get syncActivated => 'Synchronisation activée';

  @override
  String get syncOtherCaveTitle => 'Une autre cave est sur le serveur';

  @override
  String get syncOtherCaveMessage =>
      'Le serveur contient déjà une cave différente de celle de ce téléphone. Les deux ne sont jamais mélangées : choisissez celle à garder.';

  @override
  String get syncUseServer => 'Utiliser la cave du serveur';

  @override
  String get syncUseServerHelp =>
      'La cave de ce téléphone est remplacée, après une sauvegarde automatique.';

  @override
  String get syncReplaceServer => 'Remplacer la cave du serveur par celle-ci';

  @override
  String get syncReplaceServerHelp =>
      'Celle du serveur est d\'abord mise de côté sur le serveur (renommée), pas supprimée.';

  @override
  String get syncChooseCave => 'Choisir la cave à garder';

  @override
  String get syncStatusSynced => 'Synchronisé';

  @override
  String get syncStatusSyncing => 'Synchronisation en cours…';

  @override
  String get syncStatusWaiting =>
      'En attente du réseau : les modifications seront envoyées à son retour.';

  @override
  String get syncStatusError => 'Erreur de synchronisation';

  @override
  String syncLastSuccess(String date) {
    return 'Dernière synchronisation : $date';
  }

  @override
  String get syncNever => 'Pas encore synchronisé';

  @override
  String syncServerLine(String address) {
    return 'Dossier : $address';
  }

  @override
  String get syncLongError => 'L\'erreur dure depuis plus de 24 heures.';

  @override
  String get syncProblemUnreachable =>
      'Serveur injoignable. Les modifications restent sur le téléphone, rien n\'est perdu.';

  @override
  String get syncProblemUnauthorized =>
      'Identifiant ou mot de passe refusé par le serveur.';

  @override
  String get syncProblemFolderNotFound =>
      'Dossier introuvable sur le serveur : vérifiez l\'adresse.';

  @override
  String get syncProblemInsufficientStorage =>
      'Espace insuffisant sur le serveur. Les modifications restent sur le téléphone.';

  @override
  String get syncProblemServer =>
      'Le serveur a répondu de façon inattendue. Nouvel essai automatique.';

  @override
  String get syncProblemNewerVersion =>
      'La cave du serveur a été enregistrée par une version plus récente de l\'application. Synchronisation suspendue : mettez l\'application à jour.';

  @override
  String get syncProblemOtherCave =>
      'Le serveur contient une autre cave que celle de ce téléphone.';

  @override
  String get syncProblemConflict =>
      'Le fichier du serveur changeait pendant l\'envoi. Nouvel essai automatique.';

  @override
  String syncSetAside(String name) {
    return 'Le fichier du serveur était endommagé : il a été mis de côté sous le nom « $name » et remplacé par la cave de ce téléphone.';
  }

  @override
  String get syncRetry => 'Réessayer';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncOpenSettings => 'Paramètres de synchronisation';

  @override
  String get syncEdit => 'Modifier les paramètres';

  @override
  String get syncDeactivate => 'Désactiver la synchronisation';

  @override
  String get syncDeactivateMessage =>
      'Ce téléphone garde sa cave et continue seul. La cave du serveur n\'est pas supprimée.';

  @override
  String get syncDeactivated => 'Synchronisation désactivée';

  @override
  String get syncLogTitle => 'Journal des erreurs';

  @override
  String get syncLogEmpty => 'Aucune erreur.';

  @override
  String get syncIndicatorTooltip => 'État de la synchronisation';

  @override
  String get syncBackupsNote =>
      'Les sauvegardes sont aussi copiées dans le dossier « Sauvegardes » du serveur.';

  @override
  String get menuStorage => 'Espace disque';

  @override
  String get storageTitle => 'Espace disque';

  @override
  String storageSize(String size) {
    return 'Taille de la base : $size';
  }

  @override
  String storageKilobytes(String count) {
    return '$count Ko';
  }

  @override
  String storageMegabytes(String count) {
    return '$count Mo';
  }

  @override
  String storageHistory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Historique : $count mouvements',
      one: 'Historique : 1 mouvement',
      zero: 'Historique : aucun mouvement',
    );
    return '$_temp0';
  }

  @override
  String storageHistorySince(String date) {
    return 'Depuis le $date';
  }

  @override
  String storagePurgedBefore(String date) {
    return 'Historique déjà purgé avant le $date.';
  }

  @override
  String get storagePurgeTitle => 'Purge de l\'historique';

  @override
  String get storagePurgeHelp =>
      'Supprime les mouvements anciens pour alléger la base. Les stocks ne changent pas : le stock de chaque lot à la date choisie est conservé. Les statistiques de consommation de cette période sont perdues.';

  @override
  String get storagePurgeButton => 'Purger l\'historique…';

  @override
  String get storagePurgeNothingOld =>
      'Aucun mouvement de plus d\'un mois : rien à purger.';

  @override
  String get storagePurgePickerHelp => 'Supprimer l\'historique avant le';

  @override
  String get storagePurgeNone => 'Aucun mouvement avant cette date.';

  @override
  String get storagePurgeConfirmTitle => 'Purger l\'historique ?';

  @override
  String storagePurgeConfirmMessage(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mouvements antérieurs au $date seront supprimés',
      one: '1 mouvement antérieur au $date sera supprimé',
    );
    return '$_temp0 définitivement, sur tous les appareils synchronisés. Les stocks ne changent pas. Une sauvegarde est faite avant.';
  }

  @override
  String get storagePurgeConfirm => 'Purger';

  @override
  String storagePurgeDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mouvements supprimés',
      one: '1 mouvement supprimé',
      zero: 'Aucun mouvement supprimé',
    );
    return '$_temp0';
  }

  @override
  String get storageAutoTitle => 'Purge automatique';

  @override
  String get storageAutoHelp =>
      'Supprime les lots épuisés sans mouvement depuis le délai choisi, avec leur historique, et la référence si elle n\'a plus aucun lot. Les lots en stock ne sont jamais supprimés.';

  @override
  String get storageAutoDelay => 'Délai sans mouvement';

  @override
  String storageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '1 mois',
    );
    return '$_temp0';
  }

  @override
  String storageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '1 an',
    );
    return '$_temp0';
  }

  @override
  String get storageAutoConfirmTitle => 'Purge automatique';

  @override
  String storageAutoConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots épuisés seront supprimés',
      one: '1 lot épuisé sera supprimé',
    );
    return '$_temp0 dès maintenant, avec leur historique. Une sauvegarde est faite avant.';
  }

  @override
  String get storageAutoConfirm => 'Supprimer';

  @override
  String storageAutoDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots supprimés',
      one: '1 lot supprimé',
      zero: 'Aucun lot supprimé',
    );
    return '$_temp0';
  }

  @override
  String get scanButton => 'Scanner';

  @override
  String get scanTitle => 'Scanner un code';

  @override
  String get scanHint => 'Visez le code-barres ou le QR code de la bouteille.';

  @override
  String get scanTorchOn => 'Allumer la lampe';

  @override
  String get scanTorchOff => 'Éteindre la lampe';

  @override
  String get scanManualEntry => 'Saisir le code';

  @override
  String get scanManualLabel => 'Code-barres';

  @override
  String get scanCameraDenied =>
      'L\'appareil photo n\'est pas autorisé. Autorisez-le dans les paramètres d\'Android pour scanner, ou saisissez le code.';

  @override
  String scanCameraError(String detail) {
    return 'Appareil photo indisponible ($detail). Vous pouvez saisir le code.';
  }

  @override
  String scanCode(String code) {
    return 'Code : $code';
  }

  @override
  String get scanRemoveOne => '−1';

  @override
  String get scanAdd => 'Ajouter';

  @override
  String get scanNewLot => 'Nouveau lot sur cette référence';

  @override
  String get scanOpenDrink => 'Voir la fiche';

  @override
  String get scanAgain => 'Scanner un autre code';

  @override
  String get scanUnknownTitle => 'Code inconnu';

  @override
  String get scanUnknownMessage =>
      'Ce code n\'est associé à aucune bouteille de la cave.';

  @override
  String get scanNewDrink => 'Nouvelle référence avec ce code';

  @override
  String get scanAssociate => 'Associer à une référence existante';

  @override
  String get scanPickDrinkTitle => 'Choisir la référence';

  @override
  String get scanPickLotTitle => 'Associer le code à quel lot ?';

  @override
  String scanAssociated(String lot) {
    return 'Code associé à $lot';
  }

  @override
  String drinkFormBarcode(String code) {
    return 'Code-barres : $code';
  }

  @override
  String get actionOk => 'Valider';

  @override
  String get offSearching =>
      'Recherche sur Open Food Facts… (le code-barres est envoyé à ce service)';

  @override
  String get offSource => 'Open Food Facts';

  @override
  String get offUnnamed => 'Produit sans nom';

  @override
  String get offUseDraft => 'Nouvelle référence avec ces informations';

  @override
  String get offNotFound =>
      'Inconnu d\'Open Food Facts : fiche à remplir, le code sera mémorisé.';

  @override
  String get offOffline =>
      'Hors ligne : pas de recherche sur Open Food Facts. Le code sera mémorisé.';

  @override
  String get offUnavailable =>
      'Open Food Facts ne répond pas : fiche à remplir, le code sera mémorisé.';

  @override
  String get scanMaybeTitle => 'Déjà dans votre cave ?';

  @override
  String get scanMaybeHelp =>
      'Touchez une référence pour lui associer ce code.';

  @override
  String get similarTitle => 'Référence proche déjà dans la cave';

  @override
  String get similarMessage =>
      'Ajouter les bouteilles à l\'une de ces références plutôt que d\'en créer une nouvelle ? Sa fiche n\'est pas modifiée.';

  @override
  String get similarCreateAnyway => 'Créer une nouvelle référence';

  @override
  String get similarBack => 'Revenir au formulaire';

  @override
  String get labelButton => 'Lire l\'étiquette';

  @override
  String get labelScanInstead => 'Pas de code-barres ? Photo de l\'étiquette';

  @override
  String get labelTitle => 'Photo de l\'étiquette';

  @override
  String get labelHint =>
      'Cadrez l\'étiquette entière, bien à plat, sans reflet.';

  @override
  String get labelTake => 'Photographier';

  @override
  String get labelNoCamera => 'Aucun appareil photo disponible.';

  @override
  String get labelReading => 'Lecture de l\'étiquette…';

  @override
  String get labelNothingRead =>
      'Aucun texte lu sur la photo. Réessayez plus près, avec la lampe si besoin.';

  @override
  String get labelReadTitle => 'Lecture de l\'étiquette';

  @override
  String get labelReadHelp =>
      'Vérifiez les informations lues. Touchez une ligne de texte plus bas pour l\'utiliser comme nom, producteur ou appellation.';

  @override
  String get labelNotFound => 'Non trouvé';

  @override
  String get labelClear => 'Effacer';

  @override
  String get labelTypeWine => 'Vin';

  @override
  String get labelTypeBeer => 'Bière';

  @override
  String get labelTypeSpirit => 'Spiritueux';

  @override
  String get labelTypeSoft => 'Soft';

  @override
  String get labelMaybeHelp =>
      'Touchez une référence pour lui ajouter des bouteilles.';

  @override
  String get labelContinue => 'Continuer avec ces informations';

  @override
  String get labelLinesTitle => 'Texte lu';

  @override
  String get labelLinesHelp =>
      'Touchez une ligne pour l\'attribuer à un champ.';

  @override
  String get labelUseAsName => 'Utiliser comme nom';

  @override
  String get labelUseAsProducer => 'Utiliser comme producteur';

  @override
  String get labelUseAsAppellation => 'Utiliser comme appellation';

  @override
  String get scanUnknownPhoto => 'Photographier l\'étiquette';

  @override
  String get labelEngine => 'Moteur de lecture (bêta)';

  @override
  String get labelEngineMlKit => 'ML Kit';

  @override
  String get labelEngineTesseract => 'Tesseract';

  @override
  String get labelEngineCompare => 'Comparer';

  @override
  String get labelCompareTitle => 'Comparaison des moteurs';

  @override
  String get labelCompareHelp =>
      'Les deux moteurs ont lu la même photo. Gardez le meilleur résultat : vos choix aideront à décider du moteur définitif.';

  @override
  String labelCompareTally(int mlKit, int tesseract) {
    return 'Choix jusqu\'ici : ML Kit $mlKit, Tesseract $tesseract';
  }

  @override
  String labelCompareSeconds(String seconds) {
    return '$seconds s';
  }

  @override
  String labelCompareLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes lues',
      one: '1 ligne lue',
      zero: 'Aucune ligne lue',
    );
    return '$_temp0';
  }

  @override
  String labelCompareKeep(String engine) {
    return 'Garder le résultat de $engine';
  }

  @override
  String get lotScanBarcode => 'Associer un code-barres';

  @override
  String get lotChangeBarcode => 'Changer le code-barres';

  @override
  String get formScanBarcode => 'Scanner le code-barres';

  @override
  String get formBarcodeKnownTitle => 'Code déjà dans la cave';

  @override
  String formBarcodeKnownMessage(String name) {
    return 'Ce code-barres est déjà associé à « $name ». Un même code peut servir à plusieurs lots : vous pouvez continuer, ou ouvrir cette référence pour lui ajouter des bouteilles.';
  }

  @override
  String get formBarcodeKeep => 'Continuer avec ce code';

  @override
  String get formBarcodeOpen => 'Voir la référence';

  @override
  String get formOffFilled => 'Champs vides complétés avec Open Food Facts';

  @override
  String welcomeStep(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get welcomeSkip => 'Passer';

  @override
  String get welcomeNext => 'Suivant';

  @override
  String get welcomeFinish => 'Commencer';

  @override
  String get welcomeStorageTitle => 'Où ranger votre cave ?';

  @override
  String get welcomeStorageHelp =>
      'Vous pourrez changer d\'avis plus tard (menu ⋮ → Paramètres → Synchronisation).';

  @override
  String get welcomeLocal => 'Sur cet appareil uniquement';

  @override
  String get welcomeLocalHelp =>
      'Rien à configurer. Sauvegardes automatiques dans Documents/Cave/Sauvegardes.';

  @override
  String get welcomeSync => 'Synchroniser avec un serveur';

  @override
  String get welcomeSyncHelp =>
      'Nextcloud ou autre serveur WebDAV. Si une cave y est déjà, elle est récupérée (nouvel appareil).';

  @override
  String get welcomeSyncDone => 'Synchronisation activée';

  @override
  String get welcomeLocalAlertTitle => 'Données sur cet appareil seulement';

  @override
  String get welcomeLocalAlert =>
      'Votre cave n\'est enregistrée que sur ce téléphone. S\'il est perdu, cassé ou réinitialisé, elle est perdue aussi.\n\nPensez à copier de temps en temps le dossier Documents/Cave/Sauvegardes ailleurs (ordinateur, cloud), ou activez la synchronisation (menu ⋮ → Paramètres → Synchronisation).';

  @override
  String get welcomeLocalAlertOk => 'J\'ai compris';

  @override
  String get welcomeImportTitle => 'Vous avez déjà une cave ?';

  @override
  String get welcomeImportHelp =>
      'Importez un export Vivino ou un fichier CSV (par exemple une sauvegarde de Ma Cave). Un aperçu est affiché avant tout ajout. Vous pourrez aussi le faire plus tard (menu ⋮ → Importer un fichier).';

  @override
  String get welcomeImportButton => 'Importer un fichier';

  @override
  String welcomeImportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votre cave contient $count bouteilles.',
      one: 'Votre cave contient 1 bouteille.',
      zero: 'Votre cave est encore vide.',
    );
    return '$_temp0';
  }

  @override
  String get welcomeDefaultsTitle => 'Volumes par défaut';

  @override
  String get welcomeDefaultsHelp =>
      'Volume proposé pour une nouvelle bouteille, selon son type. Touchez une ligne pour le changer ; vous pourrez aussi le faire plus tard dans les paramètres.';

  @override
  String welcomeVolumeOf(String type) {
    return 'Volume par défaut : $type';
  }

  @override
  String get menuSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Comme le téléphone';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsTextSize => 'Taille du texte';

  @override
  String get settingsTextNormal => 'Normale';

  @override
  String get settingsTextLarge => 'Grande';

  @override
  String get settingsTextLarger => 'Très grande';

  @override
  String get settingsDefaults => 'Volumes par défaut';

  @override
  String get settingsDefaultsHelp =>
      'Volume proposé pour une nouvelle bouteille, selon son type. Partagé avec vos autres appareils si la synchronisation est active.';

  @override
  String get settingsDisplay => 'Affichage';

  @override
  String get settingsDefaultSort => 'Tri à l\'ouverture';

  @override
  String get settingsShowExhausted => 'Afficher les références épuisées';

  @override
  String get settingsShowExhaustedHelp =>
      'À l\'ouverture de l\'appli ; modifiable à tout moment dans les filtres.';

  @override
  String get settingsUndo => 'Durée du bandeau « Annuler »';

  @override
  String settingsSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondes',
      one: '1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get settingsRecognition => 'Reconnaissance';

  @override
  String get settingsOff => 'Recherche sur Open Food Facts';

  @override
  String get settingsOffHelp =>
      'Pour un code-barres inconnu, le code (et rien d\'autre) est envoyé à Open Food Facts pour pré-remplir la fiche.';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsDeviceNote =>
      'Sauf les volumes par défaut, ces réglages ne concernent que ce téléphone.';

  @override
  String get settingsClassification => 'Types et caractéristiques';

  @override
  String get settingsClassificationHelp =>
      'Vin, bière… et leurs familles : robe, style, parfum…';

  @override
  String get classTitle => 'Types et caractéristiques';

  @override
  String get classHelp =>
      'Chaque type a ses familles de caractéristiques (robe, style…) et leurs valeurs (rouge, IPA…). Partagé avec vos autres appareils si la synchronisation est active.';

  @override
  String classTypeSummary(String profile, String volume) {
    return '$profile · $volume';
  }

  @override
  String get classAddType => 'Ajouter un type';

  @override
  String get classAddFamily => 'Ajouter une famille';

  @override
  String get classAddValue => 'Ajouter';

  @override
  String get classNewType => 'Nouveau type';

  @override
  String get classNewFamily => 'Nouvelle famille';

  @override
  String classNewValue(String family) {
    return 'Nouvelle valeur : $family';
  }

  @override
  String get classRename => 'Renommer';

  @override
  String get classDelete => 'Supprimer';

  @override
  String get className => 'Nom';

  @override
  String get classNameRequired => 'Nom obligatoire';

  @override
  String get classNameTaken => 'Ce nom existe déjà ici';

  @override
  String get classProfile => 'Champs de la fiche';

  @override
  String get classProfileHelp => 'Ne peut plus être changé ensuite.';

  @override
  String get profileWine => 'Comme un vin';

  @override
  String get profileBeer => 'Comme une bière';

  @override
  String get profileSpirit => 'Comme un spiritueux';

  @override
  String get profileSoft => 'Comme un soft';

  @override
  String get profileWineHelp =>
      'Millésime, appellation, région ou pays obligatoire, cépages, degré';

  @override
  String get profileBeerHelp => 'Région, degré ; pas de millésime';

  @override
  String get profileSpiritHelp => 'Millésime, appellation, région, degré';

  @override
  String get profileSoftHelp => 'Nom, producteur, volume seulement';

  @override
  String get classNoFamily => 'Aucune famille pour ce type.';

  @override
  String get classNoValue => 'Aucune valeur';

  @override
  String classDeleteTypeTitle(String name) {
    return 'Supprimer le type « $name » ?';
  }

  @override
  String classDeleteTypeMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count références resteront dans la cave, « sans catégorie ».',
      one: '1 référence restera dans la cave, « sans catégorie ».',
      zero: 'Aucune référence n\'est concernée.',
    );
    return 'Ses familles et leurs valeurs seront supprimées. $_temp0';
  }

  @override
  String classDeleteFamilyTitle(String name) {
    return 'Supprimer la famille « $name » ?';
  }

  @override
  String classDeleteValueTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String classDeleteCharMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count références perdront cette caractéristique (les fiches, elles, sont gardées).',
      one: '1 référence perdra cette caractéristique (la fiche, elle, est gardée).',
      zero: 'Aucune référence n\'est concernée.',
    );
    return '$_temp0';
  }

  @override
  String get classLastType => 'Il faut garder au moins un type.';
}
