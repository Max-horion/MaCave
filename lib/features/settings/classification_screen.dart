import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/enums.dart';
import '../../domain/text.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../ui/formats.dart';

/// Gestion de la classification (CDC §6.1, §7) : types, familles de
/// caractéristiques et valeurs. Les suppressions sont logiques et les
/// références rattachées restent dans la cave, « sans catégorie ».
class ClassificationScreen extends ConsumerWidget {
  const ClassificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final classification = ref.watch(classificationProvider).value;
    final types = classification?.types ?? const <DrinkType>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.classTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createType(context, ref, types),
        icon: const Icon(Icons.add),
        label: Text(l10n.classAddType),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(l10n.classHelp, style: theme.textTheme.bodySmall),
          ),
          for (final type in types)
            ListTile(
              minTileHeight: AppTheme.minButtonHeight,
              title: Text(type.name),
              subtitle: Text(
                l10n.classTypeSummary(
                  profileLabel(l10n, type.fieldProfile),
                  formats.volume(type.defaultVolumeMl),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => TypeClassificationScreen(typeId: type.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _createType(
    BuildContext context,
    WidgetRef ref,
    List<DrinkType> types,
  ) async {
    final created = await showDialog<_NewType>(
      context: context,
      builder: (_) => _NewTypeDialog(taken: {for (final t in types) t.name}),
    );
    if (created == null) return;
    await ref
        .read(caveRepositoryProvider)
        .createType(
          name: created.name,
          profile: created.profile,
          defaultVolumeMl: created.volumeMl,
        );
  }
}

String profileLabel(AppLocalizations l10n, FieldProfile profile) =>
    switch (profile) {
      FieldProfile.wine => l10n.profileWine,
      FieldProfile.beer => l10n.profileBeer,
      FieldProfile.spirit => l10n.profileSpirit,
      FieldProfile.soft => l10n.profileSoft,
    };

String _profileHelp(AppLocalizations l10n, FieldProfile profile) =>
    switch (profile) {
      FieldProfile.wine => l10n.profileWineHelp,
      FieldProfile.beer => l10n.profileBeerHelp,
      FieldProfile.spirit => l10n.profileSpiritHelp,
      FieldProfile.soft => l10n.profileSoftHelp,
    };

/// Un type : ses familles et leurs valeurs.
class TypeClassificationScreen extends ConsumerWidget {
  const TypeClassificationScreen({super.key, required this.typeId});

  final String typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final classification = ref.watch(classificationProvider).value;
    final type = classification?.type(typeId);
    if (classification == null || type == null) {
      // Type supprimé (ici ou par la synchronisation).
      return Scaffold(appBar: AppBar());
    }
    final families = classification.familiesOf(typeId);
    final repo = ref.read(caveRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(type.name),
        actions: [
          IconButton(
            tooltip: l10n.classRename,
            onPressed: () async {
              final name = await askName(
                context,
                title: l10n.classRename,
                initial: type.name,
                taken: {for (final t in classification.types) t.name},
              );
              if (name != null) await repo.renameType(type.id, name);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: l10n.classDelete,
            onPressed: () => _deleteType(context, ref, classification, type),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            profileLabel(l10n, type.fieldProfile),
            style: theme.textTheme.titleSmall,
          ),
          Text(
            _profileHelp(l10n, type.fieldProfile),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (families.isEmpty) Text(l10n.classNoFamily),
          for (final family in families)
            _FamilyCard(
              family: family,
              classification: classification,
              siblings: {for (final f in families) f.name},
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final name = await askName(
                context,
                title: l10n.classNewFamily,
                taken: {for (final f in families) f.name},
              );
              if (name != null) await repo.createFamily(type.id, name);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.classAddFamily),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteType(
    BuildContext context,
    WidgetRef ref,
    Classification classification,
    DrinkType type,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (classification.types.length <= 1) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.classLastType), persist: false),
      );
      return;
    }
    final repo = ref.read(caveRepositoryProvider);
    final count = await repo.drinkCountOfType(type.id);
    if (!context.mounted) return;
    final confirmed = await confirmDeletion(
      context,
      title: l10n.classDeleteTypeTitle(type.name),
      message: l10n.classDeleteTypeMessage(count),
    );
    if (!confirmed || !context.mounted) return;
    Navigator.pop(context);
    await repo.deleteType(type.id);
  }
}

/// Une famille : son nom, ses valeurs, et de quoi les modifier.
class _FamilyCard extends ConsumerWidget {
  const _FamilyCard({
    required this.family,
    required this.classification,
    required this.siblings,
  });

  final CharacteristicFamily family;
  final Classification classification;

  /// Noms des familles du même type (doublons refusés).
  final Set<String> siblings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(caveRepositoryProvider);
    final values = classification.valuesOf(family.id);
    final valueNames = {for (final v in values) v.name};

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            minTileHeight: AppTheme.minButtonHeight,
            title: Text(family.name, style: theme.textTheme.titleMedium),
            trailing: _EditMenu(
              onRename: () async {
                final name = await askName(
                  context,
                  title: l10n.classRename,
                  initial: family.name,
                  taken: siblings,
                );
                if (name != null) await repo.renameFamily(family.id, name);
              },
              onDelete: () async {
                final count = await repo.drinkCountWithCharacteristics(
                  values.map((v) => v.id),
                );
                if (!context.mounted) return;
                final ok = await confirmDeletion(
                  context,
                  title: l10n.classDeleteFamilyTitle(family.name),
                  message: l10n.classDeleteCharMessage(count),
                );
                if (ok) await repo.deleteFamily(family.id);
              },
            ),
          ),
          if (values.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.classNoValue, style: theme.textTheme.bodySmall),
            ),
          for (final value in values)
            ListTile(
              minTileHeight: AppTheme.minButtonHeight,
              contentPadding: const EdgeInsets.only(left: 32, right: 16),
              title: Text(value.name),
              trailing: _EditMenu(
                onRename: () async {
                  final name = await askName(
                    context,
                    title: l10n.classRename,
                    initial: value.name,
                    taken: valueNames,
                  );
                  if (name != null) {
                    await repo.renameCharacteristic(value.id, name);
                  }
                },
                onDelete: () async {
                  final count = await repo.drinkCountWithCharacteristics([
                    value.id,
                  ]);
                  if (!context.mounted) return;
                  final ok = await confirmDeletion(
                    context,
                    title: l10n.classDeleteValueTitle(value.name),
                    message: l10n.classDeleteCharMessage(count),
                  );
                  if (ok) await repo.deleteCharacteristic(value.id);
                },
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
              child: TextButton.icon(
                onPressed: () async {
                  final name = await askName(
                    context,
                    title: l10n.classNewValue(family.name),
                    taken: valueNames,
                  );
                  if (name != null) {
                    await repo.createCharacteristic(family.id, name);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.classAddValue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu « ⋮ » d'une famille ou d'une valeur.
class _EditMenu extends StatelessWidget {
  const _EditMenu({required this.onRename, required this.onDelete});

  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<VoidCallback>(
      onSelected: (action) => action(),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: onRename,
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.classRename),
          ),
        ),
        PopupMenuItem(
          value: onDelete,
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.classDelete),
          ),
        ),
      ],
    );
  }
}

/// Demande un nom (création ou renommage). Refuse un nom vide ou déjà pris
/// au même endroit (sans tenir compte des accents ni des majuscules).
/// Null : annulé ou inchangé.
Future<String?> askName(
  BuildContext context, {
  required String title,
  String? initial,
  required Set<String> taken,
}) async {
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(title: title, initial: initial, taken: taken),
  );
  if (name == null || name == initial) return null;
  return name;
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, this.initial, required this.taken});

  final String title;
  final String? initial;
  final Set<String> taken;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, _name.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.className),
          validator: (v) => validateClassName(
            l10n,
            v,
            taken: widget.taken,
            initial: widget.initial,
          ),
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionOk)),
      ],
    );
  }
}

/// Nom vide, ou déjà utilisé par un voisin ([initial] excepté).
String? validateClassName(
  AppLocalizations l10n,
  String? value, {
  required Set<String> taken,
  String? initial,
}) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return l10n.classNameRequired;
  final key = fold(name);
  final others = taken.where((t) => t != initial).map(fold);
  if (others.contains(key)) return l10n.classNameTaken;
  return null;
}

/// Confirmation d'une suppression.
Future<bool> confirmDeletion(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.classDelete),
        ),
      ],
    ),
  );
  return ok == true;
}

typedef _NewType = ({String name, FieldProfile profile, int volumeMl});

/// Création d'un type : nom, profil de champs, volume par défaut.
class _NewTypeDialog extends StatefulWidget {
  const _NewTypeDialog({required this.taken});

  final Set<String> taken;

  @override
  State<_NewTypeDialog> createState() => _NewTypeDialogState();
}

class _NewTypeDialogState extends State<_NewTypeDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  var _profile = FieldProfile.wine;
  var _volumeMl = 750;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.classNewType),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.className),
                validator: (v) =>
                    validateClassName(l10n, v, taken: widget.taken),
              ),
              const SizedBox(height: 16),
              Text(l10n.classProfile, style: theme.textTheme.titleSmall),
              Text(l10n.classProfileHelp, style: theme.textTheme.bodySmall),
              RadioGroup<FieldProfile>(
                groupValue: _profile,
                onChanged: (p) => setState(() => _profile = p ?? _profile),
                child: Column(
                  children: [
                    for (final p in FieldProfile.values)
                      RadioListTile<FieldProfile>(
                        contentPadding: EdgeInsets.zero,
                        value: p,
                        title: Text(profileLabel(l10n, p)),
                        subtitle: Text(_profileHelp(l10n, p)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _volumeMl,
                decoration: InputDecoration(labelText: l10n.fieldVolume),
                items: [
                  for (final v in standardVolumesMl)
                    DropdownMenuItem(value: v, child: Text(formats.volume(v))),
                ],
                onChanged: (v) => setState(() => _volumeMl = v ?? _volumeMl),
              ),
            ],
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
            if (!_form.currentState!.validate()) return;
            Navigator.pop<_NewType>(context, (
              name: _name.text.trim(),
              profile: _profile,
              volumeMl: _volumeMl,
            ));
          },
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}
