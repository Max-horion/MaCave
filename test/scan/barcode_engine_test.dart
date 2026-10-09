import 'package:cave/data/local_store.dart';
import 'package:cave/scan/barcode_engine.dart';
import 'package:cave/scan/zxing_reader.dart';
import 'package:cave/sync/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('choix du lecteur', () {
    late MemoryLocalStore store;
    late ProviderContainer container;

    setUp(() {
      store = MemoryLocalStore();
      container = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(store)],
      );
    });
    tearDown(() => container.dispose());

    test('ML Kit par défaut', () async {
      expect(
        await container.read(barcodeEngineProvider.future),
        BarcodeEngine.mlKit,
      );
    });

    test('le lecteur choisi est retenu sur l\'appareil', () async {
      await container
          .read(barcodeEngineProvider.notifier)
          .setEngine(BarcodeEngine.zxing);
      expect(
        await container.read(barcodeEngineProvider.future),
        BarcodeEngine.zxing,
      );
      expect(store.values['barcode_engine'], 'zxing');
    });

    test('valeur illisible : ML Kit', () async {
      store.values['barcode_engine'] = 'laser';
      expect(
        await container.read(barcodeEngineProvider.future),
        BarcodeEngine.mlKit,
      );
    });
  });

  group('confirmation des lectures ZXing', () {
    const ean = BarcodeRead('3012345678906', 'EAN_13');

    test('un code linéaire doit être lu deux fois de suite', () {
      final confirmer = ReadConfirmer();
      expect(confirmer.offer(ean), isNull);
      expect(confirmer.offer(ean), '3012345678906');
    });

    test('une image sans code entre les deux ne remet pas à zéro', () {
      final confirmer = ReadConfirmer();
      expect(confirmer.offer(ean), isNull);
      expect(confirmer.offer(null), isNull);
      expect(confirmer.offer(ean), '3012345678906');
    });

    test('une lecture différente remet à zéro (fausse lecture écartée)', () {
      final confirmer = ReadConfirmer();
      expect(confirmer.offer(ean), isNull);
      expect(
        confirmer.offer(const BarcodeRead('3012345678913', 'EAN_13')),
        isNull,
      );
      expect(confirmer.offer(ean), isNull);
      expect(confirmer.offer(ean), '3012345678906');
    });

    test('un QR code est retenu dès la première lecture', () {
      final confirmer = ReadConfirmer();
      expect(
        confirmer.offer(const BarcodeRead(' https://exemple.fr/v ', 'QR_CODE')),
        'https://exemple.fr/v',
      );
    });

    test('un texte vide est ignoré', () {
      final confirmer = ReadConfirmer();
      expect(confirmer.offer(const BarcodeRead('  ', 'CODE_128')), isNull);
      expect(confirmer.offer(const BarcodeRead('  ', 'CODE_128')), isNull);
    });
  });
}
