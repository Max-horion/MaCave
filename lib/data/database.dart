import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/enums.dart';
import '../domain/initial_classification.dart';
import 'tables.dart';

part 'database.g.dart';

/// La base SQLite de la cave.
///
/// Toute modification du schéma : incrémenter [schemaVersion], ajouter l'étape
/// dans [migration] et un test de migration (voir CLAUDE.md, « Conventions »).
@DriftDatabase(
  tables: [
    DrinkTypes,
    CharacteristicFamilies,
    Characteristics,
    Drinks,
    DrinkCharacteristics,
    Lots,
    Movements,
    Settings,
    Meta,
  ],
)
class CaveDatabase extends _$CaveDatabase {
  CaveDatabase(super.executor);

  /// Base du téléphone, dans le dossier privé de l'application.
  factory CaveDatabase.open() => CaveDatabase(driftDatabase(name: 'cave'));

  @override
  int get schemaVersion => 1;

  /// Auteur des données livrées avec l'application. Leur date est 0 : la
  /// moindre modification de l'utilisateur l'emporte à la synchronisation.
  static const seedAuthor = 'seed';

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(
        meta,
      ).insert(MetaCompanion.insert(key: 'cave_id', value: const Uuid().v4()));
      await _seedClassification();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Identifiant unique de la cave : deux caves différentes ne sont jamais
  /// fusionnées (docs/architecture.md §4).
  Future<String> caveId() async {
    final row = await (select(
      meta,
    )..where((t) => t.key.equals('cave_id'))).getSingle();
    return row.value;
  }

  /// Insère la classification initiale du CDC §6.1.
  ///
  /// Les identifiants sont dérivés des noms (UUID v5) : identiques sur tous
  /// les appareils, même si deux téléphones créent leur base séparément.
  Future<void> _seedClassification() async {
    String seedId(String path) =>
        const Uuid().v5(Namespace.url.value, 'https://cave.bouthon.fr/$path');

    await batch((b) {
      for (final (ti, type) in initialClassification.indexed) {
        final typeId = seedId('type/${type.key}');
        b.insert(
          drinkTypes,
          DrinkTypesCompanion.insert(
            id: typeId,
            updatedAt: 0,
            updatedBy: seedAuthor,
            name: type.name,
            fieldProfile: type.profile,
            defaultVolumeMl: type.defaultVolumeMl,
            sortOrder: Value(ti),
          ),
        );
        for (final (fi, family) in type.families.indexed) {
          final familyId = seedId('type/${type.key}/family/${family.name}');
          b.insert(
            characteristicFamilies,
            CharacteristicFamiliesCompanion.insert(
              id: familyId,
              updatedAt: 0,
              updatedBy: seedAuthor,
              typeId: typeId,
              name: family.name,
              sortOrder: Value(fi),
            ),
          );
          for (final (vi, value) in family.values.indexed) {
            b.insert(
              characteristics,
              CharacteristicsCompanion.insert(
                id: seedId(
                  'type/${type.key}/family/${family.name}/value/$value',
                ),
                updatedAt: 0,
                updatedBy: seedAuthor,
                familyId: familyId,
                name: value,
                sortOrder: Value(vi),
              ),
            );
          }
        }
      }
    });
  }
}
