import 'package:drift/drift.dart';

import '../domain/enums.dart';

// Description des tables de la base (voir docs/architecture.md §3).
// drift génère à partir de ce fichier le code SQL et les classes de données
// (`dart run build_runner build`, résultat dans database.g.dart).
//
// Dates : entiers, millisecondes UTC depuis 1970 (précision nécessaire pour
// départager les modifications lors de la synchronisation).

/// Colonnes communes à toutes les tables synchronisées.
mixin SyncColumns on Table {
  /// UUID créé sur l'appareil.
  TextColumn get id => text()();

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  IntColumn get updatedAt => integer()();

  /// Appareil auteur de la dernière modification (départage les égalités).
  TextColumn get updatedBy => text()();

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  IntColumn get deletedAt => integer().nullable()();
}

/// Types de boisson : vin, bière, spiritueux, soft… (CDC §6.1).
@DataClassName('DrinkType')
class DrinkTypes extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get fieldProfile => textEnum<FieldProfile>()();

  /// Volume pré-rempli pour un nouveau lot de ce type, en millilitres (CDC §7).
  IntColumn get defaultVolumeMl => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Familles de caractéristiques d'un type : robe, style, sucre…
@DataClassName('CharacteristicFamily')
@TableIndex(name: 'idx_families_type', columns: {#typeId})
class CharacteristicFamilies extends Table with SyncColumns {
  TextColumn get typeId => text().references(DrinkTypes, #id)();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Valeurs d'une famille : rouge, IPA, cassis…
@DataClassName('Characteristic')
@TableIndex(name: 'idx_characteristics_family', columns: {#familyId})
class Characteristics extends Table with SyncColumns {
  TextColumn get familyId => text().references(CharacteristicFamilies, #id)();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Références (= boissons) : la fiche d'un produit (CDC §3, §4.1).
@DataClassName('Drink')
@TableIndex(name: 'idx_drinks_type', columns: {#typeId})
class Drinks extends Table with SyncColumns {
  /// Vide si le type a été supprimé : la référence est « sans catégorie ».
  TextColumn get typeId => text().nullable().references(DrinkTypes, #id)();
  TextColumn get name => text()();
  TextColumn get producer => text().nullable()();
  TextColumn get appellation => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get grapes => text().nullable()();

  /// Degré d'alcool, en % vol.
  RealColumn get abv => real().nullable()();

  /// Note personnelle, de 0 à 5 étoiles.
  IntColumn get rating => integer().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  TextColumn get comment => text().nullable()();

  /// Marqueur « à compléter », calculé à chaque enregistrement (field_rules.dart).
  BoolColumn get needsCompletion =>
      boolean().withDefault(const Constant(false))();

  /// Accords mets et vins (V2).
  TextColumn get foodPairing => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lien entre une référence et ses caractéristiques (plusieurs-à-plusieurs).
/// `id` vaut « drinkId|characteristicId » : deux appareils qui créent le même
/// lien produisent la même ligne, sans doublon à la fusion.
@DataClassName('DrinkCharacteristic')
@TableIndex(name: 'idx_drink_characteristics_drink', columns: {#drinkId})
class DrinkCharacteristics extends Table with SyncColumns {
  TextColumn get drinkId => text().references(Drinks, #id)();
  TextColumn get characteristicId => text().references(Characteristics, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lots : une référence × millésime (facultatif) × volume. Porte le stock.
@DataClassName('Lot')
@TableIndex(name: 'idx_lots_drink', columns: {#drinkId})
@TableIndex(name: 'idx_lots_barcode', columns: {#barcode})
class Lots extends Table with SyncColumns {
  TextColumn get drinkId => text().references(Drinks, #id)();

  /// Vide = sans millésime.
  IntColumn get vintage => integer().nullable()();
  IntColumn get volumeMl => integer()();

  /// Pas unique : un même code peut correspondre à plusieurs lots (CDC §6.2).
  TextColumn get barcode => text().nullable()();

  /// Cache du stock, recalculé à partir des mouvements (domain/stock.dart).
  /// Ne jamais le modifier directement ; il n'est pas fusionné à la synchro.
  IntColumn get stock => integer().withDefault(const Constant(0))();

  /// V2 : emplacement, période idéale de consommation, photo de l'étiquette.
  TextColumn get location => text().nullable()();
  IntColumn get drinkFrom => integer().nullable()();
  IntColumn get drinkBefore => integer().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mouvements de stock : entrées, sorties, inventaires (CDC §4.2).
/// Jamais modifiés après création, sauf `deletedAt` (annulation).
@DataClassName('Movement')
@TableIndex(name: 'idx_movements_lot', columns: {#lotId, #occurredAt})
class Movements extends Table with SyncColumns {
  TextColumn get lotId => text().references(Lots, #id)();
  IntColumn get occurredAt => integer()();
  TextColumn get kind => textEnum<MovementKind>()();

  /// Entrée / sortie : nombre de bouteilles ; inventaire : nombre constaté.
  IntColumn get quantity => integer()();

  /// Uniquement pour les sorties.
  TextColumn get reason => textEnum<ExitReason>().nullable()();
  TextColumn get comment => text().nullable()();

  /// Appareil qui a créé le mouvement.
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Réglages communs à tous les appareils (valeur JSON).
@DataClassName('Setting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();
  TextColumn get updatedBy => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Informations sur la base elle-même, jamais fusionnées (ex. `cave_id`).
@DataClassName('MetaEntry')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  String get tableName => 'meta';

  @override
  Set<Column> get primaryKey => {key};
}
