import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../scan/zxing_reader.dart';

/// Pourquoi la caméra ne montre rien.
class ScannerCameraError {
  const ScannerCameraError({this.denied = false, this.detail});

  /// L'utilisateur a refusé l'accès à la caméra.
  final bool denied;
  final String? detail;
}

/// Lecteur de codes-barres libre (lot 7) : la caméra (paquet camera) envoie
/// ses images à ZXing ([FrameDecoder]), une à la fois (les images qui
/// arrivent pendant une lecture sont ignorées). [onCode] reçoit le premier
/// code confirmé ([ReadConfirmer]), une seule fois.
class ZxingScannerController extends ChangeNotifier {
  ZxingScannerController({required this.onCode, FrameDecoder? decoder})
    : _decoder = decoder ?? ZxingFrameDecoder();

  final void Function(String code) onCode;
  final FrameDecoder _decoder;
  final _confirmer = ReadConfirmer();

  CameraController? _camera;
  CameraController? get camera => _camera;
  ScannerCameraError? error;
  bool torch = false;

  bool _busy = false;
  bool _found = false;

  /// Change à chaque arrêt : une ouverture de la caméra encore en cours au
  /// moment de l'arrêt sait ainsi qu'elle doit la refermer.
  int _generation = 0;

  bool _disposed = false;

  /// [retry] : la caméra peut être encore en cours de libération par un
  /// autre écran ou l'autre lecteur : un second essai, un peu plus tard.
  Future<void> start({bool retry = true}) async {
    if (_camera != null || _found) return;
    final generation = _generation;
    CameraController? created;
    try {
      final cameras = await availableCameras();
      final back = cameras.where(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (cameras.isEmpty) {
        _setError(const ScannerCameraError());
        return;
      }
      created = CameraController(
        back.isNotEmpty ? back.first : cameras.first,
        // 1280 × 720 : assez pour un code-barres à 15-20 cm, et une lecture
        // rapide (chaque image est lue en entier).
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await created.initialize();
      await created.setFlashMode(FlashMode.off);
      if (_disposed || generation != _generation) {
        await created.dispose();
        return;
      }
      await created.startImageStream(_onImage);
      _camera = created;
      torch = false;
      error = null;
      notifyListeners();
    } on CameraException catch (e) {
      await created?.dispose();
      if (_disposed || generation != _generation) return;
      final denied = e.code.contains('AccessDenied');
      if (retry && !denied) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!_disposed && generation == _generation) {
          await start(retry: false);
        }
        return;
      }
      _setError(
        ScannerCameraError(denied: denied, detail: e.description ?? e.code),
      );
    }
  }

  void _setError(ScannerCameraError value) {
    if (_disposed) return;
    error = value;
    notifyListeners();
  }

  Future<void> _onImage(CameraImage image) async {
    if (_busy || _found || image.planes.isEmpty) return;
    _busy = true;
    try {
      // Plan Y : la luminance, seule utile à ZXing.
      final y = image.planes.first;
      final read = await _decoder.decode(
        LuminanceFrame(
          bytes: y.bytes,
          width: image.width,
          height: image.height,
          rowStride: y.bytesPerRow,
        ),
      );
      final code = _confirmer.offer(read);
      if (code != null && !_found && !_disposed) {
        _found = true;
        onCode(code);
      }
    } catch (_) {
      // Image illisible ou lecteur indisponible : on passe à la suivante.
    } finally {
      _busy = false;
    }
  }

  Future<void> toggleTorch() async {
    final camera = _camera;
    if (camera == null) return;
    final on = !torch;
    try {
      await camera.setFlashMode(on ? FlashMode.torch : FlashMode.off);
    } on CameraException {
      return;
    }
    torch = on;
    if (!_disposed) notifyListeners();
  }

  /// Libère la caméra (à attendre avant d'ouvrir un autre écran qui s'en
  /// sert : la photo d'étiquette, l'autre lecteur).
  Future<void> stop() async {
    _generation++;
    final camera = _camera;
    _camera = null;
    torch = false;
    if (!_disposed) notifyListeners();
    if (camera == null) return;
    try {
      if (camera.value.isStreamingImages) await camera.stopImageStream();
    } on CameraException {
      // Déjà arrêtée.
    }
    await camera.dispose();
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }
}

/// Image de la caméra du lecteur ZXing (ou l'erreur, par [errorBuilder]).
/// Suit la vie de l'appli : Android reprend la caméra en arrière-plan.
class ZxingScannerView extends StatefulWidget {
  const ZxingScannerView({
    super.key,
    required this.controller,
    required this.errorBuilder,
    required this.overlayBuilder,
  });

  final ZxingScannerController controller;
  final Widget Function(BuildContext, ScannerCameraError) errorBuilder;
  final Widget Function(BuildContext, BoxConstraints) overlayBuilder;

  @override
  State<ZxingScannerView> createState() => _ZxingScannerViewState();
}

class _ZxingScannerViewState extends State<ZxingScannerView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      widget.controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      widget.controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final error = widget.controller.error;
        if (error != null) return widget.errorBuilder(context, error);
        final camera = widget.controller.camera;
        if (camera == null || !camera.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, constraints) => Stack(
            fit: StackFit.expand,
            children: [
              ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    // La prévisualisation est en paysage : on l'affiche en
                    // portrait, recadrée.
                    width: camera.value.previewSize!.height,
                    height: camera.value.previewSize!.width,
                    child: CameraPreview(camera),
                  ),
                ),
              ),
              widget.overlayBuilder(context, constraints),
            ],
          ),
        );
      },
    );
  }
}
