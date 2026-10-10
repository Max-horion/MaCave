import 'package:drift/drift.dart';

import '../domain/barcode.dart';
import '../domain/enums.dart';
import '../domain/field_rules.dart';
import '../domain/stock.dart';
import 'database.dart';
import 'write_context.dart';

/// Champs saisis sur la fiche d'une référence.
class DrinkInput {
  const DrinkInput({
    required this.name,
    required this.typeId,
    this.producer,
    this.appellation,
    this.region,
    this.country,
    this.grapes,
    this.abv,
    this.rating,
    this.favorite = false,
    this.comment,
  });

  final String name;
  final String? typeId;
  final String? producer;
  final String? appellation;
  final String? region;
  final String? country;
  final String? grapes;
  final double? abv;
  final int? rating;
  final bool favorite;
  final String? comment;
}

/// Totaux affichés sur l'écran d'accueil et dans les statistiques.
class CaveTotals {
  const CaveTotals({required this.bottles, required this.drinksInStock});

  final int bottles;

  /// Références ayant au moins une bouteille en stock.
  final int drinksInStock;
}

/// Accès aux données de la cave pour le reste de l'application.
///
/// Les écrans ne parlent jamais directement à la base : ils passent par ici.
/// Chaque écriture est estampillée (date, appareil) pour la synchronisation,
/// et chaque mouvement met à jour le stock en cache du lot, dans la même
/// transaction (tout ou rien).
class CaveRepository {
  CaveRepository(this._db, this._ctx);

  final CaveDatabase _db;
  final WriteContext _ctx;

  // ───────────────────────────── Classification ─────────────────────────────

  /// Types actifs, dans l'ordre d'affichage.
  Future<List<DrinkType>> drinkTypes() {
    return (_db.select(_db.drinkTypes)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  Future<DrinkType?> _activeType(String? typeId) async {
    if (typeId == null) return null;
    return (_db.select(_db.drinkTypes)
          ..where((t) => t.id.equals(typeId) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Volume pré-rempli pour un nouveau lot de ce type (CDC §4.1, §7).
  Future<int?> defaultVolumeMl(String typeId) async =>
      (await _activeType(typeId))?.defaultVolumeMl;

  /// Change le volume pré-rempli d'un type (premier lancement, paramètres).
  Future<void> setDefaultVolumeMl(String typeId, int volumeMl) async {
    await (_db.update(_db.drinkTypes)..where((t) => t.id.equals(typeId))).write(
      DrinkTypesCompanion(
        defaultVolumeMl: Value(volumeMl),
        updatedAt: Value(_ctx.now()),
        updatedBy: Value(_ctx.deviceId),
      ),
    );
  }

  // Modification de la classification (CDC §6.1, §7). Suppressions logiques ;
  // les références rattachées restent et apparaissent « sans catégorie ».

  /// Nouveau type, placé en dernier.
  Future<String> createType({
    required String name,
    required FieldProfile profile,
    required int defaultVolumeMl,
  }) async {
    final id = _ctx.newId();
    final now = _ctx.now();
    await _db
        .into(_db.drinkTypes)
        .insert(
          DrinkTypesCompanion.insert(
            id: id,
            name: _cleanName(name),
            fieldProfile: profile,
            defaultVolumeMl: defaultVolumeMl,
            sortOrder: Value(await _nextOrder('drink_types', null, null)),
            updatedAt: now,
            updatedBy: _ctx.deviceId,
          ),
        );
    return id;
  }

  /// Nouvelle famille de caractéristiques d'un type, placée en dernier.
  Future<String> createFamily(String typeId, String name) async {
    final id = _ctx.newId();
    final now = _ctx.now();
    await _db
        .into(_db.characteristicFamilies)
        .insert(
          CharacteristicFamiliesCompanion.insert(
            id: id,
            typeId: typeId,
            name: _cleanName(name),
            sortOrder: Value(
              await _nextOrder('characteristic_families', 'type_id', typeId),
            ),
            updatedAt: now,
            updatedBy: _ctx.deviceId,
          ),
        );
    return id;
  }

  /// Nouvelle valeur d'une famille, placée en dernier.
  Future<String> createCharacteristic(String familyId, String name) async {
    final id = _ctx.newId();
    final now = _ctx.now();
    await _db
        .into(_db.characteristics)
        .insert(
          CharacteristicsCompanion.insert(
            id: id,
            familyId: familyId,
            name: _cleanName(name),
            sortOrder: Value(
              await _nextOrder('characteristics', 'family_id', familyId),
            ),
            updatedAt: now,
            updatedBy: _ctx.deviceId,
          ),
        );
    return id;
  }

  Future<void> renameType(String id, String name) => _db.customUpdate(
    'UPDATE drink_types SET name = ?, updated_at = ?, updated_by = ? '
    'WHERE id = ?',
    variables: _renameVariables(id, name),
    updates: {_db.drinkTypes},
  );

  Future<void> renameFamily(String id, String name) => _db.customUpdate(
    'UPDATE characteristic_families SET name = ?, updated_at = ?, '
    'updated_by = ? WHERE id = ?',
    variables: _renameVariables(id, name),
    updates: {_db.characteristicFamilies},
  );

  Future<void> renameCharacteristic(String id, String name) => _db.customUpdate(
    'UPDATE characteristics SET name = ?, updated_at = ?, updated_by = ? '
    'WHERE id = ?',
    variables: _renameVariables(id, name),
    updates: {_db.characteristics},
  );

  /// Supprime un type, ses familles et leurs valeurs. Le dernier type ne
  /// peut pas être supprimé (il faut un type pour créer une référence).
  Future<void> deleteType(String id) {
    return _db.transaction(() async {
      final others = await (_db.select(
        _db.drinkTypes,
      )..where((t) => t.deletedAt.isNull() & t.id.equals(id).not())).get();
      if (others.isEmpty) {
        throw StateError('Le dernier type ne peut pas être supprimé');
      }
      final families = await (_db.select(
        _db.characteristicFamilies,
      )..where((f) => f.typeId.equals(id) & f.deletedAt.isNull())).get();
      for (final f in families) {
        await _deleteFamily(f.id);
      }
      await (_db.update(
        _db.drinkTypes,
      )..where((t) => t.id.equals(id))).write(_ctx.deletionStamp());
    });
  }

  /// Supprime une famille et ses valeurs.
  Future<void> deleteFamily(String id) =>
      _db.transaction(() => _deleteFamily(id));

  Future<void> _deleteFamily(String id) async {
    await (_db.update(_db.characteristics)
          ..where((c) => c.familyId.equals(id) & c.deletedAt.isNull()))
        .write(_ctx.deletionStamp());
    await (_db.update(
      _db.characteristicFamilies,
    )..where((f) => f.id.equals(id))).write(_ctx.deletionStamp());
  }

  Future<void> deleteCharacteristic(String id) async {
    await (_db.update(
      _db.characteristics,
    )..where((c) => c.id.equals(id))).write(_ctx.deletionStamp());
  }

  /// Références actives d'un type : prévient avant une suppression.
  Future<int> drinkCountOfType(String typeId) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM drinks '
          'WHERE type_id = ? AND deleted_at IS NULL',
          variables: [Variable(typeId)],
        )
        .getSingle();
    return row.read<int>('n');
  }

  /// Références actives qui portent l'une de ces caractéristiques.
  Future<int> drinkCountWithCharacteristics(Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return 0;
    final marks = List.filled(list.length, '?').join(', ');
    final row = await _db
        .customSelect(
          'SELECT COUNT(DISTINCT dc.drink_id) AS n FROM drink_characteristics dc '
          'JOIN drinks d ON d.id = dc.drink_id AND d.deleted_at IS NULL '
          'WHERE dc.deleted_at IS NULL AND dc.characteristic_id IN ($marks)',
          variables: [for (final id in list) Variable(id)],
        )
        .getSingle();
    return row.read<int>('n');
  }

  static String _cleanName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Nom obligatoire');
    }
    return clean;
  }

  List<Variable<Object>> _renameVariables(String id, String name) => [
    Variable(_cleanName(name)),
    Variable(_ctx.now()),
    Variable(_ctx.deviceId),
    Variable(id),
  ];

  /// Ordre d'affichage suivant dans une table (lignes supprimées comprises :
  /// deux appareils qui ajoutent en même temps restent départagés par l'ID).
  Future<int> _nextOrder(String table, String? parent, String? parentId) async {
    final where = parent == null ? '' : 'WHERE $parent = ?';
    final row = await _db
        .customSelect(
          'SELECT COALESCE(MAX(sort_order), -1) + 1 AS n FROM $table $where',
          variables: [if (parentId != null) Variable(parentId)],
        )
        .getSingle();
    return row.read<int>('n');
  }

  /// Aucune référence ni aucun lot, même supprimés : cave toute neuve, rien
  /// à perdre en la remplaçant par celle du serveur.
  Future<bool> isEmpty() async {
    final row = await _db
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM drinks) + (SELECT COUNT(*) FROM lots) '
          'AS n',
        )
        .getSingle();
    return row.read<int>('n') == 0;
  }

  // ─────────────────────────────── Références ───────────────────────────────

  Future<Drink?> drink(String id) {
    return (_db.select(
      _db.drinks,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  /// Crée une référence. [id] n'est fourni que par l'import (restauration).
  Future<String> createDrink(DrinkInput input, {String? id}) async {
    id ??= _ctx.newId();
    final now = _ctx.now();
    final companion = await _drinkCompanion(input);
    await _db
        .into(_db.drinks)
        .insert(
          companion.copyWith(
            id: Value(id),
            createdAt: Value(now),
            updatedAt: Value(now),
            updatedBy: Value(_ctx.deviceId),
          ),
        );
    return id;
  }

  Future<void> updateDrink(String id, DrinkInput input) async {
    final companion = await _drinkCompanion(input);
    await (_db.update(_db.drinks)..where((t) => t.id.equals(id))).write(
      companion.copyWith(
        updatedAt: Value(_ctx.now()),
        updatedBy: Value(_ctx.deviceId),
      ),
    );
  }

  Future<DrinksCompanion> _drinkCompanion(DrinkInput input) async {
    final name = input.name.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(input.name, 'name', 'Nom obligatoire');
    }
    final rating = input.rating;
    if (rating != null && (rating < 0 || rating > 5)) {
      throw ArgumentError.value(rating, 'rating', 'Note de 0 à 5');
    }
    final type = await _activeType(input.typeId);
    String? clean(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    return DrinksCompanion(
      typeId: Value(type?.id),
      name: Value(name),
      producer: Value(clean(input.producer)),
      appellation: Value(clean(input.appellation)),
      region: Value(clean(input.region)),
      country: Value(clean(input.country)),
      grapes: Value(clean(input.grapes)),
      abv: Value(input.abv),
      rating: Value(rating),
      favorite: Value(input.favorite),
      comment: Value(clean(input.comment)),
      needsCompletion: Value(
        needsCompletion(
          profile: type?.fieldProfile,
          appellation: input.appellation,
          region: input.region,
          country: input.country,
        ),
      ),
    );
  }

  /// Crée une référence complète en une seule transaction : fiche,
  /// caractéristiques, premier lot et ses bouteilles (formulaire d'ajout).
  /// [barcode] : code scanné, mémorisé sur le lot pour la prochaine fois.
  Future<({String drinkId, String lotId})> addNewDrink({
    required DrinkInput drink,
    Set<String> characteristicIds = const {},
    required int volumeMl,
    int? vintage,
    required int quantity,
    String? barcode,
  }) {
    return _db.transaction(() async {
      final drinkId = await createDrink(drink);
      await setDrinkCharacteristics(drinkId, characteristicIds);
      final lotId = await findOrCreateLot(
        drinkId: drinkId,
        volumeMl: volumeMl,
        vintage: vintage,
        barcode: barcode,
      );
      await addEntry(lotId, quantity);
      return (drinkId: drinkId, lotId: lotId);
    });
  }

  /// Ajoute des bouteilles à une référence existante, dans le lot
  /// (millésime × volume) correspondant, créé au besoin : choix « ajouter à
  /// la référence proche » au lieu d'en créer une nouvelle (doublons,
  /// CDC §6.2). Retourne le lot et le mouvement d'entrée.
  Future<({String lotId, String movementId})> addToExistingDrink({
    required String drinkId,
    required int volumeMl,
    int? vintage,
    required int quantity,
    String? barcode,
  }) {
    return _db.transaction(() async {
      final lotId = await findOrCreateLot(
        drinkId: drinkId,
        volumeMl: volumeMl,
        vintage: vintage,
        barcode: barcode,
      );
      final movementId = await addEntry(lotId, quantity);
      return (lotId: lotId, movementId: movementId);
    });
  }

  /// Enregistre la fiche et ses caractéristiques en une seule transaction.
  Future<void> saveDrink(
    String id,
    DrinkInput input,
    Set<String> characteristicIds,
  ) {
    return _db.transaction(() async {
      await updateDrink(id, input);
      await setDrinkCharacteristics(id, characteristicIds);
    });
  }

  /// Ajoute ou retire une référence des favoris.
  Future<void> setFavorite(String id, bool favorite) async {
    await (_db.update(_db.drinks)..where((t) => t.id.equals(id))).write(
      DrinksCompanion(
        favorite: Value(favorite),
        updatedAt: Value(_ctx.now()),
        updatedBy: Value(_ctx.deviceId),
      ),
    );
  }

  /// Supprime une référence et tous ses lots (suppression logique).
  Future<void> deleteDrink(String id) {
    return _db.transaction(() async {
      await (_db.update(_db.lots)
            ..where((t) => t.drinkId.equals(id) & t.deletedAt.isNull()))
          .write(_ctx.deletionStamp());
      await (_db.update(
        _db.drinks,
      )..where((t) => t.id.equals(id))).write(_ctx.deletionStamp());
    });
  }

  /// Caractéristiques actives d'une référence.
  Future<Set<String>> drinkCharacteristicIds(String drinkId) async {
    final rows = await (_db.select(
      _db.drinkCharacteristics,
    )..where((t) => t.drinkId.equals(drinkId) & t.deletedAt.isNull())).get();
    return {for (final r in rows) r.characteristicId};
  }

  /// Remplace l'ensemble des caractéristiques d'une référence.
  Future<void> setDrinkCharacteristics(
    String drinkId,
    Set<String> characteristicIds,
  ) {
    return _db.transaction(() async {
      final now = _ctx.now();
      final existing = await (_db.select(
        _db.drinkCharacteristics,
      )..where((t) => t.drinkId.equals(drinkId))).get();
      final byCharacteristic = {
        for (final r in existing) r.characteristicId: r,
      };

      // Liens à retirer.
      for (final r in existing) {
        if (r.deletedAt == null &&
            !characteristicIds.contains(r.characteristicId)) {
          await (_db.update(
            _db.drinkCharacteristics,
          )..where((t) => t.id.equals(r.id))).write(_ctx.deletionStamp());
        }
      }
      // Liens à ajouter ou à réactiver.
      for (final cid in characteristicIds) {
        final r = byCharacteristic[cid];
        if (r != null && r.deletedAt == null) continue;
        await _db
            .into(_db.drinkCharacteristics)
            .insertOnConflictUpdate(
              DrinkCharacteristicsCompanion.insert(
                id: '$drinkId|$cid',
                drinkId: drinkId,
                characteristicId: cid,
                updatedAt: now,
                updatedBy: _ctx.deviceId,
                deletedAt: const Value(null),
              ),
            );
      }
    });
  }

  // ────────────────────────────────── Lots ──────────────────────────────────

  Future<Lot?> lot(String id) {
    return (_db.select(
      _db.lots,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  /// Lots actifs d'une référence.
  Future<List<Lot>> lotsOf(String drinkId) {
    return (_db.select(_db.lots)
          ..where((t) => t.drinkId.equals(drinkId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.vintage, nulls: NullsOrder.last),
            (t) => OrderingTerm(expression: t.volumeMl),
          ]))
        .get();
  }

  /// Retrouve le lot (référence × millésime × volume) ou le crée s'il n'existe
  /// pas : ajouter des bouteilles à un lot existant augmente son stock, quelle
  /// que soit la date (CDC §3). Un code-barres fourni complète un lot qui n'en
  /// a pas encore. [id] et [createdAt] ne sont fournis que par l'import
  /// (restauration).
  Future<String> findOrCreateLot({
    required String drinkId,
    required int volumeMl,
    int? vintage,
    String? barcode,
    String? id,
    int? createdAt,
  }) {
    if (volumeMl <= 0) {
      throw ArgumentError.value(volumeMl, 'volumeMl', 'Volume positif');
    }
    barcode = normalizeBarcode(barcode);
    return _db.transaction(() async {
      final query = _db.select(_db.lots)
        ..where(
          (t) =>
              t.drinkId.equals(drinkId) &
              t.volumeMl.equals(volumeMl) &
              t.deletedAt.isNull() &
              (vintage == null
                  ? t.vintage.isNull()
                  : t.vintage.equals(vintage)),
        );
      final existing = await query.getSingleOrNull();
      final now = _ctx.now();
      if (existing != null) {
        if (barcode != null && existing.barcode == null) {
          await (_db.update(
            _db.lots,
          )..where((t) => t.id.equals(existing.id))).write(
            LotsCompanion(
              barcode: Value(barcode),
              updatedAt: Value(now),
              updatedBy: Value(_ctx.deviceId),
            ),
          );
        }
        return existing.id;
      }
      final lotId = id ?? _ctx.newId();
      await _db
          .into(_db.lots)
          .insert(
            LotsCompanion.insert(
              id: lotId,
              drinkId: drinkId,
              vintage: Value(vintage),
              volumeMl: volumeMl,
              barcode: Value(barcode),
              createdAt: createdAt ?? now,
              updatedAt: now,
              updatedBy: _ctx.deviceId,
            ),
          );
      return lotId;
    });
  }

  /// Lots actifs (référence active) qui portent ce code-barres, toutes
  /// références confondues : un même code peut désigner plusieurs lots
  /// (CDC §6.2). Par référence, puis du millésime le plus ancien au plus
  /// récent, lots sans millésime en dernier (CDC §6.3).
  Future<List<({Drink drink, Lot lot})>> lotsByBarcode(String code) async {
    final normalized = normalizeBarcode(code);
    if (normalized == null) return const [];
    final query =
        _db.select(_db.lots).join([
            innerJoin(_db.drinks, _db.drinks.id.equalsExp(_db.lots.drinkId)),
          ])
          ..where(
            _db.lots.barcode.equals(normalized) &
                _db.lots.deletedAt.isNull() &
                _db.drinks.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm(expression: _db.drinks.name),
            OrderingTerm(expression: _db.lots.vintage, nulls: NullsOrder.last),
            OrderingTerm(expression: _db.lots.volumeMl),
          ]);
    return (await query.get())
        .map(
          (row) =>
              (drink: row.readTable(_db.drinks), lot: row.readTable(_db.lots)),
        )
        .toList();
  }

  /// Associe un code-barres à un lot (code inconnu lu au scan, CDC §6.3) ;
  /// remplace son code précédent s'il en avait un.
  Future<void> setLotBarcode(String lotId, String code) async {
    final normalized = normalizeBarcode(code);
    if (normalized == null) throw ArgumentError.value(code, 'code', 'Vide');
    await (_db.update(_db.lots)..where((t) => t.id.equals(lotId))).write(
      LotsCompanion(
        barcode: Value(normalized),
        updatedAt: Value(_ctx.now()),
        updatedBy: Value(_ctx.deviceId),
      ),
    );
  }

  /// Supprime un lot (suppression logique) ; ses mouvements sont conservés
  /// mais ne comptent plus.
  Future<void> deleteLot(String id) async {
    await (_db.update(
      _db.lots,
    )..where((t) => t.id.equals(id))).write(_ctx.deletionStamp());
  }

  // ─────────────────────────────── Mouvements ───────────────────────────────

  /// Ajoute [quantity] bouteilles au lot.
  Future<String> addEntry(String lotId, int quantity, {String? comment}) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'Quantité positive');
    }
    return _addMovement(lotId, MovementKind.entry, quantity, comment: comment);
  }

  /// Retire [quantity] bouteilles du lot (« consommée » par défaut).
  /// Refuse de retirer plus que le stock.
  Future<String> addExit(
    String lotId,
    int quantity, {
    ExitReason reason = ExitReason.consumed,
    String? comment,
  }) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'Quantité positive');
    }
    return _addMovement(
      lotId,
      MovementKind.exit,
      quantity,
      reason: reason,
      comment: comment,
      check: (stock) {
        if (quantity > stock) {
          throw StateError('Stock insuffisant ($stock) pour retirer $quantity');
        }
      },
    );
  }

  /// Enregistre le nombre de bouteilles constaté (ajustement d'inventaire,
  /// CDC §6.4). Exclu des statistiques de consommation.
  Future<String> recordInventory(String lotId, int counted, {String? comment}) {
    if (counted < 0) {
      throw ArgumentError.value(counted, 'counted', 'Nombre positif ou nul');
    }
    return _addMovement(
      lotId,
      MovementKind.inventory,
      counted,
      comment: comment,
    );
  }

  Future<String> _addMovement(
    String lotId,
    MovementKind kind,
    int quantity, {
    ExitReason? reason,
    String? comment,
    void Function(int currentStock)? check,
  }) {
    return _db.transaction(() async {
      final target = await lot(lotId);
      if (target == null) throw StateError('Lot introuvable : $lotId');
      check?.call(target.stock);
      final id = _ctx.newId();
      final now = _ctx.now();
      await _db
          .into(_db.movements)
          .insert(
            MovementsCompanion.insert(
              id: id,
              lotId: lotId,
              occurredAt: now,
              kind: kind,
              quantity: quantity,
              reason: Value(reason),
              comment: Value(
                comment == null || comment.trim().isEmpty
                    ? null
                    : comment.trim(),
              ),
              deviceId: _ctx.deviceId,
              updatedAt: now,
              updatedBy: _ctx.deviceId,
            ),
          );
      await recomputeStock(lotId);
      return id;
    });
  }

  /// Annule un mouvement (bandeau « Annuler », CDC §6.3).
  Future<void> undoMovement(String movementId) {
    return _db.transaction(() async {
      final m = await (_db.select(
        _db.movements,
      )..where((t) => t.id.equals(movementId))).getSingle();
      if (m.deletedAt != null) return;
      await (_db.update(
        _db.movements,
      )..where((t) => t.id.equals(movementId))).write(_ctx.deletionStamp());
      await recomputeStock(m.lotId);
    });
  }

  /// Mouvements actifs d'un lot, du plus ancien au plus récent.
  Future<List<Movement>> movementsOf(String lotId) {
    return (_db.select(_db.movements)
          ..where((t) => t.lotId.equals(lotId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.occurredAt),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .get();
  }

  /// Date de la dernière entrée du lot (CDC §3), ou null.
  Future<int?> lastEntryAt(String lotId) async {
    final max = _db.movements.occurredAt.max();
    final row =
        await (_db.selectOnly(_db.movements)
              ..addColumns([max])
              ..where(
                _db.movements.lotId.equals(lotId) &
                    _db.movements.kind.equalsValue(MovementKind.entry) &
                    _db.movements.deletedAt.isNull(),
              ))
            .getSingle();
    return row.read(max);
  }

  // ────────────────────────────────── Stock ─────────────────────────────────

  /// Recalcule le stock en cache d'un lot à partir de ses mouvements.
  Future<int> recomputeStock(String lotId) async {
    final events = (await movementsOf(lotId)).map(stockEventOf);
    final stock = computeStock(events);
    // Écriture directe : le cache n'est pas une modification de la fiche,
    // il ne change donc pas updatedAt.
    await (_db.update(_db.lots)..where((t) => t.id.equals(lotId))).write(
      LotsCompanion(stock: Value(stock)),
    );
    return stock;
  }

  /// Recalcule tous les stocks (après une synchronisation, par exemple).
  Future<void> recomputeAllStocks() {
    return _db.transaction(() async {
      final ids = await (_db.selectOnly(
        _db.lots,
      )..addColumns([_db.lots.id])).map((r) => r.read(_db.lots.id)!).get();
      for (final id in ids) {
        await recomputeStock(id);
      }
    });
  }

  /// Totaux de la cave, mis à jour automatiquement à chaque changement.
  Stream<CaveTotals> watchTotals() {
    return _db
        .customSelect(
          'SELECT COALESCE(SUM(l.stock), 0) AS bottles, '
          'COUNT(DISTINCT CASE WHEN l.stock > 0 THEN l.drink_id END) AS drinks '
          'FROM lots l JOIN drinks d ON d.id = l.drink_id '
          'WHERE l.deleted_at IS NULL AND d.deleted_at IS NULL',
          readsFrom: {_db.lots, _db.drinks},
        )
        .watchSingle()
        .map(
          (row) => CaveTotals(
            bottles: row.read<int>('bottles'),
            drinksInStock: row.read<int>('drinks'),
          ),
        );
  }
}

/// Un mouvement réduit à ce qui compte pour le calcul du stock.
StockEvent stockEventOf(Movement m) => StockEvent(
  id: m.id,
  occurredAt: m.occurredAt,
  kind: m.kind,
  quantity: m.quantity,
);
