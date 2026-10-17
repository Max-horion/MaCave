import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/local_store.dart';
import '../data/write_context.dart';
import 'backup.dart';
import 'providers.dart';
import 'server_backups.dart';
import 'sync_service.dart';
import 'sync_settings.dart';
import 'webdav.dart';

// Pilote la synchronisation pendant que l'appli est ouverte (pas de tâche de
// fond en V1, décision du 05/10/2026) : quand la lancer, quoi afficher,
// quand réessayer. La mécanique d'un cycle est dans sync_service.dart.

/// État affiché par l'indicateur et l'écran Synchronisation (CDC §8.3).
enum SyncStatus {
  /// Mode local : pas de synchronisation.
  off,

  /// Dernière synchronisation réussie.
  synced,

  /// Synchronisation en cours.
  syncing,

  /// Pas de réseau : les modifications attendent, sans message.
  waiting,

  /// Synchronisation automatique désactivée : des modifications attendent
  /// « Synchroniser maintenant ».
  pending,

  /// Échec : voir [SyncState.problem] ; nouvelles tentatives automatiques.
  error,
}

class SyncState {
  const SyncState({
    required this.status,
    this.lastSuccess,
    this.problem,
    this.detail,
    this.errorSince,
    this.notice,
    this.automatic = true,
  });

  static const off = SyncState(status: SyncStatus.off);

  final SyncStatus status;
  final DateTime? lastSuccess;

  /// Cause de l'erreur en cours (statut [SyncStatus.error]).
  final SyncProblem? problem;
  final String? detail;

  /// Début de la série d'erreurs : au-delà de 24 h, l'indicateur passe au
  /// rouge (à la place de la notification du CDC §8.3).
  final DateTime? errorSince;

  /// Fichier endommagé du serveur mis de côté : nom du fichier, à signaler.
  final String? notice;

  /// Synchronisation automatique (ouverture, modification, retour du réseau)
  /// ; sinon seulement « Synchroniser maintenant » (CDC §7).
  final bool automatic;

  bool get enabled => status != SyncStatus.off;

  /// L'erreur dure depuis plus de 24 heures.
  bool longError(DateTime now) =>
      status == SyncStatus.error &&
      errorSince != null &&
      now.difference(errorSince!) > const Duration(hours: 24);

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSuccess,
    SyncProblem? problem,
    String? detail,
    DateTime? errorSince,
    String? notice,
    bool? automatic,
  }) => SyncState(
    status: status ?? this.status,
    lastSuccess: lastSuccess ?? this.lastSuccess,
    problem: problem,
    detail: detail,
    errorSince: errorSince,
    notice: notice,
    automatic: automatic ?? this.automatic,
  );
}

/// Une ligne du journal technique (CDC §8.3).
class SyncLogEntry {
  const SyncLogEntry(this.at, this.problem, this.detail);

  final DateTime at;
  final SyncProblem problem;
  final String? detail;

  Map<String, Object?> toJson() => {
    'at': at.toIso8601String(),
    'problem': problem.name,
    'detail': detail,
  };

  static SyncLogEntry? fromJson(Object? json) {
    if (json is! Map) return null;
    final at = DateTime.tryParse('${json['at']}');
    final problem = SyncProblem.values.asNameMap()[json['problem']];
    if (at == null || problem == null) return null;
    final detail = json['detail'];
    return SyncLogEntry(at, problem, detail is String ? detail : null);
  }
}

/// Résultat de l'activation de la synchronisation.
enum ActivationResult {
  /// Synchronisation active (cave envoyée ou fusionnée avec celle du serveur).
  done,

  /// Le serveur contient une autre cave : l'utilisateur doit choisir
  /// ([SyncController.resolveOtherCave]).
  otherCave,
}

/// Tout ce dont le contrôleur a besoin, regroupé pour les tests.
class SyncEnvironment {
  const SyncEnvironment({
    required this.db,
    required this.ctx,
    required this.store,
    required this.settings,
    required this.backups,
    required this.tempFolder,
    required this.isOnline,
    this.onlineChanges = const Stream.empty(),
    this.clock = DateTime.now,
    this.debounce = const Duration(seconds: 10),
    this.retryDelays = const [
      Duration(minutes: 1),
      Duration(minutes: 5),
      Duration(minutes: 30),
    ],
  });

  final CaveDatabase db;
  final WriteContext ctx;
  final LocalStore store;
  final SyncSettingsStore settings;
  final BackupService backups;
  final Future<Directory> Function() tempFolder;

  /// Le téléphone a-t-il un réseau ? (connectivity_plus)
  final Future<bool> Function() isOnline;

  /// Retour du réseau : relance une synchronisation en attente.
  final Stream<bool> onlineChanges;
  final DateTime Function() clock;

  /// Délai après une modification, pour regrouper une série de saisies.
  final Duration debounce;

  /// Nouvelles tentatives après une erreur, puis à chaque ouverture.
  final List<Duration> retryDelays;
}

class SyncController extends Notifier<SyncState> {
  late SyncEnvironment _env;

  /// Serveur configuré (null en mode local).
  _Connection? _current;

  /// Activation en attente du choix de l'utilisateur (autre cave).
  ({SyncSettings settings, String password, _Connection connection})? _pending;

  Timer? _debounceTimer;
  Timer? _retryTimer;
  var _retryIndex = 0;
  var _running = false;

  /// La cave a été modifiée pendant une synchronisation.
  var _changedWhileRunning = false;
  StreamSubscription<bool>? _onlineSubscription;

  static const _lastSuccessKey = 'sync_last_success';
  static const _errorSinceKey = 'sync_error_since';
  static const _logKey = 'sync_log';
  static const _mirroredKey = 'sync_backup_mirrored';

  /// « false » : synchronisation automatique désactivée sur cet appareil.
  static const automaticKey = 'sync_automatic';

  /// Lignes conservées dans le journal.
  static const logSize = 20;

  @override
  SyncState build() {
    _env = ref.watch(syncEnvironmentProvider);
    _onlineSubscription = _env.onlineChanges.listen((online) {
      if (online && state.automatic && state.status == SyncStatus.waiting) {
        syncNow();
      }
    });
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _retryTimer?.cancel();
      _onlineSubscription?.cancel();
      _current?.client.close();
      _pending?.connection.client.close();
    });
    return SyncState.off;
  }

  /// À l'ouverture de l'appli : charge les paramètres et synchronise.
  Future<void> start() async {
    final ({SyncSettings settings, String password})? saved;
    try {
      saved = await _env.settings.load();
    } on SyncException catch (e) {
      // Coffre inutilisable : la cave reste utilisable, l'erreur s'affiche.
      state = SyncState(
        status: SyncStatus.error,
        problem: e.problem,
        detail: e.detail,
      );
      return;
    }
    if (saved == null) {
      state = SyncState.off;
      return;
    }
    _current?.client.close();
    _current = null;
    try {
      _current = _open(saved.settings, saved.password);
    } on FormatException catch (e) {
      // Adresse enregistrée devenue inutilisable (http:// refusé depuis la
      // 1.0.1) : la cave reste utilisable, l'erreur s'affiche.
      state = SyncState(
        status: SyncStatus.error,
        problem: e is InsecureAddressException
            ? SyncProblem.insecureAddress
            : SyncProblem.folderNotFound,
        detail: e.message,
      );
      return;
    }
    final automatic = await _env.store.getString(automaticKey) != 'false';
    state = SyncState(
      status: SyncStatus.synced,
      lastSuccess: await _readDate(_lastSuccessKey),
      errorSince: await _readDate(_errorSinceKey),
      automatic: automatic,
    );
    _retryIndex = 0;
    if (automatic) await syncNow();
  }

  /// Retour de l'appli au premier plan : synchronisation si elle est
  /// automatique.
  Future<void> resumed() async {
    if (state.automatic) await syncNow();
  }

  /// Active ou désactive la synchronisation automatique sur cet appareil ;
  /// la réactiver synchronise aussitôt.
  Future<void> setAutomatic(bool automatic) async {
    await _env.store.setString(automaticKey, '$automatic');
    _debounceTimer?.cancel();
    if (!automatic) _retryTimer?.cancel();
    state = state.copyWith(
      status: state.status,
      problem: state.problem,
      detail: state.detail,
      errorSince: state.errorSince,
      notice: state.notice,
      automatic: automatic,
    );
    if (automatic) await syncNow();
  }

  /// La cave a été modifiée : synchronisation un peu plus tard, pour
  /// regrouper une série de saisies. Sans synchronisation automatique,
  /// l'état passe « en attente » jusqu'au prochain « Synchroniser
  /// maintenant ».
  void localChanged() {
    if (_current == null) return;
    if (_running) {
      // La copie envoyée a peut-être été prise avant : vu à la fin.
      _changedWhileRunning = true;
      return;
    }
    if (!state.automatic) {
      if (state.status == SyncStatus.synced) {
        state = state.copyWith(status: SyncStatus.pending);
      }
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_env.debounce, syncNow);
  }

  /// L'appli passe en arrière-plan : on n'attend pas la fin du délai.
  Future<void> paused() async {
    if (_debounceTimer?.isActive ?? false) await syncNow();
  }

  /// « Synchroniser maintenant », ouverture, modification, retour du réseau.
  Future<void> syncNow() async {
    _debounceTimer?.cancel();
    final current = _current;
    if (current == null || _running) return;
    _running = true;
    _retryTimer?.cancel();
    var succeeded = false;
    try {
      if (!await _env.isOnline()) {
        // Pas une erreur : la synchronisation reprendra avec le réseau.
        state = state.copyWith(
          status: SyncStatus.waiting,
          errorSince: state.errorSince,
        );
        return;
      }
      state = state.copyWith(
        status: SyncStatus.syncing,
        problem: state.problem,
        errorSince: state.errorSince,
      );
      final report = await current.service.sync();
      await _succeeded(notice: report.setAsideAs);
      await _mirrorBackups(current);
      succeeded = true;
    } on SyncException catch (e) {
      await _failed(e);
    } catch (e) {
      await _failed(SyncException(SyncProblem.server, '$e'));
    } finally {
      _running = false;
    }
    if (succeeded) await _afterSync(current);
  }

  /// Une modification faite pendant la synchronisation n'est peut-être pas
  /// partie (copie prise avant) : elle est envoyée après le délai habituel,
  /// seulement s'il reste vraiment quelque chose à envoyer (la fusion
  /// elle-même modifie aussi la base). Sans cela, elle attendait le
  /// prochain déclencheur (ouverture, retour au premier plan…).
  Future<void> _afterSync(_Connection connection) async {
    if (!_changedWhileRunning) return;
    _changedWhileRunning = false;
    if (await connection.service.hasUnsentChanges()) localChanged();
  }

  /// Active la synchronisation avec ces paramètres : premier cycle complet
  /// (envoi de la cave si le serveur n'en a pas). Les paramètres ne sont
  /// enregistrés qu'en cas de réussite. Lève [SyncException] sinon.
  ///
  /// [password] null : on garde le mot de passe enregistré (modification des
  /// paramètres sans le ressaisir).
  Future<ActivationResult> activate(
    SyncSettings settings,
    String? password,
  ) async {
    password ??= (await _env.settings.load())?.password;
    if (password == null) {
      throw const SyncException(SyncProblem.unauthorized, 'mot de passe vide');
    }
    await _env.settings.checkSecrets();
    cancelActivation();
    final connection = _open(settings, password);
    // Nouveau serveur ou nouveau dossier : on oublie l'état précédent.
    await connection.service.forget();
    _running = true;
    try {
      await connection.service.sync();
    } on SyncException catch (e) {
      if (e.problem != SyncProblem.otherCave) {
        connection.client.close();
        rethrow;
      }
      _pending = (
        settings: settings,
        password: password,
        connection: connection,
      );
      return ActivationResult.otherCave;
    } finally {
      _running = false;
    }
    await _enable(settings, password, connection);
    await _succeeded();
    await _mirrorBackups(connection);
    return ActivationResult.done;
  }

  /// Le serveur contient une autre cave : « Utiliser la cave du serveur »
  /// ([useServer], après sauvegarde de celle de l'appareil) ou « Remplacer
  /// la cave du serveur par celle-ci » (l'ancienne est mise de côté sur le
  /// serveur). Lève [SyncException] en cas d'échec.
  Future<void> resolveOtherCave({required bool useServer}) async {
    final pending = _pending;
    final connection = pending?.connection ?? _current;
    if (connection == null) return;
    _running = true;
    try {
      if (useServer) {
        await connection.service.useServerCave(_env.backups);
      } else {
        await connection.service.replaceServerCave();
      }
    } finally {
      _running = false;
    }
    if (pending != null) {
      _pending = null;
      await _enable(pending.settings, pending.password, connection);
    }
    await _succeeded();
    await _mirrorBackups(connection);
  }

  /// Abandonne une activation en attente du choix de l'utilisateur.
  void cancelActivation() {
    _pending?.connection.client.close();
    _pending = null;
  }

  /// Retour au mode local (CDC §8.2) : l'appareil garde sa cave, le fichier
  /// du serveur n'est pas supprimé, les sauvegardes restent sur l'appareil.
  Future<void> deactivate() async {
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    cancelActivation();
    await _current?.service.forget();
    await _env.settings.clear();
    for (final key in [
      _lastSuccessKey,
      _errorSinceKey,
      _mirroredKey,
      automaticKey,
    ]) {
      await _env.store.remove(key);
    }
    _current?.client.close();
    _current = null;
    state = SyncState.off;
  }

  /// Paramètres enregistrés (pour pré-remplir le formulaire).
  Future<SyncSettings?> savedSettings() async => _env.settings.loadSettings();

  /// Journal technique des dernières erreurs, de la plus récente à la plus
  /// ancienne.
  Future<List<SyncLogEntry>> log() async {
    final raw = await _env.store.getString(_logKey);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map(SyncLogEntry.fromJson)
          .whereType<SyncLogEntry>()
          .toList();
    } on FormatException {
      return const [];
    }
  }

  // ───────────────────────────────── Interne ────────────────────────────────

  _Connection _open(SyncSettings settings, String password) {
    final client = WebDavClient(
      folder: settings.folderUri(),
      user: settings.user.trim(),
      password: password,
    );
    final service = SyncService(
      db: _env.db,
      ctx: _env.ctx,
      store: _env.store,
      client: client,
      tempFolder: _env.tempFolder,
      clock: _env.clock,
    );
    return (service: service, client: client);
  }

  Future<void> _enable(
    SyncSettings settings,
    String password,
    _Connection connection,
  ) async {
    await _env.settings.save(settings, password);
    if (!identical(_current, connection)) _current?.client.close();
    _current = connection;
    _retryTimer?.cancel();
  }

  Future<void> _succeeded({String? notice}) async {
    final now = _env.clock();
    _retryIndex = 0;
    await _env.store.setString(_lastSuccessKey, now.toIso8601String());
    await _env.store.remove(_errorSinceKey);
    state = SyncState(
      status: SyncStatus.synced,
      lastSuccess: now,
      notice: notice,
      automatic: state.automatic,
    );
  }

  Future<void> _failed(SyncException e) async {
    final now = _env.clock();
    final since = state.errorSince ?? now;
    await _env.store.setString(_errorSinceKey, since.toIso8601String());
    await _appendLog(SyncLogEntry(now, e.problem, e.detail));
    state = state.copyWith(
      status: SyncStatus.error,
      problem: e.problem,
      detail: e.detail,
      errorSince: since,
    );
    // Pas de nouvel essai quand seul l'utilisateur peut corriger.
    const userMustAct = {
      SyncProblem.unauthorized,
      SyncProblem.folderNotFound,
      SyncProblem.newerVersion,
      SyncProblem.otherCave,
      SyncProblem.secretStore,
      SyncProblem.insecureAddress,
    };
    if (userMustAct.contains(e.problem) || !state.automatic) return;
    if (_retryIndex < _env.retryDelays.length) {
      _retryTimer = Timer(_env.retryDelays[_retryIndex++], syncNow);
    }
  }

  Future<void> _appendLog(SyncLogEntry entry) async {
    final entries = [entry, ...await log()].take(logSize);
    await _env.store.setString(
      _logKey,
      jsonEncode([for (final e in entries) e.toJson()]),
    );
  }

  /// Copie la dernière sauvegarde sur le serveur, si elle n'y est pas déjà.
  /// Une erreur va au journal sans changer l'état de la synchronisation.
  Future<void> _mirrorBackups(_Connection connection) async {
    final client = connection.client;
    try {
      final latest = (await _env.backups.list()).firstOrNull;
      if (latest == null) return;
      final name = latest.database.uri.pathSegments.last;
      if (await _env.store.getString(_mirroredKey) == name) return;
      await mirrorLatestBackup(_env.backups, client.child(serverBackupFolder));
      await _env.store.setString(_mirroredKey, name);
    } on WebDavException catch (e) {
      await _appendLog(
        SyncLogEntry(_env.clock(), SyncProblem.server, 'sauvegarde : $e'),
      );
    } on FileSystemException catch (e) {
      await _appendLog(
        SyncLogEntry(_env.clock(), SyncProblem.server, 'sauvegarde : $e'),
      );
    }
  }

  Future<DateTime?> _readDate(String key) async {
    final value = await _env.store.getString(key);
    return value == null ? null : DateTime.tryParse(value);
  }
}

/// Un serveur configuré : le service de synchronisation et sa connexion.
typedef _Connection = ({SyncService service, WebDavClient client});
