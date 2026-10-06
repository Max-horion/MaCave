import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Prise de vue d'une étiquette (CDC §6.2), avec la lampe torche (cave peu
/// éclairée). Retourne le chemin de la photo, ou null si l'utilisateur
/// ferme l'écran. La photo est supprimée par l'appelant après la lecture.
class LabelCaptureScreen extends StatefulWidget {
  const LabelCaptureScreen({super.key});

  @override
  State<LabelCaptureScreen> createState() => _LabelCaptureScreenState();
}

class _LabelCaptureScreenState extends State<LabelCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  bool _torch = false;
  bool _taking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // Android libère la caméra quand l'appli passe en arrière-plan.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive) {
      _controller = null;
      controller?.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && controller == null) {
      _start();
    }
  }

  /// [retry] : la caméra peut être encore en cours de libération par un
  /// autre écran (le scan) : un second essai, un peu plus tard.
  Future<void> _start({bool retry = true}) async {
    final l10n = AppLocalizations.of(context);
    CameraController? created;
    try {
      final cameras = await availableCameras();
      final back = cameras.where(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (back.isEmpty && cameras.isEmpty) {
        setState(() => _error = l10n.labelNoCamera);
        return;
      }
      final controller = created = CameraController(
        back.isNotEmpty ? back.first : cameras.first,
        // Assez fin pour les petites mentions (degré, volume).
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _torch = false;
        _error = null;
      });
    } on CameraException catch (e) {
      await created?.dispose();
      if (!mounted) return;
      if (retry && !e.code.contains('AccessDenied')) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) await _start(retry: false);
        return;
      }
      setState(
        () => _error = e.code.contains('AccessDenied')
            ? l10n.scanCameraDenied
            : l10n.scanCameraError(e.description ?? e.code),
      );
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    final on = !_torch;
    await controller.setFlashMode(on ? FlashMode.torch : FlashMode.off);
    if (mounted) setState(() => _torch = on);
  }

  Future<void> _take() async {
    final controller = _controller;
    if (controller == null || _taking) return;
    setState(() => _taking = true);
    try {
      final photo = await controller.takePicture();
      if (_torch) await controller.setFlashMode(FlashMode.off);
      if (mounted) Navigator.pop(context, photo.path);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _taking = false;
        _error = AppLocalizations.of(context)
            .scanCameraError(e.description ?? e.code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, textAlign: TextAlign.center),
                    ),
                  )
                : controller == null || !controller.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        // La prévisualisation est en paysage : on l'affiche
                        // en portrait, recadrée.
                        width: controller.value.previewSize!.height,
                        height: controller.value.previewSize!.width,
                        child: CameraPreview(controller),
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
                  Text(l10n.labelHint, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: controller == null ? null : _toggleTorch,
                          icon: Icon(
                            _torch ? Icons.flashlight_off : Icons.flashlight_on,
                          ),
                          label: Text(
                            _torch ? l10n.scanTorchOff : l10n.scanTorchOn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: controller == null || _taking
                              ? null
                              : _take,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(l10n.labelTake),
                        ),
                      ),
                    ],
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
