import 'dart:io';

import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/local_store.dart';
import '../data/write_context.dart';
import 'backup.dart';
import 'cave_file.dart';
import 'merge.dart';
import 'webdav.dart';

// Cycle de synchronisation avec le serveur WebDAV (docs/architecture.md §4) :
// télécharger si le fichier a changé, vérifier, fusionner, envoyer si la base
// locale a du nouveau, sans jamais écraser le fichier d'un autre appareil.
//
// La base locale n'est modifiée que par la fusion, en une transaction : une
// erreur réseau ne peut pas l'abîmer (CDC §8.3).

/// Pourquoi une synchronisation n'a pas abouti. L'écran (lot 4d) en déduit le
/// message et l'action proposée (CDC §8.3).
enum SyncProblem {
  /// Serveur injoignable ou pas de réseau : « Réessayer ».
  unreachable,

  /// Identifiants refusés : ouvrir les paramètres de synchronisation.
  unauthorized,

  /// Dossier introuvable sur le serveur : paramètres de synchronisation.
  folderNotFound,

  /// Espace insuffisant sur le serveur.
  insufficientStorage,

  /// Réponse inattendue du serveur.
  server,

  /// Le fichier du serveur vient d'une version plus récente de l'appli :
  /// synchronisation suspendue, mettre l'appli à jour.
  newerVersion,

  /// Le serveur contient une autre cave : l'utilisateur choisit
  /// ([SyncService.useServerCave] ou [SyncService.replaceServerCave]).
  otherCave,

  /// Le fichier a changé pendant chaque essai : nouvelle tentative plus tard.
  conflict,

  /// Coffre sécurisé inutilisable (sur PC : pas de trousseau de session, ou
  /// accès refusé) : le mot de passe ne peut être ni rangé ni relu.
  secretStore,

  /// Adresse enregistrée en `http://` hors du réseau local (refusée depuis la
  /// 1.0.1) : la corriger dans les paramètres de synchronisation.
  insecureAddress,
}

class SyncException implements Exception {
  const SyncException(this.problem, [this.detail]);

  final SyncProblem problem;
  final String? detail;

  @override
  String toString() =>
      'SyncException(${problem.name}${detail == null ? '' : ', $detail'})';
}

/// Bilan d'une synchronisation réussie.
class SyncReport {
  const SyncReport({this.merge, this.uploaded = false, this.setAsideAs});

  /// Résultat de la fusion, si le fichier du serveur avait changé.
  final MergeResult? merge;

  /// La base de l'appareil a été envoyée au serveur.
  final bool uploaded;

  /// Fichier du serveur illisible : nom sous lequel il a été mis de côté sur
  /// le serveur avant d'être remplacé par la base de l'appareil (message à
  /// afficher).
  final String? setAsideAs;
}

/// Synchronisation de la cave avec un dossier WebDAV.
class SyncService {
  SyncService({
    required this._db,
    required this._ctx,
    required this._store,
    required this._client,
    required this._tempFolder,
    this.fileName = 'cave.sqlite',
    this.maxAttempts = 3,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CaveDatabase _db;
  final WriteContext _ctx;
  final LocalStore _store;
  final WebDavClient _client;
  final Future<Directory> Function() _tempFolder;
  final DateTime Function() _clock;

  /// Nom du fichier de la cave sur le serveur.
  final String fileName;

  /// Essais d'un cycle quand le fichier change entre la lecture et l'envoi.
  final int maxAttempts;

  /// ETag du fichier du serveur à la dernière synchronisation.
  static const _etagKey = 'sync_etag';

  /// Empreinte de la base locale quand elle était identique au serveur.
  static const _fingerprintKey = 'sync_fingerprint';

  static final _stampFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');

  /// Évite deux synchronisations simultanées (bouton, ouverture…).
  Future<void> _queue = Future.value();

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// Oublie l'état de la synchronisation (changement de serveur ou de
  /// dossier) : la prochaine repartira d'un téléchargement complet.
  Future<void> forget() async {
    await _store.remove(_etagKey);
    await _store.remove(_fingerprintKey);
  }

  /// Un cycle complet. Lève [SyncException] en cas d'échec ; la base locale
  /// reste alors telle qu'elle était, ou fusionnée si seul l'envoi a échoué.
  Future<SyncReport> sync() => _exclusive(() async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await _guard(_cycle);
      } on _Retry {
        if (attempt >= maxAttempts) {
          throw const SyncException(
            SyncProblem.conflict,
            'fichier modifié sur le serveur à chaque essai',
          );
        }
      }
    }
  });

  Future<SyncReport> _cycle() async {
    final temp = await _tempFolder();
    final received = File('${temp.path}/synchro-recue.sqlite');
    final upgraded = '${temp.path}/synchro-recue-a-jour.sqlite';
    try {
      // 1. Télécharger si le fichier a changé depuis la dernière fois.
      final known = await _store.getString(_etagKey);
      final got = await _client.download(
        fileName,
        received,
        ifNoneMatch: known,
        maxBytes: maxCaveFileBytes,
      );

      switch (got.status) {
        case DownloadStatus.absent:
          // Pas encore de cave sur le serveur (ou supprimée) : on envoie.
          return SyncReport(uploaded: await _upload(null));

        case DownloadStatus.notModified:
          if (!await _changedSinceSync()) return const SyncReport();
          return SyncReport(uploaded: await _upload(known));

        case DownloadStatus.downloaded:
          // 2. Vérifier le fichier reçu.
          final CaveFileInfo info;
          try {
            info = inspectCaveFile(
              received.path,
              currentVersion: _db.schemaVersion,
            );
          } on CaveFileException catch (e) {
            if (e.problem == CaveFileProblem.newerVersion) {
              throw SyncException(SyncProblem.newerVersion, e.detail);
            }
            // Illisible : jamais utilisé, mis de côté puis remplacé.
            final aside =
                '$fileName.endommage-${_stampFormat.format(_clock())}';
            await _client.move(fileName, aside);
            return SyncReport(uploaded: await _upload(null), setAsideAs: aside);
          }
          if (info.caveId != await _db.caveId()) {
            throw const SyncException(SyncProblem.otherCave);
          }
          final etag = got.etag ?? await _client.etag(fileName);
          if (etag == null) {
            throw const SyncException(
              SyncProblem.server,
              'le serveur ne fournit pas d\'ETag',
            );
          }

          // 3. Fusionner.
          await migratedCopy(received.path, upgraded);
          final merge = await mergeCaveFile(_db, _ctx, upgraded);
          // L'ETag est retenu tout de suite : si l'envoi échoue, le
          // prochain cycle n'aura pas à retélécharger le même fichier.
          await _store.setString(_etagKey, etag);
          if (!merge.localAhead) {
            await _rememberSynced();
            return SyncReport(merge: merge);
          }
          // 4. Envoyer ce que le serveur n'a pas.
          return SyncReport(merge: merge, uploaded: await _upload(etag));
      }
    } finally {
      for (final path in [received.path, upgraded]) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }
    }
  }

  /// La base locale a-t-elle du nouveau que le serveur n'a pas reçu ?
  Future<bool> hasUnsentChanges() => _changedSinceSync();

  /// La base locale a-t-elle changé depuis qu'elle était identique au
  /// serveur ?
  Future<bool> _changedSinceSync() async =>
      await contentFingerprint(_db) != await _store.getString(_fingerprintKey);

  Future<void> _rememberSynced() async =>
      _store.setString(_fingerprintKey, await contentFingerprint(_db));

  /// Envoie une copie de la base locale. [ifMatch] : ETag du fichier sur
  /// lequel elle a été fusionnée ; null s'il ne doit pas y avoir de fichier.
  Future<bool> _upload(String? ifMatch) async {
    final temp = await _tempFolder();
    final snapshot = '${temp.path}/synchro-envoi.sqlite';
    // Empreinte prise avant la copie : une modification faite pendant l'envoi
    // sera envoyée au cycle suivant.
    final fingerprint = await contentFingerprint(_db);
    try {
      await snapshotDatabase(_db, snapshot);
      String? etag;
      try {
        etag = await _client.upload(fileName, File(snapshot), ifMatch: ifMatch);
      } on WebDavException catch (e) {
        if (e.problem != WebDavProblem.notFound || ifMatch != null) rethrow;
        // Premier envoi dans un dossier qui n'existe pas encore.
        await _client.createFolder();
        etag = await _client.upload(fileName, File(snapshot));
      }
      if (etag == null) {
        // Envoi fait, mais ETag inconnu : la prochaine fois, téléchargement
        // complet (la fusion de notre propre fichier ne change rien).
        await _store.remove(_etagKey);
      } else {
        await _store.setString(_etagKey, etag);
      }
      await _store.setString(_fingerprintKey, fingerprint);
      return true;
    } finally {
      final file = File(snapshot);
      if (file.existsSync()) file.deleteSync();
    }
  }

  /// « Utiliser la cave du serveur » (CDC §8.2) : la cave de l'appareil est
  /// remplacée par celle du serveur, après une sauvegarde automatique (par
  /// [backups]). Retourne cette sauvegarde de sécurité.
  Future<BackupSet> useServerCave(BackupService backups) => _exclusive(
    () => _guard(() async {
      final temp = await _tempFolder();
      final received = File('${temp.path}/synchro-serveur.sqlite');
      try {
        final got = await _client.download(
          fileName,
          received,
          maxBytes: maxCaveFileBytes,
        );
        if (got.status != DownloadStatus.downloaded) {
          throw const SyncException(
            SyncProblem.folderNotFound,
            'pas de cave sur le serveur',
          );
        }
        final etag = got.etag ?? await _client.etag(fileName);
        try {
          inspectCaveFile(received.path, currentVersion: _db.schemaVersion);
        } on CaveFileException catch (e) {
          throw SyncException(
            e.problem == CaveFileProblem.newerVersion
                ? SyncProblem.newerVersion
                : SyncProblem.server,
            '$e',
          );
        }
        final safety = await backups.restore(received.path);
        if (etag == null) {
          await _store.remove(_etagKey);
        } else {
          await _store.setString(_etagKey, etag);
        }
        await _rememberSynced();
        return safety;
      } finally {
        if (received.existsSync()) received.deleteSync();
      }
    }),
  );

  /// « Remplacer la cave du serveur par celle-ci » (CDC §8.2) : celle du
  /// serveur est d'abord mise de côté sur le serveur (renommée), puis la cave
  /// de l'appareil est envoyée. Retourne le nom du fichier mis de côté.
  Future<String> replaceServerCave() => _exclusive(
    () => _guard(() async {
      final aside = '$fileName.remplacee-${_stampFormat.format(_clock())}';
      await _client.move(fileName, aside);
      try {
        await _upload(null);
      } on WebDavException catch (e) {
        // Quelqu'un a envoyé un fichier entre-temps : on ne l'écrase pas.
        if (e.problem == WebDavProblem.preconditionFailed) {
          throw const SyncException(SyncProblem.conflict);
        }
        rethrow;
      }
      return aside;
    }),
  );

  /// Traduit les erreurs du client WebDAV en [SyncException] ; un « 412 »
  /// devient [_Retry] (le cycle recommence).
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on WebDavException catch (e) {
      throw switch (e.problem) {
        WebDavProblem.preconditionFailed => const _Retry(),
        WebDavProblem.unreachable => SyncException(
          SyncProblem.unreachable,
          e.detail,
        ),
        WebDavProblem.unauthorized => SyncException(
          SyncProblem.unauthorized,
          e.detail,
        ),
        WebDavProblem.notFound => SyncException(
          SyncProblem.folderNotFound,
          e.detail,
        ),
        WebDavProblem.insufficientStorage => SyncException(
          SyncProblem.insufficientStorage,
          e.detail,
        ),
        WebDavProblem.server => SyncException(SyncProblem.server, e.detail),
      };
    } on OtherCaveException {
      throw const SyncException(SyncProblem.otherCave);
    }
  }
}

/// Le fichier a changé sur le serveur entre la lecture et l'envoi.
class _Retry implements Exception {
  const _Retry();
}
