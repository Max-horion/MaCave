import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_preferences.dart';
import 'features/cellar/cellar_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// Racine de l'application : thèmes, langues et écran d'accueil.
class CaveApp extends ConsumerWidget {
  const CaveApp({super.key, this.firstLaunch = false});

  /// Premier lancement pas encore fait sur cet appareil : accueil en trois
  /// étapes si la cave est neuve (CDC §6.8).
  final bool firstLaunch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: prefs.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Taille du texte : celle d'Android, agrandie si demandé (CDC §7).
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1) * prefs.textScale,
            ),
          ),
          child: child!,
        );
      },
      home: firstLaunch ? const WelcomeGate() : const CellarScreen(),
    );
  }
}
