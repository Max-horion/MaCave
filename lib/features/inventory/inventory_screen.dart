import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/providers.dart';
import '../../ui/formats.dart';
import '../../ui/widgets.dart';
import '../../ui/layout.dart';

/// Inventaire guidé (CDC §5, §6.4) : les lots défilent un par un ; chacun est
/// confirmé d'un geste ou corrigé (ajustement d'inventaire).
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

enum _Phase { intro, running, done }

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  _Phase _phase = _Phase.intro;
  bool _includeExhausted = false;
  int? _lotCount;

  /// Lots figés au démarrage : l'ordre ne bouge pas pendant le parcours.
  List<InventoryItem> _items = const [];
  int _index = 0;
  bool _correcting = false;
  int _value = 0;

  /// Résultat par lot parcouru : nombre constaté, et s'il a été corrigé.
  final Map<int, ({int counted, bool corrected})> _results = {};

  @override
  void initState() {
    super.initState();
    _countLots();
  }

  Future<void> _countLots() async {
    final items = await ref
        .read(caveQueriesProvider)
        .inventoryLots(includeExhausted: _includeExhausted);
    if (mounted) setState(() => _lotCount = items.length);
  }

  Future<void> _start() async {
    final items = await ref
        .read(caveQueriesProvider)
        .inventoryLots(includeExhausted: _includeExhausted);
    if (!mounted) return;
    setState(() {
      _items = items;
      _index = 0;
      _results.clear();
      _phase = items.isEmpty ? _Phase.done : _Phase.running;
    });
  }

  int _recorded(int index) =>
      _results[index]?.counted ?? _items[index].lot.stock;

  Future<void> _record(int counted) async {
    final item = _items[_index];
    final recorded = _recorded(_index);
    if (counted != recorded) {
      await ref
          .read(caveRepositoryProvider)
          .recordInventory(item.lot.id, counted);
    }
    final wasCorrected = _results[_index]?.corrected ?? false;
    _results[_index] = (
      counted: counted,
      corrected: wasCorrected || counted != item.lot.stock,
    );
    if (!mounted) return;
    setState(() {
      _correcting = false;
      if (_index + 1 < _items.length) {
        _index++;
      } else {
        _phase = _Phase.done;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.inventoryTitle)),
      body: ReadableWidth(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: switch (_phase) {
              _Phase.intro => _buildIntro(context),
              _Phase.running => _buildLot(context, formats),
              _Phase.done => _buildDone(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final l10n = Formats.of(context).l10n;
    final count = _lotCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.inventoryIntro, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.inventoryIncludeExhausted),
          value: _includeExhausted,
          onChanged: (v) {
            setState(() => _includeExhausted = v);
            _countLots();
          },
        ),
        const SizedBox(height: 8),
        if (count != null)
          Text(
            l10n.inventoryLotCount(count),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        const Spacer(),
        FilledButton.icon(
          onPressed: count == null || count == 0 ? null : _start,
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.inventoryStart),
        ),
      ],
    );
  }

  Widget _buildLot(BuildContext context, Formats formats) {
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final item = _items[_index];
    final recorded = _recorded(_index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: (_index + 1) / _items.length),
        const SizedBox(height: 8),
        Text(
          l10n.inventoryProgress(_index + 1, _items.length),
          textAlign: TextAlign.end,
        ),
        const Spacer(),
        Text(
          item.drinkName,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          formats.lotExplicit(item.lot),
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (_correcting)
          QuantityStepper(
            value: _value,
            min: 0,
            onChanged: (v) => setState(() => _value = v),
          )
        else ...[
          Text(l10n.inventoryRecorded, textAlign: TextAlign.center),
          Text(
            formats.number(recorded),
            key: const Key('inventory-recorded'),
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        if (_correcting)
          FilledButton.icon(
            onPressed: () => _record(_value),
            icon: const Icon(Icons.check),
            label: Text(l10n.inventoryValidate),
          )
        else ...[
          FilledButton.icon(
            onPressed: () => _record(recorded),
            icon: const Icon(Icons.check),
            label: Text(l10n.inventoryConfirm),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _correcting = true;
              _value = recorded;
            }),
            icon: const Icon(Icons.edit),
            label: Text(l10n.inventoryCorrect),
          ),
        ],
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _index == 0
              ? null
              : () => setState(() {
                  _correcting = false;
                  _index--;
                }),
          icon: const Icon(Icons.arrow_back),
          label: Text(l10n.inventoryPrevious),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    final l10n = Formats.of(context).l10n;
    final corrected = _results.values.where((r) => r.corrected).length;
    return EmptyMessage(
      icon: Icons.task_alt,
      title: l10n.inventoryDoneTitle,
      message: l10n.inventorySummary(_results.length - corrected, corrected),
      action: FilledButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n.inventoryFinish),
      ),
    );
  }
}
