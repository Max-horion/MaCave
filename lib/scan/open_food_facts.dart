import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/drink_draft.dart';
import '../domain/enums.dart';
import '../domain/label_parsing.dart';

// Recherche d'un code-barres dans Open Food Facts (CDC §6.2), base libre et
// gratuite : un seul appel « produit par code-barres ». Seul le code est
// envoyé, et l'appli le signale (CDC §9).

/// Résultat d'une recherche.
sealed class OffResult {
  const OffResult();
}

/// Produit trouvé, traduit en fiche à valider.
class OffFound extends OffResult {
  const OffFound(this.draft);
  final DrinkDraft draft;
}

/// Code inconnu d'Open Food Facts.
class OffNotFound extends OffResult {
  const OffNotFound();
}

/// Pas de réseau : aucune requête n'a été faite.
class OffOffline extends OffResult {
  const OffOffline();
}

/// Le service n'a pas répondu correctement.
class OffUnavailable extends OffResult {
  const OffUnavailable(this.detail);
  final String detail;
}

class OpenFoodFacts {
  OpenFoodFacts({
    required this.isOnline,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _http = client ?? http.Client();

  final Future<bool> Function() isOnline;
  final http.Client _http;
  final Duration timeout;

  /// Champs demandés : seulement ce qui sert à la fiche.
  static const _fields =
      'product_name,product_name_fr,generic_name_fr,brands,quantity,'
      'product_quantity,product_quantity_unit,categories_tags,nutriments';

  /// Open Food Facts demande que chaque appli s'identifie.
  static const userAgent = 'MaCave/1.0 (application personnelle, Android)';

  /// Seuls les codes-barres de produits (8 à 14 chiffres) sont cherchés : le
  /// contenu d'un QR code (adresse, texte) n'est jamais envoyé.
  static bool canLookUp(String code) => RegExp(r'^\d{8,14}$').hasMatch(code);

  Future<OffResult> lookUp(String code) async {
    if (!canLookUp(code)) return const OffNotFound();
    if (!await isOnline()) return const OffOffline();
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$code.json',
      {'fields': _fields},
    );
    try {
      final response = await _http
          .get(uri, headers: {'User-Agent': userAgent})
          .timeout(timeout);
      // Open Food Facts répond 404 (status 0) pour un code inconnu.
      if (response.statusCode == 404) return const OffNotFound();
      if (response.statusCode != 200) {
        return OffUnavailable('HTTP ${response.statusCode}');
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map || json['status'] != 1 || json['product'] is! Map) {
        return const OffNotFound();
      }
      final draft = draftFromProduct(
        (json['product'] as Map).cast<String, Object?>(),
      );
      return draft.isEmpty ? const OffNotFound() : OffFound(draft);
    } on TimeoutException catch (e) {
      return OffUnavailable('$e');
    } on SocketException catch (e) {
      return OffUnavailable('$e');
    } on http.ClientException catch (e) {
      return OffUnavailable('$e');
    } on FormatException catch (e) {
      return OffUnavailable('$e');
    }
  }

  void close() => _http.close();
}

/// Traduit une fiche produit d'Open Food Facts en fiche à valider.
DrinkDraft draftFromProduct(Map<String, Object?> product) {
  String? text(String key) {
    final value = product[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  final tags = {
    for (final t in (product['categories_tags'] as List?) ?? const []) '$t',
  };
  final (profile, characteristics) = _classify(tags);

  final nutriments = product['nutriments'];
  final abv = nutriments is Map
      ? parseAbv(
          nutriments['alcohol'] ??
              nutriments['alcohol_value'] ??
              nutriments['alcohol_100g'],
        )
      : null;

  // Volume : quantité chiffrée si elle est en volume, sinon le texte
  // (« 75 cl »).
  int? volume;
  final quantity = product['product_quantity'];
  final unit = text('product_quantity_unit')?.toLowerCase();
  final amount = quantity is num
      ? quantity.toDouble()
      : double.tryParse('${quantity ?? ''}');
  if (amount != null && amount > 0 && unit != null) {
    volume = parseVolumeMl('$amount $unit');
  }
  volume ??= parseVolumeMl(text('quantity'));

  return DrinkDraft(
    name:
        text('product_name_fr') ??
        text('product_name') ??
        text('generic_name_fr'),
    // Plusieurs marques possibles (« Brasserie X, Groupe Y ») : la première.
    producer: text('brands')?.split(',').first.trim(),
    abv: abv,
    volumeMl: volume,
    profile: profile,
    characteristics: characteristics,
  );
}

/// Type et caractéristiques d'après les catégories (`en:red-wines`…). Les
/// noms sont ceux de la classification initiale (CDC §6.1).
(FieldProfile?, Set<String>) _classify(Set<String> tags) {
  bool any(List<String> names) => names.any((n) => tags.contains('en:$n'));
  Set<String> pick(Map<String, List<String>> byValue) => {
    for (final MapEntry(key: value, value: names) in byValue.entries)
      if (any(names)) value,
  };

  if (any(['wines', 'red-wines', 'white-wines', 'rose-wines', 'champagnes'])) {
    return (
      FieldProfile.wine,
      pick({
        'Rouge': ['red-wines'],
        'Blanc': ['white-wines'],
        'Rosé': ['rose-wines'],
        'Effervescent': ['sparkling-wines', 'champagnes'],
      }),
    );
  }
  if (any(['beers'])) {
    return (
      FieldProfile.beer,
      pick({
        'Blonde': ['blonde-beers'],
        'Ambrée': ['amber-beers'],
        'Brune': ['brown-beers', 'dark-beers'],
        'Blanche': ['white-beers', 'wheat-beers'],
        'IPA': ['india-pale-ales', 'ipa'],
        'Stout': ['stouts'],
        'Lager': ['lagers'],
      }),
    );
  }
  if (any(['spirits', 'liqueurs', 'rums', 'whiskies', 'gins', 'calvados'])) {
    return (
      FieldProfile.spirit,
      pick({
        'Rhum': ['rums'],
        'Whisky': ['whiskies'],
        'Gin': ['gins'],
        'Calvados': ['calvados'],
        'Liqueur': ['liqueurs'],
      }),
    );
  }
  if (any([
    'sodas',
    'juices',
    'fruit-juices',
    'syrups',
    'lemonades',
    'non-alcoholic-beverages',
  ])) {
    return (
      FieldProfile.soft,
      pick({
        'Soda': ['sodas'],
        'Jus': ['juices', 'fruit-juices'],
        'Sirop': ['syrups'],
        'Limonade': ['lemonades'],
      }),
    );
  }
  return (null, const {});
}
