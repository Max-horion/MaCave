import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Accès en écriture au stockage partagé (Documents), pour les sauvegardes.
///
/// Seul Android 8 à 10 demande une autorisation ; à partir d'Android 11, et
/// sur les autres systèmes, l'accès est toujours accordé.
abstract class StorageAccess {
  /// L'appli peut écrire dans Documents.
  Future<bool> granted();

  /// Demande l'autorisation (fenêtre du système) ; retourne la réponse.
  Future<bool> request();

  /// Refus définitif : Android n'affiche plus la fenêtre (« Ne plus
  /// demander », ou second refus sur certains téléphones). Seuls les
  /// réglages de l'appli permettent alors d'autoriser.
  Future<bool> blocked();

  /// Ouvre la page de l'appli dans les réglages d'Android.
  Future<void> openSettings();
}

/// Sur Android : canal « fr.bouthon.cave/storage » (MainActivity.kt).
class AndroidStorageAccess implements StorageAccess {
  static const _channel = MethodChannel('fr.bouthon.cave/storage');

  @override
  Future<bool> granted() async =>
      await _channel.invokeMethod<bool>('granted') ?? false;

  @override
  Future<bool> request() async =>
      await _channel.invokeMethod<bool>('request') ?? false;

  @override
  Future<bool> blocked() async =>
      await _channel.invokeMethod<bool>('blocked') ?? false;

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');
}

/// Autres systèmes, et tests : rien à demander.
class GrantedStorageAccess implements StorageAccess {
  const GrantedStorageAccess();

  @override
  Future<bool> granted() async => true;

  @override
  Future<bool> request() async => true;

  @override
  Future<bool> blocked() async => false;

  @override
  Future<void> openSettings() async {}
}

final storageAccessProvider = Provider<StorageAccess>(
  (ref) => Platform.isAndroid
      ? AndroidStorageAccess()
      : const GrantedStorageAccess(),
);
