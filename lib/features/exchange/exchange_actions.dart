import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/exchange/cave_import.dart';
import '../../data/exchange/csv_export.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

// ───────────────────────────────── Export ─────────────────────────────────

enum _ExportTarget { share, save }

/// Export CSV de la cave (CDC §6.7) : partage ou enregistrement des deux
/// fichiers, stock et historique.
Future<void> startExport(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final target = await showModalBottomSheet<_ExportTarget>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.exportTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(l10n.exportHelp),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, _ExportTarget.share),
              icon: const Icon(Icons.share),
              label: Text(l10n.exportShare),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, _ExportTarget.save),
              icon: const Icon(Icons.save_alt),
              label: Text(l10n.exportSave),
            ),
          ],
        ),
      ),
    ),
  );
  if (target == null) return;

  try {
    final export = await exportCsv(ref.read(databaseProvider));
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final files = {
      l10n.exportFileStock(date): utf8.encode(export.stock),
      l10n.exportFileHistory(date): utf8.encode(export.history),
    };
    switch (target) {
      case _ExportTarget.share:
        final dir = await getTemporaryDirectory();
        final xFiles = <XFile>[];
        for (final MapEntry(key: name, value: bytes) in files.entries) {
          final file = File('${dir.path}/$name');
          await file.writeAsBytes(bytes, flush: true);
          xFiles.add(XFile(file.path, mimeType: 'text/csv'));
        }
        await SharePlus.instance.share(ShareParams(files: xFiles));
      case _ExportTarget.save:
        var saved = 0;
        for (final MapEntry(key: name, value: bytes) in files.entries) {
          final uri = await FilePicker.saveFile(
            fileName: name,
            bytes: Uint8List.fromList(bytes),
            mimeType: 'text/csv',
          );
          if (uri != null) saved++;
        }
        if (saved > 0) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.exportSaved(saved))),
          );
        }
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric('$e'))));
  }
}

// ───────────────────────────────── Import ─────────────────────────────────

/// Import d'un fichier CSV (sauvegarde Ma Cave ou export Vivino) : choix du
/// fichier, aperçu du bilan, puis confirmation (CDC §6.7).
Future<void> startImport(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final String content;
  try {
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty) return;
    content = decodeText(await picked.first.xFile.readAsBytes());
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.importUnreadable('$e'))),
    );
    return;
  }

  final importer = CaveImporter(
    ref.read(databaseProvider),
    ref.read(writeContextProvider),
  );
  final preview = await importer.preview(content);
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ImportPreviewDialog(report: preview),
  );
  if (confirmed != true) return;

  try {
    final report = await importer.apply(content);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.importDone} — ${report.kind == ImportKind.history ? l10n.importMovements(report.movementsAdded) : l10n.importBottles(report.bottlesAdded)}',
        ),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric('$e'))));
  }
}

/// Texte d'un fichier : UTF-8 (Ma Cave, Vivino, LibreOffice), sinon
/// Windows-1252, l'encodage d'un CSV enregistré par Excel en français.
String decodeText(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}

/// Bilan d'un import avant confirmation.
class ImportPreviewDialog extends StatelessWidget {
  const ImportPreviewDialog({super.key, required this.report});

  final ImportReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final kind = report.kind;

    final lines = <String>[
      if (kind == ImportKind.stock || kind == ImportKind.vivino) ...[
        l10n.importDrinksCreated(report.drinksCreated),
        l10n.importLotsCreated(report.lotsCreated),
        l10n.importBottles(report.bottlesAdded),
        if (report.lotsAdjusted > 0)
          l10n.importLotsAdjusted(report.lotsAdjusted),
        if (report.lotsSkipped > 0) l10n.importLotsSkipped(report.lotsSkipped),
        if (report.needsCompletion > 0)
          l10n.importNeedsCompletion(report.needsCompletion),
      ],
      if (kind == ImportKind.history) ...[
        l10n.importMovements(report.movementsAdded),
        if (report.movementsSkipped > 0)
          l10n.importMovementsSkipped(report.movementsSkipped),
      ],
      if (report.unknownCharacteristics.isNotEmpty)
        l10n.importUnknownCharacteristics(
          report.unknownCharacteristics.join(', '),
        ),
    ];

    return AlertDialog(
      title: Text(l10n.importPreviewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kind != null)
              Text(switch (kind) {
                ImportKind.stock => l10n.importKindStock,
                ImportKind.history => l10n.importKindHistory,
                ImportKind.vivino => l10n.importKindVivino,
              }, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $line'),
              ),
            if (kind != null && !report.hasChanges) ...[
              const SizedBox(height: 8),
              Text(l10n.importNothing),
            ],
            if (report.issues.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.importIssuesTitle(report.issues.length),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              for (final issue in report.issues.take(20))
                Text(
                  l10n.importIssueLine(issue.line, _issueMessage(l10n, issue)),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        if (report.hasChanges)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.importConfirm),
          ),
      ],
    );
  }

  static String _issueMessage(
    AppLocalizations l10n,
    ImportIssue issue,
  ) => switch (issue.code) {
    ImportIssueCode.unknownFormat => l10n.issueUnknownFormat,
    ImportIssueCode.missingName => l10n.issueMissingName,
    ImportIssueCode.invalidVolume => l10n.issueInvalidVolume(issue.detail),
    ImportIssueCode.invalidVintage => l10n.issueInvalidVintage(issue.detail),
    ImportIssueCode.invalidStock => l10n.issueInvalidStock(issue.detail),
    ImportIssueCode.unknownLot => l10n.issueUnknownLot(issue.detail),
    ImportIssueCode.invalidDate => l10n.issueInvalidDate(issue.detail),
    ImportIssueCode.invalidKind => l10n.issueInvalidKind(issue.detail),
    ImportIssueCode.invalidQuantity => l10n.issueInvalidQuantity(issue.detail),
  };
}
