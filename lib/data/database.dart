import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/enums.dart';
import '../domain/initial_classification.dart';
import 'tables.dart';

import 'database.steps.dart';

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
  include: {'search.drift'},
)
class CaveDatabase extends _$CaveDatabase {
  CaveDatabase(super.executor);

  /// Base du téléphone, dans le dossier privé de l'application.
  factory CaveDatabase.open() => CaveDatabase(driftDatabase(name: 'cave'));

  @override
  int get schemaVersion => 4;

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
    // Migrations étape par étape (outil `make-migrations` de drift) : chaque
    // étape amène la base d'une version à la suivante, et chacune est vérifiée
    // par les tests de test/drift/.
    onUpgrade: stepByStep(
      // v2 (lot 2) : index de recherche plein texte. Ses déclencheurs et son
      // contenu sont posés par la dernière étape, qui recrée l'index.
      from1To2: (m, schema) async {
        await m.create(schema.drinksFts);
      },
      // v3 : l'index contient aussi le type et les caractéristiques.
      // v4 : … et les millésimes des lots, via la vue drink_search_rows.
      // L'index ne contient que des données recalculables : chaque étape le
      // recrée entièrement dans sa forme finale, déclencheurs compris.
      from2To3: (m, schema) async {
        await _dropSearchIndex();
        await m.create(schema.drinksFts);
      },
      from3To4: (m, schema) async {
        await _dropSearchIndex();
        await m.create(schema.drinksFts);
        await m.createView(schema.drinkSearchRows);
        await _createSearchTriggers(m);
        await rebuildSearchIndex();
      },
    ),
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

  /// Reconstruit entièrement l'index de recherche (migration, synchronisation),
  /// à partir de la vue drink_search_rows (search.drift).
  Future<void> rebuildSearchIndex() async {
    await customStatement('DELETE FROM drinks_fts');
    await customStatement(
      'INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, '
      'country, grapes, type_name, characteristics, vintages) '
      'SELECT drink_id, name, producer, appellation, region, country, grapes, '
      'type_name, characteristics, vintages FROM drink_search_rows',
    );
  }

  /// Supprime l'index, sa vue et tous ses déclencheurs, quelle que soit la
  /// version d'origine (noms des versions 2 à 4).
  Future<void> _dropSearchIndex() async {
    for (final trigger in [
      'drinks_fts_insert',
      'drinks_fts_update',
      'drinks_fts_delete',
      'drinks_fts_link_insert',
      'drinks_fts_link_update',
      'drinks_fts_lot_insert',
      'drinks_fts_lot_update',
      'drinks_fts_type_update',
      'drinks_fts_characteristic_update',
    ]) {
      await customStatement('DROP TRIGGER IF EXISTS $trigger');
    }
    await customStatement('DROP VIEW IF EXISTS drink_search_rows');
    await customStatement('DROP TABLE IF EXISTS drinks_fts');
  }

  Future<void> _createSearchTriggers(Migrator m) async {
    for (final trigger in [
      drinksFtsInsert,
      drinksFtsUpdate,
      drinksFtsDelete,
      drinksFtsLinkInsert,
      drinksFtsLinkUpdate,
      drinksFtsLotInsert,
      drinksFtsLotUpdate,
      drinksFtsTypeUpdate,
      drinksFtsCharacteristicUpdate,
    ]) {
      await m.createTrigger(trigger);
    }
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
