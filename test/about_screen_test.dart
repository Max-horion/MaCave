import 'package:cave/features/settings/about_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/licenses.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('À propos : version, licence et sources à citer', (tester) async {
    // Écran haut : tout le texte est construit d'un coup.
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appVersionProvider.overrideWith((ref) async => '0.1.0')],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version 0.1.0'), findsOneWidget);
    expect(
      find.textContaining('GNU GPL version 3 ou ultérieure'),
      findsOneWidget,
    );
    for (final source in ['INAO', 'Open Food Facts', 'Tesseract', 'ZXing']) {
      expect(find.textContaining(source), findsWidgets, reason: source);
    }
    // Appli entièrement libre depuis le retrait de ML Kit (lot 7).
    expect(find.textContaining('ML Kit'), findsNothing);
    expect(find.text('Licences des logiciels'), findsOneWidget);
    expect(find.textContaining('Tabler Icons'), findsOneWidget);
    expect(
      find.textContaining('Independent JPEG Group'),
      findsOneWidget,
      reason: 'mention exigée par la licence de libjpeg',
    );
  });

  testWidgets('À propos : liens de contact, adresse copiée à défaut', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final opened = <Uri>[];
    var canOpen = true;
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          linkLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return canOpen;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Écrire un courriel'));
    await tester.tap(find.text('Signaler un problème'));
    await tester.tap(find.text('Code source'));
    await tester.pumpAndSettle();
    expect(opened, [
      Uri.parse('mailto:maxence@bouthon.fr?subject=Ma%20Cave%201.0.0'),
      Uri.parse('https://github.com/Max-horion/MaCave/issues'),
      Uri.parse('https://github.com/Max-horion/MaCave'),
    ]);
    expect(copied, isNull);

    canOpen = false;
    await tester.tap(find.text('Écrire un courriel'));
    await tester.pumpAndSettle();
    expect(copied, 'maxence@bouthon.fr');
    expect(
      find.text("Aucune appli pour l'ouvrir : adresse copiée."),
      findsOneWidget,
    );
  });

  testWidgets('licences des éléments sans paquet Dart enregistrées', (
    tester,
  ) async {
    registerExtraLicenses();
    final packages = await tester.runAsync(() async {
      final all = <String>{};
      await for (final entry in LicenseRegistry.licenses) {
        all.addAll(entry.packages);
      }
      return all;
    });
    expect(
      packages,
      containsAll([
        'Tesseract',
        'Tesseract4Android',
        'tessdata_best',
        'Leptonica',
        'libjpeg',
        'libpng',
        'Tabler Icons',
      ]),
    );
  });
}
