import 'package:cave/data/database.dart';
import 'package:cave/data/write_context.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Base vierge en mémoire (classification initiale incluse), pour les tests.
CaveDatabase memoryDatabase() => CaveDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Contexte d'écriture prévisible : l'horloge avance d'une seconde à chaque
/// lecture et les identifiants se suivent (id-0001, id-0002…).
class TestContext extends WriteContext {
  TestContext({super.deviceId = 'appareil-test', int start = 1000000})
    : _time = start,
      super(clock: null, idGenerator: null);

  int _time;
  int _counter = 0;

  /// Fixe l'heure de la prochaine écriture.
  set time(int value) => _time = value;

  @override
  int now() => _time += 1000;

  @override
  String newId() => 'id-${(++_counter).toString().padLeft(4, '0')}';
}
