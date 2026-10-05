import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/formats.dart';
import '../../ui/widgets.dart';

/// Statistiques de base (CDC §6.6) : totaux, puis répartition des bouteilles
/// par type, par caractéristique et par région. Aucune notion de valeur.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric('$e'))),
        data: (s) {
          if (s.bottles == 0) {
            return EmptyMessage(
              icon: Icons.bar_chart,
              title: l10n.statsTitle,
              message: l10n.statsEmpty,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: l10n.statsBottles,
                      value: formats.number(s.bottles),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: l10n.statsDrinks,
                      value: formats.number(s.drinks),
                    ),
                  ),
                ],
              ),
              _Section(
                title: l10n.statsByType,
                entries: s.byType,
                unknownLabel: l10n.uncategorized,
              ),
              for (final family in s.byFamily)
                _Section(
                  title: '${family.typeName} · ${family.familyName}',
                  entries: family.values,
                ),
              _Section(
                title: l10n.statsByRegion,
                entries: s.byRegion,
                unknownLabel: l10n.statsUnknownRegion,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Chiffre clé : un nombre en grand et son libellé.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: theme.textTheme.displaySmall),
            Text(label, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Un graphique en barres horizontales avec son titre.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.entries,
    this.unknownLabel = '',
  });

  final String title;
  final List<StatEntry> entries;

  /// Libellé d'une barre dont la catégorie n'est pas renseignée.
  final String unknownLabel;

  /// Au-delà, les plus petites catégories sont regroupées dans « Autres ».
  static const maxBars = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var bars = entries;
    if (bars.length > maxBars) {
      final others = bars
          .skip(maxBars - 1)
          .fold<int>(0, (sum, e) => sum + e.bottles);
      bars = [
        ...bars.take(maxBars - 1),
        (label: l10n.statsOther, bottles: others),
      ];
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          HorizontalBars(
            entries: [
              for (final e in bars)
                (label: e.label ?? unknownLabel, bottles: e.bottles),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barres horizontales d'une seule série (CDC §6.6).
///
/// Une seule série, donc une seule couleur (celle du thème, lisible en clair
/// comme en sombre) et pas de légende : le titre la nomme. Les libellés et les
/// valeurs sont en couleur de texte ; la barre part de la ligne de base, son
/// extrémité est arrondie. La valeur est écrite en clair, ce qui tient lieu
/// d'infobulle sur un écran tactile et de tableau pour les lecteurs d'écran.
class HorizontalBars extends StatelessWidget {
  const HorizontalBars({super.key, required this.entries});

  final List<({String label, int bottles})> entries;

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final theme = Theme.of(context);
    final max = entries.fold<int>(1, (m, e) => e.bottles > m ? e.bottles : m);

    return Column(
      children: [
        for (final e in entries)
          Semantics(
            label: formats.l10n.statsBarValue(
              e.label,
              formats.number(e.bottles),
            ),
            excludeSemantics: true,
            child: Padding(
              // 2 × 5 px entre deux barres : elles ne se touchent jamais.
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      e.label,
                      style: theme.textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: e.bottles / max,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      formats.number(e.bottles),
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
