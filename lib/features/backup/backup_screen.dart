import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../sync/backup.dart';
import '../../sync/cave_file.dart';
import '../../sync/providers.dart';
import '../../ui/formats.dart';

/// État affiché par l'écran : dossier, sauvegardes présentes, dernière erreur.
class BackupOverview {
  const BackupOverview({
    required this.folder,
    required this.sets,
    required this.lastError,
  });

  final String folder;
  final List<BackupSet> sets;
  final String? lastError;
}

final backupOverviewProvider = FutureProvider.autoDispose<BackupOverview>((
  ref,
) async {
  final service = ref.watch(backupServiceProvider);
  return BackupOverview(
    folder: (await service.folder()).path,
    sets: await service.list(),
    lastError: await service.lastError(),
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

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final service = ref.watch(backupServiceProvider);
    final overview = ref.watch(backupOverviewProvider);

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
            Text(l10n.backupHelp(service.keep)),
            const SizedBox(height: 12),
            SelectableText(
              l10n.backupFolder(o.folder),
              style: theme.textTheme.bodySmall,
            ),
            Text(l10n.backupFolderHelp, style: theme.textTheme.bodySmall),
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
            const SizedBox(height: 24),
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
                  l10n.backupSize(
                    formats.number((set.database.lengthSync() / 1024).ceil()),
                  ),
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
      if (mounted) _message(AppLocalizations.of(context).errorGeneric('$e'));
    } finally {
      ref.invalidate(backupOverviewProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), action: action, persist: false),
    );
  }

  Future<void> _backupNow() => _run(() async {
    final l10n = AppLocalizations.of(context);
    final set = await ref.read(backupServiceProvider).backupNow();
    if (!mounted) return;
    _message(
      l10n.backupDone,
      action: SnackBarAction(
        label: l10n.backupShare,
        onPressed: () => _share(set),
      ),
    );
  });

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
      _message(switch (e.problem) {
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
      if (mounted) _message(l10n.backupRestored);
    });
  }
}
