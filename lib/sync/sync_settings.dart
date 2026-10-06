import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/local_store.dart';

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

/// Coffre sécurisé d'Android (Keystore).
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

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Paramètres de synchronisation enregistrés : `null` = mode local.
class SyncSettingsStore {
  SyncSettingsStore(this._store, this._secrets);

  final LocalStore _store;
  final SecretStore _secrets;

  static const _settingsKey = 'sync_settings';
  static const _passwordKey = 'sync_password';

  /// Paramètres et mot de passe, ou null si la synchronisation est désactivée
  /// (ou le mot de passe introuvable dans le coffre).
  Future<({SyncSettings settings, String password})?> load() async {
    final raw = await _store.getString(_settingsKey);
    if (raw == null) return null;
    final SyncSettings? settings;
    try {
      settings = SyncSettings.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } on FormatException {
      return null;
    }
    final password = await _secrets.read(_passwordKey);
    if (settings == null || password == null) return null;
    return (settings: settings, password: password);
  }

  Future<void> save(SyncSettings settings, String password) async {
    await _secrets.write(_passwordKey, password);
    await _store.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// Désactive la synchronisation sur cet appareil (CDC §8.2) : le fichier du
  /// serveur n'est pas touché.
  Future<void> clear() async {
    await _store.remove(_settingsKey);
    await _secrets.delete(_passwordKey);
  }
}
