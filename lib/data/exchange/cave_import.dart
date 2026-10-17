import 'package:drift/drift.dart';

import '../../domain/label_parsing.dart';
import '../../domain/csv.dart';
import '../../domain/enums.dart';
import '../../domain/text.dart';
import '../../domain/vivino.dart';
import '../cave_repository.dart';
import '../database.dart';
import '../history_purge.dart';
import '../write_context.dart';
import 'exchange_format.dart';

/// Nature du fichier importé, reconnue d'après ses colonnes.
enum ImportKind { stock, history, vivino }

/// Problème sur une ligne du fichier ; la ligne est ignorée.
enum ImportIssueCode {
  unknownFormat,
  missingName,
  invalidVolume,
  invalidVintage,
  invalidStock,
  unknownLot,
  invalidDate,
  invalidKind,
  invalidQuantity,
}

class ImportIssue {
  const ImportIssue(this.line, this.code, [this.detail = '']);

  /// Numéro de ligne dans le fichier (1 = en-têtes).
  final int line;
  final ImportIssueCode code;
  final String detail;
}

/// Bilan d'un import (ou de son aperçu).
class ImportReport {
  ImportReport(this.kind);

  final ImportKind? kind;
  int drinksCreated = 0;
  int lotsCreated = 0;

  /// Lots existants dont le stock a été mis à la valeur du fichier.
  int lotsAdjusted = 0;

  /// Lots déjà présents, laissés tels quels (import Vivino).
  int lotsSkipped = 0;
  int bottlesAdded = 0;
  int movementsAdded = 0;

  /// Mouvements déjà présents (même identifiant), ignorés.
  int movementsSkipped = 0;

  /// Références créées marquées « à compléter ».
  int needsCompletion = 0;
  final List<ImportIssue> issues = [];

  /// Caractéristiques du fichier introuvables dans la classification.
  final Set<String> unknownCharacteristics = {};

  bool get hasChanges =>
      drinksCreated + lotsCreated + lotsAdjusted + movementsAdded > 0;
}

/// Exception interne qui annule la transaction d'un aperçu.
class _Rollback implements Exception {
  const _Rollback(this.report);
  final ImportReport report;
}

/// Import de fichiers CSV dans la cave (CDC §6.7) : sauvegarde au format de
/// l'export (stock ou historique) ou export Vivino.
///
/// [preview] fait tout l'import dans une transaction puis l'annule : le bilan
/// affiché est exactement celui qu'obtiendra [apply].
/// Taille maximale d'un fichier à importer : un historique de 21 000
/// mouvements tient en quelques Mo. Au-delà, le fichier serait lu en entier
/// en mémoire pour rien (audit de sécurité du 2026-10-17).
const maxImportMegabytes = 50;

class CaveImporter {
  CaveImporter(this._db, WriteContext ctx)
    : _repo = CaveRepository(_db, ctx),
      _ctx = ctx;

  final CaveDatabase _db;
  final CaveRepository _repo;
  final WriteContext _ctx;

  Future<ImportReport> preview(String content) => _run(content, commit: false);

  Future<ImportReport> apply(String content) => _run(content, commit: true);

  static ImportKind? detect(CsvTable table) {
    if (table.has(HistoryColumns.movementId)) return ImportKind.history;
    if (isVivinoExport(table)) return ImportKind.vivino;
    if (table.has(StockColumns.name)) return ImportKind.stock;
    return null;
  }

  Future<ImportReport> _run(String content, {required bool commit}) async {
    final table = CsvTable(decodeCsv(content));
    final kind = detect(table);
    if (kind == null) {
      return ImportReport(null)
        ..issues.add(const ImportIssue(1, ImportIssueCode.unknownFormat));
    }
    try {
      return await _db.transaction(() async {
        final report = ImportReport(kind);
        final context = await _Lookup.load(_db);
        switch (kind) {
          case ImportKind.stock:
            await _importStock(table, report, context);
          case ImportKind.history:
            await _importHistory(table, report);
          case ImportKind.vivino:
            await _importVivino(table, report, context);
        }
        if (!commit) throw _Rollback(report);
        return report;
      });
    } on _Rollback catch (r) {
      return r.report;
    }
  }

  // ─────────────────────────────── Stock ───────────────────────────────

  /// Une ligne par lot. Références et lots retrouvés par identifiant, sinon par
  /// nom + producteur + type (références) et millésime + volume (lots), sinon
  /// créés. Le stock de chaque lot est mis à la valeur du fichier par un
  /// ajustement d'inventaire. Les fiches existantes ne sont pas modifiées.
  Future<void> _importStock(
    CsvTable table,
    ImportReport report,
    _Lookup lookup,
  ) async {
    for (final (i, row) in table.rows.indexed) {
      final line = i + 2;
      String col(String name) => table.cell(row, name);

      final name = col(StockColumns.name);
      if (name.isEmpty) {
        report.issues.add(ImportIssue(line, ImportIssueCode.missingName));
        continue;
      }
      final type = lookup.typeByName(col(StockColumns.type));

      final volumeText = col(StockColumns.volumeMl);
      final vintageText = col(StockColumns.vintage);
      final stockText = col(StockColumns.stock);
      final hasLot =
          col(StockColumns.lotId).isNotEmpty ||
          volumeText.isNotEmpty ||
          vintageText.isNotEmpty ||
          stockText.isNotEmpty;

      // En millilitres (« 750 »), ou avec l'unité dans un fichier préparé à
      // la main (« 75 cl », « 0,75 l »).
      final volume = volumeText.isEmpty
          ? (type?.defaultVolumeMl ?? 750)
          : int.tryParse(volumeText) ?? parseVolumeMl(volumeText);
      if (hasLot && (volume == null || volume <= 0)) {
        report.issues.add(
          ImportIssue(line, ImportIssueCode.invalidVolume, volumeText),
        );
        continue;
      }
      final vintage = vintageText.isEmpty ? null : int.tryParse(vintageText);
      if (vintageText.isNotEmpty && (vintage == null || vintage < 1800)) {
        report.issues.add(
          ImportIssue(line, ImportIssueCode.invalidVintage, vintageText),
        );
        continue;
      }
      final stock = stockText.isEmpty ? 0 : int.tryParse(stockText);
      if (stock == null || stock < 0) {
        report.issues.add(
          ImportIssue(line, ImportIssueCode.invalidStock, stockText),
        );
        continue;
      }

      final drinkId = await _findOrCreateDrink(
        report,
        lookup,
        id: col(StockColumns.drinkId),
        type: type,
        characteristics: lookup.parseCharacteristics(
          type,
          col(StockColumns.characteristics),
          report,
        ),
        input: DrinkInput(
          name: name,
          typeId: type?.id,
          producer: col(StockColumns.producer),
          appellation: col(StockColumns.appellation),
          region: col(StockColumns.region),
          country: col(StockColumns.country),
          grapes: col(StockColumns.grapes),
          abv: parseDecimal(col(StockColumns.abv)),
          rating: _rating(col(StockColumns.rating)),
          favorite: fold(col(StockColumns.favorite)) == yes,
          comment: col(StockColumns.comment),
        ),
      );
      if (!hasLot) continue;

      final lotIdText = col(StockColumns.lotId);
      var lot = lotIdText.isEmpty ? null : await _repo.lot(lotIdText);
      if (lot == null) {
        final existed = (await _repo.lotsOf(drinkId))
            .any((l) => l.vintage == vintage && l.volumeMl == volume);
        final idFree =
            lotIdText.isNotEmpty && !await _exists(_db.lots, lotIdText);
        final lotId = await _repo.findOrCreateLot(
          drinkId: drinkId,
          volumeMl: volume!,
          vintage: vintage,
          barcode: _nullIfEmpty(col(StockColumns.barcode)),
          id: idFree ? lotIdText : null,
          createdAt: parseTimestamp(col(StockColumns.addedOn)),
        );
        lot = (await _repo.lot(lotId))!;
        if (!existed) report.lotsCreated++;
      }
      if (lot.stock != stock) {
        final isNew = await _repo.movementsOf(lot.id).then((m) => m.isEmpty);
        await _repo.recordInventory(lot.id, stock);
        if (isNew) {
          report.bottlesAdded += stock;
        } else {
          report.lotsAdjusted++;
        }
      }
    }
  }

  // ───────────────────────────── Historique ────────────────────────────

  /// Ajoute les mouvements inconnus (par identifiant) des lots existants,
  /// avec leur date d'origine, puis recalcule les stocks concernés.
  Future<void> _importHistory(CsvTable table, ImportReport report) async {
    final touchedLots = <String>{};
    final kinds = {for (final e in kindTokens.entries) fold(e.value): e.key};
    final reasons = {
      for (final e in reasonTokens.entries) fold(e.value): e.key,
    };

    final purgedBefore = await HistoryPurge(_db, _ctx).purgedBefore();

    for (final (i, row) in table.rows.indexed) {
      final line = i + 2;
      String col(String name) => table.cell(row, name);

      final id = col(HistoryColumns.movementId);
      if (id.isNotEmpty && await _exists(_db.movements, id)) {
        report.movementsSkipped++;
        continue;
      }
      final lotId = col(HistoryColumns.lotId);
      if (await _repo.lot(lotId) == null) {
        report.issues.add(ImportIssue(line, ImportIssueCode.unknownLot, lotId));
        continue;
      }
      final date = parseTimestamp(col(HistoryColumns.date));
      if (date == null) {
        report.issues.add(
          ImportIssue(
            line,
            ImportIssueCode.invalidDate,
            col(HistoryColumns.date),
          ),
        );
        continue;
      }
      // Antérieur à une purge de l'historique : ne revient jamais.
      if (purgedBefore != null && date < purgedBefore) {
        report.movementsSkipped++;
        continue;
      }
      final kind = kinds[fold(col(HistoryColumns.kind))];
      if (kind == null) {
        report.issues.add(
          ImportIssue(
            line,
            ImportIssueCode.invalidKind,
            col(HistoryColumns.kind),
          ),
        );
        continue;
      }
      final quantity = int.tryParse(col(HistoryColumns.quantity));
      if (quantity == null ||
          quantity < 0 ||
          (quantity == 0 && kind != MovementKind.inventory)) {
        report.issues.add(
          ImportIssue(
            line,
            ImportIssueCode.invalidQuantity,
            col(HistoryColumns.quantity),
          ),
        );
        continue;
      }
      final now = _ctx.now();
      await _db
          .into(_db.movements)
          .insert(
            MovementsCompanion.insert(
              id: id.isEmpty ? _ctx.newId() : id,
              lotId: lotId,
              occurredAt: date,
              kind: kind,
              quantity: quantity,
              reason: Value(
                kind == MovementKind.exit
                    ? (reasons[fold(col(HistoryColumns.reason))] ??
                          ExitReason.consumed)
                    : null,
              ),
              comment: Value(_nullIfEmpty(col(HistoryColumns.comment))),
              deviceId: _ctx.deviceId,
              updatedAt: now,
              updatedBy: _ctx.deviceId,
            ),
          );
      report.movementsAdded++;
      touchedLots.add(lotId);
    }
    for (final lotId in touchedLots) {
      await _repo.recomputeStock(lotId);
    }
  }

  // ─────────────────────────────── Vivino ──────────────────────────────

  /// Chaque vin devient une référence de type Vin (regroupée par nom et
  /// domaine) avec un lot par millésime. Un lot déjà présent dans la cave
  /// avant l'import est laissé tel quel : réimporter le fichier ne double
  /// pas le stock.
  Future<void> _importVivino(
    CsvTable table,
    ImportReport report,
    _Lookup lookup,
  ) async {
    final wine = lookup.typeByProfile(FieldProfile.wine);
    final createdLots = <String>{};
    for (final v in parseVivino(table)) {
      if (v.quantity <= 0) continue;
      final characteristics = <String>{
        for (final MapEntry(key: family, value: value)
            in v.characteristics.entries)
          ?lookup.characteristicId(wine, family, value),
      };
      final drinkId = await _findOrCreateDrink(
        report,
        lookup,
        type: wine,
        characteristics: characteristics,
        input: DrinkInput(
          name: v.name,
          typeId: wine?.id,
          producer: v.producer,
          appellation: v.appellation,
          region: v.region,
          country: v.country,
        ),
      );
      final volume = wine?.defaultVolumeMl ?? 750;
      final existing = (await _repo.lotsOf(drinkId))
          .where((l) => l.vintage == v.vintage && l.volumeMl == volume);
      if (existing.isNotEmpty && !createdLots.contains(existing.first.id)) {
        report.lotsSkipped++;
        continue;
      }
      final lotId = await _repo.findOrCreateLot(
        drinkId: drinkId,
        volumeMl: volume,
        vintage: v.vintage,
      );
      if (createdLots.add(lotId)) report.lotsCreated++;
      await _repo.addEntry(lotId, v.quantity);
      report.bottlesAdded += v.quantity;
    }
  }

  // ─────────────────────────────── Outils ──────────────────────────────

  Future<String> _findOrCreateDrink(
    ImportReport report,
    _Lookup lookup, {
    String id = '',
    required DrinkType? type,
    required Set<String> characteristics,
    required DrinkInput input,
  }) async {
    if (id.isNotEmpty && await _repo.drink(id) != null) return id;
    final known = lookup.findDrink(input.name, input.producer, type?.id);
    if (known != null) return known;

    final idFree = id.isNotEmpty && !await _exists(_db.drinks, id);
    final created = await _repo.createDrink(input, id: idFree ? id : null);
    await _repo.setDrinkCharacteristics(created, characteristics);
    lookup.addDrink(created, input.name, input.producer, type?.id);
    report.drinksCreated++;
    if ((await _repo.drink(created))!.needsCompletion) report.needsCompletion++;
    return created;
  }

  Future<bool> _exists(TableInfo<Table, dynamic> table, String id) async {
    final rows = await _db
        .customSelect(
          'SELECT 1 FROM ${table.actualTableName} WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .get();
    return rows.isNotEmpty;
  }

  static int? _rating(String text) {
    final r = int.tryParse(text);
    return r == null || r < 0 || r > 5 ? null : r;
  }

  static String? _nullIfEmpty(String text) => text.isEmpty ? null : text;
}

/// Données de la cave chargées une fois au début de l'import.
class _Lookup {
  _Lookup(this.types, this.families, this.values);

  final List<DrinkType> types;
  final List<CharacteristicFamily> families;
  final List<Characteristic> values;

  /// Références actives (et créées pendant l'import), pour le rapprochement.
  final List<({String id, String name, String producer, String? typeId})>
  _drinks = [];

  static Future<_Lookup> load(CaveDatabase db) async {
    final types = await (db.select(
      db.drinkTypes,
    )..where((t) => t.deletedAt.isNull())).get();
    final families = await (db.select(
      db.characteristicFamilies,
    )..where((f) => f.deletedAt.isNull())).get();
    final values = await (db.select(
      db.characteristics,
    )..where((c) => c.deletedAt.isNull())).get();
    final drinks = await (db.select(
      db.drinks,
    )..where((d) => d.deletedAt.isNull())).get();
    final lookup = _Lookup(types, families, values);
    for (final d in drinks) {
      lookup.addDrink(d.id, d.name, d.producer, d.typeId);
    }
    return lookup;
  }

  void addDrink(String id, String name, String? producer, String? typeId) {
    _drinks.add((
      id: id,
      name: compactKey(name),
      producer: compactKey(producer ?? ''),
      typeId: typeId,
    ));
  }

  /// Même boisson : même nom et même type (aux accents, casse, espaces et
  /// ponctuation près), et producteurs identiques, ou absent d'un côté (une
  /// fiche saisie à la main n'a souvent pas de producteur).
  String? findDrink(String name, String? producer, String? typeId) {
    final n = compactKey(name), p = compactKey(producer ?? '');
    for (final d in _drinks) {
      if (d.name == n &&
          d.typeId == typeId &&
          (d.producer.isEmpty || p.isEmpty || d.producer == p)) {
        return d.id;
      }
    }
    return null;
  }

  DrinkType? typeByName(String name) {
    final key = fold(name.trim());
    if (key.isEmpty) return null;
    for (final t in types) {
      if (fold(t.name) == key) return t;
    }
    return null;
  }

  DrinkType? typeByProfile(FieldProfile profile) {
    for (final t in types) {
      if (t.fieldProfile == profile) return t;
    }
    return null;
  }

  String? characteristicId(DrinkType? type, String family, String value) {
    if (type == null) return null;
    final familyIds = {
      for (final f in families)
        if (f.typeId == type.id && fold(f.name) == fold(family)) f.id,
    };
    for (final c in values) {
      if (familyIds.contains(c.familyId) && fold(c.name) == fold(value)) {
        return c.id;
      }
    }
    return null;
  }

  /// « Robe : Rouge | Sucre : Sec » (ou « Rouge | Sec ») → identifiants.
  Set<String> parseCharacteristics(
    DrinkType? type,
    String text,
    ImportReport report,
  ) {
    final ids = <String>{};
    for (final part in text.split(characteristicSeparator.trim())) {
      final item = part.trim();
      if (item.isEmpty) continue;
      final colon = item.indexOf(familySeparator.trim());
      String? id;
      if (colon >= 0) {
        id = characteristicId(
          type,
          item.substring(0, colon).trim(),
          item.substring(colon + 1).trim(),
        );
      } else if (type != null) {
        final familyIds = {
          for (final f in families)
            if (f.typeId == type.id) f.id,
        };
        for (final c in values) {
          if (familyIds.contains(c.familyId) && fold(c.name) == fold(item)) {
            id = c.id;
            break;
          }
        }
      }
      if (id == null) {
        report.unknownCharacteristics.add(item);
      } else {
        ids.add(id);
      }
    }
    return ids;
  }
}
