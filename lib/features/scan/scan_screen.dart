import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import '../../scan/barcode_engine.dart';
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
/// La lecture se fait entièrement sur le téléphone, sans réseau : ML Kit
/// embarqué, ou ZXing (libre, lot 7), au choix pendant l'essai.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, this.offerLabel = true});

  /// Propose « Pas de code-barres ? Photo de l'étiquette » (pas quand on
  /// cherche seulement un code à associer).
  final bool offerLabel;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  /// Lecteur affiché ; un seul des deux contrôleurs existe à la fois (ils se
  /// partagent la caméra).
  BarcodeEngine? _engine;
  MobileScannerController? _mlKit;
  ZxingScannerController? _zxing;

  /// Un code a été retenu : on ignore les détections suivantes.
  bool _done = false;

  @override
  void initState() {
    super.initState();
    ref.read(barcodeEngineProvider.future).then(_use);
  }

  @override
  void dispose() {
    _mlKit?.dispose();
    _zxing?.dispose();
    super.dispose();
  }

  /// Passe au lecteur [engine] : l'autre est arrêté et retiré de l'écran
  /// **avant** d'ouvrir la caméra pour le nouveau.
  Future<void> _use(BarcodeEngine engine) async {
    if (!mounted || _done || engine == _engine) return;
    final oldMlKit = _mlKit;
    final oldZxing = _zxing;
    setState(() {
      _engine = engine;
      _mlKit = null;
      _zxing = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (oldMlKit != null) {
      await oldMlKit.stop();
      await oldMlKit.dispose();
    }
    if (oldZxing != null) {
      await oldZxing.stop();
      oldZxing.dispose();
    }
    // Choix changé entre-temps : c'est l'appel suivant qui ouvre la caméra.
    if (!mounted || _done || _engine != engine) return;
    setState(() {
      switch (engine) {
        case BarcodeEngine.mlKit:
          _mlKit = MobileScannerController(
            // Un seul code suffit : on s'arrête au premier.
            detectionSpeed: DetectionSpeed.noDuplicates,
          );
        case BarcodeEngine.zxing:
          _zxing = ZxingScannerController(onCode: _found)..start();
      }
    });
  }

  Future<void> _choose(BarcodeEngine engine) async {
    await ref.read(barcodeEngineProvider.notifier).setEngine(engine);
    await _use(engine);
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
    await _mlKit?.stop();
    await _zxing?.stop();
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
                  if (_engine case final engine?) ...[
                    _EngineChoice(engine: engine, onChanged: _choose),
                    const SizedBox(height: 12),
                  ],
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
  ) {
    if (_mlKit case final controller?) {
      return MobileScanner(
        controller: controller,
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
          message: error.errorCode == MobileScannerErrorCode.permissionDenied
              ? l10n.scanCameraDenied
              : l10n.scanCameraError(
                  error.errorDetails?.message ?? error.errorCode.name,
                ),
        ),
        overlayBuilder: overlay,
      );
    }
    if (_zxing case final controller?) {
      return ZxingScannerView(
        controller: controller,
        errorBuilder: (context, error) => _CameraError(
          message: error.denied
              ? l10n.scanCameraDenied
              : l10n.scanCameraError(error.detail ?? ''),
        ),
        overlayBuilder: overlay,
      );
    }
    // Entre deux lecteurs.
    return const Center(child: CircularProgressIndicator());
  }

  Widget _torchButton(AppLocalizations l10n) {
    Widget button({required bool on, VoidCallback? onPressed}) =>
        FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(on ? Icons.flashlight_off : Icons.flashlight_on),
          label: Text(on ? l10n.scanTorchOff : l10n.scanTorchOn),
        );
    if (_mlKit case final controller?) {
      return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, _) => button(
          on: state.torchState == TorchState.on,
          onPressed: state.torchState == TorchState.unavailable
              ? null
              : controller.toggleTorch,
        ),
      );
    }
    if (_zxing case final controller?) {
      return ListenableBuilder(
        listenable: controller,
        builder: (context, _) => button(
          on: controller.torch,
          onPressed: controller.camera == null ? null : controller.toggleTorch,
        ),
      );
    }
    return button(on: false);
  }
}

/// Choix du lecteur pendant l'essai (lot 7), retenu sur cet appareil.
class _EngineChoice extends StatelessWidget {
  const _EngineChoice({required this.engine, required this.onChanged});

  final BarcodeEngine engine;
  final ValueChanged<BarcodeEngine> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.scanEngine,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        SegmentedButton<BarcodeEngine>(
          segments: [
            ButtonSegment(
              value: BarcodeEngine.mlKit,
              label: Text(l10n.scanEngineMlKit),
            ),
            ButtonSegment(
              value: BarcodeEngine.zxing,
              label: Text(l10n.scanEngineZxing),
            ),
          ],
          selected: {engine},
          onSelectionChanged: (s) => onChanged(s.single),
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
