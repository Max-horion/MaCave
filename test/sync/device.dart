import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';

import '../helpers.dart';

/// Un appareil de test : sa base, son horloge, son dépôt.
class Device {
  Device(String deviceId, this.db) : ctx = _DeviceContext(deviceId) {
    repo = CaveRepository(db, ctx);
  }

  final CaveDatabase db;
  final TestContext ctx;
  late final CaveRepository repo;

  /// Une bière avec [bottles] bouteilles ; retourne l'ID du lot. Les ID sont
  /// préfixés par l'appareil pour ne pas se croiser.
  Future<String> addBeer(String name, int bottles) async {
    final types = await repo.drinkTypes();
    final ids = await repo.addNewDrink(
      drink: DrinkInput(name: name, typeId: types[1].id),
      volumeMl: 330,
      quantity: bottles,
    );
    return ids.lotId;
  }

  Future<List<String>> drinkNames() async {
    final drinks = await (db.select(
      db.drinks,
    )..where((t) => t.deletedAt.isNull())).get();
    return drinks.map((d) => d.name).toList()..sort();
  }

  Future<int> stockOf(String lotId) async => (await repo.lot(lotId))!.stock;

  Future<int> bottles() async => (await repo.watchTotals().first).bottles;

  Future<void> setSetting(String key, String value, int time) => db
      .into(db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: key,
          value: value,
          updatedAt: time,
          updatedBy: ctx.deviceId,
        ),
      );

  /// Contenu des tables synchronisées, pour comparer deux appareils. Les
  /// estampilles des lots regroupés diffèrent (chaque appareil a supprimé le
  /// doublon à son heure) : seules les données comptent.
  Future<Map<String, List<String>>> dump() async {
    Future<List<String>> rows(String sql) async =>
        (await db.customSelect(sql).get())
            .map((r) => r.data.values.join('|'))
            .toList();
    return {
      'drinks': await rows(
        'SELECT id, name, updated_at, deleted_at FROM drinks ORDER BY id',
      ),
      'lots': await rows(
        'SELECT id, drink_id, vintage, volume_ml, barcode, stock, '
        'deleted_at IS NOT NULL FROM lots ORDER BY id',
      ),
      'movements': await rows(
        'SELECT id, lot_id, kind, quantity, deleted_at FROM movements '
        'ORDER BY id',
      ),
    };
  }
}

/// Identifiants préfixés par l'appareil (telephone-id-0001…), qui ne se
/// croisent pas d'un appareil à l'autre, comme les vrais UUID.
class _DeviceContext extends TestContext {
  _DeviceContext(String deviceId) : super(deviceId: deviceId);

  @override
  String newId() => '$deviceId-${super.newId()}';
}
