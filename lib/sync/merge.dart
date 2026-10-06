import 'package:drift/drift.dart';

import '../data/cave_repository.dart';
import '../data/database.dart';
import '../data/history_purge.dart';
import '../data/write_context.dart';

// Moteur de fusion de la synchronisation (docs/architecture.md §4, étape 3) :
// intègre dans la base locale le contenu d'un autre fichier de la même cave
// (celui du serveur), en une seule transaction.
//
// Règles :
// - fiches (types, familles, caractéristiques, références, liens, lots) et
//   réglages : ligne par ligne, la plus récente l'emporte (`updated_at`, puis
//   `updated_by` en cas d'égalité) ; une suppression est une modification
//   comme une autre ;
// - mouvements : ajoutés s'ils sont inconnus (UUID), donc additionnés sans
//   perte ni doublon. Un mouvement n'est jamais modifié, sauf son annulation :
//   une annulation l'emporte toujours, quelles que soient les horloges ;
// - lots en double (même référence, millésime et volume créés sur deux
//   appareils) : regroupés, les mouvements rattachés au lot conservé ;
// - purge de l'historique (history_purge.dart) : la date la plus récente des
//   deux bases s'applique ; les mouvements antérieurs ne sont jamais repris ;
// - `meta` n'est jamais fusionnée ; le cache `stock` et l'index de recherche
//   sont recalculés.
//
// Les règles sont symétriques : deux appareils qui fusionnent chacun le
// fichier de l'autre obtiennent le même contenu.

/// Le fichier n'est pas la même cave : on ne fusionne jamais (CDC §8.2).
class OtherCaveException implements Exception {
  const OtherCaveException({required this.localId, required this.otherId});

  final String localId;
  final String otherId;

  @override
  String toString() => 'OtherCaveException(locale $localId, fichier $otherId)';
}

/// Bilan d'une fusion.
class MergeResult {
  const MergeResult({
    required this.applied,
    required this.regroupedLots,
    required this.localAhead,
  });

  /// Lignes ajoutées ou modifiées dans la base locale, par table.
  final Map<String, int> applied;

  /// Lots en double supprimés (leurs mouvements ont rejoint le lot conservé).
  final int regroupedLots;

  /// La base locale contient des modifications absentes du fichier : il faut
  /// l'envoyer au serveur (étape 4 du cycle).
  final bool localAhead;

  /// La fusion a modifié la base locale.
  bool get changedLocal =>
      regroupedLots > 0 || applied.values.any((n) => n > 0);
}

/// Fusionne le fichier [source] dans [db].
///
/// [source] doit avoir été vérifié (`inspectCaveFile`) et mis au schéma actuel
/// (`migratedCopy`). Lève [OtherCaveException] si ce n'est pas la même cave.
/// En cas d'erreur, la base locale reste intacte.
Future<MergeResult> mergeCaveFile(
  CaveDatabase db,
  WriteContext ctx,
  String source,
) async {
  // Parents avant enfants : une ligne ajoutée trouve toujours sa référence.
  final tables = <TableInfo<Table, dynamic>>[
    db.drinkTypes,
    db.characteristicFamilies,
    db.characteristics,
    db.drinks,
    db.drinkCharacteristics,
    db.lots,
    db.movements,
    db.settings,
  ];

  // ATTACH est impossible dans une transaction : on le fait avant.
  await db.customStatement('ATTACH DATABASE ? AS source', [source]);
  try {
    final result = await db.transaction(() async {
      final localId = await db.caveId();
      final otherRow = await db
          .customSelect("SELECT value FROM source.meta WHERE key = 'cave_id'")
          .getSingleOrNull();
      final otherId = otherRow?.read<String>('value');
      if (otherId != localId) {
        throw OtherCaveException(localId: localId, otherId: otherId ?? '');
      }

      // Purge de l'historique : la plus récente des deux bases s'applique.
      final purge = HistoryPurge(db, ctx);
      final localPurge = await purge.purgedBefore();
      final otherPurge = await purge.purgedBefore(schema: 'source');
      final purgedBefore = [
        ?localPurge,
        ?otherPurge,
      ].fold<int?>(null, (a, b) => a == null || b > a ? b : a);

      // Avant la fusion : la base locale a-t-elle quelque chose de plus ?
      var localAhead = false;
      for (final table in tables) {
        if (await _localAhead(db, table, purgedBefore: purgedBefore)) {
          localAhead = true;
          break;
        }
      }

      final applied = <String, int>{};
      for (final table in tables) {
        applied[table.actualTableName] = await _mergeTable(
          db,
          table,
          purgedBefore: purgedBefore,
        );
      }

      if (purgedBefore != null) {
        // Purge faite par l'autre appareil : appliquée ici aussi. La date est
        // réécrite si la fusion des réglages l'a fait reculer.
        if (localPurge == null || purgedBefore > localPurge) {
          await purge.applyPurge(purgedBefore);
        }
        await purge.recordPurgeDate(purgedBefore);
        // Reports de stock ou date réécrite : peut-être absents du fichier.
        if (!localAhead) {
          localAhead =
              await _localAhead(db, db.movements, purgedBefore: purgedBefore) ||
              await _localAhead(db, db.settings);
        }
      }

      final regrouped = await _regroupDuplicateLots(db, ctx);
      // Le regroupement est une modification locale, à envoyer elle aussi.
      if (regrouped > 0) localAhead = true;

      await CaveRepository(db, ctx).recomputeAllStocks();
      await db.rebuildSearchIndex();
      return MergeResult(
        applied: applied,
        regroupedLots: regrouped,
        localAhead: localAhead,
      );
    });
    // Les écrans en direct ne voient pas les requêtes SQL brutes.
    if (result.changedLocal) db.markTablesUpdated(db.allTables);
    return result;
  } finally {
    await db.customStatement('DETACH DATABASE source');
  }
}

/// Clé de la table : `id` pour les tables synchronisées, `key` pour `settings`.
String _keyOf(TableInfo<Table, dynamic> table) => table.$primaryKey.single.name;

/// Condition « la ligne [a] est plus récente que la ligne [b] ».
String _newer(String a, String b) =>
    '($a.updated_at > $b.updated_at OR '
    '($a.updated_at = $b.updated_at AND $a.updated_by > $b.updated_by))';

/// Condition « la ligne [winner] remplace la ligne [loser] », selon la table.
String _wins(TableInfo<Table, dynamic> table, String winner, String loser) {
  if (table.actualTableName == 'movements') {
    // Seule une annulation peut modifier un mouvement connu.
    return '($winner.deleted_at IS NOT NULL AND $loser.deleted_at IS NULL)';
  }
  return _newer(winner, loser);
}

/// Copie dans la base locale les lignes du fichier inconnues ou gagnantes.
/// Retourne le nombre de lignes ajoutées ou modifiées.
Future<int> _mergeTable(
  CaveDatabase db,
  TableInfo<Table, dynamic> table, {
  int? purgedBefore,
}) {
  final name = table.actualTableName;
  final key = _keyOf(table);
  final columns = table.$columns.map((c) => c.name).toList();
  final list = columns.map((c) => '"$c"').join(', ');
  // Le stock en cache n'est pas une donnée de la fiche : il est recalculé.
  final updates = columns
      .where((c) => c != key && !(name == 'lots' && c == 'stock'))
      .map((c) => '"$c" = excluded."$c"')
      .join(', ');
  // Mouvements purgés : jamais repris. « WHERE true » : exigé par SQLite
  // pour un INSERT … SELECT … ON CONFLICT.
  final filter = name == 'movements' && purgedBefore != null
      ? 'occurred_at >= $purgedBefore'
      : 'true';
  return db.customUpdate(
    'INSERT INTO main."$name" AS t ($list) '
    'SELECT $list FROM source."$name" WHERE $filter '
    'ON CONFLICT("$key") DO UPDATE SET $updates '
    'WHERE ${_wins(table, 'excluded', 't')}',
  );
}

/// La base locale a-t-elle, dans cette table, une ligne absente du fichier ou
/// qui y gagnerait ?
Future<bool> _localAhead(
  CaveDatabase db,
  TableInfo<Table, dynamic> table, {
  int? purgedBefore,
}) async {
  final name = table.actualTableName;
  final key = _keyOf(table);
  // Mouvements antérieurs à la purge : voués à disparaître, pas à être
  // envoyés.
  final purged = name == 'movements' && purgedBefore != null
      ? 'l.occurred_at >= $purgedBefore AND '
      : '';
  final row = await db
      .customSelect(
        'SELECT EXISTS (SELECT 1 FROM main."$name" l '
        'LEFT JOIN source."$name" r ON r."$key" = l."$key" '
        'WHERE $purged(r."$key" IS NULL OR ${_wins(table, 'l', 'r')})) '
        'AS ahead',
      )
      .getSingle();
  return row.read<bool>('ahead');
}

/// Regroupe les lots actifs en double (même référence, millésime et volume).
///
/// Le lot conservé est le plus ancien (`created_at`, puis `id`) : tous les
/// appareils font le même choix, et leurs bases convergent. Les mouvements des
/// autres lots lui sont rattachés ; ces lots sont supprimés (logiquement).
/// Retourne le nombre de lots supprimés.
Future<int> _regroupDuplicateLots(CaveDatabase db, WriteContext ctx) async {
  final lots =
      await (db.select(db.lots)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(expression: t.createdAt),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .get();
  final kept = <(String, int?, int), Lot>{};
  var removed = 0;
  for (final lot in lots) {
    final group = (lot.drinkId, lot.vintage, lot.volumeMl);
    final keeper = kept[group];
    if (keeper == null) {
      kept[group] = lot;
      continue;
    }
    final now = ctx.now();
    // Rattachement déterministe : pas d'estampille, chaque appareil fait le
    // même et un mouvement garde sa date de modification d'origine.
    await (db.update(db.movements)..where((t) => t.lotId.equals(lot.id))).write(
      MovementsCompanion(lotId: Value(keeper.id)),
    );
    await (db.update(db.lots)..where((t) => t.id.equals(lot.id))).write(
      LotsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        updatedBy: Value(ctx.deviceId),
      ),
    );
    // Un code-barres connu seulement du lot supprimé n'est pas perdu.
    if (keeper.barcode == null && lot.barcode != null) {
      await (db.update(db.lots)..where((t) => t.id.equals(keeper.id))).write(
        LotsCompanion(
          barcode: Value(lot.barcode),
          updatedAt: Value(now),
          updatedBy: Value(ctx.deviceId),
        ),
      );
      kept[group] = keeper.copyWith(barcode: Value(lot.barcode));
    }
    removed++;
  }
  return removed;
}
