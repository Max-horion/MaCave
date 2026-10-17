import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/enums.dart';
import '../domain/stock.dart';
import 'cave_repository.dart';
import 'database.dart';
import 'write_context.dart';

// Purges de l'historique (CDC §6.3, §7 « Espace disque »).
//
// Purge manuelle « avant une date » : les mouvements antérieurs sont
// supprimés pour de bon. Le stock étant calculé à partir des mouvements,
// chaque lot reçoit d'abord un « report de stock » : un inventaire, à la date
// de purge, du stock à cette date. Les stocks ne changent donc pas.
// La date est enregistrée dans les réglages synchronisés : la fusion ignore
// les mouvements antérieurs, qu'un autre appareil ne peut donc pas faire
// revenir (docs/architecture.md §4).
//
// Purge automatique : les lots épuisés sans mouvement depuis le délai choisi
// sont supprimés (logiquement, pour que la suppression se propage), avec
// leur historique, et la référence si elle n'a plus aucun lot. Les lots en
// stock ne sont jamais purgés.

/// Réglage de la purge automatique, commun à tous les appareils.
class AutoPurgeSettings {
  const AutoPurgeSettings({this.enabled = false, this.months = 24});

  /// Désactivée tant que l'utilisateur ne l'a pas choisie (CDC §7).
  final bool enabled;

  /// Délai sans mouvement, en mois.
  final int months;

  /// Délais proposés.
  static const monthChoices = [6, 12, 24, 60];
}

class HistoryPurge {
  HistoryPurge(this._db, this._ctx);

  final CaveDatabase _db;
  final WriteContext _ctx;

  /// Clés dans la table `settings` (format : ne pas renommer).
  static const purgedBeforeKey = 'history_purged_before';
  static const autoPurgeKey = 'auto_purge';

  // ──────────────────────────── Purge manuelle ─────────────────────────────

  /// Avance tolérée d'une date de purge sur l'horloge de cet appareil.
  static const clockTolerance = Duration(days: 1);

  /// Date avant laquelle l'historique a été purgé (UTC, millisecondes), ou
  /// null. Lit la base [schema] (`main` ou `source` pendant une fusion).
  ///
  /// Une date dans le futur (horloge d'un autre appareil très en avance,
  /// fichier abîmé ou modifié sur le serveur) est ignorée : appliquée, elle
  /// effacerait tout l'historique et la fusion n'importerait plus jamais
  /// aucun mouvement, puisque la date ne recule jamais (audit de sécurité du
  /// 2026-10-17).
  Future<int?> purgedBefore({String schema = 'main'}) async {
    final row = await _db
        .customSelect(
          'SELECT value FROM $schema.settings WHERE key = ?',
          variables: [Variable<String>(purgedBeforeKey)],
        )
        .getSingleOrNull();
    final value = row == null ? null : jsonDecode(row.read<String>('value'));
    if (value is! int) return null;
    final limit = _ctx.now() + clockTolerance.inMilliseconds;
    return value <= limit ? value : null;
  }

  /// Nombre de mouvements antérieurs à [date] (pour la confirmation).
  Future<int> countBefore(int date) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM movements WHERE occurred_at < ?',
          variables: [Variable<int>(date)],
        )
        .getSingle();
    return row.read<int>('n');
  }

  /// Date du plus ancien mouvement, ou null s'il n'y en a pas.
  Future<int?> oldestMovement() async {
    final row = await _db
        .customSelect('SELECT MIN(occurred_at) AS d FROM movements')
        .getSingle();
    return row.read<int?>('d');
  }

  /// Purge manuelle : supprime les mouvements antérieurs à [date], stocks
  /// inchangés, et enregistre la date pour les autres appareils. Retourne le
  /// nombre de mouvements supprimés.
  Future<int> purgeBefore(int date) => _db.transaction(() async {
    final removed = await applyPurge(date);
    await recordPurgeDate(date);
    return removed;
  });

  /// Reporte le stock de chaque lot à [date], puis supprime les mouvements
  /// antérieurs. N'enregistre pas la date (voir [recordPurgeDate]) : la
  /// fusion l'utilise aussi, quand elle apprend une purge d'un autre
  /// appareil. Retourne le nombre de mouvements supprimés.
  Future<int> applyPurge(int date) => _db.transaction(() async {
    final old = await (_db.select(
      _db.movements,
    )..where((t) => t.occurredAt.isSmallerThanValue(date))).get();
    final byLot = <String, List<Movement>>{};
    for (final m in old) {
      byLot.putIfAbsent(m.lotId, () => []).add(m);
    }
    final now = _ctx.now();
    for (final MapEntry(key: lotId, value: movements) in byLot.entries) {
      final stock = computeStock(
        movements.where((m) => m.deletedAt == null).map(stockEventOf),
      );
      // Rien à reporter : repartir de zéro donne le même stock.
      if (stock == 0) continue;
      // Même identifiant sur tous les appareils pour un même lot et une même
      // date : deux reports identiques ne font jamais doublon. S'il existe
      // déjà (reçu d'un autre appareil), c'est lui qui compte.
      await _db
          .into(_db.movements)
          .insert(
            MovementsCompanion.insert(
              id: carryOverId(lotId, date),
              lotId: lotId,
              occurredAt: date,
              kind: MovementKind.inventory,
              quantity: stock,
              deviceId: _ctx.deviceId,
              updatedAt: now,
              updatedBy: _ctx.deviceId,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    final removed = await (_db.delete(
      _db.movements,
    )..where((t) => t.occurredAt.isSmallerThanValue(date))).go();
    final repo = CaveRepository(_db, _ctx);
    for (final lotId in byLot.keys) {
      await repo.recomputeStock(lotId);
    }
    return removed;
  });

  /// Enregistre la date de purge si elle est plus récente que celle connue :
  /// elle ne recule jamais, quel que soit l'ordre des synchronisations (une
  /// date dans le futur, ignorée par [purgedBefore], est remplacée).
  /// Retourne true si le réglage a changé.
  Future<bool> recordPurgeDate(int date) async {
    final current = await purgedBefore();
    if (current != null && current >= date) return false;
    await _writeSetting(purgedBeforeKey, date);
    return true;
  }

  /// Identifiant du report de stock d'un lot à une date.
  static String carryOverId(String lotId, int date) => const Uuid().v5(
    Namespace.url.value,
    'https://cave.bouthon.fr/purge/$lotId/$date',
  );

  // ─────────────────────────── Purge automatique ────────────────────────────

  Future<AutoPurgeSettings> autoSettings() async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(autoPurgeKey))).getSingleOrNull();
    if (row == null) return const AutoPurgeSettings();
    try {
      final json = jsonDecode(row.value);
      if (json is Map) {
        final months = json['months'];
        return AutoPurgeSettings(
          enabled: json['enabled'] == true,
          months: months is int && months > 0 ? months : 24,
        );
      }
    } on FormatException {
      // Valeur illisible : réglage par défaut.
    }
    return const AutoPurgeSettings();
  }

  Future<void> setAutoSettings(AutoPurgeSettings settings) => _writeSetting(
    autoPurgeKey,
    {'enabled': settings.enabled, 'months': settings.months},
  );

  /// Lots qui seraient purgés à la date [now] avec un délai de [months] mois.
  Future<List<Lot>> autoPurgeCandidates(DateTime now, int months) async {
    final limit = DateTime.utc(
      now.year,
      now.month - months,
      now.day,
      now.hour,
      now.minute,
    ).millisecondsSinceEpoch;
    // Dernier mouvement actif du lot, ou sa date de création s'il n'en a pas.
    return _db
        .customSelect(
          'SELECT l.* FROM lots l '
          'WHERE l.deleted_at IS NULL AND l.stock = 0 AND COALESCE('
          '(SELECT MAX(m.occurred_at) FROM movements m '
          'WHERE m.lot_id = l.id AND m.deleted_at IS NULL), l.created_at) < ?',
          variables: [Variable<int>(limit)],
          readsFrom: {_db.lots, _db.movements},
        )
        .asyncMap((row) => _db.lots.mapFromRow(row))
        .get();
  }

  /// Purge automatique, si elle est activée. Retourne le nombre de lots
  /// supprimés.
  Future<int> autoPurge(DateTime now) => _db.transaction(() async {
    final settings = await autoSettings();
    if (!settings.enabled) return 0;
    final lots = await autoPurgeCandidates(now, settings.months);
    final drinks = <String>{};
    for (final lot in lots) {
      // Le lot et son historique.
      await (_db.update(_db.movements)
            ..where((t) => t.lotId.equals(lot.id) & t.deletedAt.isNull()))
          .write(_ctx.deletionStamp());
      await (_db.update(
        _db.lots,
      )..where((t) => t.id.equals(lot.id))).write(_ctx.deletionStamp());
      drinks.add(lot.drinkId);
    }
    // La référence, si elle n'a plus aucun lot.
    for (final drinkId in drinks) {
      final remaining = await (_db.select(
        _db.lots,
      )..where((t) => t.drinkId.equals(drinkId) & t.deletedAt.isNull())).get();
      if (remaining.isEmpty) {
        await (_db.update(_db.drinks)
              ..where((t) => t.id.equals(drinkId) & t.deletedAt.isNull()))
            .write(_ctx.deletionStamp());
      }
    }
    return lots.length;
  });

  // ───────────────────────────────── Outils ─────────────────────────────────

  Future<void> _writeSetting(String key, Object value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: key,
          value: jsonEncode(value),
          updatedAt: _ctx.now(),
          updatedBy: _ctx.deviceId,
        ),
      );
}
