import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/providers.dart';
import '../../domain/drink_filter.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/device_capabilities.dart';
import '../../ui/formats.dart';
import '../../ui/layout.dart';
import '../../ui/widgets.dart';
import '../drink/drink_detail_screen.dart';
import '../exchange/exchange_actions.dart';
import '../inventory/inventory_screen.dart';
import '../scan/scan_flow.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';
import '../sync/sync_indicator.dart';
import '../drink/drink_form_screen.dart';
import '../stock_actions.dart';
import 'filter_sheet.dart';
import 'selected_drink.dart';

/// Écran principal : la liste de la cave, avec recherche, filtres et tri
/// (CDC §6.5), et sortie rapide « −1 » sur chaque ligne (CDC §6.3).
///
/// Fenêtre large (PC, [wideLayoutMinWidth]) : la fiche de la référence
/// choisie s'affiche à droite de la liste au lieu de la recouvrir.
class CellarScreen extends ConsumerStatefulWidget {
  const CellarScreen({super.key});

  @override
  ConsumerState<CellarScreen> createState() => _CellarScreenState();
}

class _CellarScreenState extends ConsumerState<CellarScreen> {
  /// Champ de recherche, pour Ctrl+F.
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _searchFocus.requestFocus,
      },
      child: Focus(autofocus: true, child: _list(context)),
    );
    if (!isWideLayout(context)) return list;
    return Row(
      children: [
        Expanded(flex: 2, child: list),
        const VerticalDivider(width: 1),
        const Expanded(flex: 3, child: _DetailPane()),
      ],
    );
  }

  Widget _list(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(drinkFilterProvider);
    final list = ref.watch(drinkListProvider);
    final totals = ref.watch(caveTotalsProvider).value;
    final camera = ref.watch(deviceCapabilitiesProvider).camera;

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
                _SearchField(initial: filter.query, focusNode: _searchFocus),
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
                              .clearFilters(),
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
      // Scanner au-dessus d'Ajouter : les deux à portée du pouce.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'scan',
            onPressed: () => startScan(context, ref),
            icon: Icon(camera ? Icons.qr_code_scanner : Icons.keyboard),
            label: Text(camera ? l10n.scanButton : l10n.scanButtonByHand),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const DrinkFormScreen()),
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.addDrinkButton),
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { inventory, statistics, import, export, settings }

/// Menu « ⋮ » : inventaire, statistiques, import, export, paramètres
/// (synchronisation, sauvegardes et espace disque y sont rangés).
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
        _MenuAction.settings => open(const SettingsScreen()),
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
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _MenuAction.settings,
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.menuSettings),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField({required this.initial, required this.focusNode});

  final String initial;
  final FocusNode focusNode;

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
      focusNode: widget.focusNode,
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
      // Laisse la place aux boutons « Scanner » et « Ajouter ».
      padding: const EdgeInsets.only(bottom: 160),
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

    final wide = isWideLayout(context);
    return ListTile(
      minTileHeight: 72,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      selected: wide && ref.watch(selectedDrinkProvider) == drink.id,
      selectedTileColor: theme.colorScheme.secondaryContainer,
      onTap: () => wide
          ? ref.read(selectedDrinkProvider.notifier).select(drink.id)
          : openDrink(context, ref, drink.id),
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

/// Partie droite d'une fenêtre large : la fiche choisie, ou une invitation à
/// en choisir une. Ses propres messages (bandeau « Annuler »…) s'affichent
/// dans cette partie seulement.
class _DetailPane extends ConsumerWidget {
  const _DetailPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(selectedDrinkProvider);
    return ScaffoldMessenger(
      child: selected == null
          ? Scaffold(
              body: EmptyMessage(
                icon: Icons.wine_bar_outlined,
                title: l10n.detailPaneEmptyTitle,
                message: l10n.detailPaneEmptyMessage,
              ),
            )
          : DrinkDetailScreen(
              key: ValueKey(selected),
              drinkId: selected,
              onDeleted: () =>
                  ref.read(selectedDrinkProvider.notifier).select(null),
            ),
    );
  }
}
