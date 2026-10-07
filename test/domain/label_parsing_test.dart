import 'package:cave/domain/label_parsing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('volumes écrits de toutes les façons', () {
    expect(parseVolumeMl('75 cl'), 750);
    expect(parseVolumeMl('75cl'), 750);
    expect(parseVolumeMl('0,75 L'), 750);
    expect(parseVolumeMl('1.5 litre'), 1500);
    expect(parseVolumeMl('330ml'), 330);
    expect(parseVolumeMl('33 CL'), 330);
    expect(parseVolumeMl('1 l'), 1000);
    // Fût de 6 litres.
    expect(parseVolumeMl('6 l'), 6000);
    expect(parseVolumeMl('6L'), 6000);
    expect(parseVolumeMl('600 cl'), 6000);
  });

  test('un pack : volume d\'une bouteille', () {
    expect(parseVolumeMl('6 x 33 cl'), 330);
  });

  test('pas de volume plausible : null', () {
    expect(parseVolumeMl(null), isNull);
    expect(parseVolumeMl('500 g'), isNull);
    expect(parseVolumeMl('1 ml'), isNull);
    expect(parseVolumeMl('Bière blonde'), isNull);
  });

  test('degré : nombre ou texte, plausible seulement', () {
    expect(parseAbv(12.5), 12.5);
    expect(parseAbv('13 % vol'), 13);
    expect(parseAbv('12,5'), 12.5);
    expect(parseAbv(150), isNull);
    expect(parseAbv(null), isNull);
    expect(parseAbv('sans alcool'), isNull);
  });
}
