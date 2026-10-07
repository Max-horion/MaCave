import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/providers.dart';
import '../../sync/sync_controller.dart';
import '../../sync/sync_service.dart';
import '../../sync/sync_settings.dart';
import '../../theme/app_theme.dart';
import '../../ui/formats.dart';
import 'sync_messages.dart';

/// Paramètres enregistrés et journal, relus à chaque changement d'état.
final syncOverviewProvider =
    FutureProvider.autoDispose<
      ({SyncSettings? settings, List<SyncLogEntry> log})
    >((ref) async {
      ref.watch(syncControllerProvider);
      final controller = ref.read(syncControllerProvider.notifier);
      return (
        settings: await controller.savedSettings(),
        log: await controller.log(),
      );
    });

/// Écran Synchronisation (CDC §8.2, §8.3) : activation avec un serveur
/// WebDAV, état, synchronisation manuelle, journal des erreurs,
/// désactivation.
class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  /// Une opération est en cours : boutons désactivés.
  bool _busy = false;

  /// Formulaire ouvert alors que la synchronisation est active.
  bool _editing = false;

  /// Échec de l'activation, affiché sous le formulaire.
  String? _error;

  SyncController get _controller => ref.read(syncControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(syncControllerProvider);
    final overview = ref.watch(syncOverviewProvider).value;
    final showForm = !state.enabled || _editing;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncTitle),
        bottom: _busy || state.status == SyncStatus.syncing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: showForm
            ? _SyncForm(
                // Recréé une seule fois, quand les paramètres enregistrés
                // arrivent (pré-remplissage) : jamais pendant la saisie.
                key: ValueKey(overview != null),
                initial: overview?.settings,
                editing: state.enabled,
                busy: _busy,
                error: _error,
                onSubmit: _activate,
                onCancel: state.enabled
                    ? () => setState(() {
                        _editing = false;
                        _error = null;
                      })
                    : null,
              )
            : _status(context, state, overview),
      ),
    );
  }

  Widget _status(
    BuildContext context,
    SyncState state,
    ({SyncSettings? settings, List<SyncLogEntry> log})? overview,
  ) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final look = syncStatusIcon(theme.colorScheme, state, now);
    final problem = state.status == SyncStatus.error ? state.problem : null;
    final idle = !_busy && state.status != SyncStatus.syncing;
    String? address;
    try {
      address = overview?.settings?.folderUri().toString();
    } on FormatException {
      address = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(look.icon, color: look.color, size: 32),
          title: Text(
            syncStatusTitle(l10n, state),
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(syncStatusDetails(formats, state, now).join('\n')),
        ),
        if (address != null)
          SelectableText(
            l10n.syncServerLine(address),
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 16),
        if (problem == SyncProblem.otherCave)
          FilledButton.icon(
            onPressed: idle ? _chooseCave : null,
            icon: const Icon(Icons.call_split),
            label: Text(l10n.syncChooseCave),
          )
        else if (problemNeedsSettings(problem))
          FilledButton.icon(
            onPressed: idle ? () => setState(() => _editing = true) : null,
            icon: const Icon(Icons.edit),
            label: Text(l10n.syncEdit),
          )
        else
          FilledButton.icon(
            onPressed: idle ? _controller.syncNow : null,
            icon: const Icon(Icons.sync),
            label: Text(problem == null ? l10n.syncNow : l10n.syncRetry),
          ),
        const SizedBox(height: 8),
        if (!problemNeedsSettings(problem))
          OutlinedButton.icon(
            onPressed: idle ? () => setState(() => _editing = true) : null,
            icon: const Icon(Icons.edit),
            label: Text(l10n.syncEdit),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: idle ? _deactivate : null,
          icon: const Icon(Icons.cloud_off),
          label: Text(l10n.syncDeactivate),
        ),
        const SizedBox(height: 16),
        Text(l10n.syncBackupsNote, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          minTileHeight: AppTheme.minButtonHeight,
          title: Text(l10n.syncLogTitle),
          children: [
            if (overview == null || overview.log.isEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.syncLogEmpty),
              ),
            for (final entry in overview?.log ?? const <SyncLogEntry>[])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(syncProblemMessage(l10n, entry.problem)),
                subtitle: Text(
                  [
                    formats.dateTime(entry.at.toLocal()),
                    if (entry.detail != null) entry.detail!,
                  ].join('\n'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on SyncException catch (e) {
      if (mounted) {
        setState(
          () => _error = syncProblemMessage(
            AppLocalizations.of(context),
            e.problem,
          ),
        );
      }
    } finally {
      ref.invalidate(syncOverviewProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text), persist: false));
  }

  Future<void> _activate(SyncSettings settings, String? password) =>
      _run(() async {
        final l10n = AppLocalizations.of(context);
        final result = await _controller.activate(settings, password);
        if (result == ActivationResult.otherCave) {
          // Cave neuve (nouvel appareil) : on récupère celle du serveur sans
          // poser la question (CDC §6.8).
          final empty = await ref.read(caveRepositoryProvider).isEmpty();
          final useServer = empty ? true : await _askOtherCave();
          if (useServer == null) {
            _controller.cancelActivation();
            return;
          }
          await _controller.resolveOtherCave(useServer: useServer);
        }
        if (!mounted) return;
        setState(() => _editing = false);
        _message(l10n.syncActivated);
      });

  /// Autre cave sur le serveur, découverte plus tard (un autre appareil a
  /// remplacé celle du serveur).
  Future<void> _chooseCave() => _run(() async {
    final useServer = await _askOtherCave();
    if (useServer == null) return;
    await _controller.resolveOtherCave(useServer: useServer);
  });

  /// « Utiliser la cave du serveur » (true), « Remplacer la cave du
  /// serveur » (false) ou annulation (null) — CDC §8.2.
  Future<bool?> _askOtherCave() {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final small = Theme.of(context).textTheme.bodySmall;
        return AlertDialog(
          title: Text(l10n.syncOtherCaveTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.syncOtherCaveMessage),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.syncUseServer, textAlign: TextAlign.center),
                ),
                Text(l10n.syncUseServerHelp, style: small),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    l10n.syncReplaceServer,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(l10n.syncReplaceServerHelp, style: small),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deactivate() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.syncDeactivate),
        content: Text(l10n.syncDeactivateMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.syncDeactivate),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      await _controller.deactivate();
      if (mounted) _message(l10n.syncDeactivated);
    });
  }
}

/// Formulaire des paramètres du serveur.
class _SyncForm extends StatefulWidget {
  const _SyncForm({
    super.key,
    required this.initial,
    required this.editing,
    required this.busy,
    required this.error,
    required this.onSubmit,
    required this.onCancel,
  });

  final SyncSettings? initial;

  /// Modification de paramètres existants : mot de passe facultatif.
  final bool editing;
  final bool busy;
  final String? error;
  final Future<void> Function(SyncSettings settings, String? password) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<_SyncForm> createState() => _SyncFormState();
}

class _SyncFormState extends State<_SyncForm> {
  final _form = GlobalKey<FormState>();
  late var _kind = widget.initial?.kind ?? ServerKind.nextcloud;
  late final _server = TextEditingController(text: widget.initial?.server);
  late final _user = TextEditingController(text: widget.initial?.user);
  final _password = TextEditingController();
  late final _folder = TextEditingController(
    text: widget.initial?.folder ?? SyncSettings.defaultFolder,
  );
  var _hidePassword = true;

  @override
  void dispose() {
    for (final c in [_server, _user, _password, _folder]) {
      c.dispose();
    }
    super.dispose();
  }

  SyncSettings get _settings => SyncSettings(
    kind: _kind,
    server: _server.text.trim(),
    user: _user.text.trim(),
    folder: _folder.text.trim(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String? required(String? value) =>
        (value == null || value.trim().isEmpty) ? l10n.syncFieldRequired : null;

    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.editing) ...[
            Text(l10n.syncIntro),
            const SizedBox(height: 16),
          ],
          SegmentedButton<ServerKind>(
            segments: [
              ButtonSegment(
                value: ServerKind.nextcloud,
                label: Text(l10n.syncKindNextcloud),
              ),
              ButtonSegment(
                value: ServerKind.other,
                label: Text(l10n.syncKindOther),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: widget.busy
                ? null
                : (s) => setState(() => _kind = s.single),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _server,
            enabled: !widget.busy,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: _kind == ServerKind.nextcloud
                  ? l10n.syncServerLabel
                  : l10n.syncUrlLabel,
              hintText: _kind == ServerKind.nextcloud
                  ? l10n.syncServerHint
                  : l10n.syncUrlHint,
            ),
            validator: (value) {
              final missing = required(value);
              if (missing != null) return missing;
              try {
                _settings.folderUri();
              } on FormatException {
                return l10n.syncInvalidAddress;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _user,
            enabled: !widget.busy,
            autocorrect: false,
            decoration: InputDecoration(labelText: l10n.syncUserLabel),
            validator: required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            enabled: !widget.busy,
            obscureText: _hidePassword,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.syncPasswordLabel,
              helperText: widget.editing
                  ? l10n.syncPasswordKeep
                  : l10n.syncPasswordHelp,
              helperMaxLines: 4,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: widget.editing ? null : required,
          ),
          if (_kind == ServerKind.nextcloud) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _folder,
              enabled: !widget.busy,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.syncFolderLabel,
                helperText: l10n.syncFolderHelp,
              ),
              validator: required,
            ),
          ],
          if (widget.error != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.busy ? null : _submit,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(widget.editing ? l10n.syncSave : l10n.syncActivate),
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: widget.busy ? null : widget.onCancel,
              child: Text(l10n.actionCancel),
            ),
          ],
        ],
      ),
    );
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final password = _password.text;
    widget.onSubmit(_settings, password.isEmpty ? null : password);
  }
}
