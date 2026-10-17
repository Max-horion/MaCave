import 'dart:io';

import 'package:cave/data/database.dart';
import 'package:cave/sync/cave_file.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers.dart';

// Fichiers de base reçus (serveur, restauration) : ils peuvent venir de
// n'importe qui. Audit de sécurité du 2026-10-17.
void main() {
  late Directory root;
  late CaveDatabase db;
  late String path;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cave_file_test');
    db = memoryDatabase();
    path = '${root.path}/recu.sqlite';
    await snapshotDatabase(db, path);
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  /// Modifie directement le fichier reçu.
  void tamper(String sql) {
    final file = sqlite3.open(path);
    try {
      file.execute(sql);
    } finally {
      file.close();
    }
  }

  List<String> schemaCode(String file) {
    final opened = sqlite3.open(file, mode: OpenMode.readOnly);
    try {
      return [
        for (final row in opened.select(
          "SELECT name FROM sqlite_master WHERE type IN ('trigger', 'view')",
        ))
          row['name'] as String,
      ];
    } finally {
      opened.close();
    }
  }

  CaveFileInfo inspect() =>
      inspectCaveFile(path, currentVersion: db.schemaVersion);

  Matcher problem(CaveFileProblem p) =>
      throwsA(isA<CaveFileException>().having((e) => e.problem, 'problem', p));

  test('une vraie cave est acceptée', () {
    expect(inspect().caveId, isNotEmpty);
  });

  test('une table remplacée par une vue : refusé', () {
    tamper('''
      ALTER TABLE drinks RENAME TO drinks_cachees;
      CREATE VIEW drinks AS SELECT * FROM drinks_cachees;
    ''');
    expect(inspect, problem(CaveFileProblem.notACave));
  });

  test('fichier trop gros : refusé sans être ouvert', () {
    final file = File(path).openSync(mode: FileMode.append);
    // Fichier « creux » : rien n'est vraiment écrit sur le disque.
    file.setPositionSync(maxCaveFileBytes + 1);
    file.writeByteSync(0);
    file.closeSync();
    expect(inspect, problem(CaveFileProblem.unreadable));
  });

  test('vues et déclencheurs du fichier retirés de la copie', () async {
    tamper('''
      CREATE TRIGGER piege AFTER UPDATE ON drinks
        BEGIN DELETE FROM lots; END;
      CREATE VIEW espion AS SELECT * FROM settings;
    ''');
    expect(schemaCode(path), containsAll(['piege', 'espion']));
    inspect();

    final copy = '${root.path}/copie.sqlite';
    await migratedCopy(path, copy);
    expect(schemaCode(copy), isEmpty);
    // Le fichier d'origine n'est pas modifié.
    expect(schemaCode(path), containsAll(['piege', 'espion']));
  });
}
