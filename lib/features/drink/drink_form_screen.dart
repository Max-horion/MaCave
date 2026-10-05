import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/cave_repository.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/field_rules.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import '../stock_actions.dart';
import 'drink_detail_screen.dart';

/// Formulaire de création (avec le premier lot) ou de modification d'une
/// référence. Les champs affichés dépendent du type (CDC §4.1).
class DrinkFormScreen extends ConsumerStatefulWidget {
  const DrinkFormScreen({super.key, this.drinkId});

  /// Null : création.
  final String? drinkId;

  @override
  ConsumerState<DrinkFormScreen> createState() => _DrinkFormScreenState();
}

class _DrinkFormScreenState extends ConsumerState<DrinkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _producer = TextEditingController();
  final _appellation = TextEditingController();
  final _region = TextEditingController();
  final _country = TextEditingController();
  final _grapes = TextEditingController();
  final _abv = TextEditingController();
  final _comment = TextEditingController();
  final _vintage = TextEditingController();

  String? _typeId;
  int? _rating;
  bool _favorite = false;
  Set<String> _characteristicIds = {};
  int? _volumeMl;
  int _quantity = 1;
  bool _loaded = false;
  bool _saving = false;

  bool get _isNew => widget.drinkId == null;

  @override
  void initState() {
    super.initState();
    // Met à jour l'avertissement « à compléter » pendant la frappe.
    for (final c in [_appellation, _region, _country]) {
      c.addListener(() => setState(() {}));
    }
    if (!_isNew) _loadDrink();
  }

  Future<void> _loadDrink() async {
    final repo = ref.read(caveRepositoryProvider);
    final drink = await repo.drink(widget.drinkId!);
    final characteristics = await repo.drinkCharacteristicIds(widget.drinkId!);
    if (drink == null || !mounted) return;
    setState(() {
      _name.text = drink.name;
      _producer.text = drink.producer ?? '';
      _appellation.text = drink.appellation ?? '';
      _region.text = drink.region ?? '';
      _country.text = drink.country ?? '';
      _grapes.text = drink.grapes ?? '';
      _abv.text = drink.abv?.toString().replaceAll('.', ',') ?? '';
      _comment.text = drink.comment ?? '';
      _typeId = drink.typeId;
      _rating = drink.rating;
      _favorite = drink.favorite;
      _characteristicIds = characteristics;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _name, _producer, _appellation, _region, _country, //
      _grapes, _abv, _comment, _vintage,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _selectType(Classification classification, DrinkType type) {
    setState(() {
      _typeId = type.id;
      _characteristicIds = _characteristicIds.intersection(
        classification.characteristicIdsOf(type.id),
      );
      if (_isNew) _volumeMl = type.defaultVolumeMl;
    });
  }

  double? _parseAbv() => double.tryParse(_abv.text.trim().replaceAll(',', '.'));

  Future<void> _save(DrinkType? type) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(caveRepositoryProvider);
    final profile = type?.fieldProfile;
    // Les champs masqués pour ce type ne sont pas enregistrés.
    String? visible(DrinkField field, TextEditingController c) =>
        profile != null && ruleFor(profile, field) == FieldRule.hidden
        ? null
        : c.text;
    final input = DrinkInput(
      name: _name.text,
      typeId: _typeId,
      producer: _producer.text,
      appellation: visible(DrinkField.appellation, _appellation),
      region: visible(DrinkField.region, _region),
      country: visible(DrinkField.region, _country),
      grapes: visible(DrinkField.grapes, _grapes),
      abv: visible(DrinkField.abv, _abv) == null ? null : _parseAbv(),
      rating: _rating,
      favorite: _favorite,
      comment: _comment.text,
    );
    try {
      if (_isNew) {
        final created = await repo.addNewDrink(
          drink: input,
          characteristicIds: _characteristicIds,
          volumeMl: _volumeMl ?? type?.defaultVolumeMl ?? 750,
          vintage: int.tryParse(_vintage.text.trim()),
          quantity: _quantity,
        );
        if (!mounted) return;
        // Affiche directement la fiche créée.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => DrinkDetailScreen(drinkId: created.drinkId),
          ),
        );
      } else {
        await repo.saveDrink(widget.drinkId!, input, _characteristicIds);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorGeneric('$e')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final classification = ref.watch(classificationProvider).value;
    if (classification == null || (!_isNew && !_loaded)) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // En création, le premier type (Vin) est choisi par défaut.
    if (_isNew && _typeId == null && classification.types.isNotEmpty) {
      _typeId = classification.types.first.id;
      _volumeMl = classification.types.first.defaultVolumeMl;
    }
    final type = classification.type(_typeId);
    final profile = type?.fieldProfile;
    bool shown(DrinkField f) =>
        profile == null || ruleFor(profile, f) != FieldRule.hidden;
    String label(DrinkField f, String text) =>
        profile != null && ruleFor(profile, f) == FieldRule.required
        ? '$text *'
        : text;
    final incomplete = needsCompletion(
      profile: profile,
      appellation: _appellation.text,
      region: _region.text,
      country: _country.text,
    );

    Widget field(
      TextEditingController controller,
      String text, {
      Key? key,
      TextInputType? keyboard,
      List<TextInputFormatter>? formatters,
      String? Function(String?)? validator,
      int maxLines = 1,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: key,
        controller: controller,
        decoration: InputDecoration(labelText: text),
        keyboardType: keyboard,
        inputFormatters: formatters,
        validator: validator,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.formNewTitle : l10n.formEditTitle),
      ),
      // Colonne défilante plutôt que ListView : tous les champs restent
      // construits, donc tous sont vérifiés à l'enregistrement (une ListView
      // ne construit que les champs visibles à l'écran).
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.fieldType, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in classification.types)
                    ChoiceChip(
                      label: Text(t.name),
                      selected: t.id == _typeId,
                      onSelected: (_) => _selectType(classification, t),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              field(
                _name,
                '${l10n.fieldName} *',
                key: const Key('field-name'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.requiredFieldError
                    : null,
              ),
              field(_producer, l10n.fieldProducer),
              if (shown(DrinkField.appellation))
                field(
                  _appellation,
                  label(DrinkField.appellation, l10n.fieldAppellation),
                ),
              if (shown(DrinkField.region)) ...[
                field(_region, label(DrinkField.region, l10n.fieldRegion)),
                field(_country, l10n.fieldCountry),
              ],
              if (incomplete && type != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    l10n.formIncompleteWarning,
                    style: TextStyle(color: theme.colorScheme.tertiary),
                  ),
                ),
              if (shown(DrinkField.grapes)) field(_grapes, l10n.fieldGrapes),
              if (shown(DrinkField.abv))
                field(
                  _abv,
                  l10n.fieldAbv,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final abv = _parseAbv();
                    return abv == null || abv < 0 || abv > 100
                        ? l10n.invalidNumber
                        : null;
                  },
                ),
              if (type != null &&
                  classification.familiesOf(type.id).isNotEmpty) ...[
                Text(
                  l10n.characteristicsSection,
                  style: theme.textTheme.titleMedium,
                ),
                for (final family in classification.familiesOf(type.id)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Text(family.name, style: theme.textTheme.labelLarge),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final value in classification.valuesOf(family.id))
                        FilterChip(
                          label: Text(value.name),
                          selected: _characteristicIds.contains(value.id),
                          onSelected: (on) => setState(() {
                            on
                                ? _characteristicIds.add(value.id)
                                : _characteristicIds.remove(value.id);
                          }),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
              if (_isNew) ...[
                Text(l10n.formLotSection, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                LotFields(
                  vintage: shown(DrinkField.vintage) ? _vintage : null,
                  volumeMl: _volumeMl ?? 750,
                  onVolumeChanged: (v) => setState(() => _volumeMl = v),
                  quantity: _quantity,
                  onQuantityChanged: (q) => setState(() => _quantity = q),
                ),
                const SizedBox(height: 24),
              ],
              Text(l10n.fieldRating, style: theme.textTheme.titleMedium),
              RatingStars(
                value: _rating,
                onChanged: (r) => setState(() => _rating = r),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.favoriteLabel),
                value: _favorite,
                onChanged: (v) => setState(() => _favorite = v),
              ),
              const SizedBox(height: 8),
              field(_comment, l10n.fieldComment, maxLines: 3),
              FilledButton.icon(
                key: const Key('save-drink'),
                onPressed: _saving ? null : () => _save(type),
                icon: const Icon(Icons.check),
                label: Text(l10n.actionSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
