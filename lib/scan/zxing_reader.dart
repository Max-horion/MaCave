import 'package:flutter/services.dart';

// Lecture des codes-barres avec ZXing (lot 7), bibliothèque libre (Apache
// 2.0) appelée par le canal « fr.bouthon.cave/zxing » (MainActivity.kt).
// La caméra (paquet camera) fournit les images ; seule la luminance (plan Y)
// est envoyée : ZXing n'a pas besoin des couleurs.

/// Une image de la caméra, en niveaux de gris : [height] lignes de [width]
/// pixels, chaque ligne commençant tous les [rowStride] octets.
class LuminanceFrame {
  const LuminanceFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.rowStride,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int rowStride;
}

/// Un code trouvé dans une image, avec son format au sens de ZXing
/// (`EAN_13`, `QR_CODE`…).
class BarcodeRead {
  const BarcodeRead(this.text, this.format);

  final String text;
  final String format;
}

/// Cherche un code dans une image ; null si aucun n'est lisible.
abstract class FrameDecoder {
  Future<BarcodeRead?> decode(LuminanceFrame frame);
}

class ZxingFrameDecoder implements FrameDecoder {
  static const _channel = MethodChannel('fr.bouthon.cave/zxing');

  @override
  Future<BarcodeRead?> decode(LuminanceFrame frame) async {
    final found = await _channel.invokeMapMethod<String, String>('decode', {
      'bytes': frame.bytes,
      'width': frame.width,
      'height': frame.height,
      'rowStride': frame.rowStride,
    });
    if (found == null) return null;
    return BarcodeRead(found['text']!, found['format']!);
  }
}

/// Évite les fausses lectures : un code linéaire (EAN, Code 128…) n'est
/// retenu qu'une fois lu **deux fois de suite** à l'identique ; leurs
/// sommes de contrôle sont faibles (une barre mal vue peut donner un autre
/// code valide). Les codes à deux dimensions (QR code…) portent une vraie
/// correction d'erreurs : une lecture suffit.
class ReadConfirmer {
  static const _selfChecking = {'QR_CODE', 'DATA_MATRIX', 'AZTEC', 'PDF_417'};

  String? _last;

  /// Le code à retenir, ou null s'il faut encore une lecture. Une image sans
  /// code ne remet pas le compte à zéro (la mise au point en perd souvent
  /// une), un code différent si.
  String? offer(BarcodeRead? read) {
    if (read == null || read.text.trim().isEmpty) return null;
    final text = read.text.trim();
    if (_selfChecking.contains(read.format) || text == _last) {
      _last = null;
      return text;
    }
    _last = text;
    return null;
  }
}
