import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/local_store.dart';
import 'sync_service.dart';

// Paramètres de synchronisation, propres à cet appareil (chaque appareil a
// ses identifiants) : hors de la base synchronisée. Le mot de passe est rangé
// à part, dans le coffre sécurisé d'Android (CDC §9).

/// Type de serveur (CDC §8.2).
enum ServerKind {
  /// Configuration simplifiée : adresse du serveur, l'appli complète le chemin.
  nextcloud,

  /// Tout autre serveur WebDAV (ownCloud, NAS, hébergeur) : adresse complète
  /// du dossier.
  other,
}

/// Paramètres saisis sur l'écran Synchronisation.
class SyncSettings {
  const SyncSettings({
    required this.kind,
    required this.server,
    required this.user,
    this.folder = defaultFolder,
  });

  /// Dossier proposé sur un Nextcloud.
  static const defaultFolder = 'Cave';

  final ServerKind kind;

  /// Nextcloud : adresse du serveur (« cloud.exemple.fr ») ; autre : adresse
  /// complète du dossier WebDAV.
  final String server;
  final String user;

  /// Nextcloud seulement : dossier de la cave dans les fichiers de
  /// l'utilisateur (« Cave », « Documents/Cave »).
  final String folder;

  /// Adresse WebDAV du dossier de la cave, terminée par « / ». Lève
  /// [FormatException] si l'adresse saisie n'est pas utilisable.
  Uri folderUri() {
    var text = server.trim();
    if (text.isEmpty) throw const FormatException('adresse vide');
    if (!text.contains('://')) text = 'https://$text';
    final base = Uri.parse(text);
    if (!{'http', 'https'}.contains(base.scheme) || base.host.isEmpty) {
      throw FormatException('adresse invalide', server);
    }
    final List<String> segments;
    switch (kind) {
      case ServerKind.nextcloud:
        // Chemin des fichiers de l'utilisateur sur un Nextcloud. Si
        // l'utilisateur a collé une adresse de page (…/index.php/apps/files),
        // on ne garde que la partie qui mène au serveur.
        final root = base.pathSegments
            .takeWhile((s) => s != 'index.php' && s != 'remote.php')
            .where((s) => s.isNotEmpty);
        final dir = folder
            .split('/')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);
        if (dir.isEmpty) throw const FormatException('dossier vide');
        segments = [...root, 'remote.php', 'dav', 'files', user.trim(), ...dir];
      case ServerKind.other:
        segments = base.pathSegments.where((s) => s.isNotEmpty).toList();
    }
    // `pathSegments` encode chaque segment (espaces, accents…).
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      pathSegments: [...segments, ''],
    );
  }

  /// Même dossier sur le même serveur : l'état de la synchronisation reste
  /// valable (sinon, on repart de zéro).
  bool sameTarget(SyncSettings other) {
    try {
      return folderUri() == other.folderUri() &&
          user.trim() == other.user.trim();
    } on FormatException {
      return false;
    }
  }

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'server': server,
    'user': user,
    'folder': folder,
  };

  static SyncSettings? fromJson(Map<String, Object?> json) {
    final kind = ServerKind.values.asNameMap()[json['kind']];
    final server = json['server'];
    final user = json['user'];
    if (kind == null || server is! String || user is! String) return null;
    final folder = json['folder'];
    return SyncSettings(
      kind: kind,
      server: server,
      user: user,
      folder: folder is String ? folder : defaultFolder,
    );
  }
}

/// Coffre pour le mot de passe : une interface, pour que les tests puissent
/// utiliser [MemorySecretStore].
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Coffre sécurisé du système : Keystore d'Android ; sur PC Linux, trousseau
/// de la session par libsecret (KWallet, GNOME Keyring).
class SecureSecretStore implements SecretStore {
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  /// Pour les tests : coffre inutilisable (pas de trousseau sur le PC).
  bool broken = false;

  void _check() {
    if (broken) throw StateError('coffre indisponible');
  }

  @override
  Future<String?> read(String key) async {
    _check();
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _check();
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _check();
    values.remove(key);
  }
}

/// Paramètres de synchronisation enregistrés : `null` = mode local.
class SyncSettingsStore {
  SyncSettingsStore(this._store, this._secrets);

  final LocalStore _store;
  final SecretStore _secrets;

  static const _settingsKey = 'sync_settings';
  static const _passwordKey = 'sync_password';

  /// Paramètres et mot de passe, ou null si la synchronisation est désactivée
  /// (ou le mot de passe introuvable dans le coffre). Lève [SyncException]
  /// ([SyncProblem.secretStore]) si le coffre est inutilisable.
  Future<({SyncSettings settings, String password})?> load() async {
    final settings = await loadSettings();
    if (settings == null) return null;
    final password = await _guard(() => _secrets.read(_passwordKey));
    if (password == null) return null;
    return (settings: settings, password: password);
  }

  /// Paramètres seuls, sans le mot de passe (pré-remplir le formulaire).
  Future<SyncSettings?> loadSettings() async {
    final raw = await _store.getString(_settingsKey);
    if (raw == null) return null;
    try {
      return SyncSettings.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> save(SyncSettings settings, String password) async {
    await _guard(() => _secrets.write(_passwordKey, password));
    await _store.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// Vérifie que le coffre range et relit un secret. À faire **avant** la
  /// première synchronisation d'une activation : sinon la cave pourrait être
  /// reprise du serveur sans que les paramètres puissent être enregistrés.
  /// Lève [SyncException] ([SyncProblem.secretStore]).
  Future<void> checkSecrets() async {
    const probe = 'sync_probe';
    final read = await _guard(() async {
      await _secrets.write(probe, 'ok');
      final value = await _secrets.read(probe);
      await _secrets.delete(probe);
      return value;
    });
    if (read != 'ok') {
      throw const SyncException(SyncProblem.secretStore, 'relecture');
    }
  }

  /// Désactive la synchronisation sur cet appareil (CDC §8.2) : le fichier du
  /// serveur n'est pas touché. Le coffre peut être inutilisable : les
  /// paramètres sont retirés d'abord, la désactivation aboutit quand même.
  Future<void> clear() async {
    await _store.remove(_settingsKey);
    try {
      await _secrets.delete(_passwordKey);
    } catch (_) {
      // Mot de passe resté dans le coffre : sans paramètres, il ne sert plus.
    }
  }

  /// Toute erreur du coffre devient [SyncProblem.secretStore].
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException(SyncProblem.secretStore, '$e');
    }
  }
}
