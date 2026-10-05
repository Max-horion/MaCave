import 'package:flutter/material.dart';

import 'features/cellar/cellar_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// Racine de l'application : thèmes, langues et écran d'accueil.
class CaveApp extends StatelessWidget {
  const CaveApp({super.key, this.themeMode = ThemeMode.system});

  /// Système par défaut ; le paramètre « Apparence » (lot 6) pourra le forcer.
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CellarScreen(),
    );
  }
}
