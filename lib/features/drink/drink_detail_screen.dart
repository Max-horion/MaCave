import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/formats.dart';
import '../../ui/widgets.dart';
import '../stock_actions.dart';
import 'drink_form_screen.dart';

/// Fiche d'une référence : informations et lots, avec les actions de stock.
class DrinkDetailScreen extends ConsumerWidget {
  const DrinkDetailScreen({super.key, required this.drinkId});

  final String drinkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final drinkAsync = ref.watch(drinkProvider(drinkId));
    final drink = drinkAsync.value;

    if (drink == null) {
      return Scaffold(
        appBar: AppBar(),
        body: drinkAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(l10n.drinkNotFound)),
      );
    }

    final repo = ref.read(caveRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(drink.name),
        actions: [
          IconButton(
            tooltip: l10n.favoriteLabel,
            isSelected: drink.favorite,
            onPressed: () => repo.setFavorite(drink.id, !drink.favorite),
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
          IconButton(
            tooltip: l10n.actionEdit,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => DrinkFormScreen(drinkId: drink.id),
              ),
            ),
            icon: const Icon(Icons.edit),
          ),
          PopupMenuButton<void>(
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => _confirmDeleteDrink(context, ref, drink),
                child: Text(l10n.deleteDrink),
              ),
            ],
          ),
        ],
      ),
      body: _DrinkDetailBody(drink: drink),
    );
  }

  Future<void> _confirmDeleteDrink(
    BuildContext context,
    WidgetRef ref,
    Drink drink,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      context,
      l10n.deleteDrinkConfirm(drink.name),
      l10n.actionDelete,
    );
    if (confirmed && context.mounted) {
      await ref.read(caveRepositoryProvider).deleteDrink(drink.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _DrinkDetailBody extends ConsumerWidget {
  const _DrinkDetailBody({required this.drink});

  final Drink drink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final classification = ref.watch(classificationProvider).value;
    final characteristicIds =
        ref.watch(drinkCharacteristicsProvider(drink.id)).value ?? const {};
    final lots = ref.watch(lotsProvider(drink.id)).value ?? const [];
    final type = classification?.type(drink.typeId);

    final infos = <(String, String)>[
      if (drink.producer != null) (l10n.fieldProducer, drink.producer!),
      if (drink.appellation != null)
        (l10n.fieldAppellation, drink.appellation!),
      if (drink.region != null) (l10n.fieldRegion, drink.region!),
      if (drink.country != null) (l10n.fieldCountry, drink.country!),
      if (drink.grapes != null) (l10n.fieldGrapes, drink.grapes!),
      if (drink.abv != null) (l10n.fieldAbv, formats.abv(drink.abv!)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (drink.needsCompletion)
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(l10n.needsCompletionBanner),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.category, size: 18),
              label: Text(type?.name ?? l10n.uncategorized),
            ),
            if (classification != null)
              for (final id in characteristicIds)
                if (classification.characteristic(id) case final c?)
                  Chip(label: Text(c.name)),
          ],
        ),
        const SizedBox(height: 8),
        for (final (label, value) in infos)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(label, style: theme.textTheme.labelLarge),
            subtitle: Text(value, style: theme.textTheme.bodyLarge),
          ),
        if (drink.rating != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: RatingStars(value: drink.rating),
          ),
        if (drink.comment != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(drink.comment!, style: theme.textTheme.bodyLarge),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(l10n.lotsSection, style: theme.textTheme.titleLarge),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  showNewLotDialog(context, ref, drinkId: drink.id, type: type),
              icon: const Icon(Icons.add),
              label: Text(l10n.addLot),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final lot in lots) _LotCard(lot: lot),
        const SizedBox(height: 24),
        Text(l10n.historySection, style: theme.textTheme.titleLarge),
        _History(drinkId: drink.id),
      ],
    );
  }
}

/// Historique des mouvements de la référence, du plus récent au plus ancien
/// (CDC §6.3).
class _History extends ConsumerWidget {
  const _History({required this.drinkId});

  final String drinkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final movements = ref.watch(drinkMovementsProvider(drinkId)).value;
    if (movements == null) return const SizedBox.shrink();
    if (movements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(l10n.historyEmpty),
      );
    }
    return Column(
      children: [
        for (final (:movement, :lot) in movements)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(switch (movement.kind) {
              MovementKind.entry => Icons.add_circle_outline,
              MovementKind.exit => Icons.remove_circle_outline,
              MovementKind.inventory => Icons.fact_check_outlined,
            }),
            title: Text(
              '${switch (movement.kind) {
                MovementKind.entry => l10n.movementEntry(movement.quantity),
                MovementKind.exit => l10n.movementExit(movement.quantity),
                MovementKind.inventory => l10n.movementInventory(movement.quantity),
              }} · ${formats.lot(lot)}',
            ),
            subtitle: Text(
              [
                formats.date(movement.occurredAt),
                if (movement.reason != null &&
                    movement.reason != ExitReason.consumed)
                  formats.reason(movement.reason!),
                ?movement.comment,
              ].join(' · '),
            ),
          ),
      ],
    );
  }
}

class _LotCard extends ConsumerWidget {
  const _LotCard({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final exhausted = lot.stock == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formats.lotExplicit(lot),
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    exhausted ? l10n.exhausted : l10n.bottleCount(lot.stock),
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    l10n.addedOn(formats.date(lot.createdAt)),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: l10n.quickExitTooltip,
              iconSize: 28,
              onPressed: exhausted
                  ? null
                  : () => quickExit(context, ref, [lot]),
              icon: const Icon(Icons.exposure_neg_1),
            ),
            const SizedBox(width: 4),
            IconButton.filledTonal(
              tooltip: l10n.addBottles,
              iconSize: 28,
              onPressed: () => showAddBottlesDialog(context, ref, lot),
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<void>(
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: !exhausted,
                  onTap: () => showRemoveDialog(context, ref, lot),
                  child: Text(l10n.removeBottles),
                ),
                PopupMenuItem(
                  onTap: () => showCorrectStockDialog(context, ref, lot),
                  child: Text(l10n.correctStock),
                ),
                PopupMenuItem(
                  onTap: () => _confirmDeleteLot(context, ref),
                  child: Text(l10n.deleteLot),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteLot(BuildContext context, WidgetRef ref) async {
    final formats = Formats.of(context);
    final confirmed = await _confirm(
      context,
      formats.l10n.deleteLotConfirm(formats.lotExplicit(lot)),
      formats.l10n.actionDelete,
    );
    if (confirmed) await ref.read(caveRepositoryProvider).deleteLot(lot.id);
  }
}

Future<bool> _confirm(
  BuildContext context,
  String message,
  String action,
) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
}
