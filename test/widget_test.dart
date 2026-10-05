import 'package:cave/app.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("l'écran d'accueil affiche les textes français", (tester) async {
    await tester.pumpWidget(const CaveApp());
    await tester.pumpAndSettle();

    expect(find.text('Ma Cave'), findsOneWidget);
    expect(find.text('Votre cave est vide'), findsOneWidget);
    expect(find.text('Aucune bouteille'), findsOneWidget);
  });

  testWidgets('le thème suit le réglage clair / sombre du système', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const CaveApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  test('le pluriel des bouteilles est accordé', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(l10n.bottleCount(1), '1 bouteille');
    expect(l10n.bottleCount(3), '3 bouteilles');
  });

  test('les boutons font au moins 56 dp de haut', () {
    final size = AppTheme.light.filledButtonTheme.style!.minimumSize!.resolve(
      {},
    );
    expect(size!.height, greaterThanOrEqualTo(AppTheme.minButtonHeight));
  });
}
