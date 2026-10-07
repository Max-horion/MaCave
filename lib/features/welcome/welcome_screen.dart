import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/providers.dart';
import '../../theme/app_theme.dart';
import '../../ui/formats.dart';
import '../cellar/cellar_screen.dart';
import '../exchange/exchange_actions.dart';
import '../sync/sync_screen.dart';

/// Préférence de l'appareil : premier lancement terminé (ou passé).
const welcomeDoneKey = 'welcome_done';

/// Écran d'ouverture quand la préférence [welcomeDoneKey] est absente :
/// l'accueil en trois étapes pour une cave neuve, sinon directement la liste
/// (appli mise à jour sur un téléphone qui a déjà une cave).
class WelcomeGate extends ConsumerStatefulWidget {
  const WelcomeGate({super.key});

  @override
  ConsumerState<WelcomeGate> createState() => _WelcomeGateState();
}

class _WelcomeGateState extends ConsumerState<WelcomeGate> {
  /// null : vérification en cours.
  bool? _welcome;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final empty = await ref.read(caveRepositoryProvider).isEmpty();
    final syncSettings = await ref
        .read(syncControllerProvider.notifier)
        .savedSettings();
    final welcome = empty && syncSettings == null;
    if (!welcome) await _markDone();
    if (mounted) setState(() => _welcome = welcome);
  }

  Future<void> _markDone() => ref
      .read(localStoreProvider)
      .setString(welcomeDoneKey, DateTime.now().toIso8601String());

  @override
  Widget build(BuildContext context) => switch (_welcome) {
    null => const Scaffold(),
    true => WelcomeScreen(
      onDone: () async {
        await _markDone();
        if (mounted) setState(() => _welcome = false);
      },
    ),
    false => const CellarScreen(),
  };
}

/// Premier lancement (CDC §6.8) : mode de stockage, import facultatif,
/// volumes par défaut. Chaque étape peut être passée.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const _steps = 3;
  var _step = 0;

  /// L'alerte du mode local n'est montrée qu'une fois (CDC §8.4).
  var _localAlertShown = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final syncOn = ref.watch(syncControllerProvider).enabled;
    final bottles = ref.watch(caveTotalsProvider).value?.bottles ?? 0;
    final last = _step == _steps - 1;
    // Étape faite : « Suivant » ; sinon « Passer ».
    final done = switch (_step) {
      0 => syncOn,
      1 => bottles > 0,
      _ => true,
    };

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.welcomeStep(_step + 1, _steps)),
          automaticallyImplyLeading: false,
          leading: _step == 0
              ? null
              : IconButton(
                  onPressed: () => setState(() => _step--),
                  icon: const Icon(Icons.arrow_back),
                ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: switch (_step) {
              0 => _storageStep(context, syncOn),
              1 => _importStep(context, bottles),
              _ => const _DefaultsStep(),
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: done
                ? FilledButton(
                    onPressed: _next,
                    child: Text(last ? l10n.welcomeFinish : l10n.welcomeNext),
                  )
                : OutlinedButton(
                    onPressed: _next,
                    child: Text(l10n.welcomeSkip),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_step == 0 && !ref.read(syncControllerProvider).enabled) {
      if (!await _localAlert()) return;
    }
    if (!mounted) return;
    if (_step == _steps - 1) {
      widget.onDone();
    } else {
      setState(() => _step++);
    }
  }

  /// Rappel : en mode local, les données ne sont que sur l'appareil.
  Future<bool> _localAlert() async {
    if (_localAlertShown) return true;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.phone_android),
        title: Text(l10n.welcomeLocalAlertTitle),
        content: SingleChildScrollView(child: Text(l10n.welcomeLocalAlert)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.welcomeLocalAlertOk),
          ),
        ],
      ),
    );
    if (ok == true) _localAlertShown = true;
    return ok == true;
  }

  Widget _storageStep(BuildContext context, bool syncOn) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.welcomeStorageTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.welcomeStorageHelp),
        const SizedBox(height: 24),
        if (syncOn)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.cloud_done,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            title: Text(l10n.welcomeSyncDone),
          )
        else ...[
          _Choice(
            icon: Icons.phone_android,
            title: l10n.welcomeLocal,
            help: l10n.welcomeLocalHelp,
            onTap: _next,
          ),
          const SizedBox(height: 12),
          _Choice(
            icon: Icons.cloud_sync,
            title: l10n.welcomeSync,
            help: l10n.welcomeSyncHelp,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SyncScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ],
    );
  }

  Widget _importStep(BuildContext context, int bottles) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.welcomeImportTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.welcomeImportHelp),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () => startImport(context, ref),
          icon: const Icon(Icons.file_open),
          label: Text(l10n.welcomeImportButton),
        ),
        const SizedBox(height: 16),
        Text(l10n.welcomeImportCount(bottles), textAlign: TextAlign.center),
      ],
    );
  }
}

/// Grand bouton de choix, avec une explication.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.help,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String help;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppTheme.minButtonHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(help, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Étape 3 : volume pré-rempli par type, modifiable d'un toucher.
class _DefaultsStep extends ConsumerWidget {
  const _DefaultsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final types = ref.watch(classificationProvider).value?.types ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.welcomeDefaultsTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.welcomeDefaultsHelp),
        const SizedBox(height: 16),
        for (final type in types)
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: AppTheme.minButtonHeight,
            title: Text(type.name),
            trailing: Text(
              formats.volume(type.defaultVolumeMl),
              style: theme.textTheme.titleMedium,
            ),
            onTap: () => _choose(context, ref, type),
          ),
      ],
    );
  }

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    DrinkType type,
  ) async {
    final formats = Formats.of(context);
    final volumes = {...standardVolumesMl, type.defaultVolumeMl}.toList()
      ..sort();
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(formats.l10n.welcomeVolumeOf(type.name)),
        children: [
          for (final v in volumes)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, v),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Row(
                  children: [
                    Icon(
                      v == type.defaultVolumeMl ? Icons.check : null,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Text(formats.volume(v)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (chosen == null || chosen == type.defaultVolumeMl) return;
    await ref.read(caveRepositoryProvider).setDefaultVolumeMl(type.id, chosen);
  }
}
