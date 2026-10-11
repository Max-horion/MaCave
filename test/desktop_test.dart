import 'package:cave/app.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/providers.dart';
import 'package:cave/l10n/app_localizations.dart';
import 'package:cave/platform/device_capabilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

// L'appli sur PC (CDC §10) : pas de caméra, donc pas de scan ni de photo
// d'étiquette (le code se saisit au clavier ou avec une douchette), et pas
// de partage de fichiers sous Linux.
void main() {
  late CaveDatabase db;
  late TestContext ctx;
  late CaveRepository repo;
  final l10n = lookupAppLocalizations(const Locale('fr'));
  const code = '3760001234567';

  setUp(() {
    db = memoryDatabase();
    ctx = TestContext();
    repo = CaveRepository(db, ctx);
  });
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  Future<void> openApp(
    WidgetTester tester, {
    DeviceCapabilities device = DeviceCapabilities.desktop,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          writeContextProvider.overrideWithValue(ctx),
          localSyncEnvironment(db, ctx),
          deviceCapabilitiesProvider.overrideWithValue(device),
        ],
        child: const CaveApp(),
      ),
    );
    await settle(tester);
  }

  /// Saisit [typed] dans la fenêtre de saisie du code, puis Entrée (comme
  /// une douchette).
  Future<void> typeCode(WidgetTester tester, String typed) async {
    await tester.runAsync(() async {
      await tester.tap(find.text(l10n.scanButtonByHand));
    });
    await settle(tester);
    expect(find.text(l10n.scanManualScannerHelp), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, typed);
    await tester.runAsync(() async {
      await tester.testTextInput.receiveAction(TextInputAction.done);
    });
    await settle(tester);
  }

  test('capacités selon la plateforme', () {
    expect(DeviceCapabilities.of(TargetPlatform.android).camera, isTrue);
    expect(DeviceCapabilities.of(TargetPlatform.linux).camera, isFalse);
    expect(DeviceCapabilities.of(TargetPlatform.linux).shareFiles, isFalse);
    expect(DeviceCapabilities.of(TargetPlatform.windows).camera, isFalse);
  });

  testWidgets('téléphone : bouton « Scanner » sur la liste', (tester) async {
    await openApp(tester, device: DeviceCapabilities.phone);
    expect(find.text(l10n.scanButton), findsOneWidget);
    expect(find.text(l10n.scanButtonByHand), findsNothing);
  });

  testWidgets('PC : code connu saisi au clavier → ses lots', (tester) async {
    await tester.runAsync(() async {
      final types = await repo.drinkTypes();
      final id = await repo.createDrink(
        DrinkInput(name: 'Bière de la douchette', typeId: types[1].id),
      );
      final lot = await repo.findOrCreateLot(drinkId: id, volumeMl: 330);
      await repo.addEntry(lot, 2);
      await repo.setLotBarcode(lot, code);
    });
    await openApp(tester);
    expect(find.text(l10n.scanButton), findsNothing);

    await typeCode(tester, code);
    expect(find.text(l10n.scanCode(code)), findsOneWidget);
    expect(find.text(l10n.scanAgainByHand), findsOneWidget);
    expect(find.text(l10n.scanAgain), findsNothing);
  });

  testWidgets('PC : code inconnu → pas de photo d\'étiquette', (tester) async {
    await openApp(tester);
    await typeCode(tester, code);
    expect(find.text(l10n.scanUnknownTitle), findsOneWidget);
    expect(find.text(l10n.scanAssociate), findsOneWidget);
    expect(find.text(l10n.scanUnknownPhoto), findsNothing);
    expect(find.text(l10n.scanAgainByHand), findsOneWidget);
  });

  testWidgets('PC : formulaire sans « Lire l\'étiquette »', (tester) async {
    await openApp(tester);
    await tester.tap(find.text(l10n.addDrinkButton));
    await settle(tester);
    expect(find.text(l10n.labelButton), findsNothing);
    expect(find.text(l10n.formScanBarcode), findsNothing);
    expect(find.text(l10n.formEnterBarcode), findsOneWidget);
  });

  testWidgets('PC : export sans « Partager »', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip(l10n.menuTooltip));
    await settle(tester);
    await tester.tap(find.text(l10n.menuExport));
    await settle(tester);
    expect(find.text(l10n.exportTitle), findsOneWidget);
    expect(find.text(l10n.exportSave), findsOneWidget);
    expect(find.text(l10n.exportShare), findsNothing);
  });
}
