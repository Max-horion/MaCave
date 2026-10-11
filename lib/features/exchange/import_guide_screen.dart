import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/exchange/exchange_format.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'exchange_actions.dart';
import '../../ui/layout.dart';

/// Consignes pour préparer un fichier d'import dans un tableur (CDC §6.7) :
/// règles générales, colonnes, types et caractéristiques reconnus, fichier
/// modèle à remplir.
class ImportGuideScreen extends ConsumerWidget {
  const ImportGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final classification = ref.watch(classificationProvider).value;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );

    // Colonne, puis ce qu'on y écrit.
    final columns = [
      (StockColumns.type, l10n.importGuideColType),
      (StockColumns.name, l10n.importGuideColName),
      (
        '${StockColumns.producer}, ${StockColumns.appellation}, '
            '${StockColumns.region}, ${StockColumns.country}, '
            '${StockColumns.grapes}',
        l10n.importGuideColText,
      ),
      (StockColumns.abv, l10n.importGuideColAbv),
      (StockColumns.rating, l10n.importGuideColRating),
      (StockColumns.favorite, l10n.importGuideColFavorite(yes)),
      (StockColumns.comment, l10n.importGuideColComment),
      (
        StockColumns.characteristics,
        l10n.importGuideColCharacteristics(
          familySeparator.trim(),
          characteristicSeparator.trim(),
        ),
      ),
      (StockColumns.vintage, l10n.importGuideColVintage),
      (StockColumns.volumeMl, l10n.importGuideColVolume),
      (StockColumns.barcode, l10n.importGuideColBarcode),
      (StockColumns.stock, l10n.importGuideColStock),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importGuideTitle)),
      body: ReadableWidth(
        child: ListView(
          key: const Key('import-guide'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(l10n.importGuideIntro),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => deliverImportTemplate(context, ref),
              icon: const Icon(Icons.download),
              label: Text(l10n.importTemplateGet),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => pickAndImport(context, ref),
              icon: const Icon(Icons.file_open),
              label: Text(l10n.importGuideImport),
            ),
            section(l10n.importGuideRulesTitle),
            bullet(l10n.importGuideRuleLot),
            bullet(l10n.importGuideRuleHeader),
            bullet(l10n.importGuideRuleCsv),
            bullet(l10n.importGuideRuleIncomplete),
            bullet(l10n.importGuideRuleAgain),
            section(l10n.importGuideColumnsTitle),
            for (final (column, help) in columns)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      column,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(help),
                  ],
                ),
              ),
            section(l10n.importGuideTypesTitle),
            Text(l10n.importGuideTypesHelp),
            const SizedBox(height: 8),
            if (classification != null)
              for (final type in classification.types)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (final family in classification.familiesOf(type.id))
                        Text(
                          '${family.name}$familySeparator'
                          '${classification.valuesOf(family.id).map((v) => v.name).join(', ')}',
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
