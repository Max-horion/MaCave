import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_preferences.dart';
import 'features/cellar/cellar_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// Navigateur de l'appli : la touche Échap y revient à l'écran précédent.
final _navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: _navigatorKey,
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
          // Échap (clavier du PC) : les fenêtres et menus se ferment déjà
          // seuls ; ailleurs, Échap quitte d'abord le champ de texte en cours
          // (une saisie n'est pas abandonnée d'un seul geste), puis revient à
          // l'écran précédent, comme le bouton retour.
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: _escape,
            child: child!,
          ),
        );
      },
      home: firstLaunch ? const WelcomeGate() : const CellarScreen(),
    );
  }
}

/// Touche Échap sur un écran ordinaire (pas une fenêtre ni un menu : Flutter
/// les ferme lui-même). Flutter ne fait rien dans ce cas (la page arrête la
/// touche sans l'utiliser), d'où cette interception.
KeyEventResult _escape(FocusNode _, KeyEvent event) {
  if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape) {
    return KeyEventResult.ignored;
  }
  final focus = FocusManager.instance.primaryFocus;
  final context = focus?.context;
  if (context != null && ModalRoute.of(context) is PopupRoute) {
    return KeyEventResult.ignored;
  }
  if (context?.findAncestorWidgetOfExactType<EditableText>() != null) {
    focus!.unfocus();
  } else {
    _navigatorKey.currentState?.maybePop();
  }
  return KeyEventResult.handled;
}
