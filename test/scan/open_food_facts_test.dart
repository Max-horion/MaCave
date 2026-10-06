import 'dart:convert';

import 'package:cave/domain/enums.dart';
import 'package:cave/scan/open_food_facts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Produits inventés, au format de l'API Open Food Facts (v2).
const _redWine = {
  'product_name_fr': 'Domaine Imaginaire rouge',
  'brands': 'Domaine Imaginaire, Groupe Fictif',
  'quantity': '75 cl',
  'categories_tags': ['en:beverages', 'en:wines', 'en:red-wines'],
  'nutriments': {'alcohol': 13.5},
};

const _ipa = {
  'product_name': 'IPA du Test',
  'brands': 'Brasserie Inventée',
  'product_quantity': 330,
  'product_quantity_unit': 'ml',
  'categories_tags': ['en:beers', 'en:india-pale-ales', 'en:blonde-beers'],
  'nutriments': {'alcohol_value': '6,5'},
};

void main() {
  group('traduction en fiche', () {
    test('vin rouge : type, robe, producteur, volume, degré', () {
      final draft = draftFromProduct(_redWine);
      expect(draft.name, 'Domaine Imaginaire rouge');
      expect(draft.producer, 'Domaine Imaginaire');
      expect(draft.volumeMl, 750);
      expect(draft.abv, 13.5);
      expect(draft.profile, FieldProfile.wine);
      expect(draft.characteristics, {'Rouge'});
    });

    test('bière IPA blonde, volume chiffré', () {
      final draft = draftFromProduct(_ipa);
      expect(draft.profile, FieldProfile.beer);
      expect(draft.characteristics, {'IPA', 'Blonde'});
      expect(draft.volumeMl, 330);
      expect(draft.abv, 6.5);
    });

    test('soda ; catégorie inconnue : pas de type', () {
      expect(
        draftFromProduct({
          'product_name': 'Limonade',
          'categories_tags': ['en:sodas'],
        }).profile,
        FieldProfile.soft,
      );
      final other = draftFromProduct({
        'product_name': 'Truc',
        'categories_tags': ['en:snacks'],
      });
      expect(other.profile, isNull);
      expect(other.characteristics, isEmpty);
    });
  });

  group('recherche', () {
    late List<http.Request> requests;

    OpenFoodFacts service({
      bool online = true,
      int status = 200,
      Object? body,
    }) {
      requests = [];
      return OpenFoodFacts(
        isOnline: () async => online,
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(body ?? {'status': 1, 'product': _redWine}),
            status,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
    }

    test('produit trouvé : seul le code part, l\'appli s\'identifie', () async {
      final result = await service().lookUp('3760000000017');
      expect(result, isA<OffFound>());
      expect((result as OffFound).draft.name, 'Domaine Imaginaire rouge');
      final request = requests.single;
      expect(request.url.host, 'world.openfoodfacts.org');
      expect(request.url.path, '/api/v2/product/3760000000017.json');
      expect(request.headers['User-Agent'], OpenFoodFacts.userAgent);
    });

    test('code inconnu (404)', () async {
      final result = await service(
        status: 404,
        body: {'status': 0},
      ).lookUp('3760000000017');
      expect(result, isA<OffNotFound>());
    });

    test('service en panne', () async {
      final result = await service(
        status: 503,
        body: {},
      ).lookUp('3760000000017');
      expect(result, isA<OffUnavailable>());
    });

    test('hors ligne : aucune requête', () async {
      final off = service(online: false);
      expect(await off.lookUp('3760000000017'), isA<OffOffline>());
      expect(requests, isEmpty);
    });

    test('un QR code n\'est jamais envoyé', () async {
      final off = service();
      expect(
        await off.lookUp('https://exemple.fr/ma-bouteille'),
        isA<OffNotFound>(),
      );
      expect(requests, isEmpty);
    });
  });
}
