import 'package:drift/drift.dart';

import '../domain/drink_filter.dart';
import '../domain/enums.dart';
import '../domain/similarity.dart';
import '../domain/text.dart';
import 'database.dart';

/// Une ligne de la liste de la cave : la référence, son type et ses lots.
class DrinkListItem {
  const DrinkListItem({
    required this.drink,
    required this.typeName,
    required this.lots,
  });

  final Drink drink;

  /// Nom du type, ou null si « sans catégorie ».
  final String? typeName;

  /// Lots actifs, du millésime le plus ancien au plus récent.
  final List<Lot> lots;

  int get stock => lots.fold(0, (sum, l) => sum + l.stock);

  /// Lots dans lesquels on peut prendre une bouteille.
  List<Lot> get lotsInStock => lots.where((l) => l.stock > 0).toList();
}

/// Classification complète : types, familles et valeurs (CDC §6.1).
class Classification {
  Classification({
    required this.types,
    required this.families,
    required this.characteristics,
  });

  final List<DrinkType> types;
  final List<CharacteristicFamily> families;
  final List<Characteristic> characteristics;

  late final Map<String, DrinkType> _typeById = {
    for (final t in types) t.id: t,
  };
  late final Map<String, Characteristic> _characteristicById = {
    for (final c in characteristics) c.id: c,
  };

  DrinkType? type(String? id) => id == null ? null : _typeById[id];

  Characteristic? characteristic(String id) => _characteristicById[id];

  List<CharacteristicFamily> familiesOf(String typeId) =>
      families.where((f) => f.typeId == typeId).toList();

  List<Characteristic> valuesOf(String familyId) =>
      characteristics.where((c) => c.familyId == familyId).toList();

  /// Identifiants des caractéristiques appartenant à un type.
  Set<String> characteristicIdsOf(String typeId) => {
    for (final f in familiesOf(typeId))
      for (final c in valuesOf(f.id)) c.id,
  };
}

/// Un mouvement et le lot auquel il appartient (historique de la fiche).
typedef MovementWithLot = ({Movement movement, Lot lot});

/// Un lot à vérifier pendant l'inventaire, avec le nom de sa référence.
typedef InventoryItem = ({String drinkName, Lot lot});

/// Une barre de graphique : libellé (null = non renseigné) et bouteilles.
typedef StatEntry = ({String? label, int bottles});

/// Répartition des bouteilles d'une famille de caractéristiques.
typedef FamilyStats = ({
  String typeName,
  String familyName,
  List<StatEntry> values,
});

/// Statistiques de base, sans notion de valeur (CDC §6.6).
class CaveStats {
  const CaveStats({
    required this.bottles,
    required this.drinks,
    required this.byType,
    required this.byFamily,
    required this.byRegion,
  });

  final int bottles;

  /// Références ayant au moins une bouteille.
  final int drinks;
  final List<StatEntry> byType;
  final List<FamilyStats> byFamily;
  final List<StatEntry> byRegion;
}

/// Référence existante qui ressemble à celle qu'on s'apprête à créer
/// (CDC §6.2, doublons).
class SimilarDrink {
  const SimilarDrink({
    required this.drink,
    required this.score,
    required this.bottles,
  });

  final Drink drink;

  /// Ressemblance, de 0 à 1 (au moins le seuil de la comparaison utilisée).
  final double score;

  /// Bouteilles en stock (pour reconnaître la référence d'un coup d'œil).
  final int bottles;
}

/// Lectures « en direct » pour les écrans : chaque méthode `watch…` renvoie un
/// flux qui émet de nouveau dès que les tables concernées changent.
class CaveQueries {
  CaveQueries(this._db);

  final CaveDatabase _db;

  /// Références actives qui ressemblent à [name] (et [producer]), de la plus
  /// proche à la moins proche, [limit] au plus. Avec [profile] connu, une
  /// référence d'un autre profil (une bière pour un vin) est écartée.
  /// [excludeId] : la référence elle-même, en modification.
  Future<List<SimilarDrink>> similarDrinks({
    required String name,
    String? producer,
    FieldProfile? profile,
    String? excludeId,
    int limit = 3,
  }) async {
    if (similarityWords(name).isEmpty) return const [];
    return _rankDrinks(
      profile: profile,
      excludeId: excludeId,
      limit: limit,
      score: (drink) {
        final s = similarityScore(
          name: name,
          producer: producer,
          otherName: drink.name,
          otherProducer: drink.producer,
        );
        return s >= similarityThreshold ? s : null;
      },
    );
  }

  /// Références de la cave qui se retrouvent sur une étiquette photographiée
  /// (texte lu [labelText], erreurs de reconnaissance tolérées), ou dont le
  /// nom ressemble au nom retenu [name] (doublons, CDC §6.2).
  Future<List<SimilarDrink>> drinksOnLabel({
    required String labelText,
    String? name,
    String? producer,
    FieldProfile? profile,
    int limit = 3,
  }) {
    // Texte lu préparé une fois pour toute la cave.
    final matcher = LabelMatcher(labelText);
    return _rankDrinks(
      profile: profile,
      limit: limit,
      score: (drink) {
        final onLabel = matcher.score(
          drinkName: drink.name,
          drinkProducer: drink.producer,
        );
        final byName = name == null
            ? 0.0
            : similarityScore(
                name: name,
                producer: producer,
                otherName: drink.name,
                otherProducer: drink.producer,
              );
        final best = onLabel > byName ? onLabel : byName;
        return onLabel >= labelMatchThreshold || byName >= similarityThreshold
            ? best
            : null;
      },
    );
  }

  /// Références actives notées par [score] (null : écartée), de la mieux
  /// notée à la moins bien notée, puis par stock.
  Future<List<SimilarDrink>> _rankDrinks({
    required double? Function(Drink drink) score,
    FieldProfile? profile,
    String? excludeId,
    required int limit,
  }) async {
    final rows = await _db
        .customSelect(
          'SELECT d.*, t.field_profile AS profile, '
          '(SELECT COALESCE(SUM(l.stock), 0) FROM lots l '
          'WHERE l.drink_id = d.id AND l.deleted_at IS NULL) AS bottles '
          'FROM drinks d LEFT JOIN drink_types t ON t.id = d.type_id '
          'AND t.deleted_at IS NULL '
          'WHERE d.deleted_at IS NULL',
          readsFrom: {_db.drinks, _db.drinkTypes, _db.lots},
        )
        .get();
    final found = <SimilarDrink>[];
    for (final row in rows) {
      final drink = await _db.drinks.mapFromRow(row);
      if (drink.id == excludeId) continue;
      final other = FieldProfile.values
          .asNameMap()[row.readNullable<String>('profile')];
      if (profile != null && other != null && other != profile) continue;
      final value = score(drink);
      if (value != null) {
        found.add(
          SimilarDrink(
            drink: drink,
            score: value,
            bottles: row.read<int>('bottles'),
          ),
        );
      }
    }
    found.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : b.bottles.compareTo(a.bottles);
    });
    return found.take(limit).toList();
  }

  /// Liste de la cave selon les filtres (CDC §6.5).
  Stream<List<DrinkListItem>> watchDrinkList(DrinkFilter filter) {
    final where = <String>['d.deleted_at IS NULL'];
    final args = <Variable>[];

    final fts = ftsQuery(filter.query);
    if (fts != null) {
      where.add(
        'd.id IN (SELECT drink_id FROM drinks_fts WHERE drinks_fts MATCH ?)',
      );
      args.add(Variable.withString(fts));
    }
    if (filter.typeId != null) {
      where.add('d.type_id = ?');
      args.add(Variable.withString(filter.typeId!));
    }
    for (final cid in filter.characteristicIds) {
      where.add(
        'EXISTS (SELECT 1 FROM drink_characteristics dc WHERE dc.drink_id = d.id '
        'AND dc.characteristic_id = ? AND dc.deleted_at IS NULL)',
      );
      args.add(Variable.withString(cid));
    }
    if (filter.region != null) {
      where.add('(d.region = ? OR d.country = ?)');
      args
        ..add(Variable.withString(filter.region!))
        ..add(Variable.withString(filter.region!));
    }
    if (filter.favoritesOnly) where.add('d.favorite = 1');
    if (filter.needsCompletionOnly) where.add('d.needs_completion = 1');

    final sql =
        'SELECT d.*, t.name AS type_name, '
        'COALESCE((SELECT SUM(l.stock) FROM lots l '
        'WHERE l.drink_id = d.id AND l.deleted_at IS NULL), 0) AS total_stock '
        'FROM drinks d '
        'LEFT JOIN drink_types t ON t.id = d.type_id AND t.deleted_at IS NULL '
        'WHERE ${where.join(' AND ')}'
        '${filter.showExhausted ? '' : ' AND total_stock > 0'}';

    return _db
        .customSelect(
          sql,
          variables: args,
          readsFrom: {
            _db.drinks,
            _db.lots,
            _db.drinkTypes,
            _db.drinkCharacteristics,
          },
        )
        .watch()
        .asyncMap((rows) async {
          final drinks = [
            for (final row in rows)
              (
                drink: _db.drinks.map(row.data),
                typeName: row.readNullable<String>('type_name'),
              ),
          ];
          final lotsByDrink = await _lotsByDrink(
            drinks.map((d) => d.drink.id).toList(),
          );
          final items = [
            for (final d in drinks)
              DrinkListItem(
                drink: d.drink,
                typeName: d.typeName,
                lots: lotsByDrink[d.drink.id] ?? const [],
              ),
          ];
          // Nom sans accents calculé une fois par référence, pas à chaque
          // comparaison : avec 5 000 références, le tri passe de ~240 ms à
          // ~25 ms (tool/perf/cave_perf_test.dart).
          final keys = {for (final i in items) i.drink.id: fold(i.drink.name)};
          items.sort(_comparator(filter.sort, (i) => keys[i.drink.id]!));
          return items;
        });
  }

  /// Lots actifs des références données, regroupés et triés.
  Future<Map<String, List<Lot>>> _lotsByDrink(List<String> drinkIds) async {
    final result = <String, List<Lot>>{};
    // Par paquets, pour rester sous la limite de paramètres de SQLite.
    for (var i = 0; i < drinkIds.length; i += 500) {
      final chunk = drinkIds.sublist(
        i,
        i + 500 > drinkIds.length ? drinkIds.length : i + 500,
      );
      final lots =
          await (_db.select(_db.lots)
                ..where((l) => l.drinkId.isIn(chunk) & l.deletedAt.isNull())
                ..orderBy([
                  (l) => OrderingTerm(
                    expression: l.vintage,
                    nulls: NullsOrder.last,
                  ),
                  (l) => OrderingTerm(expression: l.volumeMl),
                ]))
              .get();
      for (final lot in lots) {
        result.putIfAbsent(lot.drinkId, () => []).add(lot);
      }
    }
    return result;
  }

  /// Comparaison de textes sans accents ni majuscules ; la forme [fold] de
  /// chaque texte n'est calculée qu'une fois (tri de milliers de noms).
  static int Function(String, String) _byFolded() {
    final folded = <String, String>{};
    String key(String text) => folded[text] ??= fold(text);
    return (a, b) => key(a).compareTo(key(b));
  }

  /// Ordre de la liste ; [nameKey] : nom sans accents ni majuscules.
  static int Function(DrinkListItem, DrinkListItem) _comparator(
    DrinkSort sort,
    String Function(DrinkListItem) nameKey,
  ) {
    int byName(DrinkListItem a, DrinkListItem b) =>
        nameKey(a).compareTo(nameKey(b));
    int? oldestVintage(DrinkListItem i) {
      final vintages = i.lots.map((l) => l.vintage).whereType<int>();
      return vintages.isEmpty ? null : vintages.reduce((a, b) => a < b ? a : b);
    }

    return switch (sort) {
      DrinkSort.name => byName,
      DrinkSort.recentlyAdded => (a, b) {
        final c = b.drink.createdAt.compareTo(a.drink.createdAt);
        return c != 0 ? c : byName(a, b);
      },
      DrinkSort.vintage => (a, b) {
        final va = oldestVintage(a), vb = oldestVintage(b);
        if (va != vb) {
          if (va == null) return 1;
          if (vb == null) return -1;
          return va.compareTo(vb);
        }
        return byName(a, b);
      },
      DrinkSort.stock => (a, b) {
        final c = b.stock.compareTo(a.stock);
        return c != 0 ? c : byName(a, b);
      },
    };
  }

  /// Régions et pays présents dans la cave, pour le filtre.
  Stream<List<String>> watchRegions() {
    return _db
        .customSelect(
          'SELECT region AS place FROM drinks WHERE deleted_at IS NULL AND region IS NOT NULL '
          'UNION SELECT country FROM drinks WHERE deleted_at IS NULL AND country IS NOT NULL',
          readsFrom: {_db.drinks},
        )
        .watch()
        .map(
          (rows) =>
              rows.map((r) => r.read<String>('place')).toList()
                ..sort(_byFolded()),
        );
  }

  /// Classification active, mise à jour en direct.
  Stream<Classification> watchClassification() {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.drinkTypes,
            _db.characteristicFamilies,
            _db.characteristics,
          },
        )
        .watch()
        .asyncMap((_) async {
          final types =
              await (_db.select(_db.drinkTypes)
                    ..where((t) => t.deletedAt.isNull())
                    ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
                  .get();
          final families =
              await (_db.select(_db.characteristicFamilies)
                    ..where((f) => f.deletedAt.isNull())
                    ..orderBy([(f) => OrderingTerm(expression: f.sortOrder)]))
                  .get();
          final values =
              await (_db.select(_db.characteristics)
                    ..where((c) => c.deletedAt.isNull())
                    ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
                  .get();
          return Classification(
            types: types,
            families: families,
            characteristics: values,
          );
        });
  }

  /// Une référence (null si supprimée).
  Stream<Drink?> watchDrink(String id) {
    return (_db.select(_db.drinks)
          ..where((d) => d.id.equals(id) & d.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  /// Lots actifs d'une référence, épuisés compris.
  Stream<List<Lot>> watchLotsOf(String drinkId) {
    return (_db.select(_db.lots)
          ..where((l) => l.drinkId.equals(drinkId) & l.deletedAt.isNull())
          ..orderBy([
            (l) => OrderingTerm(expression: l.vintage, nulls: NullsOrder.last),
            (l) => OrderingTerm(expression: l.volumeMl),
          ]))
        .watch();
  }

  /// Caractéristiques d'une référence.
  Stream<Set<String>> watchDrinkCharacteristicIds(String drinkId) {
    return (_db.select(_db.drinkCharacteristics)
          ..where((c) => c.drinkId.equals(drinkId) & c.deletedAt.isNull()))
        .watch()
        .map((rows) => {for (final r in rows) r.characteristicId});
  }

  /// Mouvements actifs de tous les lots actifs d'une référence, du plus récent
  /// au plus ancien.
  Stream<List<MovementWithLot>> watchMovementsOfDrink(String drinkId) {
    final query =
        _db.select(_db.movements).join([
            innerJoin(_db.lots, _db.lots.id.equalsExp(_db.movements.lotId)),
          ])
          ..where(
            _db.lots.drinkId.equals(drinkId) &
                _db.lots.deletedAt.isNull() &
                _db.movements.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.desc(_db.movements.occurredAt),
            OrderingTerm.desc(_db.movements.id),
          ]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          (movement: r.readTable(_db.movements), lot: r.readTable(_db.lots)),
      ],
    );
  }

  /// Lots à vérifier pendant l'inventaire (CDC §6.4), triés par nom de
  /// référence puis millésime. Lecture ponctuelle : la liste ne doit pas
  /// changer d'ordre pendant que l'utilisateur la parcourt.
  Future<List<InventoryItem>> inventoryLots({
    bool includeExhausted = false,
  }) async {
    final query = _db.select(_db.lots).join([
      innerJoin(_db.drinks, _db.drinks.id.equalsExp(_db.lots.drinkId)),
    ])..where(_db.lots.deletedAt.isNull() & _db.drinks.deletedAt.isNull());
    if (!includeExhausted) query.where(_db.lots.stock.isBiggerThanValue(0));
    final items = [
      for (final r in await query.get())
        (drinkName: r.readTable(_db.drinks).name, lot: r.readTable(_db.lots)),
    ];
    final byFolded = _byFolded();
    items.sort((a, b) {
      final byName = byFolded(a.drinkName, b.drinkName);
      if (byName != 0) return byName;
      final va = a.lot.vintage, vb = b.lot.vintage;
      if (va != vb) {
        if (va == null) return 1;
        if (vb == null) return -1;
        return va.compareTo(vb);
      }
      return a.lot.volumeMl.compareTo(b.lot.volumeMl);
    });
    return items;
  }

  /// Statistiques de la cave, mises à jour en direct (CDC §6.6).
  /// Seuls les lots en stock comptent.
  Stream<CaveStats> watchStats() {
    const inStock =
        'l.deleted_at IS NULL AND d.deleted_at IS NULL AND l.stock > 0';
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.lots,
            _db.drinks,
            _db.drinkTypes,
            _db.drinkCharacteristics,
            _db.characteristics,
            _db.characteristicFamilies,
          },
        )
        .watch()
        .asyncMap((_) async {
          final totals = await _db
              .customSelect(
                'SELECT COALESCE(SUM(l.stock), 0) AS bottles, '
                'COUNT(DISTINCT l.drink_id) AS drinks '
                'FROM lots l JOIN drinks d ON d.id = l.drink_id '
                'WHERE $inStock',
              )
              .getSingle();
          final byType = await _db
              .customSelect(
                'SELECT t.name AS label, SUM(l.stock) AS bottles '
                'FROM lots l JOIN drinks d ON d.id = l.drink_id '
                'LEFT JOIN drink_types t '
                'ON t.id = d.type_id AND t.deleted_at IS NULL '
                'WHERE $inStock GROUP BY t.id ORDER BY bottles DESC',
              )
              .get();
          final byValue = await _db
              .customSelect(
                'SELECT t.name AS type_name, f.id AS family_id, '
                'f.name AS family_name, c.name AS label, '
                'SUM(l.stock) AS bottles '
                'FROM lots l JOIN drinks d ON d.id = l.drink_id '
                'JOIN drink_characteristics dc '
                'ON dc.drink_id = d.id AND dc.deleted_at IS NULL '
                'JOIN characteristics c '
                'ON c.id = dc.characteristic_id AND c.deleted_at IS NULL '
                'JOIN characteristic_families f '
                'ON f.id = c.family_id AND f.deleted_at IS NULL '
                'JOIN drink_types t '
                'ON t.id = f.type_id AND t.deleted_at IS NULL '
                'WHERE $inStock GROUP BY c.id '
                'ORDER BY t.sort_order, f.sort_order, bottles DESC',
              )
              .get();
          final byRegion = await _db
              .customSelect(
                'SELECT COALESCE(d.region, d.country) AS label, '
                'SUM(l.stock) AS bottles '
                'FROM lots l JOIN drinks d ON d.id = l.drink_id '
                'WHERE $inStock GROUP BY label ORDER BY bottles DESC',
              )
              .get();

          StatEntry entry(QueryRow r) => (
            label: r.readNullable<String>('label'),
            bottles: r.read<int>('bottles'),
          );
          final families = <String, FamilyStats>{};
          for (final r in byValue) {
            families
                .putIfAbsent(
                  r.read<String>('family_id'),
                  () => (
                    typeName: r.read<String>('type_name'),
                    familyName: r.read<String>('family_name'),
                    values: <StatEntry>[],
                  ),
                )
                .values
                .add(entry(r));
          }
          return CaveStats(
            bottles: totals.read<int>('bottles'),
            drinks: totals.read<int>('drinks'),
            byType: byType.map(entry).toList(),
            byFamily: families.values.toList(),
            byRegion: byRegion.map(entry).toList(),
          );
        });
  }
}
