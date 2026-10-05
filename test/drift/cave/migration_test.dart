// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:cave/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = CaveDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Vérifie qu'une base v1 réelle (avec des données) garde tout après la
  // migration et que la recherche plein texte trouve les références existantes.
  test('v1 → dernière version : données conservées et références trouvables', () async {
    final schema = await verifier.schemaAt(1);
    final raw = schema.rawDatabase;
    raw.execute(
      "INSERT INTO drink_types VALUES ('t', 0, 'seed', NULL, 'Vin', 'wine', 750, 0)",
    );
    raw.execute(
      "INSERT INTO drinks (id, updated_at, updated_by, type_id, name, appellation, "
      "region, created_at) VALUES ('d', 1, 'tel', 't', 'Château Exemple', "
      "'Saint-Émilion', 'Bordeaux', 1)",
    );
    raw.execute(
      "INSERT INTO lots (id, updated_at, updated_by, drink_id, vintage, volume_ml, "
      "stock, created_at) VALUES ('l', 1, 'tel', 'd', 2018, 750, 5, 1)",
    );
    raw.execute(
      "INSERT INTO movements (id, updated_at, updated_by, lot_id, occurred_at, kind, "
      "quantity, device_id) VALUES ('m', 1, 'tel', 'l', 1, 'entry', 5, 'tel')",
    );

    final db = CaveDatabase(schema.newConnection());
    addTearDown(db.close);

    final drink = await db.select(db.drinks).getSingle();
    expect(drink.name, 'Château Exemple');
    expect((await db.select(db.lots).getSingle()).stock, 5);
    expect(await db.select(db.movements).get(), hasLength(1));

    final found = await db
        .customSelect(
          "SELECT drink_id FROM drinks_fts WHERE drinks_fts MATCH 'emilion*'",
        )
        .get();
    expect(found.map((r) => r.read<String>('drink_id')), ['d']);

    // v3 : le type est indexé aussi.
    final byType = await db
        .customSelect(
          "SELECT drink_id FROM drinks_fts WHERE drinks_fts MATCH 'vin*'",
        )
        .get();
    expect(byType.map((r) => r.read<String>('drink_id')), ['d']);

    // v4 : les millésimes des lots aussi.
    final byVintage = await db
        .customSelect(
          "SELECT drink_id FROM drinks_fts WHERE drinks_fts MATCH '2018*'",
        )
        .get();
    expect(byVintage.map((r) => r.read<String>('drink_id')), ['d']);
  });
}
