import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ce que l'appareil sait faire, pour n'afficher que les fonctions
/// utilisables (CDC §10, portage PC).
///
/// Sur PC (Linux, puis Windows) : pas de caméra, donc ni scan de code-barres
/// ni photo d'étiquette — le code se saisit au clavier, ou avec une douchette
/// USB qui se comporte comme un clavier. Linux ne sait pas non plus partager
/// un fichier avec une autre application : on l'enregistre à la place.
class DeviceCapabilities {
  const DeviceCapabilities({
    required this.camera,
    required this.shareFiles,
    required this.icon,
  });

  /// Téléphone (Android) : tout est disponible.
  static const phone = DeviceCapabilities(
    camera: true,
    shareFiles: true,
    icon: Icons.phone_android,
  );

  /// Ordinateur.
  static const desktop = DeviceCapabilities(
    camera: false,
    shareFiles: false,
    icon: Icons.computer,
  );

  factory DeviceCapabilities.of(TargetPlatform platform) => switch (platform) {
    TargetPlatform.android || TargetPlatform.iOS => phone,
    _ => desktop,
  };

  /// Scan de code-barres et photo d'étiquette.
  final bool camera;

  /// Partage de fichiers (export, sauvegarde) avec une autre application.
  final bool shareFiles;

  /// Icône qui représente « cet appareil ».
  final IconData icon;
}

/// Capacités de l'appareil. Dans les tests, `defaultTargetPlatform` vaut
/// Android : pour essayer l'affichage PC, régler
/// `debugDefaultTargetPlatformOverride` ou remplacer ce fournisseur.
final deviceCapabilitiesProvider = Provider<DeviceCapabilities>(
  (ref) => DeviceCapabilities.of(defaultTargetPlatform),
);
