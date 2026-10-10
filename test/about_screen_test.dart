import 'package:cave/features/settings/about_screen.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/licenses.dart';
import 'package:cave/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
