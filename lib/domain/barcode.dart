/// Forme enregistrée d'un code-barres ou d'un QR code, pour que le même
/// produit soit reconnu quel que soit le lecteur ou la saisie :
/// - espaces et tirets retirés d'un code numérique (saisie à la main) ;
/// - UPC-A (12 chiffres, Amérique du Nord) ramené à l'EAN-13 équivalent
///   (« 0 » devant), comme le font la plupart des lecteurs ;
/// - tout autre contenu (QR code : adresse, texte) gardé tel quel, sans les
///   espaces autour.
///
/// Retourne null si le code est vide.
String? normalizeBarcode(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return null;
  final digits = text.replaceAll(RegExp(r'[\s-]'), '');
  if (RegExp(r'^\d+$').hasMatch(digits)) {
    return digits.length == 12 ? '0$digits' : digits;
  }
  return text;
}
