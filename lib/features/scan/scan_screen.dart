import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'zxing_scanner.dart';

/// Ce que l'écran de scan retourne.
sealed class ScanResult {
  const ScanResult();
}

/// Code lu, ou tapé à la main.
class ScannedCode extends ScanResult {
  const ScannedCode(this.code);
  final String code;
}

/// Pas de code-barres : l'utilisateur veut photographier l'étiquette.
class LabelRequested extends ScanResult {
  const LabelRequested();
}

/// Écran de scan d'un code-barres ou d'un QR code (CDC §6.2, §6.3), avec la
/// lampe torche (cave peu éclairée). Retourne le premier code lu, celui tapé
/// à la main, ou la demande de photo d'étiquette ; null si l'utilisateur
/// ferme l'écran.
///
/// La lecture se fait entièrement sur le téléphone, sans réseau, avec ZXing
/// (libre, lot 7 ; ML Kit retiré le 2026-10-10).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, this.offerLabel = true});

  /// Propose « Pas de code-barres ? Photo de l'étiquette » (pas quand on
  /// cherche seulement un code à associer).
  final bool offerLabel;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  late final ZxingScannerController _zxing;

  /// Un code a été retenu : on ignore les détections suivantes.
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _zxing = ZxingScannerController(onCode: _found)..start();
  }

  @override
  void dispose() {
    _zxing.dispose();
    super.dispose();
  }

  void _found(String code) {
    if (_done || code.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    _close(ScannedCode(code.trim()));
  }

  /// Ferme l'écran après avoir **arrêté** le lecteur : la caméra est ainsi
  /// libérée tout de suite. Sinon elle ne l'est qu'à la fin de l'animation de
  /// fermeture, et l'écran de photo d'étiquette, ouvert aussitôt, la trouve
  /// occupée (image figée, boutons sans effet).
  Future<void> _close(ScanResult result) async {
    if (_done) return;
    _done = true;
    await _zxing.stop();
    if (mounted) Navigator.pop(context, result);
  }

  Future<void> _typeCode() async {
    final code = await showDialog<String>(
      context: context,
      builder: (context) => const _ManualCodeDialog(),
    );
    if (code != null && mounted) _found(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    Widget overlay(BuildContext context, BoxConstraints constraints) => Center(
      child: Container(
        width: constraints.maxWidth * 0.8,
        height: constraints.maxWidth * 0.45,
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _viewer(l10n, overlay)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.scanHint, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _torchButton(l10n)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _typeCode,
                          icon: const Icon(Icons.keyboard),
                          label: Text(l10n.scanManualEntry),
                        ),
                      ),
                    ],
                  ),
                  if (widget.offerLabel) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _close(const LabelRequested()),
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: Text(l10n.labelScanInstead),
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

  Widget _viewer(
    AppLocalizations l10n,
    Widget Function(BuildContext, BoxConstraints) overlay,
  ) => ZxingScannerView(
    controller: _zxing,
    errorBuilder: (context, error) => _CameraError(
      message: error.denied
          ? l10n.scanCameraDenied
          : l10n.scanCameraError(error.detail ?? ''),
    ),
    overlayBuilder: overlay,
  );

  Widget _torchButton(AppLocalizations l10n) => ListenableBuilder(
    listenable: _zxing,
    builder: (context, _) => FilledButton.tonalIcon(
      onPressed: _zxing.camera == null ? null : _zxing.toggleTorch,
      icon: Icon(_zxing.torch ? Icons.flashlight_off : Icons.flashlight_on),
      label: Text(_zxing.torch ? l10n.scanTorchOff : l10n.scanTorchOn),
    ),
  );
}

/// Saisie du code à la main. Le champ appartient à la fenêtre : il n'est
/// détruit qu'une fois celle-ci fermée (animation comprise).
class _ManualCodeDialog extends StatefulWidget {
  const _ManualCodeDialog();

  @override
  State<_ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<_ManualCodeDialog> {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.scanManualEntry),
      content: TextField(
        controller: _field,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: l10n.scanManualLabel),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _field.text),
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.no_photography_outlined,
                size: 48,
                color: colors.error,
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
