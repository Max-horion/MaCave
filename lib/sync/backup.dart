import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/exchange/csv_export.dart';
import '../data/local_store.dart';
import 'cave_file.dart';

/// Une sauvegarde : copie datée de la base et export CSV (CDC §8.4), trois
/// fichiers qui partagent le même horodatage dans leur nom.
class BackupSet {
  const BackupSet({required this.date, required this.database, this.size = 0});

  /// Date de la sauvegarde (heure locale, à la seconde).
  final DateTime date;

  /// `cave_<date>.sqlite`, de quoi tout restaurer.
  final File database;

  /// Taille de la base en octets, lue au moment de lister les sauvegardes :
  /// l'écran ne relit pas le fichier, qui peut avoir été supprimé entre-temps.
  final int size;

  File get stockCsv => File(_sibling('stock.csv'));
  File get historyCsv => File(_sibling('historique.csv'));

  /// Les fichiers présents (le CSV est un complément, il peut manquer).
  List<File> get files =>
      [database, stockCsv, historyCsv].where((f) => f.existsSync()).toList();

  String _sibling(String suffix) =>
      database.path.replaceFirst(RegExp(r'\.sqlite$'), '_$suffix');
}

/// Sauvegardes de la cave dans un dossier (CDC §8.4) : « Sauvegarder
/// maintenant », sauvegarde automatique, seules les dernières sont
/// conservées, restauration.
///
/// Les noms de fichiers sont un format : ne pas les traduire ni les changer,
/// sinon les sauvegardes existantes ne seraient plus reconnues.
class BackupService {
  BackupService({
    required this._db,
    required this._store,
    required this._folder,
    required this._tempFolder,
    this.defaultKeep = 3,
    this.every = const Duration(days: 1),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CaveDatabase _db;
  final LocalStore _store;
  final Future<Directory> Function() _folder;
  final Future<Directory> Function() _tempFolder;
  final DateTime Function() _clock;

  /// Nombre de sauvegardes conservées tant que l'utilisateur n'a pas choisi
  /// (voir [keepCount]).
  final int defaultKeep;

  /// Choix proposés pour le nombre de sauvegardes conservées.
  static const keepChoices = [1, 2, 3, 5, 10];

  /// Intervalle minimal entre deux sauvegardes automatiques.
  final Duration every;

  static const _lastAtKey = 'backup_last_at';
  static const _lastFingerprintKey = 'backup_last_fingerprint';
  static const _lastErrorKey = 'backup_last_error';
  static const _keepKey = 'backup_keep';

  static final _stampFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  static final _namePattern = RegExp(
    r'^cave_(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})\.sqlite$',
  );

  /// Date d'une sauvegarde d'après le nom de sa base (`cave_<date>.sqlite`),
  /// ou null si ce n'est pas une sauvegarde de l'application.
  static DateTime? dateOfName(String name) {
    final match = _namePattern.firstMatch(name);
    return match == null ? null : _stampFormat.tryParseStrict(match.group(1)!);
  }

  /// Noms des trois fichiers d'une sauvegarde, d'après le nom de sa base.
  static List<String> fileNamesOf(String databaseName) {
    final stem = databaseName.replaceFirst(RegExp(r'\.sqlite$'), '');
    return [databaseName, '${stem}_stock.csv', '${stem}_historique.csv'];
  }

  /// Évite deux sauvegardes simultanées (automatique et manuelle).
  Future<void> _queue = Future.value();

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// Dossier des sauvegardes (créé si besoin).
  Future<Directory> folder() async {
    final dir = await _folder();
    await dir.create(recursive: true);
    return dir;
  }

  /// Sauvegardes présentes dans le dossier, de la plus récente à la plus
  /// ancienne.
  Future<List<BackupSet>> list() async {
    final dir = await folder();
    final sets = <BackupSet>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final date = dateOfName(entity.uri.pathSegments.last);
      if (date == null) continue;
      try {
        sets.add(
          BackupSet(date: date, database: entity, size: await entity.length()),
        );
      } on FileSystemException {
        // Supprimée pendant la lecture du dossier : on l'ignore.
      }
    }
    sets.sort((a, b) => b.date.compareTo(a.date));
    return sets;
  }

  /// Sauvegarde immédiate, puis suppression des plus anciennes.
  Future<BackupSet> backupNow() => _exclusive(_backup);

  Future<BackupSet> _backup() async {
    final dir = await folder();
    var date = _clock();
    date = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );
    // Deux sauvegardes dans la même seconde : on décale la seconde.
    while (File(_databasePath(dir, date)).existsSync()) {
      date = date.add(const Duration(seconds: 1));
    }
    final set = BackupSet(date: date, database: File(_databasePath(dir, date)));
    final fingerprint = await contentFingerprint(_db);

    // La copie est faite dans le dossier temporaire de l'appli, puis copiée :
    // SQLite écrit plus sûrement dans un dossier privé que dans un dossier
    // partagé.
    final temp = await _tempFolder();
    final snapshot = '${temp.path}/sauvegarde-en-cours.sqlite';
    try {
      await snapshotDatabase(_db, snapshot);
      await File(snapshot).copy(set.database.path);
    } finally {
      final file = File(snapshot);
      if (file.existsSync()) file.deleteSync();
    }
    final csv = await exportCsv(_db);
    await set.stockCsv.writeAsString(csv.stock, encoding: utf8, flush: true);
    await set.historyCsv.writeAsString(
      csv.history,
      encoding: utf8,
      flush: true,
    );

    await _store.setString(_lastAtKey, date.toIso8601String());
    await _store.setString(_lastFingerprintKey, fingerprint);
    await _store.remove(_lastErrorKey);
    await _prune();
    return set;
  }

  /// Nombre de sauvegardes conservées (réglage propre à cet appareil).
  Future<int> keepCount() async {
    final value = int.tryParse(await _store.getString(_keepKey) ?? '');
    return value != null && value >= 1 ? value : defaultKeep;
  }

  /// Change le nombre de sauvegardes conservées et supprime aussitôt celles
  /// qui sont en trop : l'écran demande confirmation avant (voir
  /// [excessWith]).
  Future<void> setKeepCount(int count) => _exclusive(() async {
    if (count < 1) throw ArgumentError.value(count, 'count', 'Au moins 1');
    await _store.setString(_keepKey, '$count');
    await _prune();
  });

  /// Nombre de sauvegardes qui seraient supprimées en n'en gardant que
  /// [count].
  Future<int> excessWith(int count) async {
    final total = (await list()).length;
    return total > count ? total - count : 0;
  }

  /// Supprime les sauvegardes au-delà des [keepCount] plus récentes. Seuls
  /// les fichiers créés par l'application (nom reconnu) sont touchés.
  Future<void> _prune() async {
    final sets = await list();
    for (final old in sets.skip(await keepCount())) {
      for (final file in old.files) {
        await file.delete();
      }
    }
  }

  /// Sauvegarde automatique, si la dernière date de plus de [every] et si la
  /// cave a changé depuis. Ne lève jamais d'erreur : elle est mémorisée et
  /// affichée sur l'écran des sauvegardes ([lastError]).
  Future<BackupSet?> backupIfDue() => _exclusive(() async {
    try {
      final last = await lastBackupAt();
      if (last != null && _clock().difference(last) < every) return null;
      final fingerprint = await contentFingerprint(_db);
      if (fingerprint == await _store.getString(_lastFingerprintKey)) {
        return null;
      }
      if (await _isEmpty()) return null;
      return await _backup();
    } catch (e) {
      try {
        await _store.setString(_lastErrorKey, '$e');
      } catch (_) {
        // Rien à faire : la sauvegarde automatique ne doit pas gêner l'appli.
      }
      return null;
    }
  });

  /// Date de la dernière sauvegarde réussie sur cet appareil.
  Future<DateTime?> lastBackupAt() async {
    final value = await _store.getString(_lastAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  /// Erreur de la dernière sauvegarde automatique, s'il y en a eu une.
  Future<String?> lastError() => _store.getString(_lastErrorKey);

  /// Vérifie un fichier de sauvegarde avant de proposer sa restauration.
  CaveFileInfo inspect(String path) =>
      inspectCaveFile(path, currentVersion: _db.schemaVersion);

  /// Remplace la cave par le contenu du fichier [path] (une sauvegarde, ou un
  /// fichier choisi par l'utilisateur). La cave actuelle est d'abord
  /// sauvegardée : une restauration peut toujours être annulée en restaurant
  /// cette sauvegarde. Retourne cette sauvegarde de sécurité.
  Future<BackupSet> restore(String path) => _exclusive(() async {
    inspect(path);
    // Copie mise à niveau d'abord : la sauvegarde de sécurité ci-dessous
    // pourrait supprimer le fichier à restaurer (le plus ancien du dossier).
    final temp = await _tempFolder();
    final copy = '${temp.path}/restauration-en-cours.sqlite';
    try {
      await migratedCopy(path, copy);
      final safety = await _backup();
      await replaceDatabaseContents(_db, copy);
      return safety;
    } finally {
      final file = File(copy);
      if (file.existsSync()) file.deleteSync();
    }
  });

  String _databasePath(Directory dir, DateTime date) =>
      '${dir.path}/cave_${_stampFormat.format(date)}.sqlite';

  /// Cave neuve (aucune référence ni mouvement) : rien à sauvegarder.
  Future<bool> _isEmpty() async {
    final row = await _db
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM drinks) + '
          '(SELECT COUNT(*) FROM movements) AS n',
        )
        .getSingle();
    return row.read<int>('n') == 0;
  }
}
