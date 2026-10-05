import 'package:cave/data/database.dart';
import 'package:cave/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late CaveDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  test('la classification initiale du CDC §6.1 est créée', () async {
    final types = await db.select(db.drinkTypes).get();
    expect(types.map((t) => t.name), ['Vin', 'Bière', 'Spiritueux', 'Soft']);
    expect(await db.select(db.characteristicFamilies).get(), hasLength(10));
    expect(await db.select(db.characteristics).get(), hasLength(34));
  });

  test('volumes par défaut du CDC §7', () async {
    final types = await db.select(db.drinkTypes).get();
    expect(
      {for (final t in types) t.fieldProfile: t.defaultVolumeMl},
      {
        FieldProfile.wine: 750,
        FieldProfile.beer: 750,
        FieldProfile.spirit: 700,
        FieldProfile.soft: 1000,
      },
    );
  });

  test(
    'les identifiants de la classification sont les mêmes partout',
    () async {
      final other = memoryDatabase();
      addTearDown(other.close);
      final ids = (await db.select(db.characteristics).get()).map((c) => c.id);
      final otherIds = (await other.select(other.characteristics).get()).map(
        (c) => c.id,
      );
      expect(ids.toSet(), otherIds.toSet());
    },
  );

  test('chaque base reçoit son propre identifiant de cave', () async {
    final other = memoryDatabase();
    addTearDown(other.close);
    expect(await db.caveId(), isNotEmpty);
    expect(await db.caveId(), isNot(await other.caveId()));
  });

  test('les clés étrangères sont vérifiées', () async {
    await expectLater(
      db
          .into(db.lots)
          .insert(
            LotsCompanion.insert(
              id: 'lot',
              drinkId: 'reference-inexistante',
              volumeMl: 750,
              createdAt: 0,
              updatedAt: 0,
              updatedBy: 'test',
            ),
          ),
      throwsA(anything),
    );
  });
}
