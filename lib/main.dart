import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';
import 'data/app_preferences.dart';
import 'data/local_store.dart';
import 'data/providers.dart';
import 'data/write_context.dart';
import 'features/welcome/welcome_screen.dart';
import 'sync/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceId = await _loadDeviceId();
  final preferences = await AppPreferences.load(PrefsLocalStore());
  final firstLaunch =
      await SharedPreferencesAsync().getString(welcomeDoneKey) == null;
  runApp(
    ProviderScope(
      overrides: [
        writeContextProvider.overrideWithValue(
          WriteContext(deviceId: deviceId),
        ),
        initialAppPreferencesProvider.overrideWithValue(preferences),
      ],
      child: AutomaticTasks(child: CaveApp(firstLaunch: firstLaunch)),
    ),
  );
}

/// Identifiant de cet appareil, créé au premier lancement puis conservé.
/// Propre à l'appareil : il n'est pas stocké dans la base synchronisée.
Future<String> _loadDeviceId() async {
  const key = 'device_id';
  final prefs = SharedPreferencesAsync();
  final existing = await prefs.getString(key);
  if (existing != null) return existing;
  final created = const Uuid().v4();
  await prefs.setString(key, created);
  return created;
}
