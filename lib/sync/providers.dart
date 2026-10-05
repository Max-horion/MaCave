import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/local_store.dart';
import '../data/providers.dart';
import 'backup.dart';

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
  final documents = await getApplicationDocumentsDirectory();
  return Directory('${documents.path}/Cave/Sauvegardes');
}

/// Lance la sauvegarde automatique à l'ouverture et quand l'appli passe en
/// arrière-plan (fin d'une séance de saisie). Pas de tâche de fond en V1 :
/// l'appli doit être ouverte (décision du 05/10/2026).
class AutoBackup extends ConsumerStatefulWidget {
  const AutoBackup({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AutoBackup> createState() => _AutoBackupState();
}

class _AutoBackupState extends ConsumerState<AutoBackup>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Après l'ouverture, pour ne pas la ralentir (CDC §9 : moins de 2 s).
    Future<void>.delayed(const Duration(seconds: 5), _run);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _run();
  }

  void _run() {
    if (!mounted) return;
    ref.read(backupServiceProvider).backupIfDue();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
