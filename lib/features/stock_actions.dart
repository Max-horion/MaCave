import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_preferences.dart';
import '../data/database.dart';
import '../data/providers.dart';
import '../domain/enums.dart';
import '../domain/field_rules.dart';
import '../l10n/app_localizations.dart';
import '../ui/formats.dart';
import '../ui/widgets.dart';

/// Sortie rapide « −1 » (CDC §6.3) : retire une bouteille, « consommée ».
/// S'il y a plusieurs lots en stock, demande lequel, du millésime le plus
/// ancien au plus récent (les lots arrivent déjà dans cet ordre).
Future<void> quickExit(
  BuildContext context,
  WidgetRef ref,
  List<Lot> lotsInStock,
) async {
  if (lotsInStock.isEmpty) return;
  final lot = lotsInStock.length == 1
      ? lotsInStock.single
      : await _chooseLot(context, lotsInStock);
  if (lot == null || !context.mounted) return;
  await _run(context, () async {
    final id = await ref.read(caveRepositoryProvider).addExit(lot.id, 1);
    if (context.mounted) {
      _showUndo(context, ref, AppLocalizations.of(context).bottleRemoved, id);
    }
  });
}

Future<Lot?> _chooseLot(BuildContext context, List<Lot> lots) {
  final formats = Formats.of(context);
  return showModalBottomSheet<Lot>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formats.l10n.chooseLotTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final lot in lots)
            ListTile(
              minTileHeight: 64,
              title: Text(formats.lotExplicit(lot)),
              trailing: Text(
                formats.l10n.bottleCount(lot.stock),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () => Navigator.pop(context, lot),
            ),
        ],
      ),
    ),
  );
}

/// Ajoute des bouteilles à un lot existant (« + n bouteilles », CDC §5).
Future<void> showAddBottlesDialog(
  BuildContext context,
  WidgetRef ref,
  Lot lot,
) async {
  final formats = Formats.of(context);
  final quantity = await _quantityDialog(
    context,
    title: formats.l10n.addBottles,
    subtitle: formats.lotExplicit(lot),
    initial: 1,
    min: 1,
  );
  if (quantity == null || !context.mounted) return;
  await _run(context, () async {
    final id = await ref
        .read(caveRepositoryProvider)
        .addEntry(lot.id, quantity);
    if (context.mounted) {
      _showUndo(context, ref, formats.l10n.bottlesAdded(quantity), id);
    }
  });
}

/// Corrige le stock d'un lot : ajustement d'inventaire (CDC §6.4).
Future<void> showCorrectStockDialog(
  BuildContext context,
  WidgetRef ref,
  Lot lot,
) async {
  final formats = Formats.of(context);
  final counted = await _quantityDialog(
    context,
    title: formats.l10n.correctStock,
    subtitle: '${formats.lotExplicit(lot)}\n${formats.l10n.correctStockHelp}',
    initial: lot.stock,
    min: 0,
  );
  if (counted == null || counted == lot.stock || !context.mounted) return;
  await _run(context, () async {
    final id = await ref
        .read(caveRepositoryProvider)
        .recordInventory(lot.id, counted);
    if (context.mounted) {
      _showUndo(context, ref, formats.l10n.stockCorrected, id);
    }
  });
}

/// Retrait avec quantité, motif et commentaire (CDC §6.3).
Future<void> showRemoveDialog(
  BuildContext context,
  WidgetRef ref,
  Lot lot,
) async {
  if (lot.stock == 0) return;
  final l10n = AppLocalizations.of(context);
  final exit = await showDialog<_ExitChoice>(
    context: context,
    builder: (context) => _RemoveDialog(lot: lot),
  );
  if (exit == null || !context.mounted) return;
  final (:quantity, :reason, :comment) = exit;
  await _run(context, () async {
    final id = await ref
        .read(caveRepositoryProvider)
        .addExit(lot.id, quantity, reason: reason, comment: comment);
    if (context.mounted) {
      _showUndo(context, ref, l10n.bottlesRemoved(quantity), id);
    }
  });
}

/// Quantité, motif et commentaire choisis dans [_RemoveDialog].
typedef _ExitChoice = ({int quantity, ExitReason reason, String comment});

/// Fenêtre « Retirer des bouteilles ». Le champ du commentaire appartient à
/// la fenêtre : il n'est détruit qu'une fois celle-ci fermée (animation
/// comprise).
class _RemoveDialog extends StatefulWidget {
  const _RemoveDialog({required this.lot});

  final Lot lot;

  @override
  State<_RemoveDialog> createState() => _RemoveDialogState();
}

class _RemoveDialogState extends State<_RemoveDialog> {
  var _quantity = 1;
  var _reason = ExitReason.consumed;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    return AlertDialog(
      title: Text(l10n.removeBottles),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(formats.lotExplicit(widget.lot), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            QuantityStepper(
              value: _quantity,
              max: widget.lot.stock,
              onChanged: (v) => setState(() => _quantity = v),
            ),
            const SizedBox(height: 16),
            Text(l10n.fieldReason),
            const SizedBox(height: 8),
            SegmentedButton<ExitReason>(
              segments: [
                for (final r in ExitReason.values)
                  ButtonSegment(value: r, label: Text(formats.reason(r))),
              ],
              selected: {_reason},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _reason = s.single),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comment,
              decoration: InputDecoration(labelText: l10n.fieldComment),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (
            quantity: _quantity,
            reason: _reason,
            comment: _comment.text,
          )),
          child: Text(l10n.removeBottles),
        ),
      ],
    );
  }
}

/// Nouveau lot sur une référence existante : autre millésime ou volume
/// (CDC §6.2). Si le lot existe déjà, les bouteilles s'y ajoutent.
///
/// [barcode] : code scanné, mémorisé sur le lot. [vintage] et [volumeMl] :
/// valeurs proposées (lues sur l'étiquette). Retourne true si des
/// bouteilles ont été ajoutées.
Future<bool> showNewLotDialog(
  BuildContext context,
  WidgetRef ref, {
  required String drinkId,
  required DrinkType? type,
  String? barcode,
  int? vintage,
  int? volumeMl,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<LotDraft>(
    context: context,
    builder: (context) =>
        _NewLotDialog(type: type, vintage: vintage, volumeMl: volumeMl),
  );
  if (result == null || !context.mounted) return false;
  var added = false;
  await _run(context, () async {
    final repo = ref.read(caveRepositoryProvider);
    final lotId = await repo.findOrCreateLot(
      drinkId: drinkId,
      volumeMl: result.volumeMl,
      vintage: result.vintage,
      barcode: barcode,
    );
    final id = await repo.addEntry(lotId, result.quantity);
    added = true;
    if (context.mounted) {
      _showUndo(context, ref, l10n.bottlesAdded(result.quantity), id);
    }
  });
  return added;
}

/// Millésime, volume et quantité saisis pour un lot.
class LotDraft {
  const LotDraft({
    required this.vintage,
    required this.volumeMl,
    required this.quantity,
  });

  final int? vintage;
  final int volumeMl;
  final int quantity;
}

class _NewLotDialog extends StatefulWidget {
  const _NewLotDialog({required this.type, this.vintage, this.volumeMl});

  final DrinkType? type;

  /// Valeurs proposées.
  final int? vintage;
  final int? volumeMl;

  @override
  State<_NewLotDialog> createState() => _NewLotDialogState();
}

class _NewLotDialogState extends State<_NewLotDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _vintage = TextEditingController(
    text: widget.vintage?.toString() ?? '',
  );
  late int _volumeMl = widget.volumeMl ?? widget.type?.defaultVolumeMl ?? 750;
  int _quantity = 1;

  @override
  void dispose() {
    _vintage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = widget.type?.fieldProfile;
    final showVintage =
        profile == null ||
        ruleFor(profile, DrinkField.vintage) != FieldRule.hidden;
    return AlertDialog(
      title: Text(l10n.addLot),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: LotFields(
            vintage: showVintage ? _vintage : null,
            volumeMl: _volumeMl,
            onVolumeChanged: (v) => setState(() => _volumeMl = v),
            quantity: _quantity,
            onQuantityChanged: (q) => setState(() => _quantity = q),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              LotDraft(
                vintage: int.tryParse(_vintage.text.trim()),
                volumeMl: _volumeMl,
                quantity: _quantity,
              ),
            );
          },
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

/// Champs d'un lot (millésime facultatif, volume, quantité), partagés entre le
/// formulaire de création et la fenêtre « Ajouter un lot ».
class LotFields extends StatelessWidget {
  const LotFields({
    super.key,
    required this.vintage,
    required this.volumeMl,
    required this.onVolumeChanged,
    required this.quantity,
    required this.onQuantityChanged,
  });

  /// Null : millésime masqué pour ce type (CDC §4.1).
  final TextEditingController? vintage;
  final int volumeMl;
  final ValueChanged<int> onVolumeChanged;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final volumes = {...standardVolumesMl, volumeMl}.toList()..sort();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vintage != null) ...[
          TextFormField(
            key: const Key('field-vintage'),
            controller: vintage,
            decoration: InputDecoration(labelText: l10n.fieldVintage),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: (text) => validateVintage(l10n, text),
          ),
          const SizedBox(height: 16),
        ],
        DropdownButtonFormField<int>(
          // La clé change avec le volume : le choix suit le type sélectionné.
          key: Key('field-volume-$volumeMl'),
          initialValue: volumeMl,
          decoration: InputDecoration(labelText: l10n.fieldVolume),
          items: [
            for (final v in volumes)
              DropdownMenuItem(value: v, child: Text(formats.volume(v))),
          ],
          onChanged: (v) => v == null ? null : onVolumeChanged(v),
        ),
        const SizedBox(height: 16),
        Text(l10n.fieldQuantity, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        QuantityStepper(value: quantity, onChanged: onQuantityChanged),
      ],
    );
  }
}

/// Millésime facultatif, entre 1800 et l'année prochaine.
String? validateVintage(AppLocalizations l10n, String? text) {
  final value = text?.trim() ?? '';
  if (value.isEmpty) return null;
  final year = int.tryParse(value);
  final max = DateTime.now().year + 1;
  if (year == null || year < 1800 || year > max) {
    return l10n.invalidVintage(max);
  }
  return null;
}

/// Fenêtre de saisie d'une quantité.
Future<int?> _quantityDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required int initial,
  required int min,
}) {
  final l10n = AppLocalizations.of(context);
  var value = initial;
  return showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            QuantityStepper(
              value: value,
              min: min,
              onChanged: (v) => setState(() => value = v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, value),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ),
  );
}

/// Bandeau « … — Annuler » qui disparaît seul (durée réglable, CDC §7).
void _showUndo(
  BuildContext context,
  WidgetRef ref,
  String message,
  String movementId,
) {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(caveRepositoryProvider);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: ref.read(appPreferencesProvider).undoDuration,
        // Sans cela, un bandeau avec action reste affiché indéfiniment.
        persist: false,
        action: SnackBarAction(
          label: l10n.actionUndo,
          onPressed: () => repo.undoMovement(movementId),
        ),
      ),
    );
}

/// Exécute une écriture et affiche un message clair en cas d'échec.
Future<void> _run(BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  try {
    await action();
  } on StateError {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.errorInsufficientStock)),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric('$e'))));
  }
}
