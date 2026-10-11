import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// Nom de l'application, affiché dans la barre de titre.
  ///
  /// In fr, this message translates to:
  /// **'Ma Cave'**
  String get appTitle;

  /// Titre affiché sur l'écran d'accueil quand aucune bouteille n'est enregistrée.
  ///
  /// In fr, this message translates to:
  /// **'Votre cave est vide'**
  String get homeEmptyTitle;

  /// Message d'aide sous le titre de la cave vide.
  ///
  /// In fr, this message translates to:
  /// **'Touchez « Ajouter » pour enregistrer votre première bouteille.'**
  String get homeEmptyMessage;

  /// Nombre de bouteilles, avec accord du pluriel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune bouteille} =1{1 bouteille} other{{count} bouteilles}}'**
  String bottleCount(int count);

  /// Bouton pour fermer une fenêtre sans rien changer.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// Bouton d'enregistrement d'un formulaire.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionSave;

  /// Bouton de suppression.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get actionDelete;

  /// Bouton pour modifier une fiche.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get actionEdit;

  /// Action du bandeau qui annule la dernière opération.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionUndo;

  /// Infobulle du bouton qui diminue une quantité.
  ///
  /// In fr, this message translates to:
  /// **'Moins'**
  String get actionDecrease;

  /// Infobulle du bouton qui augmente une quantité.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get actionIncrease;

  /// Texte d'aide du champ de recherche de la liste.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une boisson'**
  String get searchHint;

  /// Infobulle du bouton des filtres.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtersTooltip;

  /// Infobulle du bouton de tri.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sortTooltip;

  /// Tri par nom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get sortByName;

  /// Tri par date d'ajout, les plus récents d'abord.
  ///
  /// In fr, this message translates to:
  /// **'Derniers ajouts'**
  String get sortRecentlyAdded;

  /// Tri par millésime, le plus ancien d'abord.
  ///
  /// In fr, this message translates to:
  /// **'Millésime'**
  String get sortByVintage;

  /// Tri par nombre de bouteilles, le plus grand d'abord.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get sortByStock;

  /// Bouton flottant pour ajouter une boisson.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addDrinkButton;

  /// Titre quand la recherche ou les filtres ne trouvent rien.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResultsTitle;

  /// Conseil sous « Aucun résultat ».
  ///
  /// In fr, this message translates to:
  /// **'Modifiez la recherche ou les filtres.'**
  String get noResultsMessage;

  /// Bouton qui retire tous les filtres.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get clearFilters;

  /// Nombre de références, avec accord du pluriel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune référence} =1{1 référence} other{{count} références}}'**
  String drinkCount(int count);

  /// Résumé sous le titre : « 12 bouteilles · 5 références ».
  ///
  /// In fr, this message translates to:
  /// **'{bottles} · {drinks}'**
  String cellarSummary(String bottles, String drinks);

  /// Infobulle du bouton « −1 ».
  ///
  /// In fr, this message translates to:
  /// **'Retirer une bouteille'**
  String get quickExitTooltip;

  /// Bandeau affiché après une sortie, avec un bouton Annuler.
  ///
  /// In fr, this message translates to:
  /// **'Bouteille retirée'**
  String get bottleRemoved;

  /// Bandeau après une sortie de plusieurs bouteilles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille retirée} other{{count} bouteilles retirées}}'**
  String bottlesRemoved(int count);

  /// Bandeau après un ajout de bouteilles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bouteille ajoutée} other{{count} bouteilles ajoutées}}'**
  String bottlesAdded(int count);

  /// Bandeau après une correction de stock.
  ///
  /// In fr, this message translates to:
  /// **'Stock corrigé'**
  String get stockCorrected;

  /// Titre de la liste des lots quand une référence en a plusieurs.
  ///
  /// In fr, this message translates to:
  /// **'Quelle bouteille ?'**
  String get chooseLotTitle;

  /// Lot sans millésime.
  ///
  /// In fr, this message translates to:
  /// **'Sans millésime'**
  String get withoutVintage;

  /// Référence dont le type a été supprimé.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie'**
  String get uncategorized;

  /// Étiquette d'une fiche incomplète.
  ///
  /// In fr, this message translates to:
  /// **'À compléter'**
  String get needsCompletionLabel;

  /// Étiquette ou infobulle du favori.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get favoriteLabel;

  /// Description courte d'un lot : « 2018 · 75 cl ».
  ///
  /// In fr, this message translates to:
  /// **'{vintage} · {volume}'**
  String lotSummary(String vintage, String volume);

  /// Titre du panneau des filtres.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtersTitle;

  /// Rubrique du filtre par type.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get filterType;

  /// Option « tous les types ».
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAllTypes;

  /// Rubrique du filtre par région.
  ///
  /// In fr, this message translates to:
  /// **'Région ou pays'**
  String get filterRegion;

  /// Option « toutes les régions ».
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterAnyRegion;

  /// Interrupteur du filtre des favoris.
  ///
  /// In fr, this message translates to:
  /// **'Favoris uniquement'**
  String get filterFavorites;

  /// Interrupteur du filtre des fiches incomplètes.
  ///
  /// In fr, this message translates to:
  /// **'Fiches à compléter'**
  String get filterNeedsCompletion;

  /// Interrupteur qui montre les références sans stock.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les épuisés'**
  String get filterShowExhausted;

  /// Bouton qui ferme le panneau des filtres.
  ///
  /// In fr, this message translates to:
  /// **'Voir les résultats'**
  String get showResults;

  /// Titre de la section des lots sur la fiche.
  ///
  /// In fr, this message translates to:
  /// **'Lots'**
  String get lotsSection;

  /// Bouton qui crée un lot (autre millésime ou volume).
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un lot'**
  String get addLot;

  /// Action ou titre : ajouter des bouteilles à un lot.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des bouteilles'**
  String get addBottles;

  /// Action ou titre : sortie avec motif et commentaire.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des bouteilles'**
  String get removeBottles;

  /// Action ou titre : saisie du nombre réel de bouteilles.
  ///
  /// In fr, this message translates to:
  /// **'Corriger le stock'**
  String get correctStock;

  /// Explication de la correction de stock.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de bouteilles réellement présentes.'**
  String get correctStockHelp;

  /// Action de suppression d'un lot.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le lot'**
  String get deleteLot;

  /// Action de suppression d'une référence.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la référence'**
  String get deleteDrink;

  /// Question de confirmation avant suppression d'une référence.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » et tous ses lots ?'**
  String deleteDrinkConfirm(String name);

  /// Question de confirmation avant suppression d'un lot.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le lot « {lot} » ?'**
  String deleteLotConfirm(String lot);

  /// Bandeau sur une fiche marquée « à compléter ».
  ///
  /// In fr, this message translates to:
  /// **'Il manque des informations obligatoires sur cette fiche.'**
  String get needsCompletionBanner;

  /// Date de création d'un lot.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté le {date}'**
  String addedOn(String date);

  /// Message si la fiche ouverte a été supprimée.
  ///
  /// In fr, this message translates to:
  /// **'Cette référence n\'existe plus.'**
  String get drinkNotFound;

  /// Lot dont le stock est à zéro.
  ///
  /// In fr, this message translates to:
  /// **'Épuisé'**
  String get exhausted;

  /// Titre du formulaire de création.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle boisson'**
  String get formNewTitle;

  /// Titre du formulaire de modification.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la fiche'**
  String get formEditTitle;

  /// Section du formulaire de création : millésime, volume, quantité.
  ///
  /// In fr, this message translates to:
  /// **'Bouteilles'**
  String get formLotSection;

  /// Section des caractéristiques (robe, style…).
  ///
  /// In fr, this message translates to:
  /// **'Caractéristiques'**
  String get characteristicsSection;

  /// Avertissement quand un champ obligatoire du vin (région ou pays) est vide.
  ///
  /// In fr, this message translates to:
  /// **'Sans région ni pays, la fiche sera marquée « à compléter ».'**
  String get formIncompleteWarning;

  /// Champ : nom de la boisson.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get fieldName;

  /// Champ : type de boisson.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// Champ : producteur.
  ///
  /// In fr, this message translates to:
  /// **'Producteur ou domaine'**
  String get fieldProducer;

  /// Champ : appellation.
  ///
  /// In fr, this message translates to:
  /// **'Appellation'**
  String get fieldAppellation;

  /// Champ : région.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get fieldRegion;

  /// Champ : pays.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get fieldCountry;

  /// Champ : cépages.
  ///
  /// In fr, this message translates to:
  /// **'Cépages'**
  String get fieldGrapes;

  /// Champ : degré d'alcool.
  ///
  /// In fr, this message translates to:
  /// **'Degré d\'alcool (% vol.)'**
  String get fieldAbv;

  /// Champ : note sur 5 étoiles.
  ///
  /// In fr, this message translates to:
  /// **'Note personnelle'**
  String get fieldRating;

  /// Champ : commentaire libre.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get fieldComment;

  /// Champ : millésime.
  ///
  /// In fr, this message translates to:
  /// **'Millésime'**
  String get fieldVintage;

  /// Champ : volume de la bouteille.
  ///
  /// In fr, this message translates to:
  /// **'Volume'**
  String get fieldVolume;

  /// Champ : quantité.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de bouteilles'**
  String get fieldQuantity;

  /// Champ : motif de sortie.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get fieldReason;

  /// Erreur : champ vide.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get requiredFieldError;

  /// Erreur : millésime invalide.
  ///
  /// In fr, this message translates to:
  /// **'Année entre 1800 et {max}'**
  String invalidVintage(int max);

  /// Erreur : nombre mal saisi.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get invalidNumber;

  /// Infobulle d'une étoile de notation.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 étoile} other{{count} étoiles}}'**
  String ratingStars(int count);

  /// Motif de sortie par défaut.
  ///
  /// In fr, this message translates to:
  /// **'Consommée'**
  String get reasonConsumed;

  /// Motif de sortie : offerte.
  ///
  /// In fr, this message translates to:
  /// **'Offerte'**
  String get reasonGifted;

  /// Motif de sortie : cassée.
  ///
  /// In fr, this message translates to:
  /// **'Cassée'**
  String get reasonBroken;

  /// Volume en centilitres ; value est déjà formaté (« 37,5 »).
  ///
  /// In fr, this message translates to:
  /// **'{value} cl'**
  String volumeCentiliters(String value);

  /// Volume en litres ; value est déjà formaté (« 1,5 »).
  ///
  /// In fr, this message translates to:
  /// **'{value} l'**
  String volumeLiters(String value);

  /// Degré d'alcool ; value est déjà formaté.
  ///
  /// In fr, this message translates to:
  /// **'{value} % vol.'**
  String abvValue(String value);

  /// Erreur : on veut retirer plus que le stock.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant'**
  String get errorInsufficientStock;

  /// Erreur inattendue.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue : {message}'**
  String errorGeneric(String message);

  /// Infobulle du menu de l'écran principal.
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'actions'**
  String get menuTooltip;

  /// Entrée de menu : inventaire guidé.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire'**
  String get menuInventory;

  /// Entrée de menu : statistiques.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get menuStatistics;

  /// Entrée de menu : import CSV ou Vivino.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier'**
  String get menuImport;

  /// Entrée de menu : export CSV.
  ///
  /// In fr, this message translates to:
  /// **'Exporter (CSV)'**
  String get menuExport;

  /// Titre de la section des mouvements sur la fiche.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historySection;

  /// Historique vide.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement.'**
  String get historyEmpty;

  /// Mouvement : entrée.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{+1 bouteille} other{+{count} bouteilles}}'**
  String movementEntry(int count);

  /// Mouvement : sortie.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{−1 bouteille} other{−{count} bouteilles}}'**
  String movementExit(int count);

  /// Mouvement : ajustement d'inventaire (nombre constaté).
  ///
  /// In fr, this message translates to:
  /// **'Inventaire : {count}'**
  String movementInventory(int count);

  /// Titre du choix de l'export.
  ///
  /// In fr, this message translates to:
  /// **'Exporter la cave'**
  String get exportTitle;

  /// Explication de l'export.
  ///
  /// In fr, this message translates to:
  /// **'Deux fichiers CSV, lisibles dans Excel ou LibreOffice : le stock et l\'historique. Ils servent aussi de sauvegarde.'**
  String get exportHelp;

  /// Action : partager les fichiers (courriel, Drive…).
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get exportShare;

  /// Action : enregistrer les fichiers dans un dossier.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer sur l\'appareil'**
  String get exportSave;

  /// Confirmation après enregistrement.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fichier enregistré} other{{count} fichiers enregistrés}}'**
  String exportSaved(int count);

  /// Nom du fichier de stock exporté.
  ///
  /// In fr, this message translates to:
  /// **'ma-cave-stock-{date}.csv'**
  String exportFileStock(String date);

  /// Nom du fichier d'historique exporté.
  ///
  /// In fr, this message translates to:
  /// **'ma-cave-historique-{date}.csv'**
  String exportFileHistory(String date);

  /// Titre du choix de l'import (CDC §6.7).
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier'**
  String get importTitle;

  /// Explication sous le titre de l'import.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers acceptés : une sauvegarde ou un export de Ma Cave, l\'export de Vivino (cellar.csv), ou un fichier préparé dans un tableur.'**
  String get importHelp;

  /// Bouton : ouvrir le sélecteur de fichier pour importer.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le fichier'**
  String get importChooseFile;

  /// Bouton : ouvrir les consignes de format et le fichier modèle.
  ///
  /// In fr, this message translates to:
  /// **'Préparer un fichier dans un tableur'**
  String get importPrepare;

  /// Lien dans l'aperçu quand le fichier n'est pas reconnu.
  ///
  /// In fr, this message translates to:
  /// **'Préparer un fichier : voir les consignes'**
  String get importSeeGuide;

  /// Titre de l'écran des consignes d'import.
  ///
  /// In fr, this message translates to:
  /// **'Préparer un fichier d\'import'**
  String get importGuideTitle;

  /// Introduction de l'écran des consignes d'import.
  ///
  /// In fr, this message translates to:
  /// **'Pour importer une cave tenue dans un tableur (Excel, LibreOffice…), le plus simple est de partir du fichier modèle : il contient les bonnes colonnes et deux lignes d\'exemple à remplacer.'**
  String get importGuideIntro;

  /// Bouton : partager ou enregistrer le fichier CSV modèle.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir le fichier modèle'**
  String get importTemplateGet;

  /// Bouton de l'écran des consignes : choisir le fichier préparé et l'importer.
  ///
  /// In fr, this message translates to:
  /// **'Importer mon fichier'**
  String get importGuideImport;

  /// Titre du choix partage/enregistrement du fichier modèle.
  ///
  /// In fr, this message translates to:
  /// **'Fichier modèle'**
  String get importTemplateTitle;

  /// Explication du fichier modèle.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez-le dans un tableur, remplacez les lignes d\'exemple par vos bouteilles, enregistrez-le au format CSV puis importez-le.'**
  String get importTemplateHelp;

  /// Nom du fichier modèle d'import.
  ///
  /// In fr, this message translates to:
  /// **'ma-cave-modele-import.csv'**
  String get importTemplateFile;

  /// Titre de section des consignes d'import.
  ///
  /// In fr, this message translates to:
  /// **'Règles générales'**
  String get importGuideRulesTitle;

  /// Consigne d'import : une ligne par lot.
  ///
  /// In fr, this message translates to:
  /// **'Une ligne par lot : une même boisson en deux millésimes ou deux volumes s\'écrit sur deux lignes, avec le même nom et le même producteur.'**
  String get importGuideRuleLot;

  /// Consigne d'import : ligne d'en-tête.
  ///
  /// In fr, this message translates to:
  /// **'La première ligne contient les noms des colonnes, écrits comme dans le modèle (majuscules et accents indifférents). L\'ordre des colonnes est libre ; seule la colonne « Nom » est obligatoire.'**
  String get importGuideRuleHeader;

  /// Consigne d'import : format CSV.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez au format CSV, avec le point-virgule ou la virgule comme séparateur, de préférence en UTF-8.'**
  String get importGuideRuleCsv;

  /// Consigne d'import : fiches incomplètes et aperçu.
  ///
  /// In fr, this message translates to:
  /// **'Une ligne incomplète est quand même importée : la fiche est marquée « à compléter ». Avant l\'import, un aperçu indique ce qui sera créé et les lignes ignorées.'**
  String get importGuideRuleIncomplete;

  /// Consigne d'import : réimport sans doublon.
  ///
  /// In fr, this message translates to:
  /// **'Importer à nouveau le même fichier ne double pas le stock : le stock du fichier remplace celui du lot. Les fiches déjà présentes ne sont pas modifiées.'**
  String get importGuideRuleAgain;

  /// Titre de section des consignes d'import : liste des colonnes.
  ///
  /// In fr, this message translates to:
  /// **'Colonnes'**
  String get importGuideColumnsTitle;

  /// Consigne pour la colonne Type.
  ///
  /// In fr, this message translates to:
  /// **'Un des types de votre cave (liste ci-dessous). Vide ou inconnu : fiche « à compléter ».'**
  String get importGuideColType;

  /// Consigne pour la colonne Nom.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire. Nom de la boisson ; une ligne sans nom est ignorée.'**
  String get importGuideColName;

  /// Consigne pour les colonnes texte (producteur, appellation, région, pays, cépages).
  ///
  /// In fr, this message translates to:
  /// **'Texte libre, facultatif. Pour un vin, indiquez la région ou le pays, sinon la fiche sera « à compléter ».'**
  String get importGuideColText;

  /// Consigne pour la colonne Degré.
  ///
  /// In fr, this message translates to:
  /// **'Degré d\'alcool : 13,5 ou 13.5.'**
  String get importGuideColAbv;

  /// Consigne pour la colonne Note.
  ///
  /// In fr, this message translates to:
  /// **'Note personnelle, de 0 à 5 (étoiles).'**
  String get importGuideColRating;

  /// Consigne pour la colonne Commentaire.
  ///
  /// In fr, this message translates to:
  /// **'Texte libre.'**
  String get importGuideColComment;

  /// Consigne pour la colonne Millésime.
  ///
  /// In fr, this message translates to:
  /// **'Année (2020) ; vide pour une boisson sans millésime.'**
  String get importGuideColVintage;

  /// Consigne pour la colonne Volume.
  ///
  /// In fr, this message translates to:
  /// **'En millilitres (750) ou avec l\'unité (75 cl, 1,5 l). Vide : volume par défaut du type.'**
  String get importGuideColVolume;

  /// Consigne pour la colonne Code-barres.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif : chiffres du code-barres de la bouteille.'**
  String get importGuideColBarcode;

  /// Consigne pour la colonne Stock.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de bouteilles ; vide : 0.'**
  String get importGuideColStock;

  /// Titre de section : classification de l'utilisateur, utilisable dans le fichier.
  ///
  /// In fr, this message translates to:
  /// **'Types et caractéristiques reconnus'**
  String get importGuideTypesTitle;

  /// Explication de la section types et caractéristiques.
  ///
  /// In fr, this message translates to:
  /// **'Ceux de votre cave, modifiables dans Paramètres → Types et caractéristiques.'**
  String get importGuideTypesHelp;

  /// Consigne pour la colonne Favori ; yes = mot attendu (oui).
  ///
  /// In fr, this message translates to:
  /// **'« {yes} » pour un favori, sinon vide.'**
  String importGuideColFavorite(String yes);

  /// Consigne pour la colonne Caractéristiques.
  ///
  /// In fr, this message translates to:
  /// **'Famille et valeur séparées par « {family} », plusieurs séparées par « {separator} » : Robe : Rouge {separator} Sucre : Sec. La famille peut être omise. Une valeur inconnue est ignorée et signalée.'**
  String importGuideColCharacteristics(String family, String separator);

  /// Titre du bilan avant import.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de l\'import'**
  String get importPreviewTitle;

  /// Nature du fichier reconnu.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde ou tableur : stock'**
  String get importKindStock;

  /// Nature du fichier reconnu.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde : historique'**
  String get importKindHistory;

  /// Nature du fichier reconnu.
  ///
  /// In fr, this message translates to:
  /// **'Export Vivino'**
  String get importKindVivino;

  /// Bilan d'import.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune référence créée} =1{1 référence créée} other{{count} références créées}}'**
  String importDrinksCreated(int count);

  /// Bilan d'import.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun lot créé} =1{1 lot créé} other{{count} lots créés}}'**
  String importLotsCreated(int count);

  /// Bilan d'import.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune bouteille ajoutée} =1{1 bouteille ajoutée} other{{count} bouteilles ajoutées}}'**
  String importBottles(int count);

  /// Bilan d'import (restauration).
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 lot existant remis au stock du fichier} other{{count} lots existants remis au stock du fichier}}'**
  String importLotsAdjusted(int count);

  /// Bilan d'import Vivino.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 lot déjà présent, laissé tel quel} other{{count} lots déjà présents, laissés tels quels}}'**
  String importLotsSkipped(int count);

  /// Bilan d'import d'historique.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun mouvement ajouté} =1{1 mouvement ajouté} other{{count} mouvements ajoutés}}'**
  String importMovements(int count);

  /// Bilan d'import d'historique.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 mouvement déjà présent} other{{count} mouvements déjà présents}}'**
  String importMovementsSkipped(int count);

  /// Bilan d'import.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fiche sera « à compléter »} other{{count} fiches seront « à compléter »}}'**
  String importNeedsCompletion(int count);

  /// Bilan d'import.
  ///
  /// In fr, this message translates to:
  /// **'Caractéristiques inconnues, ignorées : {names}'**
  String importUnknownCharacteristics(String names);

  /// Titre de la liste des lignes en erreur.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 ligne ignorée} other{{count} lignes ignorées}}'**
  String importIssuesTitle(int count);

  /// Une ligne en erreur.
  ///
  /// In fr, this message translates to:
  /// **'Ligne {line} : {message}'**
  String importIssueLine(int line, String message);

  /// Bilan quand l'import ne changerait rien.
  ///
  /// In fr, this message translates to:
  /// **'Rien à importer : tout est déjà dans la cave.'**
  String get importNothing;

  /// Bouton de confirmation de l'import.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importConfirm;

  /// Confirmation après import.
  ///
  /// In fr, this message translates to:
  /// **'Import terminé'**
  String get importDone;

  /// Erreur à la lecture du fichier.
  ///
  /// In fr, this message translates to:
  /// **'Fichier illisible : {message}'**
  String importUnreadable(String message);

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'fichier non reconnu (ni sauvegarde Ma Cave, ni export Vivino)'**
  String get issueUnknownFormat;

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'nom manquant'**
  String get issueMissingName;

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'volume invalide « {value} »'**
  String issueInvalidVolume(String value);

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'millésime invalide « {value} »'**
  String issueInvalidVintage(String value);

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'stock invalide « {value} »'**
  String issueInvalidStock(String value);

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'lot introuvable « {value} »'**
  String issueUnknownLot(String value);

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'date invalide « {value} »'**
  String issueInvalidDate(String value);

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'nature invalide « {value} »'**
  String issueInvalidKind(String value);

  /// Erreur d'import.
  ///
  /// In fr, this message translates to:
  /// **'quantité invalide « {value} »'**
  String issueInvalidQuantity(String value);

  /// Titre de l'écran d'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire'**
  String get inventoryTitle;

  /// Explication avant de commencer l'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'Les lots défilent un par un : confirmez le nombre de bouteilles, ou corrigez-le.'**
  String get inventoryIntro;

  /// Option de l'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'Inclure les lots épuisés'**
  String get inventoryIncludeExhausted;

  /// Nombre de lots de l'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun lot à vérifier} =1{1 lot à vérifier} other{{count} lots à vérifier}}'**
  String inventoryLotCount(int count);

  /// Bouton qui lance l'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get inventoryStart;

  /// Avancement de l'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {total}'**
  String inventoryProgress(int current, int total);

  /// Libellé du stock actuel pendant l'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'Stock enregistré'**
  String get inventoryRecorded;

  /// Bouton : le stock est correct.
  ///
  /// In fr, this message translates to:
  /// **'C\'est juste'**
  String get inventoryConfirm;

  /// Bouton : saisir le vrai nombre.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get inventoryCorrect;

  /// Bouton : enregistrer la correction.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get inventoryValidate;

  /// Bouton : revenir au lot précédent.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get inventoryPrevious;

  /// Titre de fin d'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire terminé'**
  String get inventoryDoneTitle;

  /// Bilan de l'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'{confirmed, plural, =0{Aucun lot confirmé} =1{1 lot confirmé} other{{confirmed} lots confirmés}}, {corrected, plural, =0{aucun corrigé} =1{1 corrigé} other{{corrected} corrigés}}.'**
  String inventorySummary(int confirmed, int corrected);

  /// Bouton de fin d'inventaire.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get inventoryFinish;

  /// Titre de l'écran des statistiques.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statsTitle;

  /// Libellé du nombre total de bouteilles.
  ///
  /// In fr, this message translates to:
  /// **'Bouteilles'**
  String get statsBottles;

  /// Libellé du nombre de références en stock.
  ///
  /// In fr, this message translates to:
  /// **'Références'**
  String get statsDrinks;

  /// Titre du graphique par type.
  ///
  /// In fr, this message translates to:
  /// **'Par type'**
  String get statsByType;

  /// Titre du graphique par région.
  ///
  /// In fr, this message translates to:
  /// **'Par région ou pays'**
  String get statsByRegion;

  /// Regroupement des petites catégories.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get statsOther;

  /// Région absente.
  ///
  /// In fr, this message translates to:
  /// **'Non renseignée'**
  String get statsUnknownRegion;

  /// Statistiques sans données.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des bouteilles pour voir les statistiques.'**
  String get statsEmpty;

  /// Lecture d'écran d'une barre de graphique.
  ///
  /// In fr, this message translates to:
  /// **'{label} : {count}'**
  String statsBarValue(String label, String count);

  /// Entrée de menu : écran des sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardes'**
  String get menuBackups;

  /// Titre de l'écran des sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardes'**
  String get backupTitle;

  /// Explication en tête de l'écran des sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Votre cave est enregistrée uniquement sur cet appareil. Elle est sauvegardée automatiquement, à la fréquence choisie ci-dessous et seulement si elle a changé.'**
  String get backupHelp;

  /// Dossier où sont enregistrées les sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Dossier : {path}'**
  String backupFolder(String path);

  /// Bouton : choisir le dossier des sauvegardes sur l'appareil (CDC §8.4).
  ///
  /// In fr, this message translates to:
  /// **'Choisir le dossier'**
  String get backupChooseFolder;

  /// Bouton : abandonner le dossier choisi et revenir à Documents/Cave/Sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Revenir au dossier par défaut'**
  String get backupDefaultFolder;

  /// Message après le changement du dossier des sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Dossier changé. Les sauvegardes déjà faites restent dans l\'ancien dossier.'**
  String get backupFolderChanged;

  /// Message : le dossier choisi n'est pas accessible en écriture (Android limite les dossiers utilisables).
  ///
  /// In fr, this message translates to:
  /// **'L\'appli ne peut pas écrire dans ce dossier. Choisissez un dossier dans Documents ou Download.'**
  String get backupFolderRefused;

  /// Avertissement sur Android 8 à 10 quand l'autorisation de stockage n'est pas accordée.
  ///
  /// In fr, this message translates to:
  /// **'Android doit autoriser l\'appli à écrire dans Documents pour y ranger les sauvegardes.'**
  String get backupNeedsPermission;

  /// Bouton : demander l'autorisation d'écrire dans Documents (Android 8 à 10).
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get backupAllow;

  /// Explication quand l'autorisation de stockage a été refusée définitivement (Android 8 à 10) : il faut passer par les réglages d'Android.
  ///
  /// In fr, this message translates to:
  /// **'Android ne propose plus de le demander. Dans les réglages de l\'appli, touchez Autorisations, puis Stockage, puis Autoriser.'**
  String get backupPermissionBlocked;

  /// Bouton : ouvrir la page de l'appli dans les réglages d'Android, pour autoriser le stockage.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get backupOpenSettings;

  /// Conseil sous le dossier des sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Copiez ce dossier sur un autre appareil ou synchronisez-le avec une autre application pour en garder une copie ailleurs.'**
  String get backupFolderHelp;

  /// Bouton : sauvegarde immédiate.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder maintenant'**
  String get backupNow;

  /// Bouton : choisir un fichier de sauvegarde (.sqlite) à restaurer.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer depuis un fichier…'**
  String get backupRestoreFromFile;

  /// Titre de la liste des sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardes sur cet appareil'**
  String get backupListTitle;

  /// Liste des sauvegardes vide.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sauvegarde pour l\'instant.'**
  String get backupNone;

  /// Erreur de la sauvegarde automatique.
  ///
  /// In fr, this message translates to:
  /// **'La dernière sauvegarde automatique a échoué : {message}'**
  String backupLastError(String message);

  /// Confirmation après « Sauvegarder maintenant ».
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde enregistrée.'**
  String get backupDone;

  /// Action : partager les fichiers d'une sauvegarde.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get backupShare;

  /// Action : restaurer une sauvegarde.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get backupRestore;

  /// Taille d'un fichier de sauvegarde, en kilo-octets.
  ///
  /// In fr, this message translates to:
  /// **'{size} Ko'**
  String backupSize(String size);

  /// Titre de la confirmation de restauration.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer cette sauvegarde ?'**
  String get backupRestoreTitle;

  /// Contenu d'une sauvegarde.
  ///
  /// In fr, this message translates to:
  /// **'{drinks, plural, =0{aucune référence} =1{1 référence} other{{drinks} références}}, {bottles, plural, =0{aucune bouteille} =1{1 bouteille} other{{bottles} bouteilles}}'**
  String backupContents(int drinks, int bottles);

  /// Message de confirmation de restauration.
  ///
  /// In fr, this message translates to:
  /// **'La cave actuelle sera remplacée par celle de la sauvegarde du {date} : {contents}.\n\nLa cave actuelle est d\'abord sauvegardée : vous pourrez revenir en arrière en restaurant cette sauvegarde de sécurité.'**
  String backupRestoreMessage(String date, String contents);

  /// Confirmation de restauration d'un fichier choisi.
  ///
  /// In fr, this message translates to:
  /// **'La cave actuelle sera remplacée par celle de ce fichier : {contents}.\n\nLa cave actuelle est d\'abord sauvegardée : vous pourrez revenir en arrière en restaurant cette sauvegarde de sécurité.'**
  String backupRestoreFileMessage(String contents);

  /// Confirmation après une restauration.
  ///
  /// In fr, this message translates to:
  /// **'Cave restaurée.'**
  String get backupRestored;

  /// Fichier à restaurer illisible.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une sauvegarde lisible : il est peut-être endommagé.'**
  String get backupProblemUnreadable;

  /// Fichier à restaurer qui n'est pas une base Ma Cave.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une sauvegarde de Ma Cave. Pour un fichier CSV, utilisez « Importer un fichier ».'**
  String get backupProblemNotACave;

  /// Fichier à restaurer créé par une version plus récente.
  ///
  /// In fr, this message translates to:
  /// **'Cette sauvegarde vient d\'une version plus récente de Ma Cave. Mettez l\'application à jour pour la restaurer.'**
  String get backupProblemNewer;

  /// Réglage : fréquence de la sauvegarde automatique (CDC §7).
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde automatique'**
  String get backupEveryLabel;

  /// Explication sous le réglage de fréquence de la sauvegarde automatique.
  ///
  /// In fr, this message translates to:
  /// **'Faite à l\'ouverture de l\'appli, seulement si la cave a changé.'**
  String get backupEveryHelp;

  /// Fréquence de la sauvegarde automatique : une par jour au plus.
  ///
  /// In fr, this message translates to:
  /// **'Chaque jour'**
  String get backupEveryDay;

  /// Fréquence de la sauvegarde automatique : une par semaine au plus.
  ///
  /// In fr, this message translates to:
  /// **'Chaque semaine'**
  String get backupEveryWeek;

  /// Fréquence de la sauvegarde automatique : une tous les 30 jours au plus.
  ///
  /// In fr, this message translates to:
  /// **'Chaque mois'**
  String get backupEveryMonth;

  /// Fréquence de la sauvegarde automatique, nombre de jours quelconque.
  ///
  /// In fr, this message translates to:
  /// **'Tous les {count} jours'**
  String backupEveryDays(int count);

  /// Réglage : nombre de sauvegardes gardées (les plus anciennes sont supprimées).
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardes conservées'**
  String get backupKeepLabel;

  /// Explication sous le réglage du nombre de sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Les plus anciennes sont supprimées automatiquement.'**
  String get backupKeepHelp;

  /// Titre de la confirmation quand on réduit le nombre de sauvegardes.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer des sauvegardes ?'**
  String get backupKeepConfirmTitle;

  /// Confirmation quand on réduit le nombre de sauvegardes conservées.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{La sauvegarde la plus ancienne sera supprimée.} other{Les {count} sauvegardes les plus anciennes seront supprimées.}}'**
  String backupKeepConfirmMessage(int count);

  /// Bouton : confirmer la suppression des sauvegardes en trop.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get backupKeepConfirm;

  /// Explication en tête de l'écran des sauvegardes, quand la synchronisation est active.
  ///
  /// In fr, this message translates to:
  /// **'Votre cave est synchronisée avec le serveur. Elle est sauvegardée automatiquement, à la fréquence choisie ci-dessous et seulement si elle a changé : sur cet appareil, et une copie dans le dossier « Sauvegardes » du serveur.'**
  String get backupHelpSynced;

  /// Menu principal : ouvrir l'écran de synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get menuSync;

  /// Titre de l'écran de synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get syncTitle;

  /// Explication de l'écran de synchronisation en mode local.
  ///
  /// In fr, this message translates to:
  /// **'Votre cave est enregistrée uniquement sur cet appareil. Avec la synchronisation, elle est aussi copiée sur votre serveur (Nextcloud ou autre serveur WebDAV) et partagée avec vos autres appareils. Tout reste utilisable sans réseau.'**
  String get syncIntro;

  /// Type de serveur : Nextcloud (adresse simplifiée).
  ///
  /// In fr, this message translates to:
  /// **'Nextcloud'**
  String get syncKindNextcloud;

  /// Type de serveur : tout autre serveur WebDAV (adresse complète).
  ///
  /// In fr, this message translates to:
  /// **'Autre serveur WebDAV'**
  String get syncKindOther;

  /// Champ : adresse du serveur Nextcloud.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du serveur'**
  String get syncServerLabel;

  /// Exemple d'adresse de serveur Nextcloud.
  ///
  /// In fr, this message translates to:
  /// **'cloud.exemple.fr'**
  String get syncServerHint;

  /// Champ : adresse complète du dossier, pour un autre serveur WebDAV.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du dossier WebDAV'**
  String get syncUrlLabel;

  /// Exemple d'adresse de dossier WebDAV.
  ///
  /// In fr, this message translates to:
  /// **'https://nas.exemple.fr/webdav/cave'**
  String get syncUrlHint;

  /// Champ : identifiant de connexion au serveur.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get syncUserLabel;

  /// Champ : mot de passe de connexion au serveur.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe d\'application'**
  String get syncPasswordLabel;

  /// Aide sous le champ mot de passe.
  ///
  /// In fr, this message translates to:
  /// **'Dans Nextcloud : Paramètres personnels › Sécurité › Créer un nouveau mot de passe d\'application. Il est rangé dans le coffre sécurisé de l\'appareil.'**
  String get syncPasswordHelp;

  /// Aide sous le champ mot de passe, quand on modifie des paramètres existants.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide pour garder le mot de passe actuel.'**
  String get syncPasswordKeep;

  /// Champ : dossier de la cave dans les fichiers Nextcloud.
  ///
  /// In fr, this message translates to:
  /// **'Dossier sur le serveur'**
  String get syncFolderLabel;

  /// Aide sous le champ dossier.
  ///
  /// In fr, this message translates to:
  /// **'Créé automatiquement s\'il n\'existe pas.'**
  String get syncFolderHelp;

  /// Message d'erreur : champ obligatoire vide.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire'**
  String get syncFieldRequired;

  /// Message d'erreur : adresse du serveur incorrecte.
  ///
  /// In fr, this message translates to:
  /// **'Adresse invalide'**
  String get syncInvalidAddress;

  /// Bouton : activer la synchronisation avec les paramètres saisis.
  ///
  /// In fr, this message translates to:
  /// **'Activer la synchronisation'**
  String get syncActivate;

  /// Bouton : enregistrer les paramètres modifiés.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get syncSave;

  /// Message : la synchronisation vient d'être activée.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation activée'**
  String get syncActivated;

  /// Titre de la question : le serveur contient une cave différente.
  ///
  /// In fr, this message translates to:
  /// **'Une autre cave est sur le serveur'**
  String get syncOtherCaveTitle;

  /// Explication de la question « autre cave ».
  ///
  /// In fr, this message translates to:
  /// **'Le serveur contient déjà une cave différente de celle de cet appareil. Les deux ne sont jamais mélangées : choisissez celle à garder.'**
  String get syncOtherCaveMessage;

  /// Choix : remplacer la cave du téléphone par celle du serveur.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser la cave du serveur'**
  String get syncUseServer;

  /// Explication du choix « Utiliser la cave du serveur ».
  ///
  /// In fr, this message translates to:
  /// **'La cave de cet appareil est remplacée, après une sauvegarde automatique.'**
  String get syncUseServerHelp;

  /// Choix : envoyer la cave du téléphone à la place de celle du serveur.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer la cave du serveur par celle-ci'**
  String get syncReplaceServer;

  /// Explication du choix « Remplacer la cave du serveur ».
  ///
  /// In fr, this message translates to:
  /// **'Celle du serveur est d\'abord mise de côté sur le serveur (renommée), pas supprimée.'**
  String get syncReplaceServerHelp;

  /// Bouton : rouvrir la question « autre cave ».
  ///
  /// In fr, this message translates to:
  /// **'Choisir la cave à garder'**
  String get syncChooseCave;

  /// État : synchronisation à jour.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé'**
  String get syncStatusSynced;

  /// État : synchronisation en cours.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours…'**
  String get syncStatusSyncing;

  /// État : pas de réseau (ce n'est pas une erreur).
  ///
  /// In fr, this message translates to:
  /// **'En attente du réseau : les modifications seront envoyées à son retour.'**
  String get syncStatusWaiting;

  /// État : synchronisation automatique désactivée et modifications pas encore envoyées au serveur.
  ///
  /// In fr, this message translates to:
  /// **'Modifications à envoyer'**
  String get syncStatusPending;

  /// Ligne d'explication sous l'état de la synchronisation quand elle n'est pas automatique.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation automatique désactivée : touchez « Synchroniser maintenant » pour envoyer et recevoir les modifications.'**
  String get syncManualNote;

  /// Interrupteur de l'écran Synchronisation (CDC §7).
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation automatique'**
  String get syncAutomatic;

  /// Explication sous l'interrupteur « Synchronisation automatique ».
  ///
  /// In fr, this message translates to:
  /// **'À l\'ouverture, après chaque modification et au retour du réseau. Désactivée : seulement avec « Synchroniser maintenant ».'**
  String get syncAutomaticHelp;

  /// État : la dernière synchronisation a échoué.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchronisation'**
  String get syncStatusError;

  /// Date de la dernière synchronisation réussie.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchronisation : {date}'**
  String syncLastSuccess(String date);

  /// Aucune synchronisation réussie sur cet appareil.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore synchronisé'**
  String get syncNever;

  /// Adresse du dossier de la cave sur le serveur.
  ///
  /// In fr, this message translates to:
  /// **'Dossier : {address}'**
  String syncServerLine(String address);

  /// Avertissement : erreur de synchronisation ancienne (remplace la notification).
  ///
  /// In fr, this message translates to:
  /// **'L\'erreur dure depuis plus de 24 heures.'**
  String get syncLongError;

  /// Erreur : serveur injoignable.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable. Les modifications restent sur l\'appareil, rien n\'est perdu.'**
  String get syncProblemUnreachable;

  /// Erreur : identifiants refusés.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe refusé par le serveur.'**
  String get syncProblemUnauthorized;

  /// Erreur : dossier introuvable.
  ///
  /// In fr, this message translates to:
  /// **'Dossier introuvable sur le serveur : vérifiez l\'adresse.'**
  String get syncProblemFolderNotFound;

  /// Erreur : plus de place sur le serveur.
  ///
  /// In fr, this message translates to:
  /// **'Espace insuffisant sur le serveur. Les modifications restent sur l\'appareil.'**
  String get syncProblemInsufficientStorage;

  /// Erreur : réponse inattendue du serveur.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a répondu de façon inattendue. Nouvel essai automatique.'**
  String get syncProblemServer;

  /// Erreur : base créée par une version plus récente.
  ///
  /// In fr, this message translates to:
  /// **'La cave du serveur a été enregistrée par une version plus récente de l\'application. Synchronisation suspendue : mettez l\'application à jour.'**
  String get syncProblemNewerVersion;

  /// Erreur : autre cave sur le serveur.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur contient une autre cave que celle de cet appareil.'**
  String get syncProblemOtherCave;

  /// Erreur : conflit d'écriture répété.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier du serveur changeait pendant l\'envoi. Nouvel essai automatique.'**
  String get syncProblemConflict;

  /// Message : fichier du serveur endommagé, mis de côté.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier du serveur était endommagé : il a été mis de côté sous le nom « {name} » et remplacé par la cave de cet appareil.'**
  String syncSetAside(String name);

  /// Bouton : relancer la synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get syncRetry;

  /// Bouton : lancer une synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get syncNow;

  /// Bouton : ouvrir l'écran de synchronisation pour corriger.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de synchronisation'**
  String get syncOpenSettings;

  /// Bouton : modifier l'adresse, l'identifiant ou le mot de passe.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les paramètres'**
  String get syncEdit;

  /// Bouton : revenir au mode local.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver la synchronisation'**
  String get syncDeactivate;

  /// Confirmation de la désactivation.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil garde sa cave et continue seul. La cave du serveur n\'est pas supprimée.'**
  String get syncDeactivateMessage;

  /// Message : retour au mode local.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation désactivée'**
  String get syncDeactivated;

  /// Titre de la liste des dernières erreurs.
  ///
  /// In fr, this message translates to:
  /// **'Journal des erreurs'**
  String get syncLogTitle;

  /// Journal des erreurs vide.
  ///
  /// In fr, this message translates to:
  /// **'Aucune erreur.'**
  String get syncLogEmpty;

  /// Infobulle de l'indicateur de synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'État de la synchronisation'**
  String get syncIndicatorTooltip;

  /// Rappel sur l'écran de synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Les sauvegardes sont aussi copiées dans le dossier « Sauvegardes » du serveur.'**
  String get syncBackupsNote;

  /// Menu principal : ouvrir l'écran Espace disque (purges).
  ///
  /// In fr, this message translates to:
  /// **'Espace disque'**
  String get menuStorage;

  /// Titre de l'écran Espace disque.
  ///
  /// In fr, this message translates to:
  /// **'Espace disque'**
  String get storageTitle;

  /// Taille du fichier de la cave (déjà formatée, ex. « 312 Ko »).
  ///
  /// In fr, this message translates to:
  /// **'Taille de la base : {size}'**
  String storageSize(String size);

  /// Taille en kilo-octets.
  ///
  /// In fr, this message translates to:
  /// **'{count} Ko'**
  String storageKilobytes(String count);

  /// Taille en mégaoctets.
  ///
  /// In fr, this message translates to:
  /// **'{count} Mo'**
  String storageMegabytes(String count);

  /// Nombre de mouvements dans l'historique.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Historique : aucun mouvement} =1{Historique : 1 mouvement} other{Historique : {count} mouvements}}'**
  String storageHistory(int count);

  /// Date du plus ancien mouvement.
  ///
  /// In fr, this message translates to:
  /// **'Depuis le {date}'**
  String storageHistorySince(String date);

  /// Date de la dernière purge manuelle.
  ///
  /// In fr, this message translates to:
  /// **'Historique déjà purgé avant le {date}.'**
  String storagePurgedBefore(String date);

  /// Titre de la section purge manuelle.
  ///
  /// In fr, this message translates to:
  /// **'Purge de l\'historique'**
  String get storagePurgeTitle;

  /// Explication de la purge manuelle.
  ///
  /// In fr, this message translates to:
  /// **'Supprime les mouvements anciens pour alléger la base. Les stocks ne changent pas : le stock de chaque lot à la date choisie est conservé. Les statistiques de consommation de cette période sont perdues.'**
  String get storagePurgeHelp;

  /// Bouton : choisir la date de purge.
  ///
  /// In fr, this message translates to:
  /// **'Purger l\'historique…'**
  String get storagePurgeButton;

  /// La purge n'est pas possible : pas de mouvement assez ancien.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement de plus d\'un mois : rien à purger.'**
  String get storagePurgeNothingOld;

  /// Titre du calendrier de choix de la date de purge.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'historique avant le'**
  String get storagePurgePickerHelp;

  /// Message : rien à purger avant la date choisie.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement avant cette date.'**
  String get storagePurgeNone;

  /// Titre de la confirmation de purge.
  ///
  /// In fr, this message translates to:
  /// **'Purger l\'historique ?'**
  String get storagePurgeConfirmTitle;

  /// Confirmation de la purge manuelle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 mouvement antérieur au {date} sera supprimé} other{{count} mouvements antérieurs au {date} seront supprimés}} définitivement, sur tous les appareils synchronisés. Les stocks ne changent pas. Une sauvegarde est faite avant.'**
  String storagePurgeConfirmMessage(int count, String date);

  /// Bouton : confirmer la purge.
  ///
  /// In fr, this message translates to:
  /// **'Purger'**
  String get storagePurgeConfirm;

  /// Message : résultat de la purge manuelle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun mouvement supprimé} =1{1 mouvement supprimé} other{{count} mouvements supprimés}}'**
  String storagePurgeDone(int count);

  /// Interrupteur : purge automatique des lots épuisés.
  ///
  /// In fr, this message translates to:
  /// **'Purge automatique'**
  String get storageAutoTitle;

  /// Explication de la purge automatique.
  ///
  /// In fr, this message translates to:
  /// **'Supprime les lots épuisés sans mouvement depuis le délai choisi, avec leur historique, et la référence si elle n\'a plus aucun lot. Les lots en stock ne sont jamais supprimés.'**
  String get storageAutoHelp;

  /// Choix du délai de la purge automatique.
  ///
  /// In fr, this message translates to:
  /// **'Délai sans mouvement'**
  String get storageAutoDelay;

  /// Durée en mois.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 mois} other{{count} mois}}'**
  String storageMonths(int count);

  /// Durée en années.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 an} other{{count} ans}}'**
  String storageYears(int count);

  /// Titre de la confirmation de la purge automatique.
  ///
  /// In fr, this message translates to:
  /// **'Purge automatique'**
  String get storageAutoConfirmTitle;

  /// Confirmation : lots supprimés dès l'activation de la purge automatique.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 lot épuisé sera supprimé} other{{count} lots épuisés seront supprimés}} dès maintenant, avec leur historique. Une sauvegarde est faite avant.'**
  String storageAutoConfirmMessage(int count);

  /// Bouton : confirmer la purge automatique immédiate.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get storageAutoConfirm;

  /// Message : résultat de la purge automatique.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun lot supprimé} =1{1 lot supprimé} other{{count} lots supprimés}}'**
  String storageAutoDone(int count);

  /// Bouton de la liste : ouvrir le scan de code-barres.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get scanButton;

  /// Bouton de la liste sur PC (pas de caméra) : saisir un code-barres au clavier ou avec une douchette.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres'**
  String get scanButtonByHand;

  /// Titre de l'écran de scan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un code'**
  String get scanTitle;

  /// Consigne affichée sur l'image de l'appareil photo.
  ///
  /// In fr, this message translates to:
  /// **'Visez le code-barres ou le QR code de la bouteille.'**
  String get scanHint;

  /// Bouton : allumer la lampe torche.
  ///
  /// In fr, this message translates to:
  /// **'Allumer la lampe'**
  String get scanTorchOn;

  /// Bouton : éteindre la lampe torche.
  ///
  /// In fr, this message translates to:
  /// **'Éteindre la lampe'**
  String get scanTorchOff;

  /// Bouton : taper le code-barres à la main.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le code'**
  String get scanManualEntry;

  /// Champ : code-barres tapé à la main.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres'**
  String get scanManualLabel;

  /// Aide du champ de saisie du code sur PC (pas de caméra).
  ///
  /// In fr, this message translates to:
  /// **'Tapez le code, ou lisez-le avec une douchette USB.'**
  String get scanManualScannerHelp;

  /// Erreur : autorisation de l'appareil photo refusée.
  ///
  /// In fr, this message translates to:
  /// **'L\'appareil photo n\'est pas autorisé. Autorisez-le dans les paramètres d\'Android pour scanner, ou saisissez le code.'**
  String get scanCameraDenied;

  /// Erreur : l'appareil photo ne démarre pas.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo indisponible ({detail}). Vous pouvez saisir le code.'**
  String scanCameraError(String detail);

  /// Code lu, affiché sous le résultat.
  ///
  /// In fr, this message translates to:
  /// **'Code : {code}'**
  String scanCode(String code);

  /// Bouton du résultat du scan : retirer une bouteille de ce lot.
  ///
  /// In fr, this message translates to:
  /// **'−1'**
  String get scanRemoveOne;

  /// Bouton du résultat du scan : ajouter des bouteilles à ce lot.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get scanAdd;

  /// Bouton : autre millésime ou volume pour la même référence.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau lot sur cette référence'**
  String get scanNewLot;

  /// Bouton : ouvrir la fiche de la référence trouvée.
  ///
  /// In fr, this message translates to:
  /// **'Voir la fiche'**
  String get scanOpenDrink;

  /// Bouton : relancer le scan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un autre code'**
  String get scanAgain;

  /// Bouton sur PC (pas de caméra) : saisir un autre code-barres.
  ///
  /// In fr, this message translates to:
  /// **'Saisir un autre code'**
  String get scanAgainByHand;

  /// Titre : le code lu n'est dans aucun lot.
  ///
  /// In fr, this message translates to:
  /// **'Code inconnu'**
  String get scanUnknownTitle;

  /// Explication : code inconnu.
  ///
  /// In fr, this message translates to:
  /// **'Ce code n\'est associé à aucune bouteille de la cave.'**
  String get scanUnknownMessage;

  /// Bouton : créer une référence, code pré-rempli.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle référence avec ce code'**
  String get scanNewDrink;

  /// Bouton : rattacher le code à un lot existant.
  ///
  /// In fr, this message translates to:
  /// **'Associer à une référence existante'**
  String get scanAssociate;

  /// Titre de l'écran de choix d'une référence pour y associer un code.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la référence'**
  String get scanPickDrinkTitle;

  /// Titre du choix du lot pour y associer un code.
  ///
  /// In fr, this message translates to:
  /// **'Associer le code à quel lot ?'**
  String get scanPickLotTitle;

  /// Message : code-barres mémorisé sur un lot.
  ///
  /// In fr, this message translates to:
  /// **'Code associé à {lot}'**
  String scanAssociated(String lot);

  /// Rappel dans le formulaire d'ajout : code scanné, mémorisé sur le lot.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres : {code}'**
  String drinkFormBarcode(String code);

  /// Bouton : valider une saisie.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get actionOk;

  /// Recherche en cours ; signale l'envoi du code (CDC §9).
  ///
  /// In fr, this message translates to:
  /// **'Recherche sur Open Food Facts… (le code-barres est envoyé à ce service)'**
  String get offSearching;

  /// Source des informations pré-remplies.
  ///
  /// In fr, this message translates to:
  /// **'Open Food Facts'**
  String get offSource;

  /// Produit trouvé sur Open Food Facts mais sans nom.
  ///
  /// In fr, this message translates to:
  /// **'Produit sans nom'**
  String get offUnnamed;

  /// Bouton : formulaire pré-rempli avec le produit trouvé.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle référence avec ces informations'**
  String get offUseDraft;

  /// Résultat : produit introuvable.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu d\'Open Food Facts : fiche à remplir, le code sera mémorisé.'**
  String get offNotFound;

  /// Résultat : pas de réseau.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne : pas de recherche sur Open Food Facts. Le code sera mémorisé.'**
  String get offOffline;

  /// Résultat : service indisponible.
  ///
  /// In fr, this message translates to:
  /// **'Open Food Facts ne répond pas : fiche à remplir, le code sera mémorisé.'**
  String get offUnavailable;

  /// Titre : références proches du produit trouvé.
  ///
  /// In fr, this message translates to:
  /// **'Déjà dans votre cave ?'**
  String get scanMaybeTitle;

  /// Aide sous les références proches.
  ///
  /// In fr, this message translates to:
  /// **'Touchez une référence pour lui associer ce code.'**
  String get scanMaybeHelp;

  /// Titre de l'avertissement de doublon à la création.
  ///
  /// In fr, this message translates to:
  /// **'Référence proche déjà dans la cave'**
  String get similarTitle;

  /// Explication de l'avertissement de doublon.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter les bouteilles à l\'une de ces références plutôt que d\'en créer une nouvelle ? Sa fiche n\'est pas modifiée.'**
  String get similarMessage;

  /// Bouton : ignorer l'avertissement de doublon.
  ///
  /// In fr, this message translates to:
  /// **'Créer une nouvelle référence'**
  String get similarCreateAnyway;

  /// Bouton : fermer l'avertissement de doublon pour modifier la saisie.
  ///
  /// In fr, this message translates to:
  /// **'Revenir au formulaire'**
  String get similarBack;

  /// Bouton : photographier l'étiquette pour pré-remplir la fiche.
  ///
  /// In fr, this message translates to:
  /// **'Lire l\'étiquette'**
  String get labelButton;

  /// Bouton de l'écran de scan : passer à la photo de l'étiquette.
  ///
  /// In fr, this message translates to:
  /// **'Pas de code-barres ? Photo de l\'étiquette'**
  String get labelScanInstead;

  /// Titre de l'écran de prise de vue.
  ///
  /// In fr, this message translates to:
  /// **'Photo de l\'étiquette'**
  String get labelTitle;

  /// Consigne de prise de vue.
  ///
  /// In fr, this message translates to:
  /// **'Cadrez l\'étiquette entière, bien à plat, sans reflet.'**
  String get labelHint;

  /// Bouton : prendre la photo.
  ///
  /// In fr, this message translates to:
  /// **'Photographier'**
  String get labelTake;

  /// Erreur : pas de caméra.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil photo disponible.'**
  String get labelNoCamera;

  /// Pendant la reconnaissance du texte.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de l\'étiquette…'**
  String get labelReading;

  /// Message : rien n'a été reconnu.
  ///
  /// In fr, this message translates to:
  /// **'Aucun texte lu sur la photo. Réessayez plus près, avec la lampe si besoin.'**
  String get labelNothingRead;

  /// Titre de l'écran des informations lues.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de l\'étiquette'**
  String get labelReadTitle;

  /// Explication de l'écran de lecture.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les informations lues. Touchez une ligne de texte plus bas pour l\'utiliser comme nom, producteur ou appellation.'**
  String get labelReadHelp;

  /// Champ que la lecture n'a pas trouvé.
  ///
  /// In fr, this message translates to:
  /// **'Non trouvé'**
  String get labelNotFound;

  /// Infobulle : effacer une suggestion.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get labelClear;

  /// Type deviné : vin.
  ///
  /// In fr, this message translates to:
  /// **'Vin'**
  String get labelTypeWine;

  /// Type deviné : bière.
  ///
  /// In fr, this message translates to:
  /// **'Bière'**
  String get labelTypeBeer;

  /// Type deviné : spiritueux.
  ///
  /// In fr, this message translates to:
  /// **'Spiritueux'**
  String get labelTypeSpirit;

  /// Type deviné : soft.
  ///
  /// In fr, this message translates to:
  /// **'Soft'**
  String get labelTypeSoft;

  /// Aide sous les références proches, après lecture d'une étiquette.
  ///
  /// In fr, this message translates to:
  /// **'Touchez une référence pour lui ajouter des bouteilles.'**
  String get labelMaybeHelp;

  /// Bouton : ouvrir le formulaire pré-rempli.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec ces informations'**
  String get labelContinue;

  /// Titre de la liste des lignes reconnues.
  ///
  /// In fr, this message translates to:
  /// **'Texte lu'**
  String get labelLinesTitle;

  /// Aide sous la liste des lignes reconnues.
  ///
  /// In fr, this message translates to:
  /// **'Touchez une ligne pour l\'attribuer à un champ.'**
  String get labelLinesHelp;

  /// Choix : la ligne devient le nom.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser comme nom'**
  String get labelUseAsName;

  /// Choix : la ligne devient le producteur.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser comme producteur'**
  String get labelUseAsProducer;

  /// Choix : la ligne devient l'appellation.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser comme appellation'**
  String get labelUseAsAppellation;

  /// Choix : la ligne est ajoutée à la fin du nom déjà rempli (nom découpé en plusieurs lignes sur la photo).
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à la suite du nom'**
  String get labelAppendToName;

  /// Choix : la ligne est ajoutée à la fin du producteur déjà rempli.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à la suite du producteur'**
  String get labelAppendToProducer;

  /// Bouton de la fiche « Code inconnu » : lire l'étiquette.
  ///
  /// In fr, this message translates to:
  /// **'Photographier l\'étiquette'**
  String get scanUnknownPhoto;

  /// Menu d'un lot : scanner son code-barres pour la prochaine fois.
  ///
  /// In fr, this message translates to:
  /// **'Associer un code-barres'**
  String get lotScanBarcode;

  /// Menu d'un lot qui a déjà un code-barres.
  ///
  /// In fr, this message translates to:
  /// **'Changer le code-barres'**
  String get lotChangeBarcode;

  /// Bouton du formulaire de création : lire le code de la bouteille.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le code-barres'**
  String get formScanBarcode;

  /// Bouton du formulaire de création sur PC (pas de caméra) : saisir le code de la bouteille.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le code-barres'**
  String get formEnterBarcode;

  /// Titre : le code scanné est déjà associé à une référence.
  ///
  /// In fr, this message translates to:
  /// **'Code déjà dans la cave'**
  String get formBarcodeKnownTitle;

  /// Explication : code déjà connu.
  ///
  /// In fr, this message translates to:
  /// **'Ce code-barres est déjà associé à « {name} ». Un même code peut servir à plusieurs lots : vous pouvez continuer, ou ouvrir cette référence pour lui ajouter des bouteilles.'**
  String formBarcodeKnownMessage(String name);

  /// Bouton : associer quand même le code à la nouvelle référence.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec ce code'**
  String get formBarcodeKeep;

  /// Bouton : ouvrir la référence qui porte déjà ce code.
  ///
  /// In fr, this message translates to:
  /// **'Voir la référence'**
  String get formBarcodeOpen;

  /// Message : le formulaire a été complété grâce au code-barres.
  ///
  /// In fr, this message translates to:
  /// **'Champs vides complétés avec Open Food Facts'**
  String get formOffFilled;

  /// Premier lancement : position dans les étapes.
  ///
  /// In fr, this message translates to:
  /// **'Étape {step} sur {total}'**
  String welcomeStep(int step, int total);

  /// Premier lancement : passer l'étape.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get welcomeSkip;

  /// Premier lancement : étape suivante.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get welcomeNext;

  /// Premier lancement : dernière étape, ouvrir la cave.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get welcomeFinish;

  /// Premier lancement, étape 1 : titre.
  ///
  /// In fr, this message translates to:
  /// **'Où ranger votre cave ?'**
  String get welcomeStorageTitle;

  /// Premier lancement, étape 1 : explication.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez changer d\'avis plus tard (menu ⋮ → Paramètres → Synchronisation).'**
  String get welcomeStorageHelp;

  /// Premier lancement : choix du mode local.
  ///
  /// In fr, this message translates to:
  /// **'Sur cet appareil uniquement'**
  String get welcomeLocal;

  /// Premier lancement : détail du mode local.
  ///
  /// In fr, this message translates to:
  /// **'Rien à configurer. Sauvegardes automatiques dans Documents/Cave/Sauvegardes.'**
  String get welcomeLocalHelp;

  /// Premier lancement : choix de la synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser avec un serveur'**
  String get welcomeSync;

  /// Premier lancement : détail de la synchronisation.
  ///
  /// In fr, this message translates to:
  /// **'Nextcloud ou autre serveur WebDAV. Si une cave y est déjà, elle est récupérée (nouvel appareil).'**
  String get welcomeSyncHelp;

  /// Premier lancement : la synchronisation est en place.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation activée'**
  String get welcomeSyncDone;

  /// Alerte du mode local (CDC §8.4) : titre.
  ///
  /// In fr, this message translates to:
  /// **'Données sur cet appareil seulement'**
  String get welcomeLocalAlertTitle;

  /// Alerte du mode local (CDC §8.4) : message.
  ///
  /// In fr, this message translates to:
  /// **'Votre cave n\'est enregistrée que sur cet appareil. S\'il est perdu, cassé ou réinitialisé, elle est perdue aussi.\n\nPensez à copier de temps en temps le dossier Documents/Cave/Sauvegardes ailleurs (autre appareil, cloud), ou activez la synchronisation (menu ⋮ → Paramètres → Synchronisation).'**
  String get welcomeLocalAlert;

  /// Alerte du mode local : bouton.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai compris'**
  String get welcomeLocalAlertOk;

  /// Premier lancement, étape 2 : titre.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà une cave ?'**
  String get welcomeImportTitle;

  /// Premier lancement, étape 2 : explication.
  ///
  /// In fr, this message translates to:
  /// **'Importez un export Vivino ou un fichier CSV (par exemple une sauvegarde de Ma Cave). Un aperçu est affiché avant tout ajout. Vous pourrez aussi le faire plus tard (menu ⋮ → Importer un fichier).'**
  String get welcomeImportHelp;

  /// Premier lancement, étape 2 : bouton d'import.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier'**
  String get welcomeImportButton;

  /// Premier lancement, étape 2 : contenu actuel de la cave.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Votre cave est encore vide.} =1{Votre cave contient 1 bouteille.} other{Votre cave contient {count} bouteilles.}}'**
  String welcomeImportCount(int count);

  /// Premier lancement, étape 3 : titre.
  ///
  /// In fr, this message translates to:
  /// **'Volumes par défaut'**
  String get welcomeDefaultsTitle;

  /// Premier lancement, étape 3 : explication.
  ///
  /// In fr, this message translates to:
  /// **'Volume proposé pour une nouvelle bouteille, selon son type. Touchez une ligne pour le changer ; vous pourrez aussi le faire plus tard dans les paramètres.'**
  String get welcomeDefaultsHelp;

  /// Fenêtre de choix du volume par défaut d'un type.
  ///
  /// In fr, this message translates to:
  /// **'Volume par défaut : {type}'**
  String welcomeVolumeOf(String type);

  /// Menu : ouvrir les paramètres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get menuSettings;

  /// Titre de l'écran des paramètres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// Paramètres : rubrique.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// Paramètres : choix du thème.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// Thème : suivre le réglage d'Android.
  ///
  /// In fr, this message translates to:
  /// **'Comme le système'**
  String get settingsThemeSystem;

  /// Thème clair.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// Thème sombre.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// Paramètres : taille du texte.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get settingsTextSize;

  /// Taille du texte : celle d'Android.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get settingsTextNormal;

  /// Taille du texte : un peu plus grande.
  ///
  /// In fr, this message translates to:
  /// **'Grande'**
  String get settingsTextLarge;

  /// Taille du texte : nettement plus grande.
  ///
  /// In fr, this message translates to:
  /// **'Très grande'**
  String get settingsTextLarger;

  /// Paramètres : rubrique des volumes pré-remplis.
  ///
  /// In fr, this message translates to:
  /// **'Volumes par défaut'**
  String get settingsDefaults;

  /// Paramètres : explication des volumes par défaut.
  ///
  /// In fr, this message translates to:
  /// **'Volume proposé pour une nouvelle bouteille, selon son type. Partagé avec vos autres appareils si la synchronisation est active.'**
  String get settingsDefaultsHelp;

  /// Paramètres : rubrique.
  ///
  /// In fr, this message translates to:
  /// **'Affichage'**
  String get settingsDisplay;

  /// Paramètres : tri de la liste au démarrage.
  ///
  /// In fr, this message translates to:
  /// **'Tri à l\'ouverture'**
  String get settingsDefaultSort;

  /// Paramètres : interrupteur.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les références épuisées'**
  String get settingsShowExhausted;

  /// Paramètres : explication de l'interrupteur des épuisés.
  ///
  /// In fr, this message translates to:
  /// **'À l\'ouverture de l\'appli ; modifiable à tout moment dans les filtres.'**
  String get settingsShowExhaustedHelp;

  /// Paramètres : durée d'affichage du bandeau d'annulation.
  ///
  /// In fr, this message translates to:
  /// **'Durée du bandeau « Annuler »'**
  String get settingsUndo;

  /// Une durée en secondes.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 seconde} other{{count} secondes}}'**
  String settingsSeconds(int count);

  /// Paramètres : rubrique.
  ///
  /// In fr, this message translates to:
  /// **'Reconnaissance'**
  String get settingsRecognition;

  /// Paramètres : interrupteur.
  ///
  /// In fr, this message translates to:
  /// **'Recherche sur Open Food Facts'**
  String get settingsOff;

  /// Paramètres : explication de la recherche Open Food Facts.
  ///
  /// In fr, this message translates to:
  /// **'Pour un code-barres inconnu, le code (et rien d\'autre) est envoyé à Open Food Facts pour pré-remplir la fiche.'**
  String get settingsOffHelp;

  /// Paramètres : rubrique synchronisation, sauvegardes, import/export.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsData;

  /// Paramètres : note en bas de l'écran.
  ///
  /// In fr, this message translates to:
  /// **'Sauf les volumes par défaut, ces réglages ne concernent que cet appareil.'**
  String get settingsDeviceNote;

  /// Paramètres : lien vers la gestion de la classification.
  ///
  /// In fr, this message translates to:
  /// **'Types et caractéristiques'**
  String get settingsClassification;

  /// Paramètres : détail du lien classification.
  ///
  /// In fr, this message translates to:
  /// **'Vin, bière… et leurs familles : robe, style, parfum…'**
  String get settingsClassificationHelp;

  /// Titre de l'écran de gestion de la classification.
  ///
  /// In fr, this message translates to:
  /// **'Types et caractéristiques'**
  String get classTitle;

  /// Explication en haut de l'écran classification.
  ///
  /// In fr, this message translates to:
  /// **'Chaque type a ses familles de caractéristiques (robe, style…) et leurs valeurs (rouge, IPA…). Partagé avec vos autres appareils si la synchronisation est active.'**
  String get classHelp;

  /// Ligne sous le nom d'un type : profil de champs et volume par défaut.
  ///
  /// In fr, this message translates to:
  /// **'{profile} · {volume}'**
  String classTypeSummary(String profile, String volume);

  /// Bouton : créer un type de boisson.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un type'**
  String get classAddType;

  /// Bouton : créer une famille de caractéristiques.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une famille'**
  String get classAddFamily;

  /// Puce : ajouter une valeur à une famille.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get classAddValue;

  /// Titre de la fenêtre de création d'un type.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau type'**
  String get classNewType;

  /// Titre de la fenêtre de création d'une famille.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle famille'**
  String get classNewFamily;

  /// Titre de la fenêtre de création d'une valeur.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle valeur : {family}'**
  String classNewValue(String family);

  /// Action : renommer.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get classRename;

  /// Action : supprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get classDelete;

  /// Champ : nom d'un type, d'une famille ou d'une valeur.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get className;

  /// Erreur : nom vide.
  ///
  /// In fr, this message translates to:
  /// **'Nom obligatoire'**
  String get classNameRequired;

  /// Erreur : nom déjà utilisé au même endroit.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom existe déjà ici'**
  String get classNameTaken;

  /// Champ : profil de champs d'un nouveau type.
  ///
  /// In fr, this message translates to:
  /// **'Champs de la fiche'**
  String get classProfile;

  /// Aide sous le choix du profil.
  ///
  /// In fr, this message translates to:
  /// **'Ne peut plus être changé ensuite.'**
  String get classProfileHelp;

  /// Profil de champs : vin.
  ///
  /// In fr, this message translates to:
  /// **'Comme un vin'**
  String get profileWine;

  /// Profil de champs : bière.
  ///
  /// In fr, this message translates to:
  /// **'Comme une bière'**
  String get profileBeer;

  /// Profil de champs : spiritueux.
  ///
  /// In fr, this message translates to:
  /// **'Comme un spiritueux'**
  String get profileSpirit;

  /// Profil de champs : soft.
  ///
  /// In fr, this message translates to:
  /// **'Comme un soft'**
  String get profileSoft;

  /// Champs du profil vin.
  ///
  /// In fr, this message translates to:
  /// **'Millésime, appellation, région ou pays obligatoire, cépages, degré'**
  String get profileWineHelp;

  /// Champs du profil bière.
  ///
  /// In fr, this message translates to:
  /// **'Région, degré ; pas de millésime'**
  String get profileBeerHelp;

  /// Champs du profil spiritueux.
  ///
  /// In fr, this message translates to:
  /// **'Millésime, appellation, région, degré'**
  String get profileSpiritHelp;

  /// Champs du profil soft.
  ///
  /// In fr, this message translates to:
  /// **'Nom, producteur, volume seulement'**
  String get profileSoftHelp;

  /// Message : type sans famille.
  ///
  /// In fr, this message translates to:
  /// **'Aucune famille pour ce type.'**
  String get classNoFamily;

  /// Message : famille sans valeur.
  ///
  /// In fr, this message translates to:
  /// **'Aucune valeur'**
  String get classNoValue;

  /// Confirmation : suppression d'un type.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le type « {name} » ?'**
  String classDeleteTypeTitle(String name);

  /// Confirmation : conséquences de la suppression d'un type.
  ///
  /// In fr, this message translates to:
  /// **'Ses familles et leurs valeurs seront supprimées. {count, plural, =0{Aucune référence n\'est concernée.} =1{1 référence restera dans la cave, « sans catégorie ».} other{{count} références resteront dans la cave, « sans catégorie ».}}'**
  String classDeleteTypeMessage(int count);

  /// Confirmation : suppression d'une famille.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la famille « {name} » ?'**
  String classDeleteFamilyTitle(String name);

  /// Confirmation : suppression d'une valeur.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ?'**
  String classDeleteValueTitle(String name);

  /// Confirmation : conséquences de la suppression d'une famille ou d'une valeur.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune référence n\'est concernée.} =1{1 référence perdra cette caractéristique (la fiche, elle, est gardée).} other{{count} références perdront cette caractéristique (les fiches, elles, sont gardées).}}'**
  String classDeleteCharMessage(int count);

  /// Message : le dernier type ne peut pas être supprimé.
  ///
  /// In fr, this message translates to:
  /// **'Il faut garder au moins un type.'**
  String get classLastType;

  /// Titre de l'écran À propos ; lien dans les paramètres.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutTitle;

  /// Numéro de version de l'appli.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// Présentation de l'appli.
  ///
  /// In fr, this message translates to:
  /// **'Gestion d\'une cave personnelle, entièrement hors ligne, avec synchronisation facultative sur votre serveur.'**
  String get aboutDescription;

  /// Auteur de l'appli.
  ///
  /// In fr, this message translates to:
  /// **'© 2026 Maxence Pithon'**
  String get aboutCopyright;

  /// Licence de l'appli.
  ///
  /// In fr, this message translates to:
  /// **'Logiciel libre sous licence GNU GPL version 3 ou ultérieure. Fourni sans aucune garantie.'**
  String get aboutLicense;

  /// À propos : rubrique des sources de données.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get aboutData;

  /// Source des appellations. Dates de mise à jour affichées par tool/build_appellations.py : à reporter ici et dans COPYING.md après chaque reconstruction de la liste.
  ///
  /// In fr, this message translates to:
  /// **'Appellations : Institut national de l\'origine et de la qualité (INAO), data.gouv.fr, jeux de données « Aires et produits AOC/AOP et IGP » (mis à jour le 9 octobre 2025) et « Délimitation parcellaire des AOC viticoles » (mis à jour le 5 octobre 2026) — Licence Ouverte / Etalab 2.0.'**
  String get aboutInao;

  /// Source Open Food Facts.
  ///
  /// In fr, this message translates to:
  /// **'Fiches pré-remplies : Open Food Facts (openfoodfacts.org), base libre sous licence ODbL. Seul le code-barres est envoyé.'**
  String get aboutOff;

  /// À propos : rubrique des moteurs de reconnaissance.
  ///
  /// In fr, this message translates to:
  /// **'Lecture des codes-barres et des étiquettes'**
  String get aboutRecognition;

  /// Mention Tesseract et bibliothèques embarquées (mention IJG exigée).
  ///
  /// In fr, this message translates to:
  /// **'Tesseract OCR et son dictionnaire français (tessdata_best), via Tesseract4Android — Apache 2.0. Avec Leptonica, libpng et libjpeg : ce logiciel est basé en partie sur les travaux de l\'Independent JPEG Group.'**
  String get aboutTesseract;

  /// Mention ZXing.
  ///
  /// In fr, this message translates to:
  /// **'ZXing, lecteur de codes-barres libre — Apache 2.0.'**
  String get aboutZxing;

  /// Source de l'icône.
  ///
  /// In fr, this message translates to:
  /// **'Icône : « bottle » de Tabler Icons (tabler.io), © Paweł Kuna — MIT.'**
  String get aboutIcon;

  /// Bouton : liste des licences des bibliothèques.
  ///
  /// In fr, this message translates to:
  /// **'Licences des logiciels'**
  String get aboutLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
