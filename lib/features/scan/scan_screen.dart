import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';

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
/// La lecture se fait entièrement sur le téléphone (ML Kit embarqué) : pas
/// besoin de réseau dans la cave.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(
    // Un seul code suffit : on s'arrête au premier.
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// Un code a été retenu : on ignore les détections suivantes.
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
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
    await _controller.stop();
    if (mounted) Navigator.pop(context, result);
  }

  Future<void> _typeCode() async {
    final l10n = AppLocalizations.of(context);
    final field = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanManualEntry),
        content: TextField(
          controller: field,
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
            onPressed: () => Navigator.pop(context, field.text),
            child: Text(l10n.actionOk),
          ),
        ],
      ),
    );
    field.dispose();
    if (code != null && mounted) _found(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  final value = barcode.rawValue;
                  if (value != null && value.trim().isNotEmpty) {
                    _found(value);
                    return;
                  }
                }
              },
              errorBuilder: (context, error) => _CameraError(
                message:
                    error.errorCode == MobileScannerErrorCode.permissionDenied
                    ? l10n.scanCameraDenied
                    : l10n.scanCameraError(
                        error.errorDetails?.message ?? error.errorCode.name,
                      ),
              ),
              overlayBuilder: (context, constraints) => Center(
                child: Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxWidth * 0.45,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.primary, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
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
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (context, state, _) {
                            final on = state.torchState == TorchState.on;
                            return FilledButton.tonalIcon(
                              onPressed:
                                  state.torchState == TorchState.unavailable
                                  ? null
                                  : _controller.toggleTorch,
                              icon: Icon(
                                on ? Icons.flashlight_off : Icons.flashlight_on,
                              ),
                              label: Text(
                                on ? l10n.scanTorchOff : l10n.scanTorchOn,
                              ),
                            );
                          },
                        ),
                      ),
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
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _close(const LabelRequested()),
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: Text(l10n.labelScanInstead),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
