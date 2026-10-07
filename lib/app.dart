import 'package:flutter/material.dart';

import 'features/cellar/cellar_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// Racine de l'application : thèmes, langues et écran d'accueil.
class CaveApp extends StatelessWidget {
  const CaveApp({
    super.key,
    this.themeMode = ThemeMode.system,
    this.firstLaunch = false,
  });

  /// Système par défaut ; le paramètre « Apparence » (lot 6) pourra le forcer.
  final ThemeMode themeMode;

  /// Premier lancement pas encore fait sur cet appareil : accueil en trois
  /// étapes si la cave est neuve (CDC §6.8).
  final bool firstLaunch;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: firstLaunch ? const WelcomeGate() : const CellarScreen(),
    );
  }
}
