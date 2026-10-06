import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../sync/providers.dart';
import '../../sync/sync_controller.dart';
import '../../sync/sync_service.dart';
import '../../ui/formats.dart';
import 'sync_messages.dart';
import 'sync_screen.dart';

/// Indicateur discret de l'état de la synchronisation, dans la barre du haut
/// (CDC §8.3). Le toucher affiche un message clair et l'action qui corrige.
/// Invisible en mode local.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncControllerProvider);
    if (!state.enabled) return const SizedBox.shrink();
    final look = syncStatusIcon(
      Theme.of(context).colorScheme,
      state,
      DateTime.now(),
    );
    return IconButton(
      tooltip: AppLocalizations.of(context).syncIndicatorTooltip,
      onPressed: () => _showDetails(context, ref),
      icon: Badge(
        isLabelVisible: state.notice != null,
        child: Icon(look.icon, color: look.color),
      ),
    );
  }

  Future<void> _showDetails(BuildContext context, WidgetRef ref) {
    void openScreen() => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const SyncScreen()),
    );
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => Consumer(
        builder: (sheet, ref, _) {
          final formats = Formats.of(sheet);
          final l10n = formats.l10n;
          final state = ref.watch(syncControllerProvider);
          final problem = state.status == SyncStatus.error
              ? state.problem
              : null;
          final mustOpenScreen =
              problemNeedsSettings(problem) || problem == SyncProblem.otherCave;
          void close() => Navigator.pop(sheet);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    syncStatusTitle(l10n, state),
                    style: Theme.of(sheet).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    syncStatusDetails(
                      formats,
                      state,
                      DateTime.now(),
                    ).join('\n'),
                  ),
                  const SizedBox(height: 16),
                  if (mustOpenScreen)
                    FilledButton.icon(
                      onPressed: () {
                        close();
                        openScreen();
                      },
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.syncOpenSettings),
                    )
                  else if (problem != SyncProblem.newerVersion)
                    FilledButton.icon(
                      onPressed: state.status == SyncStatus.syncing
                          ? null
                          : () {
                              close();
                              ref
                                  .read(syncControllerProvider.notifier)
                                  .syncNow();
                            },
                      icon: const Icon(Icons.sync),
                      label: Text(
                        problem == null ? l10n.syncNow : l10n.syncRetry,
                      ),
                    ),
                  if (!mustOpenScreen) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        close();
                        openScreen();
                      },
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.syncOpenSettings),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
