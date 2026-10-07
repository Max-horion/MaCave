import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_preferences.dart';
import '../../domain/drink_filter.dart';
import '../../l10n/app_localizations.dart';
import '../../scan/ocr_engine.dart';
import '../../theme/app_theme.dart';
import '../backup/backup_screen.dart';
import '../exchange/exchange_actions.dart';
import '../storage/storage_screen.dart';
import '../sync/sync_screen.dart';
import 'default_volumes.dart';

/// Écran des paramètres (CDC §7). Les réglages d'affichage sont propres à
/// l'appareil ([AppPreferences]) ; les volumes par défaut sont dans la base,
/// donc synchronisés. Synchronisation, sauvegardes et espace disque gardent
/// leurs propres écrans, ouverts d'ici.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(appPreferencesProvider);
    final notifier = ref.read(appPreferencesProvider.notifier);
    final engine = ref.watch(ocrPreferencesProvider).value?.engine;

    final themes = {
      ThemeMode.system: l10n.settingsThemeSystem,
      ThemeMode.light: l10n.settingsThemeLight,
      ThemeMode.dark: l10n.settingsThemeDark,
    };
    final textSizes = {
      for (final (i, scale) in AppPreferences.textScales.indexed)
        scale: [
          l10n.settingsTextNormal,
          l10n.settingsTextLarge,
          l10n.settingsTextLarger,
        ][i],
    };
    final sorts = {
      DrinkSort.name: l10n.sortByName,
      DrinkSort.recentlyAdded: l10n.sortRecentlyAdded,
      DrinkSort.vintage: l10n.sortByVintage,
      DrinkSort.stock: l10n.sortByStock,
    };
    final undo = {
      for (final s in AppPreferences.undoChoices) s: l10n.settingsSeconds(s),
    };
    final engines = {
      OcrEngine.mlKit: l10n.labelEngineMlKit,
      OcrEngine.tesseract: l10n.labelEngineTesseract,
      OcrEngine.compare: l10n.labelEngineCompare,
    };

    void open(Widget screen) => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        key: const Key('settings-list'),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Section(l10n.settingsAppearance),
          _ChoiceTile(
            title: l10n.settingsTheme,
            options: themes,
            value: prefs.themeMode,
            onChanged: (v) => notifier.change((p) => p.copyWith(themeMode: v)),
          ),
          _ChoiceTile(
            title: l10n.settingsTextSize,
            options: textSizes,
            value: prefs.textScale,
            onChanged: (v) => notifier.change((p) => p.copyWith(textScale: v)),
          ),

          _Section(l10n.settingsDefaults),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.settingsDefaultsHelp,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const DefaultVolumeTiles(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),

          _Section(l10n.settingsDisplay),
          _ChoiceTile(
            title: l10n.settingsDefaultSort,
            options: sorts,
            value: prefs.defaultSort,
            onChanged: (v) =>
                notifier.change((p) => p.copyWith(defaultSort: v)),
          ),
          SwitchListTile(
            title: Text(l10n.settingsShowExhausted),
            subtitle: Text(l10n.settingsShowExhaustedHelp),
            value: prefs.showExhausted,
            onChanged: (v) =>
                notifier.change((p) => p.copyWith(showExhausted: v)),
          ),
          _ChoiceTile(
            title: l10n.settingsUndo,
            options: undo,
            value: prefs.undoSeconds,
            onChanged: (v) =>
                notifier.change((p) => p.copyWith(undoSeconds: v)),
          ),

          _Section(l10n.settingsRecognition),
          if (engine != null)
            _ChoiceTile(
              title: l10n.labelEngine,
              options: engines,
              value: engine,
              onChanged: (v) =>
                  ref.read(ocrPreferencesProvider.notifier).setEngine(v),
            ),
          SwitchListTile(
            title: Text(l10n.settingsOff),
            subtitle: Text(l10n.settingsOffHelp),
            value: prefs.openFoodFacts,
            onChanged: (v) =>
                notifier.change((p) => p.copyWith(openFoodFacts: v)),
          ),

          _Section(l10n.settingsData),
          _LinkTile(
            icon: Icons.cloud_outlined,
            title: l10n.menuSync,
            onTap: () => open(const SyncScreen()),
          ),
          _LinkTile(
            icon: Icons.save_outlined,
            title: l10n.menuBackups,
            onTap: () => open(const BackupScreen()),
          ),
          _LinkTile(
            icon: Icons.storage_outlined,
            title: l10n.menuStorage,
            onTap: () => open(const StorageScreen()),
          ),
          _LinkTile(
            icon: Icons.file_open_outlined,
            title: l10n.menuImport,
            onTap: () => startImport(context, ref),
          ),
          _LinkTile(
            icon: Icons.ios_share,
            title: l10n.menuExport,
            onTap: () => startExport(context, ref),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.settingsDeviceNote,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titre de rubrique.
class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Réglage à choix : la valeur actuelle sous le titre, la liste dans une
/// fenêtre.
class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: AppTheme.minButtonHeight,
      title: Text(title),
      subtitle: Text(options[value] ?? ''),
      onTap: () async {
        final chosen = await showDialog<T>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(title),
            children: [
              for (final MapEntry(key: option, value: label) in options.entries)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, option),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 40),
                    child: Row(
                      children: [
                        Icon(
                          option == value ? Icons.check : null,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(label)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
        if (chosen != null && chosen != value) onChanged(chosen);
      },
    );
  }
}

/// Lien vers un autre écran ou une action.
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: AppTheme.minButtonHeight,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
