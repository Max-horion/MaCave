import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/providers.dart';
import '../../domain/drink_filter.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/formats.dart';
import '../../ui/widgets.dart';
import '../backup/backup_screen.dart';
import '../drink/drink_detail_screen.dart';
import '../exchange/exchange_actions.dart';
import '../inventory/inventory_screen.dart';
import '../stats/stats_screen.dart';
import '../sync/sync_indicator.dart';
import '../sync/sync_screen.dart';
import '../drink/drink_form_screen.dart';
import '../stock_actions.dart';
import 'filter_sheet.dart';

/// Écran principal : la liste de la cave, avec recherche, filtres et tri
/// (CDC §6.5), et sortie rapide « −1 » sur chaque ligne (CDC §6.3).
class CellarScreen extends ConsumerWidget {
  const CellarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(drinkFilterProvider);
    final list = ref.watch(drinkListProvider);
    final totals = ref.watch(caveTotalsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const SyncIndicator(),
          _SortMenu(current: filter.sort),
          IconButton(
            tooltip: l10n.filtersTooltip,
            onPressed: () => showFilterSheet(context),
            icon: Badge(
              isLabelVisible: filter.activeCount > 0,
              label: Text('${filter.activeCount}'),
              child: const Icon(Icons.tune),
            ),
          ),
          const _MainMenu(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchField(initial: filter.query),
                const SizedBox(height: 6),
                // Résumé sur toute la largeur : jamais coupé par les boutons.
                Text(
                  totals == null
                      ? ''
                      : l10n.cellarSummary(
                          l10n.bottleCount(totals.bottles),
                          l10n.drinkCount(totals.drinksInStock),
                        ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric('$e'))),
        data: (items) {
          if (items.isNotEmpty) return _DrinkList(items: items);
          final filtering = filter.query.isNotEmpty || filter.activeCount > 0;
          return filtering
              ? EmptyMessage(
                  icon: Icons.search_off,
                  title: l10n.noResultsTitle,
                  message: l10n.noResultsMessage,
                  action: filter.activeCount > 0
                      ? OutlinedButton(
                          onPressed: () => ref
                              .read(drinkFilterProvider.notifier)
                              .change((f) => f.cleared()),
                          child: Text(l10n.clearFilters),
                        )
                      : null,
                )
              : EmptyMessage(
                  icon: Icons.wine_bar,
                  title: l10n.homeEmptyTitle,
                  message: l10n.homeEmptyMessage,
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const DrinkFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDrinkButton),
      ),
    );
  }
}

enum _MenuAction { inventory, statistics, import, export, backups, sync }

/// Menu « ⋮ » : inventaire, statistiques, import, export, sauvegardes et
/// synchronisation.
class _MainMenu extends ConsumerWidget {
  const _MainMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    void open(Widget screen) => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    return PopupMenuButton<_MenuAction>(
      tooltip: l10n.menuTooltip,
      onSelected: (action) => switch (action) {
        _MenuAction.inventory => open(const InventoryScreen()),
        _MenuAction.statistics => open(const StatsScreen()),
        _MenuAction.import => startImport(context, ref),
        _MenuAction.export => startExport(context, ref),
        _MenuAction.backups => open(const BackupScreen()),
        _MenuAction.sync => open(const SyncScreen()),
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _MenuAction.inventory,
          child: ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(l10n.menuInventory),
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.statistics,
          child: ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(l10n.menuStatistics),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _MenuAction.import,
          child: ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: Text(l10n.menuImport),
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.export,
          child: ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(l10n.menuExport),
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.backups,
          child: ListTile(
            leading: const Icon(Icons.save_outlined),
            title: Text(l10n.menuBackups),
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.sync,
          child: ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: Text(l10n.menuSync),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField({required this.initial});

  final String initial;

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String query) => ref
      .read(drinkFilterProvider.notifier)
      .change((f) => f.copyWith(query: query));

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      hintText: AppLocalizations.of(context).searchHint,
      leading: const Icon(Icons.search),
      trailing: [
        if (_controller.text.isNotEmpty)
          IconButton(
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            onPressed: () {
              _controller.clear();
              _setQuery('');
              setState(() {});
            },
            icon: const Icon(Icons.clear),
          ),
      ],
      onChanged: (text) {
        _setQuery(text);
        setState(() {}); // affiche ou masque le bouton d'effacement
      },
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu({required this.current});

  final DrinkSort current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      DrinkSort.name: l10n.sortByName,
      DrinkSort.recentlyAdded: l10n.sortRecentlyAdded,
      DrinkSort.vintage: l10n.sortByVintage,
      DrinkSort.stock: l10n.sortByStock,
    };
    return PopupMenuButton<DrinkSort>(
      tooltip: l10n.sortTooltip,
      icon: const Icon(Icons.swap_vert),
      initialValue: current,
      onSelected: (sort) => ref
          .read(drinkFilterProvider.notifier)
          .change((f) => f.copyWith(sort: sort)),
      itemBuilder: (_) => [
        for (final entry in labels.entries)
          CheckedPopupMenuItem(
            value: entry.key,
            checked: entry.key == current,
            child: Text(entry.value),
          ),
      ],
    );
  }
}

class _DrinkList extends StatelessWidget {
  const _DrinkList({required this.items});

  final List<DrinkListItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // Laisse la place au bouton « Ajouter » en bas de la liste.
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) => DrinkTile(item: items[i]),
    );
  }
}

/// Une ligne de la liste : nom, détails, stock et bouton « −1 ».
class DrinkTile extends ConsumerWidget {
  const DrinkTile({super.key, required this.item});

  final DrinkListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final drink = item.drink;
    final inStock = item.lotsInStock;

    final details = [
      ?drink.producer,
      ?drink.appellation,
      if (inStock.isNotEmpty) inStock.map(formats.lot).join(', '),
    ].join(' · ');

    return ListTile(
      minTileHeight: 72,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DrinkDetailScreen(drinkId: drink.id),
        ),
      ),
      title: Row(
        children: [
          Flexible(child: Text(drink.name, overflow: TextOverflow.ellipsis)),
          if (drink.favorite) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.favorite,
              size: 18,
              color: theme.colorScheme.primary,
              semanticLabel: l10n.favoriteLabel,
            ),
          ],
          if (drink.needsCompletion) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.edit_note,
              size: 20,
              color: theme.colorScheme.tertiary,
              semanticLabel: l10n.needsCompletionLabel,
            ),
          ],
        ],
      ),
      subtitle: details.isEmpty
          ? null
          : Text(details, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formats.number(item.stock),
            style: theme.textTheme.headlineSmall,
            semanticsLabel: l10n.bottleCount(item.stock),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: l10n.quickExitTooltip,
            iconSize: 28,
            onPressed: inStock.isEmpty
                ? null
                : () => quickExit(context, ref, inStock),
            icon: const Icon(Icons.exposure_neg_1),
          ),
        ],
      ),
    );
  }
}
