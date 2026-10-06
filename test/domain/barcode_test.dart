import 'package:cave/domain/barcode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EAN-13 gardé tel quel, espaces et tirets retirés', () {
    expect(normalizeBarcode('3760001234567'), '3760001234567');
    expect(normalizeBarcode(' 376 0001-234567 '), '3760001234567');
  });

  test('UPC-A (12 chiffres) ramené à l\'EAN-13 équivalent', () {
    expect(normalizeBarcode('012345678905'), '0012345678905');
  });

  test('EAN-8 et autres longueurs : inchangés', () {
    expect(normalizeBarcode('96385074'), '96385074');
  });

  test('QR code : contenu gardé, seulement sans espaces autour', () {
    expect(
      normalizeBarcode('  https://exemple.fr/vin?id=12 '),
      'https://exemple.fr/vin?id=12',
    );
  });

  test('vide : null', () {
    expect(normalizeBarcode(null), isNull);
    expect(normalizeBarcode('   '), isNull);
  });
}
