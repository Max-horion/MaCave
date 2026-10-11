import 'dart:async';
import 'dart:io';
import 'dart:ui' show AppExitResponse;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/local_store.dart';
import '../data/providers.dart';
import 'backup.dart';
import 'storage_access.dart';
import 'sync_controller.dart';
import 'sync_settings.dart';

/// Préférences propres à cet appareil.
final localStoreProvider = Provider<LocalStore>((ref) => PrefsLocalStore());

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    db: ref.watch(databaseProvider),
    store: ref.watch(localStoreProvider),
    folder: defaultBackupFolder,
    tempFolder: getTemporaryDirectory,
  ),
);

/// Ce qu'utilise la synchronisation sur le téléphone ; remplacé dans les
/// tests.
final syncEnvironmentProvider = Provider<SyncEnvironment>((ref) {
  final store = ref.watch(localStoreProvider);
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
  return SyncEnvironment(
    db: ref.watch(databaseProvider),
    ctx: ref.watch(writeContextProvider),
    store: store,
    settings: SyncSettingsStore(store, SecureSecretStore()),
    backups: ref.watch(backupServiceProvider),
    tempFolder: getTemporaryDirectory,
    isOnline: () async => online(await connectivity.checkConnectivity()),
    onlineChanges: connectivity.onConnectivityChanged.map(online),
  );
});

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

/// Dossier des sauvegardes en mode local (CDC §8.4) : `Documents/Cave/
/// Sauvegardes`, visible depuis un PC branché en USB ou une appli de
/// synchronisation de fichiers, et conservé si l'appli est désinstallée.
///
/// Android 11+ autorise une appli à écrire ses propres fichiers dans
/// Documents sans autorisation ; elle ne voit pas ceux des autres applis (ni
/// les siens après une réinstallation) : la restauration passe alors par le
/// sélecteur de fichiers.
Future<Directory> defaultBackupFolder() async {
  if (Platform.isAndroid) {
    // getExternalStorageDirectory donne le dossier privé de l'appli
    // (…/0/Android/data/fr.bouthon.cave/files) : on remonte à la racine.
    final private = await getExternalStorageDirectory();
    if (private != null && private.path.contains('/Android/')) {
      final root = private.path.split('/Android/').first;
      return Directory('$root/Documents/Cave/Sauvegardes');
    }
  }
  // Séparateur du système : le chemin s'affiche sur l'écran Sauvegardes
  // (Windows : C:\Users\…\Documents\Cave\Sauvegardes).
  final documents = await getApplicationDocumentsDirectory();
  final sep = Platform.pathSeparator;
  return Directory('${documents.path}${sep}Cave${sep}Sauvegardes');
}

/// Lance la sauvegarde et la synchronisation automatiques (pas de tâche de
/// fond en V1 : l'appli doit être ouverte, décision du 05/10/2026) :
/// - à l'ouverture et au retour au premier plan : synchronisation, puis
///   sauvegarde si elle est due ;
/// - après une modification de la cave : synchronisation quelques secondes
///   plus tard (les saisies sont regroupées) ;
/// - à la mise en arrière-plan (fin d'une séance de saisie) : sauvegarde, et
///   synchronisation si une modification attendait.
class AutomaticTasks extends ConsumerStatefulWidget {
  const AutomaticTasks({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AutomaticTasks> createState() => _AutomaticTasksState();
}

class _AutomaticTasksState extends ConsumerState<AutomaticTasks>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Après l'ouverture, pour ne pas la ralentir (CDC §9 : moins de 2 s).
    Future<void>.delayed(const Duration(seconds: 3), _opened);
    _changes = ref.read(databaseProvider).tableUpdates().listen((_) {
      if (mounted) ref.read(syncControllerProvider.notifier).localChanged();
    });
  }

  StreamSubscription<void>? _changes;

  @override
  void dispose() {
    _changes?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    switch (state) {
      // Linux ne signale jamais « paused » : une fenêtre réduite est
      // « hidden ». Sur Android, « hidden » précède toujours « paused ».
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden when !Platform.isAndroid:
        _leaving();
      case AppLifecycleState.resumed:
        ref.read(syncControllerProvider.notifier).resumed();
      default:
    }
  }

  /// Fermeture de la fenêtre (PC) : comme une mise en arrière-plan, mais la
  /// fermeture attend la fin (10 s au plus, réseau lent compris).
  @override
  Future<AppExitResponse> didRequestAppExit() async {
    if (mounted) {
      await _leaving().timeout(const Duration(seconds: 10), onTimeout: () {});
    }
    return AppExitResponse.exit;
  }

  /// Fin d'une séance de saisie : sauvegarde si elle est due, et envoi des
  /// modifications qui attendaient le regroupement.
  Future<void> _leaving() async {
    await ref.read(backupServiceProvider).backupIfDue();
    if (!mounted) return;
    await ref.read(syncControllerProvider.notifier).paused();
  }

  /// Synchronisation d'abord : la sauvegarde du jour contient alors les
  /// modifications des autres appareils. Puis purge automatique, après la
  /// sauvegarde.
  Future<void> _opened() async {
    if (!mounted) return;
    await ref.read(syncControllerProvider.notifier).start();
    if (!mounted) return;
    await _askStorageOnce();
    if (!mounted) return;
    await ref.read(backupServiceProvider).backupIfDue();
    if (!mounted) return;
    await _autoPurgeIfDue();
  }

  /// Android 8 à 10 : la sauvegarde automatique a besoin de l'autorisation
  /// d'écrire dans Documents. Demandée une seule fois, et seulement si la
  /// cave contient quelque chose ; si elle est refusée, l'écran Sauvegardes
  /// affiche l'erreur et un bouton « Autoriser ».
  Future<void> _askStorageOnce() async {
    const askedKey = 'storage_permission_asked';
    final store = ref.read(localStoreProvider);
    try {
      final access = ref.read(storageAccessProvider);
      if (await access.granted()) return;
      if (await store.getString(askedKey) != null) return;
      if (await ref.read(caveRepositoryProvider).isEmpty()) return;
      await store.setString(askedKey, 'true');
      await access.request();
    } catch (_) {
      // Rien : la sauvegarde signalera le problème.
    }
  }

  /// Purge automatique (si activée), au plus une fois par jour. Ne gêne
  /// jamais l'appli : une erreur est ignorée, elle sera retentée demain.
  Future<void> _autoPurgeIfDue() async {
    const lastKey = 'auto_purge_last_day';
    final store = ref.read(localStoreProvider);
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    try {
      if (await store.getString(lastKey) == today) return;
      await ref.read(historyPurgeProvider).autoPurge(now.toUtc());
      await store.setString(lastKey, today);
    } catch (_) {
      // Rien : voir ci-dessus.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
