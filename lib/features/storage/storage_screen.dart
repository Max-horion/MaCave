import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/history_purge.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/providers.dart';
import '../../theme/app_theme.dart';
import '../../ui/formats.dart';

/// Ce qu'affiche l'écran : taille, historique, réglage de la purge auto.
class StorageOverview {
  const StorageOverview({
    required this.bytes,
    required this.movements,
    required this.oldest,
    required this.purgedBefore,
    required this.auto,
  });

  final int bytes;
  final int movements;

  /// Plus ancien mouvement et date de la dernière purge (UTC, ms).
  final int? oldest;
  final int? purgedBefore;
  final AutoPurgeSettings auto;
}

final storageOverviewProvider = FutureProvider.autoDispose<StorageOverview>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final purge = ref.watch(historyPurgeProvider);
  final size = await db
      .customSelect(
        'SELECT (SELECT page_count FROM pragma_page_count()) * '
        '(SELECT page_size FROM pragma_page_size()) AS bytes, '
        '(SELECT COUNT(*) FROM movements) AS movements',
      )
      .getSingle();
  return StorageOverview(
    bytes: size.read<int>('bytes'),
    movements: size.read<int>('movements'),
    oldest: await purge.oldestMovement(),
    purgedBefore: await purge.purgedBefore(),
    auto: await purge.autoSettings(),
  );
});

/// Écran « Espace disque » (CDC §7) : taille de la base, purge manuelle de
/// l'historique avant une date, purge automatique des lots épuisés.
class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  /// La purge manuelle ne touche pas au dernier mois : un appareil resté
  /// hors ligne quelques jours peut encore avoir des mouvements récents à
  /// envoyer, qui seraient ignorés s'ils étaient antérieurs à la purge.
  static const minimumAge = Duration(days: 30);

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final overview = ref.watch(storageOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storageTitle),
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
        data: (o) {
          final limit = DateTime.now().subtract(StorageScreen.minimumAge);
          final canPurge =
              o.oldest != null &&
              o.oldest! < limit.toUtc().millisecondsSinceEpoch;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(l10n.storageSize(_size(l10n, formats, o.bytes))),
              const SizedBox(height: 4),
              Text(l10n.storageHistory(o.movements)),
              if (o.oldest != null)
                Text(
                  l10n.storageHistorySince(formats.date(o.oldest!)),
                  style: theme.textTheme.bodySmall,
                ),
              if (o.purgedBefore != null)
                Text(
                  l10n.storagePurgedBefore(formats.date(o.purgedBefore!)),
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 24),
              Text(l10n.storagePurgeTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.storagePurgeHelp),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy || !canPurge ? null : () => _purge(o),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: Text(l10n.storagePurgeButton),
              ),
              if (!canPurge)
                Text(
                  l10n.storagePurgeNothingOld,
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.storageAutoTitle,
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(l10n.storageAutoHelp),
                value: o.auto.enabled,
                onChanged: _busy
                    ? null
                    : (on) => _changeAuto(
                        AutoPurgeSettings(enabled: on, months: o.auto.months),
                      ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: AppTheme.minButtonHeight,
                title: Text(l10n.storageAutoDelay),
                trailing: DropdownButton<int>(
                  value: o.auto.months,
                  onChanged: _busy
                      ? null
                      : (months) => _changeAuto(
                          AutoPurgeSettings(
                            enabled: o.auto.enabled,
                            months: months ?? o.auto.months,
                          ),
                        ),
                  items: [
                    for (final m in {
                      ...AutoPurgeSettings.monthChoices,
                      o.auto.months,
                    })
                      DropdownMenuItem(
                        value: m,
                        child: Text(
                          m % 12 == 0
                              ? l10n.storageYears(m ~/ 12)
                              : l10n.storageMonths(m),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _size(AppLocalizations l10n, Formats formats, int bytes) {
    if (bytes < 1024 * 1024) {
      return l10n.storageKilobytes(formats.number((bytes / 1024).ceil()));
    }
    return l10n.storageMegabytes(
      formats.number((bytes / (1024 * 1024) * 10).round() / 10),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) _message(AppLocalizations.of(context).errorGeneric('$e'));
    } finally {
      ref.invalidate(storageOverviewProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text), persist: false));
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  /// Purge manuelle : date, confirmation, sauvegarde, purge, compactage.
  Future<void> _purge(StorageOverview o) async {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final purge = ref.read(historyPurgeProvider);
    final last = DateTime.now().subtract(StorageScreen.minimumAge);
    final first = DateTime.fromMillisecondsSinceEpoch(o.oldest!);
    final picked = await showDatePicker(
      context: context,
      helpText: l10n.storagePurgePickerHelp,
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: last,
      initialDate: last,
    );
    if (picked == null || !mounted) return;
    // Début du jour choisi, heure locale : « avant le 1er janvier ».
    final date = DateTime(
      picked.year,
      picked.month,
      picked.day,
    ).toUtc().millisecondsSinceEpoch;
    final count = await purge.countBefore(date);
    if (!mounted) return;
    if (count == 0) {
      _message(l10n.storagePurgeNone);
      return;
    }
    final ok = await _confirm(
      l10n.storagePurgeConfirmTitle,
      l10n.storagePurgeConfirmMessage(count, formats.date(date)),
      l10n.storagePurgeConfirm,
    );
    if (!ok) return;
    await _run(() async {
      await ref.read(backupServiceProvider).backupNow();
      final removed = await purge.purgeBefore(date);
      // Rend au téléphone la place libérée (impossible dans une transaction).
      await ref.read(databaseProvider).customStatement('VACUUM');
      if (mounted) _message(l10n.storagePurgeDone(removed));
    });
  }

  /// Purge automatique : si des lots sont supprimés tout de suite, on
  /// demande d'abord et on sauvegarde avant.
  Future<void> _changeAuto(AutoPurgeSettings settings) async {
    final l10n = AppLocalizations.of(context);
    final purge = ref.read(historyPurgeProvider);
    final now = DateTime.now().toUtc();
    final candidates = settings.enabled
        ? (await purge.autoPurgeCandidates(now, settings.months)).length
        : 0;
    if (candidates > 0) {
      if (!mounted) return;
      final ok = await _confirm(
        l10n.storageAutoConfirmTitle,
        l10n.storageAutoConfirmMessage(candidates),
        l10n.storageAutoConfirm,
      );
      if (!ok) return;
    }
    await _run(() async {
      if (candidates > 0) await ref.read(backupServiceProvider).backupNow();
      await purge.setAutoSettings(settings);
      if (candidates > 0) {
        final removed = await purge.autoPurge(now);
        if (mounted) _message(l10n.storageAutoDone(removed));
      }
    });
  }
}
