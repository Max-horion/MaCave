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
  int get schemaVersion => 3;

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
      // contenu sont posés par l'étape suivante, qui recrée l'index.
      from1To2: (m, schema) async {
        await m.create(schema.drinksFts);
      },
      // v3 : l'index contient aussi le type et les caractéristiques. Il ne
      // contient que des données recalculables : on le recrée entièrement.
      from2To3: (m, schema) async {
        for (final trigger in [
          'drinks_fts_insert',
          'drinks_fts_update',
          'drinks_fts_delete',
        ]) {
          await customStatement('DROP TRIGGER IF EXISTS $trigger');
        }
        await customStatement('DROP TABLE IF EXISTS drinks_fts');
        await m.create(schema.drinksFts);
        for (final trigger in [
          drinksFtsInsert,
          drinksFtsUpdate,
          drinksFtsDelete,
          drinksFtsLinkInsert,
          drinksFtsLinkUpdate,
          drinksFtsTypeUpdate,
          drinksFtsCharacteristicUpdate,
        ]) {
          await m.createTrigger(trigger);
        }
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

  /// Reconstruit entièrement l'index de recherche (migration, synchronisation).
  /// Même contenu que celui écrit par les déclencheurs de search.drift.
  Future<void> rebuildSearchIndex() async {
    await customStatement('DELETE FROM drinks_fts');
    await customStatement(
      'INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, '
      'country, grapes, type_name, characteristics) '
      'SELECT d.id, d.name, d.producer, d.appellation, d.region, d.country, '
      'd.grapes, '
      '(SELECT t.name FROM drink_types t '
      'WHERE t.id = d.type_id AND t.deleted_at IS NULL), '
      "(SELECT group_concat(c.name, ' ') FROM drink_characteristics dc "
      'JOIN characteristics c ON c.id = dc.characteristic_id '
      'WHERE dc.drink_id = d.id AND dc.deleted_at IS NULL '
      'AND c.deleted_at IS NULL) '
      'FROM drinks d',
    );
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
