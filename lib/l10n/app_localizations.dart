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

  /// Avertissement quand un champ obligatoire du vin est vide.
  ///
  /// In fr, this message translates to:
  /// **'Sans appellation ni région, la fiche sera marquée « à compléter ».'**
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
