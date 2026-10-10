import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cave_queries.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/drink_draft.dart';
import '../../domain/enums.dart';
import '../../domain/label_reading.dart';
import '../../l10n/app_localizations.dart';
import '../../scan/label_recognizer.dart';
import '../../scan/ocr_engine.dart';
import '../../scan/providers.dart';
import '../../ui/formats.dart';
import '../drink/drink_detail_screen.dart';
import '../drink/drink_form_screen.dart';
import '../stock_actions.dart';
import 'label_capture_screen.dart';

// Photo de l'étiquette (CDC §6.2) : prise de vue, reconnaissance du texte
// sur le téléphone, puis écran de lecture où l'utilisateur valide ou corrige
// les suggestions. La photo est supprimée dès la lecture faite (V1).

/// Ce que l'utilisateur a décidé après la lecture.
sealed class LabelOutcome {
  const LabelOutcome(this.draft);

  /// Ce qui a été lu et validé.
  final DrinkDraft draft;
}

/// Créer une référence avec ces informations (formulaire pré-rempli).
class LabelUseDraft extends LabelOutcome {
  const LabelUseDraft(super.draft);
}

/// Ajouter des bouteilles à une référence existante (doublon reconnu).
class LabelAddToExisting extends LabelOutcome {
  const LabelAddToExisting(this.drink, super.draft);
  final Drink drink;
}

/// Prise de vue de l'étiquette : retourne le chemin de la photo. Remplacée
/// dans les tests (pas d'appareil photo).
final labelPhotoProvider = Provider<Future<String?> Function(BuildContext)>(
  (ref) =>
      (context) => Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const LabelCaptureScreen()),
      ),
);

/// Photographie et lit une étiquette. Null si l'utilisateur abandonne ou si
/// aucun texte n'est lu (un message le dit).
Future<LabelOutcome?> readLabelWithCamera(
  BuildContext context,
  WidgetRef ref,
) async {
  final path = await ref.read(labelPhotoProvider)(context);
  if (path == null || !context.mounted) return null;
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  late final LabelReading reading;
  final navigator = Navigator.of(context);
  // La fenêtre « Lecture… » n'est fermée qu'une fois, quoi qu'il arrive.
  var waiting = true;
  void stopWaiting() {
    if (waiting) navigator.pop();
    waiting = false;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.labelReading)),
          ],
        ),
      ),
    ),
  );
  final List<EngineResult> results;
  try {
    final engine = (await ref.read(ocrPreferencesProvider.future)).engine;
    final index = await ref.read(appellationIndexProvider.future);
    results = [
      for (final (kind, provider) in [
        (OcrEngine.mlKit, labelRecognizerProvider),
        (OcrEngine.tesseract, tesseractRecognizerProvider),
      ])
        if (engine == kind || engine == OcrEngine.compare)
          await _readWith(ref.read(provider), kind, path, index),
    ];
    // La photo n'est plus utile : supprimée tout de suite (CDC §6.2), même
    // si l'utilisateur prend son temps pour comparer ou corriger.
    _deletePhoto(path);
    final usable = results.where((r) => r.reading != null).toList();
    if (usable.isEmpty) throw results.first.error!;
    if (engine != OcrEngine.compare || usable.length == 1) {
      reading = usable.first.reading!;
    } else {
      stopWaiting();
      if (!context.mounted) return null;
      final chosen = await Navigator.push<EngineResult>(
        context,
        MaterialPageRoute(builder: (_) => LabelCompareScreen(results: results)),
      );
      if (chosen == null || !context.mounted) return null;
      await ref
          .read(ocrPreferencesProvider.notifier)
          .recordChoice(chosen.engine);
      if (!context.mounted) return null;
      return await _review(context, chosen.reading!, messenger, l10n);
    }
  } catch (e) {
    stopWaiting();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.errorGeneric('$e')), persist: false),
    );
    return null;
  } finally {
    // La photo n'est pas conservée en V1 (CDC §6.2), même après une erreur.
    _deletePhoto(path);
  }
  stopWaiting();
  if (!context.mounted) return null;
  return _review(context, reading, messenger, l10n);
}

void _deletePhoto(String path) {
  final file = File(path);
  if (file.existsSync()) file.deleteSync();
}

/// Écran de lecture, sauf si rien n'a été lu (un message le dit).
Future<LabelOutcome?> _review(
  BuildContext context,
  LabelReading reading,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
) async {
  if (reading.lines.isEmpty) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.labelNothingRead), persist: false),
    );
    return null;
  }
  return Navigator.push<LabelOutcome>(
    context,
    MaterialPageRoute(builder: (_) => LabelReadingScreen(reading: reading)),
  );
}

/// Résultat d'un moteur sur une photo, avec sa durée (mode comparaison).
class EngineResult {
  const EngineResult({
    required this.engine,
    required this.name,
    required this.took,
    this.reading,
    this.error,
    this.note,
  });

  final OcrEngine engine;
  final String name;
  final Duration took;
  final LabelReading? reading;
  final Object? error;

  /// Diagnostic technique du moteur (bêta).
  final String? note;
}

Future<EngineResult> _readWith(
  LabelRecognizer recognizer,
  OcrEngine engine,
  String path,
  AppellationIndex index,
) async {
  final watch = Stopwatch()..start();
  try {
    final lines = await recognizer.recognize(path);
    return EngineResult(
      engine: engine,
      name: recognizer.name,
      took: watch.elapsed,
      reading: readLabel(lines, index, currentYear: DateTime.now().year),
      note: recognizer.lastNote,
    );
  } catch (e) {
    return EngineResult(
      engine: engine,
      name: recognizer.name,
      took: watch.elapsed,
      error: e,
    );
  }
}

/// Mode comparaison (bêta, CDC §10) : ce que chaque moteur a lu sur la même
/// photo ; l'utilisateur garde le meilleur résultat, et son choix est compté.
class LabelCompareScreen extends ConsumerWidget {
  const LabelCompareScreen({super.key, required this.results});

  final List<EngineResult> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final prefs = ref.watch(ocrPreferencesProvider).value;

    String seconds(Duration d) => l10n.labelCompareSeconds(
      formats.number((d.inMilliseconds / 100).round() / 10),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelCompareTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.labelCompareHelp),
          if (prefs != null)
            Text(
              l10n.labelCompareTally(prefs.chosenMlKit, prefs.chosenTesseract),
              style: theme.textTheme.bodySmall,
            ),
          for (final result in results)
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${result.name} · ${seconds(result.took)}',
                      style: theme.textTheme.titleLarge,
                    ),
                    if (result.note != null)
                      Text(result.note!, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    if (result.reading == null)
                      Text(
                        l10n.errorGeneric('${result.error}'),
                        style: TextStyle(color: theme.colorScheme.error),
                      )
                    else ...[
                      for (final (label, value) in _summary(
                        formats,
                        result.reading!,
                      ))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$label : ',
                                  style: theme.textTheme.bodySmall,
                                ),
                                TextSpan(text: value ?? l10n.labelNotFound),
                              ],
                            ),
                          ),
                        ),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          l10n.labelCompareLines(result.reading!.lines.length),
                        ),
                        children: [
                          for (final line in result.reading!.lines)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(line),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, result),
                        child: Text(l10n.labelCompareKeep(result.name)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static List<(String, String?)> _summary(Formats formats, LabelReading r) {
    final l10n = formats.l10n;
    return [
      (l10n.fieldName, r.name),
      (l10n.fieldProducer, r.producer),
      (l10n.fieldAppellation, r.appellation),
      (l10n.fieldVintage, r.vintage?.toString()),
      (l10n.fieldAbv, r.abv == null ? null : formats.abv(r.abv!)),
      (
        l10n.fieldVolume,
        r.volumeMl == null ? null : formats.volume(r.volumeMl!),
      ),
    ];
  }
}

/// Ajoute des bouteilles à la référence reconnue, millésime et volume
/// pré-remplis d'après l'étiquette. Retourne true si des bouteilles ont été
/// ajoutées.
Future<bool> addToExistingFromLabel(
  BuildContext context,
  WidgetRef ref,
  LabelAddToExisting outcome, {
  String? barcode,
}) {
  final classification = ref.read(classificationProvider).value;
  return showNewLotDialog(
    context,
    ref,
    drinkId: outcome.drink.id,
    type: classification?.type(outcome.drink.typeId),
    barcode: barcode,
    vintage: outcome.draft.vintage,
    volumeMl: outcome.draft.volumeMl,
  );
}

/// Suite d'une lecture lancée hors du formulaire (scan, code inconnu) :
/// formulaire pré-rempli, ou bouteilles ajoutées à la référence reconnue
/// puis sa fiche. [base] : fiche déjà connue (Open Food Facts), complétée
/// par l'étiquette.
Future<void> continueAfterLabel(
  BuildContext context,
  WidgetRef ref,
  LabelOutcome outcome, {
  String? barcode,
  DrinkDraft? base,
}) async {
  switch (outcome) {
    case LabelUseDraft(:final draft):
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DrinkFormScreen(
            barcode: barcode,
            draft: base == null ? draft : draft.fillWith(base),
          ),
        ),
      );
    case LabelAddToExisting(:final drink):
      final added = await addToExistingFromLabel(
        context,
        ref,
        outcome,
        barcode: barcode,
      );
      if (!added || !context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DrinkDetailScreen(drinkId: drink.id),
        ),
      );
  }
}

/// Ce qui a été lu sur l'étiquette : suggestions à valider, lignes à
/// attribuer d'un toucher, références proches de la cave.
class LabelReadingScreen extends ConsumerStatefulWidget {
  const LabelReadingScreen({super.key, required this.reading});

  final LabelReading reading;

  @override
  ConsumerState<LabelReadingScreen> createState() => _LabelReadingScreenState();
}

/// Champ auquel attribuer une ligne.
enum _Field { name, producer, appellation }

class _LabelReadingScreenState extends ConsumerState<LabelReadingScreen> {
  late LabelReading _reading = widget.reading;
  late Future<List<SimilarDrink>> _similar = _findSimilar();

  /// Références de la cave retrouvées dans tout le texte lu (pas seulement
  /// le nom, qui peut être mal lu ou mal choisi), ou proches du nom retenu.
  Future<List<SimilarDrink>> _findSimilar() {
    return ref
        .read(caveQueriesProvider)
        .drinksOnLabel(
          labelText: _reading.lines.join('\n'),
          name: _reading.name,
          producer: _reading.producer,
          profile: _reading.toDraft().profile,
        );
  }

  void _set(_Field field, String? value) {
    setState(() {
      _reading = switch (field) {
        _Field.name => _reading.copyWith(name: () => value),
        _Field.producer => _reading.copyWith(producer: () => value),
        _Field.appellation => _reading.copyWith(appellation: () => value),
      };
      if (field != _Field.appellation) _similar = _findSimilar();
    });
  }

  /// Attribue une ligne (remise en forme : « CHÂTEAU » → « Château ») à un
  /// champ, à la place de son contenu ou à la suite : un nom découpé en
  /// plusieurs lignes se recompose en quelques touchers.
  Future<void> _assign(String line) async {
    final l10n = AppLocalizations.of(context);
    final text = tidyLabelText(line);
    final choice = await showModalBottomSheet<(_Field, bool)>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              for (final (field, label) in [
                (_Field.name, l10n.labelUseAsName),
                (_Field.producer, l10n.labelUseAsProducer),
                (_Field.appellation, l10n.labelUseAsAppellation),
              ])
                ListTile(
                  minTileHeight: 56,
                  title: Text(label),
                  onTap: () => Navigator.pop(context, (field, false)),
                ),
              for (final (field, label, current) in [
                (_Field.name, l10n.labelAppendToName, _reading.name),
                (
                  _Field.producer,
                  l10n.labelAppendToProducer,
                  _reading.producer,
                ),
              ])
                if (current != null && current.isNotEmpty)
                  ListTile(
                    minTileHeight: 56,
                    leading: const Icon(Icons.playlist_add),
                    title: Text(label),
                    subtitle: Text('$current $text'),
                    onTap: () => Navigator.pop(context, (field, true)),
                  ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    final (field, append) = choice;
    final current = switch (field) {
      _Field.name => _reading.name,
      _Field.producer => _reading.producer,
      _Field.appellation => _reading.appellation,
    };
    _set(field, append ? '$current $text' : text);
  }

  @override
  Widget build(BuildContext context) {
    final formats = Formats.of(context);
    final l10n = formats.l10n;
    final theme = Theme.of(context);
    final r = _reading;
    final draft = r.toDraft();

    Widget field(String label, String? value, {_Field? editable}) => ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 56,
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(
        value ?? l10n.labelNotFound,
        style: value == null
            ? TextStyle(color: theme.colorScheme.onSurfaceVariant)
            : theme.textTheme.titleMedium,
      ),
      trailing: editable != null && value != null
          ? IconButton(
              tooltip: l10n.labelClear,
              icon: const Icon(Icons.clear),
              onPressed: () => _set(editable, null),
            )
          : null,
    );

    final type = switch (draft.profile) {
      FieldProfile.wine => l10n.labelTypeWine,
      FieldProfile.beer => l10n.labelTypeBeer,
      FieldProfile.spirit => l10n.labelTypeSpirit,
      FieldProfile.soft => l10n.labelTypeSoft,
      null => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelReadTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(l10n.labelReadHelp),
          const SizedBox(height: 8),
          field(l10n.fieldName, r.name, editable: _Field.name),
          field(l10n.fieldProducer, r.producer, editable: _Field.producer),
          field(
            l10n.fieldAppellation,
            r.appellation,
            editable: _Field.appellation,
          ),
          field(l10n.fieldVintage, r.vintage?.toString()),
          field(l10n.fieldAbv, r.abv == null ? null : formats.abv(r.abv!)),
          field(
            l10n.fieldVolume,
            r.volumeMl == null ? null : formats.volume(r.volumeMl!),
          ),
          field(
            l10n.fieldType,
            type == null ? null : [type, ...draft.characteristics].join(' · '),
          ),
          FutureBuilder<List<SimilarDrink>>(
            future: _similar,
            builder: (context, snapshot) {
              final similar = snapshot.data ?? const [];
              if (similar.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(l10n.scanMaybeTitle, style: theme.textTheme.titleMedium),
                  Text(l10n.labelMaybeHelp, style: theme.textTheme.bodySmall),
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
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () => Navigator.pop(
                        context,
                        LabelAddToExisting(s.drink, draft),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, LabelUseDraft(draft)),
            icon: const Icon(Icons.check),
            label: Text(l10n.labelContinue),
          ),
          const SizedBox(height: 24),
          Text(l10n.labelLinesTitle, style: theme.textTheme.titleMedium),
          Text(l10n.labelLinesHelp, style: theme.textTheme.bodySmall),
          for (final line in r.lines)
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 48,
              title: Text(tidyLabelText(line)),
              trailing: const Icon(Icons.touch_app_outlined),
              onTap: () => _assign(line),
            ),
        ],
      ),
    );
  }
}
