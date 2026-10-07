import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../theme/app_theme.dart';
import '../../ui/formats.dart';

/// Volume pré-rempli pour chaque type (CDC §7, Valeurs par défaut), modifiable
/// d'un toucher. Utilisé au premier lancement et dans les paramètres.
class DefaultVolumeTiles extends ConsumerWidget {
  const DefaultVolumeTiles({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final theme = Theme.of(context);
    final types = ref.watch(classificationProvider).value?.types ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final type in types)
          ListTile(
            contentPadding: padding,
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
