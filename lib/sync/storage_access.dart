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
}

/// Autres systèmes, et tests : rien à demander.
class GrantedStorageAccess implements StorageAccess {
  const GrantedStorageAccess();

  @override
  Future<bool> granted() async => true;

  @override
  Future<bool> request() async => true;
}

final storageAccessProvider = Provider<StorageAccess>(
  (ref) => Platform.isAndroid
      ? AndroidStorageAccess()
      : const GrantedStorageAccess(),
);
