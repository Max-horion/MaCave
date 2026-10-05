import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/database.dart';

// Opérations sur un fichier de base entier : copie cohérente, vérification
// d'un fichier reçu (sauvegarde, serveur), remplacement du contenu de la cave.
// Utilisées par les sauvegardes (lot 4a) et la synchronisation.

/// Ce qui empêche d'utiliser un fichier de base.
enum CaveFileProblem {
  /// Pas un fichier SQLite, ou fichier endommagé.
  unreadable,

  /// Base SQLite valide, mais pas une cave Ma Cave.
  notACave,

  /// Créée par une version plus récente de l'application (CDC §8.3).
  newerVersion,
}

class CaveFileException implements Exception {
  const CaveFileException(this.problem, [this.detail]);

  final CaveFileProblem problem;
  final String? detail;

  @override
  String toString() =>
      'CaveFileException(${problem.name}${detail == null ? '' : ', $detail'})';
}

/// Résumé d'un fichier de base valide.
class CaveFileInfo {
  const CaveFileInfo({
    required this.caveId,
    required this.schemaVersion,
    required this.drinks,
    required this.bottles,
  });

  final String caveId;
  final int schemaVersion;

  /// Références et bouteilles (non supprimées), pour la confirmation.
  final int drinks;
  final int bottles;
}

/// Vérifie un fichier de base sans le modifier : intégrité SQLite, version de
/// schéma au plus égale à [currentVersion], présence d'un `cave_id`.
///
/// Lève [CaveFileException] si le fichier ne peut pas être utilisé.
CaveFileInfo inspectCaveFile(String path, {required int currentVersion}) {
  if (!File(path).existsSync()) {
    throw CaveFileException(CaveFileProblem.unreadable, 'absent : $path');
  }
  final Database file;
  try {
    file = sqlite3.open(path, mode: OpenMode.readOnly);
  } on SqliteException catch (e) {
    throw CaveFileException(CaveFileProblem.unreadable, e.message);
  }
  try {
    final check = file.select('PRAGMA integrity_check');
    if (check.length != 1 || check.first.values.first != 'ok') {
      throw CaveFileException(
        CaveFileProblem.unreadable,
        check.map((r) => r.values.first).join(' ; '),
      );
    }
    final version = file.userVersion;
    final hasMeta = file.select(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'meta'",
    );
    if (version < 1 || hasMeta.isEmpty) {
      throw const CaveFileException(CaveFileProblem.notACave);
    }
    if (version > currentVersion) {
      throw CaveFileException(
        CaveFileProblem.newerVersion,
        'version $version > $currentVersion',
      );
    }
    final caveId = file.select("SELECT value FROM meta WHERE key = 'cave_id'");
    if (caveId.isEmpty) {
      throw const CaveFileException(CaveFileProblem.notACave);
    }
    final counts = file.select('''
      SELECT
        (SELECT COUNT(*) FROM drinks WHERE deleted_at IS NULL) AS drinks,
        (SELECT COALESCE(SUM(l.stock), 0) FROM lots l
           JOIN drinks d ON d.id = l.drink_id
           WHERE l.deleted_at IS NULL AND d.deleted_at IS NULL) AS bottles
    ''').first;
    return CaveFileInfo(
      caveId: caveId.first['value'] as String,
      schemaVersion: version,
      drinks: counts['drinks'] as int,
      bottles: counts['bottles'] as int,
    );
  } on SqliteException catch (e) {
    throw CaveFileException(CaveFileProblem.unreadable, e.message);
  } finally {
    file.close();
  }
}

/// Copie cohérente de la base dans [path] (`VACUUM INTO`), sans arrêter
/// l'application : on n'envoie ni ne copie jamais le fichier en cours
/// d'utilisation (docs/architecture.md §4).
Future<void> snapshotDatabase(CaveDatabase db, String path) async {
  final target = File(path);
  if (target.existsSync()) target.deleteSync();
  await db.customStatement('VACUUM INTO ?', [path]);
}

/// Copie [source] dans [copyPath] et la met à niveau vers le schéma actuel
/// (migrations drift habituelles). Le fichier d'origine n'est pas modifié.
/// [source] doit avoir été vérifié par [inspectCaveFile].
Future<void> migratedCopy(String source, String copyPath) async {
  final copy = File(copyPath);
  if (copy.existsSync()) copy.deleteSync();
  await File(source).copy(copyPath);
  // Une seconde instance de CaveDatabase, sur un autre fichier : voulu ici,
  // on coupe l'avertissement de drift le temps de la créer.
  final warned = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = CaveDatabase(NativeDatabase(copy));
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = warned;
  try {
    // La première requête ouvre la base, ce qui lance les migrations.
    await db.customSelect('SELECT 1').get();
  } finally {
    await db.close();
  }
}

/// Remplace tout le contenu de la cave par celui du fichier [source], en une
/// seule transaction : en cas d'erreur, la cave reste intacte.
///
/// [source] doit être au schéma actuel (voir [migratedCopy]). La table `meta`
/// est remplacée aussi : la cave prend l'identité (`cave_id`) du fichier.
Future<void> replaceDatabaseContents(CaveDatabase db, String source) async {
  // Enfants avant parents, pour respecter les clés étrangères à la suppression ;
  // l'ordre inverse sert à l'insertion.
  final tables = <TableInfo<Table, dynamic>>[
    db.movements,
    db.lots,
    db.drinkCharacteristics,
    db.drinks,
    db.characteristics,
    db.characteristicFamilies,
    db.drinkTypes,
    db.settings,
    db.meta,
  ];
  // ATTACH est impossible dans une transaction : on le fait avant.
  await db.customStatement('ATTACH DATABASE ? AS source', [source]);
  try {
    await db.transaction(() async {
      for (final table in tables) {
        await db.customStatement('DELETE FROM main."${table.actualTableName}"');
      }
      for (final table in tables.reversed) {
        // Colonnes nommées : leur ordre peut différer d'une base à l'autre.
        final columns = table.$columns.map((c) => '"${c.name}"').join(', ');
        final name = table.actualTableName;
        await db.customStatement(
          'INSERT INTO main."$name" ($columns) SELECT $columns FROM source."$name"',
        );
      }
      await db.rebuildSearchIndex();
    });
  } finally {
    await db.customStatement('DETACH DATABASE source');
  }
  // Les écrans en direct ne voient pas les requêtes SQL brutes : on les
  // prévient que tout a changé.
  db.markTablesUpdated(db.allTables);
}
