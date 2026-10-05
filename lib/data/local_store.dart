import 'package:shared_preferences/shared_preferences.dart';

/// Petites valeurs propres à cet appareil, hors de la base synchronisée
/// (docs/architecture.md §3) : date de la dernière sauvegarde, ETag connu…
///
/// Une interface plutôt que SharedPreferences directement, pour que les tests
/// puissent utiliser [MemoryLocalStore].
abstract class LocalStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

/// Préférences Android (SharedPreferences).
class PrefsLocalStore implements LocalStore {
  final _prefs = SharedPreferencesAsync();

  @override
  Future<String?> getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Préférences en mémoire, pour les tests.
class MemoryLocalStore implements LocalStore {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}
