import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Panneau des filtres de la liste (CDC §6.5). Chaque changement s'applique
/// immédiatement : la liste derrière se met à jour pendant qu'on règle.
Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filter = ref.watch(drinkFilterProvider);
    final notifier = ref.read(drinkFilterProvider.notifier);
    final classification = ref.watch(classificationProvider).value;
    final regions = ref.watch(regionsProvider).value ?? const [];
    if (classification == null) return const SizedBox(height: 200);

    final typeId = filter.typeId;
    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: theme.textTheme.titleMedium),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.filtersTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (filter.activeCount > 0)
                TextButton(
                  onPressed: () => notifier.change((f) => f.cleared()),
                  child: Text(l10n.clearFilters),
                ),
            ],
          ),
          section(l10n.filterType),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.filterAllTypes),
                selected: typeId == null,
                onSelected: (_) => notifier.change(
                  (f) => f.copyWith(typeId: () => null, characteristicIds: {}),
                ),
              ),
              for (final type in classification.types)
                ChoiceChip(
                  label: Text(type.name),
                  selected: typeId == type.id,
                  onSelected: (_) => notifier.change(
                    (f) => f.copyWith(
                      typeId: () => type.id,
                      // Garde seulement les caractéristiques de ce type.
                      characteristicIds: f.characteristicIds.intersection(
                        classification.characteristicIdsOf(type.id),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Les caractéristiques n'ont de sens qu'une fois le type choisi.
          if (typeId != null)
            for (final family in classification.familiesOf(typeId)) ...[
              section(family.name),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in classification.valuesOf(family.id))
                    FilterChip(
                      label: Text(value.name),
                      selected: filter.characteristicIds.contains(value.id),
                      onSelected: (on) => notifier.change(
                        (f) => f.copyWith(
                          characteristicIds: on
                              ? {...f.characteristicIds, value.id}
                              : ({...f.characteristicIds}..remove(value.id)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          if (regions.isNotEmpty) ...[
            section(l10n.filterRegion),
            DropdownButtonFormField<String?>(
              initialValue: regions.contains(filter.region)
                  ? filter.region
                  : null,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.filterAnyRegion),
                ),
                for (final r in regions)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (r) =>
                  notifier.change((f) => f.copyWith(region: () => r)),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.filterFavorites),
            value: filter.favoritesOnly,
            onChanged: (v) =>
                notifier.change((f) => f.copyWith(favoritesOnly: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.filterNeedsCompletion),
            value: filter.needsCompletionOnly,
            onChanged: (v) =>
                notifier.change((f) => f.copyWith(needsCompletionOnly: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.filterShowExhausted),
            value: filter.showExhausted,
            onChanged: (v) =>
                notifier.change((f) => f.copyWith(showExhausted: v)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.showResults),
          ),
        ],
      ),
    );
  }
}
