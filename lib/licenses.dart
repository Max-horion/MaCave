import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ajoute à la page « Licences des logiciels » (showLicensePage) les
/// éléments de tiers qui ne sont pas des paquets Dart : Tesseract et les
/// bibliothèques qu'il embarque (code natif Android), son dictionnaire,
/// ZXing (bibliothèque Java) et l'icône. Les paquets Dart y figurent déjà d'eux-mêmes.
void registerExtraLicenses() {
  LicenseRegistry.addLicense(() async* {
    Future<String> text(String file) =>
        rootBundle.loadString('assets/licenses/$file');
    yield LicenseEntryWithLineBreaks([
      'Tesseract',
      'Tesseract4Android',
      'tessdata_best',
    ], await text('apache-2.0.txt'));
    yield LicenseEntryWithLineBreaks(['ZXing'], await text('apache-2.0.txt'));
    yield LicenseEntryWithLineBreaks([
      'Leptonica',
    ], await text('leptonica.txt'));
    // libjpeg : « this software is based in part on the work of the
    // Independent JPEG Group » (mention exigée, dans le texte affiché).
    yield LicenseEntryWithLineBreaks(['libjpeg'], await text('libjpeg.txt'));
    yield LicenseEntryWithLineBreaks(['libpng'], await text('libpng.txt'));
    yield LicenseEntryWithLineBreaks([
      'Tabler Icons',
    ], await text('tabler-icons.txt'));
  });
}
