import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/drink_filter.dart';
import '../sync/providers.dart';
import 'local_store.dart';

/// Réglages d'affichage propres à cet appareil (CDC §7 : Apparence,
/// Affichage, Reconnaissance) : chacun règle son téléphone, rien n'est
/// synchronisé.
class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.textScale = 1.0,
    this.defaultSort = DrinkSort.name,
    this.showExhausted = false,
    this.undoSeconds = 6,
    this.openFoodFacts = true,
  });

  final ThemeMode themeMode;

  /// Multiplie la taille du texte choisie dans Android ([textScales]).
  final double textScale;

  /// Tri de la liste à l'ouverture de l'appli.
  final DrinkSort defaultSort;

  /// Références épuisées affichées dans la liste à l'ouverture.
  final bool showExhausted;

  /// Durée du bandeau « Annuler » ([undoChoices]).
  final int undoSeconds;

  /// Recherche des codes-barres inconnus sur Open Food Facts.
  final bool openFoodFacts;

  Duration get undoDuration => Duration(seconds: undoSeconds);

  static const textScales = [1.0, 1.15, 1.3];
  static const undoChoices = [4, 6, 10, 15];

  AppPreferences copyWith({
    ThemeMode? themeMode,
    double? textScale,
    DrinkSort? defaultSort,
    bool? showExhausted,
    int? undoSeconds,
    bool? openFoodFacts,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    textScale: textScale ?? this.textScale,
    defaultSort: defaultSort ?? this.defaultSort,
    showExhausted: showExhausted ?? this.showExhausted,
    undoSeconds: undoSeconds ?? this.undoSeconds,
    openFoodFacts: openFoodFacts ?? this.openFoodFacts,
  );

  // Clés des préférences : ne pas les renommer (réglages déjà enregistrés).
  static const _themeKey = 'pref_theme';
  static const _textScaleKey = 'pref_text_scale';
  static const _sortKey = 'pref_default_sort';
  static const _exhaustedKey = 'pref_show_exhausted';
  static const _undoKey = 'pref_undo_seconds';
  static const _offKey = 'pref_open_food_facts';

  /// Lit les réglages ; une valeur absente ou illisible garde sa valeur par
  /// défaut.
  static Future<AppPreferences> load(LocalStore store) async {
    const d = AppPreferences();
    final scale = double.tryParse(await store.getString(_textScaleKey) ?? '');
    final undo = int.tryParse(await store.getString(_undoKey) ?? '');
    return AppPreferences(
      themeMode:
          ThemeMode.values.asNameMap()[await store.getString(_themeKey)] ??
          d.themeMode,
      textScale: textScales.contains(scale) ? scale! : d.textScale,
      defaultSort:
          DrinkSort.values.asNameMap()[await store.getString(_sortKey)] ??
          d.defaultSort,
      showExhausted: await store.getString(_exhaustedKey) == 'true',
      undoSeconds: undoChoices.contains(undo) ? undo! : d.undoSeconds,
      openFoodFacts: await store.getString(_offKey) != 'false',
    );
  }

  Future<void> save(LocalStore store) async {
    await store.setString(_themeKey, themeMode.name);
    await store.setString(_textScaleKey, '$textScale');
    await store.setString(_sortKey, defaultSort.name);
    await store.setString(_exhaustedKey, '$showExhausted');
    await store.setString(_undoKey, '$undoSeconds');
    await store.setString(_offKey, '$openFoodFacts');
  }
}

/// Réglages lus avant le premier dessin (`main.dart`), pour que l'appli
/// s'ouvre directement avec le bon thème. Valeurs par défaut dans les tests.
final initialAppPreferencesProvider = Provider<AppPreferences>(
  (ref) => const AppPreferences(),
);

final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferences>(
      AppPreferencesNotifier.new,
    );

class AppPreferencesNotifier extends Notifier<AppPreferences> {
  @override
  AppPreferences build() => ref.read(initialAppPreferencesProvider);

  /// Applique tout de suite, puis enregistre.
  Future<void> change(AppPreferences Function(AppPreferences) edit) async {
    state = edit(state);
    await state.save(ref.read(localStoreProvider));
  }
}
