import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_preferences.dart';
import '../../data/cave_queries.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/barcode.dart';
import '../../domain/drink_draft.dart';
import '../../domain/drink_filter.dart';
import '../../platform/device_capabilities.dart';
import '../../scan/open_food_facts.dart';
import '../../scan/providers.dart';
import '../../ui/formats.dart';
import '../drink/drink_form_screen.dart';
import '../label/label_flow.dart';
import '../stock_actions.dart';
import 'scan_screen.dart';
import '../cellar/selected_drink.dart';
import '../../ui/layout.dart';

// Déroulé d'un scan (CDC §6.2, §6.3) : le code lu est cherché dans la cave.
// - Connu : le ou les lots s'affichent avec « −1 » et « Ajouter » ; le scan
//   ne retire jamais rien seul (2 gestes : scanner, puis « −1 »).
// - Inconnu : nouvelle référence avec ce code, ou association à un lot
//   existant, mémorisée pour la prochaine fois.
//
// Les actions s'exécutent dans le contexte de l'écran appelant (la liste),
// pour que le bandeau « Annuler » reste visible une fois le scan fermé.

/// Ouvre le scan, puis traite le code lu (ou la photo de l'étiquette, pour
/// une bouteille sans code-barres). Sans caméra (PC) : saisie du code.
Future<void> startScan(BuildContext context, WidgetRef ref) async {
  if (!ref.read(deviceCapabilitiesProvider).camera) {
    final code = await askBarcodeByHand(context, scanner: true);
    if (code == null || !context.mounted) return;
    return handleScannedCode(context, ref, code);
  }
  final result = await Navigator.push<ScanResult>(
    context,
    MaterialPageRoute(builder: (_) => const ScanScreen()),
  );
  if (result == null || !context.mounted) return;
  switch (result) {
    case ScannedCode(:final code):
      await handleScannedCode(context, ref, code);
    case LabelRequested():
      final outcome = await readLabelWithCamera(context, ref);
      if (outcome == null || !context.mounted) return;
      await continueAfterLabel(context, ref, outcome);
  }
}

/// Scanne un code-barres à associer (formulaire, lot existant) : le code
/// lu, sous sa forme enregistrée, ou null. Remplaçable dans les tests (pas
/// de caméra). Sans caméra (PC) : saisie du code.
final barcodeScannerProvider = Provider<Future<String?> Function(BuildContext)>(
  (ref) => (context) async {
    if (!ref.read(deviceCapabilitiesProvider).camera) {
      final code = await askBarcodeByHand(context, scanner: true);
      return code == null ? null : normalizeBarcode(code);
    }
    final result = await Navigator.push<ScanResult>(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen(offerLabel: false)),
    );
    return result is ScannedCode ? normalizeBarcode(result.code) : null;
  },
);

/// Associe un code-barres scanné à [lot] (lot créé avant le scan, import
/// Vivino…), avec un message.
Future<void> scanBarcodeForLot(
  BuildContext context,
  WidgetRef ref,
  Lot lot,
) async {
  final code = await ref.read(barcodeScannerProvider)(context);
  if (code == null || !context.mounted) return;
  await ref.read(caveRepositoryProvider).setLotBarcode(lot.id, code);
  if (!context.mounted) return;
  final formats = Formats.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(formats.l10n.scanAssociated(formats.lotExplicit(lot))),
      persist: false,
    ),
  );
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
  final camera = ref.read(deviceCapabilitiesProvider).camera;
  final choice = matches.isEmpty
      ? await _showUnknown(
          context,
          normalized,
          camera,
          // Recherche lancée tout de suite, pendant l'affichage de la fiche.
          OpenFoodFacts.canLookUp(normalized) &&
                  ref.read(appPreferencesProvider).openFoodFacts
              ? _lookUp(ref, normalized)
              : null,
        )
      : await _showKnown(context, normalized, matches, camera);
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
      await openDrink(context, ref, drink.id);
    case _NewDrink(:final draft):
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DrinkFormScreen(barcode: normalized, draft: draft),
        ),
      );
    case _Associate(:final drink):
      await _associate(context, ref, normalized, drink: drink);
    case _ReadLabel(:final draft):
      final outcome = await readLabelWithCamera(context, ref);
      if (outcome == null || !context.mounted) return;
      await continueAfterLabel(
        context,
        ref,
        outcome,
        barcode: normalized,
        base: draft,
      );
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
  const _Associate([this.drink]);

  /// Référence déjà choisie (proposée comme proche) ; sinon, à chercher.
  final Drink? drink;
}

/// Résultat d'Open Food Facts et, si un produit est trouvé, les références
/// de la cave qui lui ressemblent (doublons, CDC §6.2).
typedef _Lookup = ({OffResult result, List<SimilarDrink> similar});

Future<_Lookup> _lookUp(WidgetRef ref, String code) async {
  final queries = ref.read(caveQueriesProvider);
  final result = await ref.read(openFoodFactsProvider).lookUp(code);
  final draft = result is OffFound ? result.draft : null;
  final name = draft?.name;
  return (
    result: result,
    similar: name == null
        ? const <SimilarDrink>[]
        : await queries.similarDrinks(
            name: name,
            producer: draft!.producer,
            profile: draft.profile,
          ),
  );
}

class _ReadLabel extends _ScanChoice {
  const _ReadLabel([this.draft]);

  /// Fiche d'Open Food Facts, complétée par l'étiquette.
  final DrinkDraft? draft;
}

class _ScanAgain extends _ScanChoice {
  const _ScanAgain();
}

/// Code connu : les lots qui le portent, groupés par référence.
Future<_ScanChoice?> _showKnown(
  BuildContext context,
  String code,
  List<({Drink drink, Lot lot})> matches,
  bool camera,
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
                icon: Icon(camera ? Icons.qr_code_scanner : Icons.keyboard),
                label: Text(camera ? l10n.scanAgain : l10n.scanAgainByHand),
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
  bool camera,
  Future<_Lookup>? lookup,
) {
  return showModalBottomSheet<_ScanChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) =>
        _UnknownCodeSheet(code: code, camera: camera, lookup: lookup),
  );
}

class _UnknownCodeSheet extends StatelessWidget {
  const _UnknownCodeSheet({
    required this.code,
    required this.camera,
    required this.lookup,
  });

  final String code;

  /// Photo de l'étiquette proposée (pas sur PC).
  final bool camera;

  /// Null : pas de recherche (QR code, contenu non numérique).
  final Future<_Lookup>? lookup;

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FutureBuilder<_Lookup>(
          future: lookup,
          builder: (context, snapshot) {
            final result = snapshot.data?.result;
            final similar = snapshot.data?.similar ?? const [];
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
                    OffDisabled() => '',
                    OffUnavailable() => l10n.offUnavailable,
                    OffFound() => '',
                  }, style: theme.textTheme.bodySmall),
                if (similar.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.scanMaybeTitle, style: theme.textTheme.titleMedium),
                  Text(l10n.scanMaybeHelp, style: theme.textTheme.bodySmall),
                  for (final s in similar)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minTileHeight: 64,
                      title: Text(s.drink.name),
                      subtitle: Text(
                        [
                          ?s.drink.producer,
                          l10n.bottleCount(s.bottles),
                        ].join(' · '),
                      ),
                      trailing: const Icon(Icons.link),
                      onTap: () => Navigator.pop(context, _Associate(s.drink)),
                    ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, _NewDrink(draft)),
                  icon: const Icon(Icons.add),
                  label: Text(
                    draft != null ? l10n.offUseDraft : l10n.scanNewDrink,
                  ),
                ),
                if (camera) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.pop(context, _ReadLabel(draft)),
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: Text(l10n.scanUnknownPhoto),
                  ),
                ],
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pop(context, const _Associate()),
                  icon: const Icon(Icons.link),
                  label: Text(l10n.scanAssociate),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, const _ScanAgain()),
                  icon: Icon(camera ? Icons.qr_code_scanner : Icons.keyboard),
                  label: Text(camera ? l10n.scanAgain : l10n.scanAgainByHand),
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
  String code, {
  Drink? drink,
}) async {
  drink ??= await Navigator.push<Drink>(
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
      body: ReadableWidth(
        child: StreamBuilder(
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
      ),
    );
  }
}
