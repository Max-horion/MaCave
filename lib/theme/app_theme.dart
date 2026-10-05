import 'package:flutter/material.dart';

/// Thèmes clair et sombre de l'application.
///
/// Le cahier des charges (section 9, Ergonomie) demande une appli utilisable
/// d'une main dans une cave peu éclairée : contraste élevé et gros boutons.
/// Le choix clair / sombre suit le système par défaut (géré dans `app.dart`).
abstract final class AppTheme {
  /// Couleur de départ de la palette : un bordeaux.
  static const Color seedColor = Color(0xFF7B1E3A);

  /// Hauteur minimale des boutons, au-dessus des 48 dp recommandés.
  static const double minButtonHeight = 56;

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: 0.5, // contraste renforcé (de -1 à 1)
    );
    const buttonSize = Size(64, minButtonHeight);

    return ThemeData(
      colorScheme: colorScheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: buttonSize),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: buttonSize),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: buttonSize),
      ),
    );
  }
}
