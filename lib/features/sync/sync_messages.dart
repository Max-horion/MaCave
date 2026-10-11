import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../sync/sync_controller.dart';
import '../../sync/sync_service.dart';
import '../../ui/formats.dart';

// Textes et icônes de l'état de la synchronisation, communs à l'indicateur et
// à l'écran Synchronisation (CDC §8.3).

/// Message clair pour chaque cause d'erreur.
String syncProblemMessage(AppLocalizations l10n, SyncProblem problem) =>
    switch (problem) {
      SyncProblem.unreachable => l10n.syncProblemUnreachable,
      SyncProblem.unauthorized => l10n.syncProblemUnauthorized,
      SyncProblem.folderNotFound => l10n.syncProblemFolderNotFound,
      SyncProblem.insufficientStorage => l10n.syncProblemInsufficientStorage,
      SyncProblem.server => l10n.syncProblemServer,
      SyncProblem.newerVersion => l10n.syncProblemNewerVersion,
      SyncProblem.otherCave => l10n.syncProblemOtherCave,
      SyncProblem.conflict => l10n.syncProblemConflict,
      SyncProblem.secretStore => l10n.syncProblemSecretStore,
    };

/// L'erreur ne se corrige que dans les paramètres de synchronisation.
bool problemNeedsSettings(SyncProblem? problem) =>
    problem == SyncProblem.unauthorized ||
    problem == SyncProblem.folderNotFound;

/// Titre de l'état (« Synchronisé », « Erreur… »).
String syncStatusTitle(AppLocalizations l10n, SyncState state) =>
    switch (state.status) {
      SyncStatus.off => l10n.syncTitle,
      SyncStatus.synced => l10n.syncStatusSynced,
      SyncStatus.syncing => l10n.syncStatusSyncing,
      SyncStatus.waiting => l10n.syncStatusWaiting,
      SyncStatus.pending => l10n.syncStatusPending,
      SyncStatus.error => l10n.syncStatusError,
    };

/// Lignes d'explication sous le titre : cause, durée, dernière réussite.
List<String> syncStatusDetails(Formats formats, SyncState state, DateTime now) {
  final l10n = formats.l10n;
  return [
    if (state.status == SyncStatus.error && state.problem != null)
      syncProblemMessage(l10n, state.problem!),
    if (state.longError(now)) l10n.syncLongError,
    if (state.notice != null) l10n.syncSetAside(state.notice!),
    if (!state.automatic) l10n.syncManualNote,
    state.lastSuccess == null
        ? l10n.syncNever
        : l10n.syncLastSuccess(formats.dateTime(state.lastSuccess!.toLocal())),
  ];
}

/// Icône et couleur de l'état : discrète quand tout va bien, colorée
/// (tertiaire, puis rouge après 24 h) en cas d'erreur.
({IconData icon, Color color}) syncStatusIcon(
  ColorScheme colors,
  SyncState state,
  DateTime now,
) => switch (state.status) {
  SyncStatus.off => (icon: Icons.cloud_off_outlined, color: colors.onSurface),
  SyncStatus.synced => (
    icon: Icons.cloud_done_outlined,
    color: colors.onSurfaceVariant,
  ),
  SyncStatus.syncing => (
    icon: Icons.cloud_sync_outlined,
    color: colors.primary,
  ),
  SyncStatus.waiting || SyncStatus.pending => (
    icon: Icons.cloud_queue,
    color: colors.onSurfaceVariant,
  ),
  SyncStatus.error => (
    icon: Icons.sync_problem,
    color: state.longError(now) ? colors.error : colors.tertiary,
  ),
};
