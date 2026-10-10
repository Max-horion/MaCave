import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../sync/backup.dart';
import '../../sync/cave_file.dart';
import '../../sync/providers.dart';
import '../../sync/storage_access.dart';
import '../../ui/formats.dart';
import '../../ui/widgets.dart';

/// État affiché par l'écran : dossier, sauvegardes présentes, dernière erreur.
class BackupOverview {
  const BackupOverview({
    required this.folder,
    required this.sets,
    required this.lastError,
    required this.keep,
    required this.everyDays,
    required this.chosenFolder,
    required this.access,
    this.accessBlocked = false,
  });

  final String folder;
  final List<BackupSet> sets;
  final String? lastError;

  /// Nombre de sauvegardes conservées.
  final int keep;

  /// Fréquence de la sauvegarde automatique, en jours.
  final int everyDays;

  /// Dossier choisi par l'utilisateur (pas celui par défaut).
  final bool chosenFolder;

  /// L'appli peut écrire dans Documents (autorisation, Android 8 à 10).
  final bool access;

  /// Autorisation refusée définitivement : seuls les réglages d'Android
  /// permettent de l'accorder.
  final bool accessBlocked;
}

final backupOverviewProvider = FutureProvider.autoDispose<BackupOverview>((
  ref,
) async {
  final service = ref.watch(backupServiceProvider);
  final storage = ref.watch(storageAccessProvider);
  final access = await storage.granted();
  return BackupOverview(
    accessBlocked: !access && await storage.blocked(),
    chosenFolder: await service.hasChosenFolder(),
    access: access,
    // Sans autorisation (Android 8 à 10), Android refuse même la lecture du
    // dossier : on n'y touche pas, l'écran montre l'avertissement et le
    // bouton pour autoriser.
    folder: access ? (await service.folder()).path : await service.folderPath(),
    sets: access ? await service.list() : const [],
    lastError: await service.lastError(),
    keep: await service.keepCount(),
    everyDays: await service.everyDays(),
  );
});

/// Sauvegardes de la cave (CDC §8.4) : sauvegarder maintenant, partager,
/// restaurer.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  /// Une opération est en cours : boutons désactivés.
  bool _busy = false;

  /// Au retour des réglages d'Android, l'autorisation a pu changer.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(backupOverviewProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final overview = ref.watch(backupOverviewProvider);
    final synced = ref.watch(syncControllerProvider).enabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupTitle),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.errorGeneric('$e')),
        ),
        data: (o) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(synced ? l10n.backupHelpSynced : l10n.backupHelp),
            const SizedBox(height: 12),
            SelectableText(
              l10n.backupFolder(o.folder),
              style: theme.textTheme.bodySmall,
            ),
            Text(l10n.backupFolderHelp, style: theme.textTheme.bodySmall),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: _busy ? null : _chooseFolder,
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.backupChooseFolder),
                ),
                if (o.chosenFolder)
                  TextButton(
                    onPressed: _busy ? null : () => _setFolder(null),
                    child: Text(l10n.backupDefaultFolder),
                  ),
              ],
            ),
            if (!o.access) ...[
              const SizedBox(height: 8),
              Text(
                l10n.backupNeedsPermission,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              if (o.accessBlocked) ...[
                Text(l10n.backupPermissionBlocked),
                FilledButton.tonalIcon(
                  onPressed: _busy
                      ? null
                      : ref.read(storageAccessProvider).openSettings,
                  icon: const Icon(Icons.settings),
                  label: Text(l10n.backupOpenSettings),
                ),
              ] else
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _allow,
                  icon: const Icon(Icons.lock_open),
                  label: Text(l10n.backupAllow),
                ),
            ],
            if (o.lastError != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.backupLastError(o.lastError!),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _backupNow,
              icon: const Icon(Icons.save),
              label: Text(l10n.backupNow),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restoreFromFile,
              icon: const Icon(Icons.settings_backup_restore),
              label: Text(l10n.backupRestoreFromFile),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 56,
              title: Text(l10n.backupEveryLabel),
              subtitle: Text(l10n.backupEveryHelp),
              trailing: DropdownButton<int>(
                value: o.everyDays,
                onChanged: _busy ? null : _changeEvery,
                items: [
                  for (final n in {
                    ...BackupService.everyDaysChoices,
                    o.everyDays,
                  })
                    DropdownMenuItem(
                      value: n,
                      child: Text(switch (n) {
                        1 => l10n.backupEveryDay,
                        7 => l10n.backupEveryWeek,
                        30 => l10n.backupEveryMonth,
                        _ => l10n.backupEveryDays(n),
                      }),
                    ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 56,
              title: Text(l10n.backupKeepLabel),
              subtitle: Text(l10n.backupKeepHelp),
              trailing: DropdownButton<int>(
                value: o.keep,
                onChanged: _busy ? null : _changeKeep,
                items: [
                  for (final n in {...BackupService.keepChoices, o.keep})
                    DropdownMenuItem(value: n, child: Text(formats.number(n))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.backupListTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (o.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.backupNone),
              ),
            for (final set in o.sets)
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: 56,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(formats.dateTime(set.date)),
                subtitle: Text(
                  l10n.backupSize(formats.number((set.size / 1024).ceil())),
                ),
                trailing: const Icon(Icons.more_vert),
                enabled: !_busy,
                onTap: () => _openSet(set),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        showMessage(context, AppLocalizations.of(context).errorGeneric('$e'));
      }
    } finally {
      ref.invalidate(backupOverviewProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Android 8 à 10 : demande l'autorisation si besoin. Refusée, rien n'est
  /// tenté (l'écriture échouerait) : un message renvoie vers l'explication
  /// affichée sur l'écran.
  Future<bool> _ensureAccess() async {
    final access = ref.read(storageAccessProvider);
    if (await access.granted() || await access.request()) return true;
    if (mounted) {
      showMessage(context, AppLocalizations.of(context).backupNeedsPermission);
    }
    return false;
  }

  Future<void> _allow() =>
      _run(() => ref.read(storageAccessProvider).request());

  Future<void> _chooseFolder() async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null || !mounted) return;
    await _setFolder(path);
  }

  /// Change le dossier (null : dossier par défaut), après l'avoir essayé.
  Future<void> _setFolder(String? path) => _run(() async {
    final l10n = AppLocalizations.of(context);
    if (!await _ensureAccess()) return;
    try {
      await ref.read(backupServiceProvider).setFolder(path);
    } on FileSystemException {
      if (mounted) showMessage(context, l10n.backupFolderRefused);
      return;
    }
    if (mounted) showMessage(context, l10n.backupFolderChanged);
  });

  Future<void> _backupNow() => _run(() async {
    final l10n = AppLocalizations.of(context);
    if (!await _ensureAccess()) return;
    final set = await ref.read(backupServiceProvider).backupNow();
    if (!mounted) return;
    showMessage(
      context,
      l10n.backupDone,
      action: SnackBarAction(
        label: l10n.backupShare,
        onPressed: () => _share(set),
      ),
    );
  });

  Future<void> _changeEvery(int? days) async {
    if (days == null) return;
    await _run(() => ref.read(backupServiceProvider).setEveryDays(days));
  }

  /// Change le nombre de sauvegardes conservées, après confirmation s'il
  /// faut en supprimer.
  Future<void> _changeKeep(int? count) async {
    if (count == null) return;
    final l10n = AppLocalizations.of(context);
    final service = ref.read(backupServiceProvider);
    final excess = await service.excessWith(count);
    if (excess > 0 && mounted) {
      final confirmed = await confirm(
        context,
        title: l10n.backupKeepConfirmTitle,
        message: l10n.backupKeepConfirmMessage(excess),
        action: l10n.backupKeepConfirm,
      );
      if (!confirmed) return;
    }
    await _run(() => service.setKeepCount(count));
  }

  Future<void> _share(BackupSet set) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          for (final file in set.files)
            XFile(
              file.path,
              mimeType: file.path.endsWith('.csv')
                  ? 'text/csv'
                  : 'application/vnd.sqlite3',
            ),
        ],
      ),
    );
  }

  Future<void> _openSet(BackupSet set) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              minTileHeight: 56,
              leading: const Icon(Icons.share),
              title: Text(l10n.backupShare),
              onTap: () => Navigator.pop(context, 'share'),
            ),
            ListTile(
              minTileHeight: 56,
              leading: const Icon(Icons.settings_backup_restore),
              title: Text(l10n.backupRestore),
              onTap: () => Navigator.pop(context, 'restore'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'share':
        await _share(set);
      case 'restore':
        await _restore(set.database.path, date: set.date);
    }
  }

  Future<void> _restoreFromFile() async {
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty || !mounted) return;
    await _restore(picked.first.xFile.path);
  }

  /// Vérifie le fichier, demande confirmation, puis restaure.
  Future<void> _restore(String path, {DateTime? date}) async {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final service = ref.read(backupServiceProvider);

    final CaveFileInfo info;
    try {
      info = service.inspect(path);
    } on CaveFileException catch (e) {
      showMessage(context, switch (e.problem) {
        CaveFileProblem.unreadable => l10n.backupProblemUnreadable,
        CaveFileProblem.notACave => l10n.backupProblemNotACave,
        CaveFileProblem.newerVersion => l10n.backupProblemNewer,
      });
      return;
    }

    final contents = l10n.backupContents(info.drinks, info.bottles);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupRestoreTitle),
        content: Text(
          date == null
              ? l10n.backupRestoreFileMessage(contents)
              : l10n.backupRestoreMessage(formats.dateTime(date), contents),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupRestore),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _run(() async {
      await service.restore(path);
      if (mounted) showMessage(context, l10n.backupRestored);
    });
  }
}
