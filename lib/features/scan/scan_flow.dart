import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/barcode.dart';
import '../../domain/drink_draft.dart';
import '../../domain/drink_filter.dart';
import '../../scan/open_food_facts.dart';
import '../../scan/providers.dart';
import '../../ui/formats.dart';
import '../drink/drink_detail_screen.dart';
import '../drink/drink_form_screen.dart';
import '../stock_actions.dart';
import 'scan_screen.dart';

// Déroulé d'un scan (CDC §6.2, §6.3) : le code lu est cherché dans la cave.
// - Connu : le ou les lots s'affichent avec « −1 » et « Ajouter » ; le scan
//   ne retire jamais rien seul (2 gestes : scanner, puis « −1 »).
// - Inconnu : nouvelle référence avec ce code, ou association à un lot
//   existant, mémorisée pour la prochaine fois.
//
// Les actions s'exécutent dans le contexte de l'écran appelant (la liste),
// pour que le bandeau « Annuler » reste visible une fois le scan fermé.

/// Ouvre le scan, puis traite le code lu.
Future<void> startScan(BuildContext context, WidgetRef ref) async {
  final code = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => const ScanScreen()),
  );
  if (code == null || !context.mounted) return;
  await handleScannedCode(context, ref, code);
}

/// Cherche [code] dans la cave et propose les actions possibles.
Future<void> handleScannedCode(
  BuildContext context,
  WidgetRef ref,
  String code,
) async {
  final normalized = normalizeBarcode(code);
  if (normalized == null) return;
  final matches = await ref.read(caveRepositoryProvider).lotsByBarcode(code);
  if (!context.mounted) return;
  final choice = matches.isEmpty
      ? await _showUnknown(
          context,
          normalized,
          // Recherche lancée tout de suite, pendant l'affichage de la fiche.
          OpenFoodFacts.canLookUp(normalized)
              ? ref.read(openFoodFactsProvider).lookUp(normalized)
              : null,
        )
      : await _showKnown(context, normalized, matches);
  if (choice == null || !context.mounted) return;

  final classification = ref.read(classificationProvider).value;
  switch (choice) {
    case _RemoveOne(:final lot):
      await quickExit(context, ref, [lot]);
    case _AddBottles(:final lot):
      await showAddBottlesDialog(context, ref, lot);
    case _NewLot(:final drink):
      await showNewLotDialog(
        context,
        ref,
        drinkId: drink.id,
        type: classification?.type(drink.typeId),
        barcode: normalized,
      );
    case _OpenDrink(:final drink):
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DrinkDetailScreen(drinkId: drink.id),
        ),
      );
    case _NewDrink(:final draft):
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DrinkFormScreen(barcode: normalized, draft: draft),
        ),
      );
    case _Associate():
      await _associate(context, ref, normalized);
    case _ScanAgain():
      await startScan(context, ref);
  }
}

/// Ce que l'utilisateur a choisi après un scan.
sealed class _ScanChoice {
  const _ScanChoice();
}

class _RemoveOne extends _ScanChoice {
  const _RemoveOne(this.lot);
  final Lot lot;
}

class _AddBottles extends _ScanChoice {
  const _AddBottles(this.lot);
  final Lot lot;
}

class _NewLot extends _ScanChoice {
  const _NewLot(this.drink);
  final Drink drink;
}

class _OpenDrink extends _ScanChoice {
  const _OpenDrink(this.drink);
  final Drink drink;
}

class _NewDrink extends _ScanChoice {
  const _NewDrink([this.draft]);

  /// Fiche trouvée sur Open Food Facts, à valider.
  final DrinkDraft? draft;
}

class _Associate extends _ScanChoice {
  const _Associate();
}

class _ScanAgain extends _ScanChoice {
  const _ScanAgain();
}

/// Code connu : les lots qui le portent, groupés par référence.
Future<_ScanChoice?> _showKnown(
  BuildContext context,
  String code,
  List<({Drink drink, Lot lot})> matches,
) {
  final byDrink = <String, (Drink, List<Lot>)>{};
  for (final m in matches) {
    byDrink.putIfAbsent(m.drink.id, () => (m.drink, [])).$2.add(m.lot);
  }
  return showModalBottomSheet<_ScanChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final formats = Formats.of(context);
      final l10n = formats.l10n;
      final theme = Theme.of(context);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (drink, lots) in byDrink.values) ...[
                Text(drink.name, style: theme.textTheme.titleLarge),
                if (drink.producer != null) Text(drink.producer!),
                const SizedBox(height: 8),
                for (final lot in lots)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formats.lotExplicit(lot)}\n'
                            '${l10n.bottleCount(lot.stock)}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: lot.stock > 0
                              ? () => Navigator.pop(context, _RemoveOne(lot))
                              : null,
                          child: Text(l10n.scanRemoveOne),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () =>
                              Navigator.pop(context, _AddBottles(lot)),
                          child: Text(l10n.scanAdd),
                        ),
                      ],
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, _NewLot(drink)),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.scanNewLot),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, _OpenDrink(drink)),
                  icon: const Icon(Icons.wine_bar_outlined),
                  label: Text(l10n.scanOpenDrink),
                ),
                const Divider(),
              ],
              Text(l10n.scanCode(code), style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, const _ScanAgain()),
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.scanAgain),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Code inconnu : créer une référence (pré-remplie si Open Food Facts la
/// connaît) ou associer le code à un lot.
Future<_ScanChoice?> _showUnknown(
  BuildContext context,
  String code,
  Future<OffResult>? lookup,
) {
  return showModalBottomSheet<_ScanChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _UnknownCodeSheet(code: code, lookup: lookup),
  );
}

class _UnknownCodeSheet extends StatelessWidget {
  const _UnknownCodeSheet({required this.code, required this.lookup});

  final String code;

  /// Null : pas de recherche (QR code, contenu non numérique).
  final Future<OffResult>? lookup;

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FutureBuilder<OffResult>(
          future: lookup,
          builder: (context, snapshot) {
            final result = snapshot.data;
            final searching =
                lookup != null &&
                snapshot.connectionState != ConnectionState.done;
            final draft = result is OffFound ? result.draft : null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.scanUnknownTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(l10n.scanUnknownMessage),
                Text(l10n.scanCode(code), style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                if (searching)
                  Row(
                    children: [
                      const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.offSearching)),
                    ],
                  )
                else if (draft != null)
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(draft.name ?? l10n.offUnnamed),
                      subtitle: Text(
                        [
                          ?draft.producer,
                          if (draft.volumeMl != null)
                            formats.volume(draft.volumeMl!),
                          if (draft.abv != null) formats.abv(draft.abv!),
                          l10n.offSource,
                        ].join(' · '),
                      ),
                    ),
                  )
                else if (result != null)
                  Text(switch (result) {
                    OffNotFound() => l10n.offNotFound,
                    OffOffline() => l10n.offOffline,
                    OffUnavailable() => l10n.offUnavailable,
                    OffFound() => '',
                  }, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, _NewDrink(draft)),
                  icon: const Icon(Icons.add),
                  label: Text(
                    draft != null ? l10n.offUseDraft : l10n.scanNewDrink,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pop(context, const _Associate()),
                  icon: const Icon(Icons.link),
                  label: Text(l10n.scanAssociate),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, const _ScanAgain()),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.scanAgain),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Associe [code] à un lot d'une référence choisie, puis affiche le résultat
/// comme pour un code connu (« −1 » ou « Ajouter » tout de suite).
Future<void> _associate(
  BuildContext context,
  WidgetRef ref,
  String code,
) async {
  final drink = await Navigator.push<Drink>(
    context,
    MaterialPageRoute(builder: (_) => const DrinkPickerScreen()),
  );
  if (drink == null || !context.mounted) return;
  final repo = ref.read(caveRepositoryProvider);
  final lots = await repo.lotsOf(drink.id);
  if (!context.mounted) return;
  final classification = ref.read(classificationProvider).value;

  final formats = Formats.of(context);
  final l10n = formats.l10n;
  // Le lot à associer, ou null pour un nouveau lot.
  final Lot? lot;
  if (lots.isEmpty) {
    lot = null;
  } else {
    final picked = await showModalBottomSheet<({Lot? lot})>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.scanPickLotTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final lot in lots)
                ListTile(
                  minTileHeight: 64,
                  title: Text(formats.lotExplicit(lot)),
                  trailing: Text(l10n.bottleCount(lot.stock)),
                  onTap: () => Navigator.pop(context, (lot: lot)),
                ),
              ListTile(
                minTileHeight: 64,
                leading: const Icon(Icons.add),
                title: Text(l10n.scanNewLot),
                onTap: () => Navigator.pop(context, (lot: null)),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    lot = picked.lot;
  }

  if (lot == null) {
    await showNewLotDialog(
      context,
      ref,
      drinkId: drink.id,
      type: classification?.type(drink.typeId),
      barcode: code,
    );
    return;
  }
  await repo.setLotBarcode(lot.id, code);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.scanAssociated(formats.lotExplicit(lot))),
      persist: false,
    ),
  );
  await handleScannedCode(context, ref, code);
}

/// Choix d'une référence existante, avec recherche (épuisées comprises :
/// on rachète souvent une bouteille déjà bue).
class DrinkPickerScreen extends ConsumerStatefulWidget {
  const DrinkPickerScreen({super.key});

  @override
  ConsumerState<DrinkPickerScreen> createState() => _DrinkPickerScreenState();
}

class _DrinkPickerScreenState extends ConsumerState<DrinkPickerScreen> {
  var _filter = const DrinkFilter(showExhausted: true);
  late Stream<List<DrinkListItem>> _items = _watch();

  Stream<List<DrinkListItem>> _watch() =>
      ref.read(caveQueriesProvider).watchDrinkList(_filter);

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanPickDrinkTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              autoFocus: true,
              hintText: l10n.searchHint,
              leading: const Icon(Icons.search),
              onChanged: (query) => setState(() {
                _filter = _filter.copyWith(query: query);
                _items = _watch();
              }),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _items,
        builder: (context, snapshot) {
          final items = snapshot.data;
          if (items == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = items[i];
              return ListTile(
                minTileHeight: 64,
                title: Text(item.drink.name),
                subtitle: Text(
                  [?item.drink.producer, ?item.drink.appellation].join(' · '),
                ),
                onTap: () => Navigator.pop(context, item.drink),
              );
            },
          );
        },
      ),
    );
  }
}
