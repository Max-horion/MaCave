// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class DrinksFts extends Table
    with TableInfo<DrinksFts, DrinksFt>, VirtualTableInfo<DrinksFts, DrinksFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DrinksFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _drinkIdMeta = const VerificationMeta(
    'drinkId',
  );
  late final GeneratedColumn<String> drinkId = GeneratedColumn<String>(
    'drink_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _producerMeta = const VerificationMeta(
    'producer',
  );
  late final GeneratedColumn<String> producer = GeneratedColumn<String>(
    'producer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _appellationMeta = const VerificationMeta(
    'appellation',
  );
  late final GeneratedColumn<String> appellation = GeneratedColumn<String>(
    'appellation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _grapesMeta = const VerificationMeta('grapes');
  late final GeneratedColumn<String> grapes = GeneratedColumn<String>(
    'grapes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _typeNameMeta = const VerificationMeta(
    'typeName',
  );
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
    'type_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _characteristicsMeta = const VerificationMeta(
    'characteristics',
  );
  late final GeneratedColumn<String> characteristics = GeneratedColumn<String>(
    'characteristics',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    drinkId,
    name,
    producer,
    appellation,
    region,
    country,
    grapes,
    typeName,
    characteristics,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drinks_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrinksFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('drink_id')) {
      context.handle(
        _drinkIdMeta,
        drinkId.isAcceptableOrUnknown(data['drink_id']!, _drinkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drinkIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('producer')) {
      context.handle(
        _producerMeta,
        producer.isAcceptableOrUnknown(data['producer']!, _producerMeta),
      );
    } else if (isInserting) {
      context.missing(_producerMeta);
    }
    if (data.containsKey('appellation')) {
      context.handle(
        _appellationMeta,
        appellation.isAcceptableOrUnknown(
          data['appellation']!,
          _appellationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appellationMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('grapes')) {
      context.handle(
        _grapesMeta,
        grapes.isAcceptableOrUnknown(data['grapes']!, _grapesMeta),
      );
    } else if (isInserting) {
      context.missing(_grapesMeta);
    }
    if (data.containsKey('type_name')) {
      context.handle(
        _typeNameMeta,
        typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_typeNameMeta);
    }
    if (data.containsKey('characteristics')) {
      context.handle(
        _characteristicsMeta,
        characteristics.isAcceptableOrUnknown(
          data['characteristics']!,
          _characteristicsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characteristicsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DrinksFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrinksFt(
      drinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drink_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      producer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producer'],
      )!,
      appellation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appellation'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      grapes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grapes'],
      )!,
      typeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_name'],
      )!,
      characteristics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}characteristics'],
      )!,
    );
  }

  @override
  DrinksFts createAlias(String alias) {
    return DrinksFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(drink_id UNINDEXED, name, producer, appellation, region, country, grapes, type_name, characteristics, tokenize = \'unicode61 remove_diacritics 2\')';
}

class DrinksFt extends DataClass implements Insertable<DrinksFt> {
  final String drinkId;
  final String name;
  final String producer;
  final String appellation;
  final String region;
  final String country;
  final String grapes;
  final String typeName;
  final String characteristics;
  const DrinksFt({
    required this.drinkId,
    required this.name,
    required this.producer,
    required this.appellation,
    required this.region,
    required this.country,
    required this.grapes,
    required this.typeName,
    required this.characteristics,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['drink_id'] = Variable<String>(drinkId);
    map['name'] = Variable<String>(name);
    map['producer'] = Variable<String>(producer);
    map['appellation'] = Variable<String>(appellation);
    map['region'] = Variable<String>(region);
    map['country'] = Variable<String>(country);
    map['grapes'] = Variable<String>(grapes);
    map['type_name'] = Variable<String>(typeName);
    map['characteristics'] = Variable<String>(characteristics);
    return map;
  }

  DrinksFtsCompanion toCompanion(bool nullToAbsent) {
    return DrinksFtsCompanion(
      drinkId: Value(drinkId),
      name: Value(name),
      producer: Value(producer),
      appellation: Value(appellation),
      region: Value(region),
      country: Value(country),
      grapes: Value(grapes),
      typeName: Value(typeName),
      characteristics: Value(characteristics),
    );
  }

  factory DrinksFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrinksFt(
      drinkId: serializer.fromJson<String>(json['drink_id']),
      name: serializer.fromJson<String>(json['name']),
      producer: serializer.fromJson<String>(json['producer']),
      appellation: serializer.fromJson<String>(json['appellation']),
      region: serializer.fromJson<String>(json['region']),
      country: serializer.fromJson<String>(json['country']),
      grapes: serializer.fromJson<String>(json['grapes']),
      typeName: serializer.fromJson<String>(json['type_name']),
      characteristics: serializer.fromJson<String>(json['characteristics']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'drink_id': serializer.toJson<String>(drinkId),
      'name': serializer.toJson<String>(name),
      'producer': serializer.toJson<String>(producer),
      'appellation': serializer.toJson<String>(appellation),
      'region': serializer.toJson<String>(region),
      'country': serializer.toJson<String>(country),
      'grapes': serializer.toJson<String>(grapes),
      'type_name': serializer.toJson<String>(typeName),
      'characteristics': serializer.toJson<String>(characteristics),
    };
  }

  DrinksFt copyWith({
    String? drinkId,
    String? name,
    String? producer,
    String? appellation,
    String? region,
    String? country,
    String? grapes,
    String? typeName,
    String? characteristics,
  }) => DrinksFt(
    drinkId: drinkId ?? this.drinkId,
    name: name ?? this.name,
    producer: producer ?? this.producer,
    appellation: appellation ?? this.appellation,
    region: region ?? this.region,
    country: country ?? this.country,
    grapes: grapes ?? this.grapes,
    typeName: typeName ?? this.typeName,
    characteristics: characteristics ?? this.characteristics,
  );
  DrinksFt copyWithCompanion(DrinksFtsCompanion data) {
    return DrinksFt(
      drinkId: data.drinkId.present ? data.drinkId.value : this.drinkId,
      name: data.name.present ? data.name.value : this.name,
      producer: data.producer.present ? data.producer.value : this.producer,
      appellation: data.appellation.present
          ? data.appellation.value
          : this.appellation,
      region: data.region.present ? data.region.value : this.region,
      country: data.country.present ? data.country.value : this.country,
      grapes: data.grapes.present ? data.grapes.value : this.grapes,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
      characteristics: data.characteristics.present
          ? data.characteristics.value
          : this.characteristics,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrinksFt(')
          ..write('drinkId: $drinkId, ')
          ..write('name: $name, ')
          ..write('producer: $producer, ')
          ..write('appellation: $appellation, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('grapes: $grapes, ')
          ..write('typeName: $typeName, ')
          ..write('characteristics: $characteristics')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    drinkId,
    name,
    producer,
    appellation,
    region,
    country,
    grapes,
    typeName,
    characteristics,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrinksFt &&
          other.drinkId == this.drinkId &&
          other.name == this.name &&
          other.producer == this.producer &&
          other.appellation == this.appellation &&
          other.region == this.region &&
          other.country == this.country &&
          other.grapes == this.grapes &&
          other.typeName == this.typeName &&
          other.characteristics == this.characteristics);
}

class DrinksFtsCompanion extends UpdateCompanion<DrinksFt> {
  final Value<String> drinkId;
  final Value<String> name;
  final Value<String> producer;
  final Value<String> appellation;
  final Value<String> region;
  final Value<String> country;
  final Value<String> grapes;
  final Value<String> typeName;
  final Value<String> characteristics;
  final Value<int> rowid;
  const DrinksFtsCompanion({
    this.drinkId = const Value.absent(),
    this.name = const Value.absent(),
    this.producer = const Value.absent(),
    this.appellation = const Value.absent(),
    this.region = const Value.absent(),
    this.country = const Value.absent(),
    this.grapes = const Value.absent(),
    this.typeName = const Value.absent(),
    this.characteristics = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DrinksFtsCompanion.insert({
    required String drinkId,
    required String name,
    required String producer,
    required String appellation,
    required String region,
    required String country,
    required String grapes,
    required String typeName,
    required String characteristics,
    this.rowid = const Value.absent(),
  }) : drinkId = Value(drinkId),
       name = Value(name),
       producer = Value(producer),
       appellation = Value(appellation),
       region = Value(region),
       country = Value(country),
       grapes = Value(grapes),
       typeName = Value(typeName),
       characteristics = Value(characteristics);
  static Insertable<DrinksFt> custom({
    Expression<String>? drinkId,
    Expression<String>? name,
    Expression<String>? producer,
    Expression<String>? appellation,
    Expression<String>? region,
    Expression<String>? country,
    Expression<String>? grapes,
    Expression<String>? typeName,
    Expression<String>? characteristics,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (drinkId != null) 'drink_id': drinkId,
      if (name != null) 'name': name,
      if (producer != null) 'producer': producer,
      if (appellation != null) 'appellation': appellation,
      if (region != null) 'region': region,
      if (country != null) 'country': country,
      if (grapes != null) 'grapes': grapes,
      if (typeName != null) 'type_name': typeName,
      if (characteristics != null) 'characteristics': characteristics,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DrinksFtsCompanion copyWith({
    Value<String>? drinkId,
    Value<String>? name,
    Value<String>? producer,
    Value<String>? appellation,
    Value<String>? region,
    Value<String>? country,
    Value<String>? grapes,
    Value<String>? typeName,
    Value<String>? characteristics,
    Value<int>? rowid,
  }) {
    return DrinksFtsCompanion(
      drinkId: drinkId ?? this.drinkId,
      name: name ?? this.name,
      producer: producer ?? this.producer,
      appellation: appellation ?? this.appellation,
      region: region ?? this.region,
      country: country ?? this.country,
      grapes: grapes ?? this.grapes,
      typeName: typeName ?? this.typeName,
      characteristics: characteristics ?? this.characteristics,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (drinkId.present) {
      map['drink_id'] = Variable<String>(drinkId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (producer.present) {
      map['producer'] = Variable<String>(producer.value);
    }
    if (appellation.present) {
      map['appellation'] = Variable<String>(appellation.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (grapes.present) {
      map['grapes'] = Variable<String>(grapes.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    if (characteristics.present) {
      map['characteristics'] = Variable<String>(characteristics.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrinksFtsCompanion(')
          ..write('drinkId: $drinkId, ')
          ..write('name: $name, ')
          ..write('producer: $producer, ')
          ..write('appellation: $appellation, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('grapes: $grapes, ')
          ..write('typeName: $typeName, ')
          ..write('characteristics: $characteristics, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrinkTypesTable extends DrinkTypes
    with TableInfo<$DrinkTypesTable, DrinkType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrinkTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FieldProfile, String>
  fieldProfile = GeneratedColumn<String>(
    'field_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<FieldProfile>($DrinkTypesTable.$converterfieldProfile);
  static const VerificationMeta _defaultVolumeMlMeta = const VerificationMeta(
    'defaultVolumeMl',
  );
  @override
  late final GeneratedColumn<int> defaultVolumeMl = GeneratedColumn<int>(
    'default_volume_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    name,
    fieldProfile,
    defaultVolumeMl,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drink_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrinkType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_volume_ml')) {
      context.handle(
        _defaultVolumeMlMeta,
        defaultVolumeMl.isAcceptableOrUnknown(
          data['default_volume_ml']!,
          _defaultVolumeMlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultVolumeMlMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DrinkType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrinkType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fieldProfile: $DrinkTypesTable.$converterfieldProfile.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}field_profile'],
        )!,
      ),
      defaultVolumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_volume_ml'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $DrinkTypesTable createAlias(String alias) {
    return $DrinkTypesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FieldProfile, String, String>
  $converterfieldProfile = const EnumNameConverter<FieldProfile>(
    FieldProfile.values,
  );
}

class DrinkType extends DataClass implements Insertable<DrinkType> {
  /// UUID créé sur l'appareil.
  final String id;

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  final int updatedAt;

  /// Appareil auteur de la dernière modification (départage les égalités).
  final String updatedBy;

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  final int? deletedAt;
  final String name;
  final FieldProfile fieldProfile;

  /// Volume pré-rempli pour un nouveau lot de ce type, en millilitres (CDC §7).
  final int defaultVolumeMl;
  final int sortOrder;
  const DrinkType({
    required this.id,
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.name,
    required this.fieldProfile,
    required this.defaultVolumeMl,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    {
      map['field_profile'] = Variable<String>(
        $DrinkTypesTable.$converterfieldProfile.toSql(fieldProfile),
      );
    }
    map['default_volume_ml'] = Variable<int>(defaultVolumeMl);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DrinkTypesCompanion toCompanion(bool nullToAbsent) {
    return DrinkTypesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      fieldProfile: Value(fieldProfile),
      defaultVolumeMl: Value(defaultVolumeMl),
      sortOrder: Value(sortOrder),
    );
  }

  factory DrinkType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrinkType(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      fieldProfile: $DrinkTypesTable.$converterfieldProfile.fromJson(
        serializer.fromJson<String>(json['fieldProfile']),
      ),
      defaultVolumeMl: serializer.fromJson<int>(json['defaultVolumeMl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'fieldProfile': serializer.toJson<String>(
        $DrinkTypesTable.$converterfieldProfile.toJson(fieldProfile),
      ),
      'defaultVolumeMl': serializer.toJson<int>(defaultVolumeMl),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DrinkType copyWith({
    String? id,
    int? updatedAt,
    String? updatedBy,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    FieldProfile? fieldProfile,
    int? defaultVolumeMl,
    int? sortOrder,
  }) => DrinkType(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    fieldProfile: fieldProfile ?? this.fieldProfile,
    defaultVolumeMl: defaultVolumeMl ?? this.defaultVolumeMl,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DrinkType copyWithCompanion(DrinkTypesCompanion data) {
    return DrinkType(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      fieldProfile: data.fieldProfile.present
          ? data.fieldProfile.value
          : this.fieldProfile,
      defaultVolumeMl: data.defaultVolumeMl.present
          ? data.defaultVolumeMl.value
          : this.defaultVolumeMl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrinkType(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('fieldProfile: $fieldProfile, ')
          ..write('defaultVolumeMl: $defaultVolumeMl, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    name,
    fieldProfile,
    defaultVolumeMl,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrinkType &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.fieldProfile == this.fieldProfile &&
          other.defaultVolumeMl == this.defaultVolumeMl &&
          other.sortOrder == this.sortOrder);
}

class DrinkTypesCompanion extends UpdateCompanion<DrinkType> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<FieldProfile> fieldProfile;
  final Value<int> defaultVolumeMl;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const DrinkTypesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.fieldProfile = const Value.absent(),
    this.defaultVolumeMl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DrinkTypesCompanion.insert({
    required String id,
    required int updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String name,
    required FieldProfile fieldProfile,
    required int defaultVolumeMl,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       name = Value(name),
       fieldProfile = Value(fieldProfile),
       defaultVolumeMl = Value(defaultVolumeMl);
  static Insertable<DrinkType> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<String>? fieldProfile,
    Expression<int>? defaultVolumeMl,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (fieldProfile != null) 'field_profile': fieldProfile,
      if (defaultVolumeMl != null) 'default_volume_ml': defaultVolumeMl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DrinkTypesCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<FieldProfile>? fieldProfile,
    Value<int>? defaultVolumeMl,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return DrinkTypesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      fieldProfile: fieldProfile ?? this.fieldProfile,
      defaultVolumeMl: defaultVolumeMl ?? this.defaultVolumeMl,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fieldProfile.present) {
      map['field_profile'] = Variable<String>(
        $DrinkTypesTable.$converterfieldProfile.toSql(fieldProfile.value),
      );
    }
    if (defaultVolumeMl.present) {
      map['default_volume_ml'] = Variable<int>(defaultVolumeMl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrinkTypesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('fieldProfile: $fieldProfile, ')
          ..write('defaultVolumeMl: $defaultVolumeMl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrinksTable extends Drinks with TableInfo<$DrinksTable, Drink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<String> typeId = GeneratedColumn<String>(
    'type_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drink_types (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _producerMeta = const VerificationMeta(
    'producer',
  );
  @override
  late final GeneratedColumn<String> producer = GeneratedColumn<String>(
    'producer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appellationMeta = const VerificationMeta(
    'appellation',
  );
  @override
  late final GeneratedColumn<String> appellation = GeneratedColumn<String>(
    'appellation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grapesMeta = const VerificationMeta('grapes');
  @override
  late final GeneratedColumn<String> grapes = GeneratedColumn<String>(
    'grapes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abvMeta = const VerificationMeta('abv');
  @override
  late final GeneratedColumn<double> abv = GeneratedColumn<double>(
    'abv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsCompletionMeta = const VerificationMeta(
    'needsCompletion',
  );
  @override
  late final GeneratedColumn<bool> needsCompletion = GeneratedColumn<bool>(
    'needs_completion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_completion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _foodPairingMeta = const VerificationMeta(
    'foodPairing',
  );
  @override
  late final GeneratedColumn<String> foodPairing = GeneratedColumn<String>(
    'food_pairing',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    typeId,
    name,
    producer,
    appellation,
    region,
    country,
    grapes,
    abv,
    rating,
    favorite,
    comment,
    needsCompletion,
    foodPairing,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drinks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Drink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('producer')) {
      context.handle(
        _producerMeta,
        producer.isAcceptableOrUnknown(data['producer']!, _producerMeta),
      );
    }
    if (data.containsKey('appellation')) {
      context.handle(
        _appellationMeta,
        appellation.isAcceptableOrUnknown(
          data['appellation']!,
          _appellationMeta,
        ),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('grapes')) {
      context.handle(
        _grapesMeta,
        grapes.isAcceptableOrUnknown(data['grapes']!, _grapesMeta),
      );
    }
    if (data.containsKey('abv')) {
      context.handle(
        _abvMeta,
        abv.isAcceptableOrUnknown(data['abv']!, _abvMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('needs_completion')) {
      context.handle(
        _needsCompletionMeta,
        needsCompletion.isAcceptableOrUnknown(
          data['needs_completion']!,
          _needsCompletionMeta,
        ),
      );
    }
    if (data.containsKey('food_pairing')) {
      context.handle(
        _foodPairingMeta,
        foodPairing.isAcceptableOrUnknown(
          data['food_pairing']!,
          _foodPairingMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Drink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Drink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      producer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producer'],
      ),
      appellation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appellation'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      grapes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grapes'],
      ),
      abv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}abv'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      needsCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_completion'],
      )!,
      foodPairing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_pairing'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DrinksTable createAlias(String alias) {
    return $DrinksTable(attachedDatabase, alias);
  }
}

class Drink extends DataClass implements Insertable<Drink> {
  /// UUID créé sur l'appareil.
  final String id;

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  final int updatedAt;

  /// Appareil auteur de la dernière modification (départage les égalités).
  final String updatedBy;

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  final int? deletedAt;

  /// Vide si le type a été supprimé : la référence est « sans catégorie ».
  final String? typeId;
  final String name;
  final String? producer;
  final String? appellation;
  final String? region;
  final String? country;
  final String? grapes;

  /// Degré d'alcool, en % vol.
  final double? abv;

  /// Note personnelle, de 0 à 5 étoiles.
  final int? rating;
  final bool favorite;
  final String? comment;

  /// Marqueur « à compléter », calculé à chaque enregistrement (field_rules.dart).
  final bool needsCompletion;

  /// Accords mets et vins (V2).
  final String? foodPairing;
  final int createdAt;
  const Drink({
    required this.id,
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    this.typeId,
    required this.name,
    this.producer,
    this.appellation,
    this.region,
    this.country,
    this.grapes,
    this.abv,
    this.rating,
    required this.favorite,
    this.comment,
    required this.needsCompletion,
    this.foodPairing,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || typeId != null) {
      map['type_id'] = Variable<String>(typeId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || producer != null) {
      map['producer'] = Variable<String>(producer);
    }
    if (!nullToAbsent || appellation != null) {
      map['appellation'] = Variable<String>(appellation);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || grapes != null) {
      map['grapes'] = Variable<String>(grapes);
    }
    if (!nullToAbsent || abv != null) {
      map['abv'] = Variable<double>(abv);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['favorite'] = Variable<bool>(favorite);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['needs_completion'] = Variable<bool>(needsCompletion);
    if (!nullToAbsent || foodPairing != null) {
      map['food_pairing'] = Variable<String>(foodPairing);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DrinksCompanion toCompanion(bool nullToAbsent) {
    return DrinksCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      typeId: typeId == null && nullToAbsent
          ? const Value.absent()
          : Value(typeId),
      name: Value(name),
      producer: producer == null && nullToAbsent
          ? const Value.absent()
          : Value(producer),
      appellation: appellation == null && nullToAbsent
          ? const Value.absent()
          : Value(appellation),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      grapes: grapes == null && nullToAbsent
          ? const Value.absent()
          : Value(grapes),
      abv: abv == null && nullToAbsent ? const Value.absent() : Value(abv),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      favorite: Value(favorite),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      needsCompletion: Value(needsCompletion),
      foodPairing: foodPairing == null && nullToAbsent
          ? const Value.absent()
          : Value(foodPairing),
      createdAt: Value(createdAt),
    );
  }

  factory Drink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Drink(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      typeId: serializer.fromJson<String?>(json['typeId']),
      name: serializer.fromJson<String>(json['name']),
      producer: serializer.fromJson<String?>(json['producer']),
      appellation: serializer.fromJson<String?>(json['appellation']),
      region: serializer.fromJson<String?>(json['region']),
      country: serializer.fromJson<String?>(json['country']),
      grapes: serializer.fromJson<String?>(json['grapes']),
      abv: serializer.fromJson<double?>(json['abv']),
      rating: serializer.fromJson<int?>(json['rating']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      comment: serializer.fromJson<String?>(json['comment']),
      needsCompletion: serializer.fromJson<bool>(json['needsCompletion']),
      foodPairing: serializer.fromJson<String?>(json['foodPairing']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'typeId': serializer.toJson<String?>(typeId),
      'name': serializer.toJson<String>(name),
      'producer': serializer.toJson<String?>(producer),
      'appellation': serializer.toJson<String?>(appellation),
      'region': serializer.toJson<String?>(region),
      'country': serializer.toJson<String?>(country),
      'grapes': serializer.toJson<String?>(grapes),
      'abv': serializer.toJson<double?>(abv),
      'rating': serializer.toJson<int?>(rating),
      'favorite': serializer.toJson<bool>(favorite),
      'comment': serializer.toJson<String?>(comment),
      'needsCompletion': serializer.toJson<bool>(needsCompletion),
      'foodPairing': serializer.toJson<String?>(foodPairing),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Drink copyWith({
    String? id,
    int? updatedAt,
    String? updatedBy,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> typeId = const Value.absent(),
    String? name,
    Value<String?> producer = const Value.absent(),
    Value<String?> appellation = const Value.absent(),
    Value<String?> region = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> grapes = const Value.absent(),
    Value<double?> abv = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    bool? favorite,
    Value<String?> comment = const Value.absent(),
    bool? needsCompletion,
    Value<String?> foodPairing = const Value.absent(),
    int? createdAt,
  }) => Drink(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    typeId: typeId.present ? typeId.value : this.typeId,
    name: name ?? this.name,
    producer: producer.present ? producer.value : this.producer,
    appellation: appellation.present ? appellation.value : this.appellation,
    region: region.present ? region.value : this.region,
    country: country.present ? country.value : this.country,
    grapes: grapes.present ? grapes.value : this.grapes,
    abv: abv.present ? abv.value : this.abv,
    rating: rating.present ? rating.value : this.rating,
    favorite: favorite ?? this.favorite,
    comment: comment.present ? comment.value : this.comment,
    needsCompletion: needsCompletion ?? this.needsCompletion,
    foodPairing: foodPairing.present ? foodPairing.value : this.foodPairing,
    createdAt: createdAt ?? this.createdAt,
  );
  Drink copyWithCompanion(DrinksCompanion data) {
    return Drink(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      name: data.name.present ? data.name.value : this.name,
      producer: data.producer.present ? data.producer.value : this.producer,
      appellation: data.appellation.present
          ? data.appellation.value
          : this.appellation,
      region: data.region.present ? data.region.value : this.region,
      country: data.country.present ? data.country.value : this.country,
      grapes: data.grapes.present ? data.grapes.value : this.grapes,
      abv: data.abv.present ? data.abv.value : this.abv,
      rating: data.rating.present ? data.rating.value : this.rating,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      comment: data.comment.present ? data.comment.value : this.comment,
      needsCompletion: data.needsCompletion.present
          ? data.needsCompletion.value
          : this.needsCompletion,
      foodPairing: data.foodPairing.present
          ? data.foodPairing.value
          : this.foodPairing,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Drink(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('typeId: $typeId, ')
          ..write('name: $name, ')
          ..write('producer: $producer, ')
          ..write('appellation: $appellation, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('grapes: $grapes, ')
          ..write('abv: $abv, ')
          ..write('rating: $rating, ')
          ..write('favorite: $favorite, ')
          ..write('comment: $comment, ')
          ..write('needsCompletion: $needsCompletion, ')
          ..write('foodPairing: $foodPairing, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    typeId,
    name,
    producer,
    appellation,
    region,
    country,
    grapes,
    abv,
    rating,
    favorite,
    comment,
    needsCompletion,
    foodPairing,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Drink &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.typeId == this.typeId &&
          other.name == this.name &&
          other.producer == this.producer &&
          other.appellation == this.appellation &&
          other.region == this.region &&
          other.country == this.country &&
          other.grapes == this.grapes &&
          other.abv == this.abv &&
          other.rating == this.rating &&
          other.favorite == this.favorite &&
          other.comment == this.comment &&
          other.needsCompletion == this.needsCompletion &&
          other.foodPairing == this.foodPairing &&
          other.createdAt == this.createdAt);
}

class DrinksCompanion extends UpdateCompanion<Drink> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int?> deletedAt;
  final Value<String?> typeId;
  final Value<String> name;
  final Value<String?> producer;
  final Value<String?> appellation;
  final Value<String?> region;
  final Value<String?> country;
  final Value<String?> grapes;
  final Value<double?> abv;
  final Value<int?> rating;
  final Value<bool> favorite;
  final Value<String?> comment;
  final Value<bool> needsCompletion;
  final Value<String?> foodPairing;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DrinksCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.typeId = const Value.absent(),
    this.name = const Value.absent(),
    this.producer = const Value.absent(),
    this.appellation = const Value.absent(),
    this.region = const Value.absent(),
    this.country = const Value.absent(),
    this.grapes = const Value.absent(),
    this.abv = const Value.absent(),
    this.rating = const Value.absent(),
    this.favorite = const Value.absent(),
    this.comment = const Value.absent(),
    this.needsCompletion = const Value.absent(),
    this.foodPairing = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DrinksCompanion.insert({
    required String id,
    required int updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    this.typeId = const Value.absent(),
    required String name,
    this.producer = const Value.absent(),
    this.appellation = const Value.absent(),
    this.region = const Value.absent(),
    this.country = const Value.absent(),
    this.grapes = const Value.absent(),
    this.abv = const Value.absent(),
    this.rating = const Value.absent(),
    this.favorite = const Value.absent(),
    this.comment = const Value.absent(),
    this.needsCompletion = const Value.absent(),
    this.foodPairing = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Drink> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? deletedAt,
    Expression<String>? typeId,
    Expression<String>? name,
    Expression<String>? producer,
    Expression<String>? appellation,
    Expression<String>? region,
    Expression<String>? country,
    Expression<String>? grapes,
    Expression<double>? abv,
    Expression<int>? rating,
    Expression<bool>? favorite,
    Expression<String>? comment,
    Expression<bool>? needsCompletion,
    Expression<String>? foodPairing,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (typeId != null) 'type_id': typeId,
      if (name != null) 'name': name,
      if (producer != null) 'producer': producer,
      if (appellation != null) 'appellation': appellation,
      if (region != null) 'region': region,
      if (country != null) 'country': country,
      if (grapes != null) 'grapes': grapes,
      if (abv != null) 'abv': abv,
      if (rating != null) 'rating': rating,
      if (favorite != null) 'favorite': favorite,
      if (comment != null) 'comment': comment,
      if (needsCompletion != null) 'needs_completion': needsCompletion,
      if (foodPairing != null) 'food_pairing': foodPairing,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DrinksCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int?>? deletedAt,
    Value<String?>? typeId,
    Value<String>? name,
    Value<String?>? producer,
    Value<String?>? appellation,
    Value<String?>? region,
    Value<String?>? country,
    Value<String?>? grapes,
    Value<double?>? abv,
    Value<int?>? rating,
    Value<bool>? favorite,
    Value<String?>? comment,
    Value<bool>? needsCompletion,
    Value<String?>? foodPairing,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DrinksCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      typeId: typeId ?? this.typeId,
      name: name ?? this.name,
      producer: producer ?? this.producer,
      appellation: appellation ?? this.appellation,
      region: region ?? this.region,
      country: country ?? this.country,
      grapes: grapes ?? this.grapes,
      abv: abv ?? this.abv,
      rating: rating ?? this.rating,
      favorite: favorite ?? this.favorite,
      comment: comment ?? this.comment,
      needsCompletion: needsCompletion ?? this.needsCompletion,
      foodPairing: foodPairing ?? this.foodPairing,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<String>(typeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (producer.present) {
      map['producer'] = Variable<String>(producer.value);
    }
    if (appellation.present) {
      map['appellation'] = Variable<String>(appellation.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (grapes.present) {
      map['grapes'] = Variable<String>(grapes.value);
    }
    if (abv.present) {
      map['abv'] = Variable<double>(abv.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (needsCompletion.present) {
      map['needs_completion'] = Variable<bool>(needsCompletion.value);
    }
    if (foodPairing.present) {
      map['food_pairing'] = Variable<String>(foodPairing.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrinksCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('typeId: $typeId, ')
          ..write('name: $name, ')
          ..write('producer: $producer, ')
          ..write('appellation: $appellation, ')
          ..write('region: $region, ')
          ..write('country: $country, ')
          ..write('grapes: $grapes, ')
          ..write('abv: $abv, ')
          ..write('rating: $rating, ')
          ..write('favorite: $favorite, ')
          ..write('comment: $comment, ')
          ..write('needsCompletion: $needsCompletion, ')
          ..write('foodPairing: $foodPairing, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacteristicFamiliesTable extends CharacteristicFamilies
    with TableInfo<$CharacteristicFamiliesTable, CharacteristicFamily> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacteristicFamiliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<String> typeId = GeneratedColumn<String>(
    'type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drink_types (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    typeId,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characteristic_families';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacteristicFamily> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacteristicFamily map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacteristicFamily(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CharacteristicFamiliesTable createAlias(String alias) {
    return $CharacteristicFamiliesTable(attachedDatabase, alias);
  }
}

class CharacteristicFamily extends DataClass
    implements Insertable<CharacteristicFamily> {
  /// UUID créé sur l'appareil.
  final String id;

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  final int updatedAt;

  /// Appareil auteur de la dernière modification (départage les égalités).
  final String updatedBy;

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  final int? deletedAt;
  final String typeId;
  final String name;
  final int sortOrder;
  const CharacteristicFamily({
    required this.id,
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.typeId,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['type_id'] = Variable<String>(typeId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CharacteristicFamiliesCompanion toCompanion(bool nullToAbsent) {
    return CharacteristicFamiliesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      typeId: Value(typeId),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory CharacteristicFamily.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacteristicFamily(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      typeId: serializer.fromJson<String>(json['typeId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'typeId': serializer.toJson<String>(typeId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CharacteristicFamily copyWith({
    String? id,
    int? updatedAt,
    String? updatedBy,
    Value<int?> deletedAt = const Value.absent(),
    String? typeId,
    String? name,
    int? sortOrder,
  }) => CharacteristicFamily(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    typeId: typeId ?? this.typeId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CharacteristicFamily copyWithCompanion(CharacteristicFamiliesCompanion data) {
    return CharacteristicFamily(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacteristicFamily(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('typeId: $typeId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, updatedBy, deletedAt, typeId, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacteristicFamily &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.typeId == this.typeId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class CharacteristicFamiliesCompanion
    extends UpdateCompanion<CharacteristicFamily> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int?> deletedAt;
  final Value<String> typeId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CharacteristicFamiliesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.typeId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacteristicFamiliesCompanion.insert({
    required String id,
    required int updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String typeId,
    required String name,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       typeId = Value(typeId),
       name = Value(name);
  static Insertable<CharacteristicFamily> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? deletedAt,
    Expression<String>? typeId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (typeId != null) 'type_id': typeId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacteristicFamiliesCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int?>? deletedAt,
    Value<String>? typeId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CharacteristicFamiliesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      typeId: typeId ?? this.typeId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<String>(typeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacteristicFamiliesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('typeId: $typeId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacteristicsTable extends Characteristics
    with TableInfo<$CharacteristicsTable, Characteristic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacteristicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characteristic_families (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    familyId,
    name,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characteristics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Characteristic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Characteristic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Characteristic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CharacteristicsTable createAlias(String alias) {
    return $CharacteristicsTable(attachedDatabase, alias);
  }
}

class Characteristic extends DataClass implements Insertable<Characteristic> {
  /// UUID créé sur l'appareil.
  final String id;

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  final int updatedAt;

  /// Appareil auteur de la dernière modification (départage les égalités).
  final String updatedBy;

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  final int? deletedAt;
  final String familyId;
  final String name;
  final int sortOrder;
  const Characteristic({
    required this.id,
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.familyId,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['family_id'] = Variable<String>(familyId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CharacteristicsCompanion toCompanion(bool nullToAbsent) {
    return CharacteristicsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      familyId: Value(familyId),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory Characteristic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Characteristic(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      familyId: serializer.fromJson<String>(json['familyId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'familyId': serializer.toJson<String>(familyId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Characteristic copyWith({
    String? id,
    int? updatedAt,
    String? updatedBy,
    Value<int?> deletedAt = const Value.absent(),
    String? familyId,
    String? name,
    int? sortOrder,
  }) => Characteristic(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    familyId: familyId ?? this.familyId,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Characteristic copyWithCompanion(CharacteristicsCompanion data) {
    return Characteristic(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Characteristic(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('familyId: $familyId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    familyId,
    name,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Characteristic &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.familyId == this.familyId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class CharacteristicsCompanion extends UpdateCompanion<Characteristic> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int?> deletedAt;
  final Value<String> familyId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CharacteristicsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.familyId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacteristicsCompanion.insert({
    required String id,
    required int updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String familyId,
    required String name,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       familyId = Value(familyId),
       name = Value(name);
  static Insertable<Characteristic> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? deletedAt,
    Expression<String>? familyId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (familyId != null) 'family_id': familyId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacteristicsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int?>? deletedAt,
    Value<String>? familyId,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CharacteristicsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacteristicsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('familyId: $familyId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrinkCharacteristicsTable extends DrinkCharacteristics
    with TableInfo<$DrinkCharacteristicsTable, DrinkCharacteristic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrinkCharacteristicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drinkIdMeta = const VerificationMeta(
    'drinkId',
  );
  @override
  late final GeneratedColumn<String> drinkId = GeneratedColumn<String>(
    'drink_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drinks (id)',
    ),
  );
  static const VerificationMeta _characteristicIdMeta = const VerificationMeta(
    'characteristicId',
  );
  @override
  late final GeneratedColumn<String> characteristicId = GeneratedColumn<String>(
    'characteristic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characteristics (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    drinkId,
    characteristicId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drink_characteristics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrinkCharacteristic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('drink_id')) {
      context.handle(
        _drinkIdMeta,
        drinkId.isAcceptableOrUnknown(data['drink_id']!, _drinkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drinkIdMeta);
    }
    if (data.containsKey('characteristic_id')) {
      context.handle(
        _characteristicIdMeta,
        characteristicId.isAcceptableOrUnknown(
          data['characteristic_id']!,
          _characteristicIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characteristicIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DrinkCharacteristic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrinkCharacteristic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      drinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drink_id'],
      )!,
      characteristicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}characteristic_id'],
      )!,
    );
  }

  @override
  $DrinkCharacteristicsTable createAlias(String alias) {
    return $DrinkCharacteristicsTable(attachedDatabase, alias);
  }
}

class DrinkCharacteristic extends DataClass
    implements Insertable<DrinkCharacteristic> {
  /// UUID créé sur l'appareil.
  final String id;

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  final int updatedAt;

  /// Appareil auteur de la dernière modification (départage les égalités).
  final String updatedBy;

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  final int? deletedAt;
  final String drinkId;
  final String characteristicId;
  const DrinkCharacteristic({
    required this.id,
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.drinkId,
    required this.characteristicId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['drink_id'] = Variable<String>(drinkId);
    map['characteristic_id'] = Variable<String>(characteristicId);
    return map;
  }

  DrinkCharacteristicsCompanion toCompanion(bool nullToAbsent) {
    return DrinkCharacteristicsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      drinkId: Value(drinkId),
      characteristicId: Value(characteristicId),
    );
  }

  factory DrinkCharacteristic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrinkCharacteristic(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      drinkId: serializer.fromJson<String>(json['drinkId']),
      characteristicId: serializer.fromJson<String>(json['characteristicId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'drinkId': serializer.toJson<String>(drinkId),
      'characteristicId': serializer.toJson<String>(characteristicId),
    };
  }

  DrinkCharacteristic copyWith({
    String? id,
    int? updatedAt,
    String? updatedBy,
    Value<int?> deletedAt = const Value.absent(),
    String? drinkId,
    String? characteristicId,
  }) => DrinkCharacteristic(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    drinkId: drinkId ?? this.drinkId,
    characteristicId: characteristicId ?? this.characteristicId,
  );
  DrinkCharacteristic copyWithCompanion(DrinkCharacteristicsCompanion data) {
    return DrinkCharacteristic(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      drinkId: data.drinkId.present ? data.drinkId.value : this.drinkId,
      characteristicId: data.characteristicId.present
          ? data.characteristicId.value
          : this.characteristicId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrinkCharacteristic(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('drinkId: $drinkId, ')
          ..write('characteristicId: $characteristicId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    drinkId,
    characteristicId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrinkCharacteristic &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.drinkId == this.drinkId &&
          other.characteristicId == this.characteristicId);
}

class DrinkCharacteristicsCompanion
    extends UpdateCompanion<DrinkCharacteristic> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int?> deletedAt;
  final Value<String> drinkId;
  final Value<String> characteristicId;
  final Value<int> rowid;
  const DrinkCharacteristicsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.drinkId = const Value.absent(),
    this.characteristicId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DrinkCharacteristicsCompanion.insert({
    required String id,
    required int updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String drinkId,
    required String characteristicId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       drinkId = Value(drinkId),
       characteristicId = Value(characteristicId);
  static Insertable<DrinkCharacteristic> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? deletedAt,
    Expression<String>? drinkId,
    Expression<String>? characteristicId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (drinkId != null) 'drink_id': drinkId,
      if (characteristicId != null) 'characteristic_id': characteristicId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DrinkCharacteristicsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int?>? deletedAt,
    Value<String>? drinkId,
    Value<String>? characteristicId,
    Value<int>? rowid,
  }) {
    return DrinkCharacteristicsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      drinkId: drinkId ?? this.drinkId,
      characteristicId: characteristicId ?? this.characteristicId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (drinkId.present) {
      map['drink_id'] = Variable<String>(drinkId.value);
    }
    if (characteristicId.present) {
      map['characteristic_id'] = Variable<String>(characteristicId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrinkCharacteristicsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('drinkId: $drinkId, ')
          ..write('characteristicId: $characteristicId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotsTable extends Lots with TableInfo<$LotsTable, Lot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drinkIdMeta = const VerificationMeta(
    'drinkId',
  );
  @override
  late final GeneratedColumn<String> drinkId = GeneratedColumn<String>(
    'drink_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drinks (id)',
    ),
  );
  static const VerificationMeta _vintageMeta = const VerificationMeta(
    'vintage',
  );
  @override
  late final GeneratedColumn<int> vintage = GeneratedColumn<int>(
    'vintage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volumeMlMeta = const VerificationMeta(
    'volumeMl',
  );
  @override
  late final GeneratedColumn<int> volumeMl = GeneratedColumn<int>(
    'volume_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drinkFromMeta = const VerificationMeta(
    'drinkFrom',
  );
  @override
  late final GeneratedColumn<int> drinkFrom = GeneratedColumn<int>(
    'drink_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drinkBeforeMeta = const VerificationMeta(
    'drinkBefore',
  );
  @override
  late final GeneratedColumn<int> drinkBefore = GeneratedColumn<int>(
    'drink_before',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    drinkId,
    vintage,
    volumeMl,
    barcode,
    stock,
    location,
    drinkFrom,
    drinkBefore,
    photoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('drink_id')) {
      context.handle(
        _drinkIdMeta,
        drinkId.isAcceptableOrUnknown(data['drink_id']!, _drinkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drinkIdMeta);
    }
    if (data.containsKey('vintage')) {
      context.handle(
        _vintageMeta,
        vintage.isAcceptableOrUnknown(data['vintage']!, _vintageMeta),
      );
    }
    if (data.containsKey('volume_ml')) {
      context.handle(
        _volumeMlMeta,
        volumeMl.isAcceptableOrUnknown(data['volume_ml']!, _volumeMlMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMlMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('drink_from')) {
      context.handle(
        _drinkFromMeta,
        drinkFrom.isAcceptableOrUnknown(data['drink_from']!, _drinkFromMeta),
      );
    }
    if (data.containsKey('drink_before')) {
      context.handle(
        _drinkBeforeMeta,
        drinkBefore.isAcceptableOrUnknown(
          data['drink_before']!,
          _drinkBeforeMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      drinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drink_id'],
      )!,
      vintage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vintage'],
      ),
      volumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume_ml'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      drinkFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}drink_from'],
      ),
      drinkBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}drink_before'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LotsTable createAlias(String alias) {
    return $LotsTable(attachedDatabase, alias);
  }
}

class Lot extends DataClass implements Insertable<Lot> {
  /// UUID créé sur l'appareil.
  final String id;

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  final int updatedAt;

  /// Appareil auteur de la dernière modification (départage les égalités).
  final String updatedBy;

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  final int? deletedAt;
  final String drinkId;

  /// Vide = sans millésime.
  final int? vintage;
  final int volumeMl;

  /// Pas unique : un même code peut correspondre à plusieurs lots (CDC §6.2).
  final String? barcode;

  /// Cache du stock, recalculé à partir des mouvements (domain/stock.dart).
  /// Ne jamais le modifier directement ; il n'est pas fusionné à la synchro.
  final int stock;

  /// V2 : emplacement, période idéale de consommation, photo de l'étiquette.
  final String? location;
  final int? drinkFrom;
  final int? drinkBefore;
  final String? photoPath;
  final int createdAt;
  const Lot({
    required this.id,
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.drinkId,
    this.vintage,
    required this.volumeMl,
    this.barcode,
    required this.stock,
    this.location,
    this.drinkFrom,
    this.drinkBefore,
    this.photoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['drink_id'] = Variable<String>(drinkId);
    if (!nullToAbsent || vintage != null) {
      map['vintage'] = Variable<int>(vintage);
    }
    map['volume_ml'] = Variable<int>(volumeMl);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['stock'] = Variable<int>(stock);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || drinkFrom != null) {
      map['drink_from'] = Variable<int>(drinkFrom);
    }
    if (!nullToAbsent || drinkBefore != null) {
      map['drink_before'] = Variable<int>(drinkBefore);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  LotsCompanion toCompanion(bool nullToAbsent) {
    return LotsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      drinkId: Value(drinkId),
      vintage: vintage == null && nullToAbsent
          ? const Value.absent()
          : Value(vintage),
      volumeMl: Value(volumeMl),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      stock: Value(stock),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      drinkFrom: drinkFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(drinkFrom),
      drinkBefore: drinkBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(drinkBefore),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory Lot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lot(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      drinkId: serializer.fromJson<String>(json['drinkId']),
      vintage: serializer.fromJson<int?>(json['vintage']),
      volumeMl: serializer.fromJson<int>(json['volumeMl']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      stock: serializer.fromJson<int>(json['stock']),
      location: serializer.fromJson<String?>(json['location']),
      drinkFrom: serializer.fromJson<int?>(json['drinkFrom']),
      drinkBefore: serializer.fromJson<int?>(json['drinkBefore']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'drinkId': serializer.toJson<String>(drinkId),
      'vintage': serializer.toJson<int?>(vintage),
      'volumeMl': serializer.toJson<int>(volumeMl),
      'barcode': serializer.toJson<String?>(barcode),
      'stock': serializer.toJson<int>(stock),
      'location': serializer.toJson<String?>(location),
      'drinkFrom': serializer.toJson<int?>(drinkFrom),
      'drinkBefore': serializer.toJson<int?>(drinkBefore),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Lot copyWith({
    String? id,
    int? updatedAt,
    String? updatedBy,
    Value<int?> deletedAt = const Value.absent(),
    String? drinkId,
    Value<int?> vintage = const Value.absent(),
    int? volumeMl,
    Value<String?> barcode = const Value.absent(),
    int? stock,
    Value<String?> location = const Value.absent(),
    Value<int?> drinkFrom = const Value.absent(),
    Value<int?> drinkBefore = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    int? createdAt,
  }) => Lot(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    drinkId: drinkId ?? this.drinkId,
    vintage: vintage.present ? vintage.value : this.vintage,
    volumeMl: volumeMl ?? this.volumeMl,
    barcode: barcode.present ? barcode.value : this.barcode,
    stock: stock ?? this.stock,
    location: location.present ? location.value : this.location,
    drinkFrom: drinkFrom.present ? drinkFrom.value : this.drinkFrom,
    drinkBefore: drinkBefore.present ? drinkBefore.value : this.drinkBefore,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  Lot copyWithCompanion(LotsCompanion data) {
    return Lot(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      drinkId: data.drinkId.present ? data.drinkId.value : this.drinkId,
      vintage: data.vintage.present ? data.vintage.value : this.vintage,
      volumeMl: data.volumeMl.present ? data.volumeMl.value : this.volumeMl,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      stock: data.stock.present ? data.stock.value : this.stock,
      location: data.location.present ? data.location.value : this.location,
      drinkFrom: data.drinkFrom.present ? data.drinkFrom.value : this.drinkFrom,
      drinkBefore: data.drinkBefore.present
          ? data.drinkBefore.value
          : this.drinkBefore,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lot(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('drinkId: $drinkId, ')
          ..write('vintage: $vintage, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('barcode: $barcode, ')
          ..write('stock: $stock, ')
          ..write('location: $location, ')
          ..write('drinkFrom: $drinkFrom, ')
          ..write('drinkBefore: $drinkBefore, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    drinkId,
    vintage,
    volumeMl,
    barcode,
    stock,
    location,
    drinkFrom,
    drinkBefore,
    photoPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lot &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.drinkId == this.drinkId &&
          other.vintage == this.vintage &&
          other.volumeMl == this.volumeMl &&
          other.barcode == this.barcode &&
          other.stock == this.stock &&
          other.location == this.location &&
          other.drinkFrom == this.drinkFrom &&
          other.drinkBefore == this.drinkBefore &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class LotsCompanion extends UpdateCompanion<Lot> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int?> deletedAt;
  final Value<String> drinkId;
  final Value<int?> vintage;
  final Value<int> volumeMl;
  final Value<String?> barcode;
  final Value<int> stock;
  final Value<String?> location;
  final Value<int?> drinkFrom;
  final Value<int?> drinkBefore;
  final Value<String?> photoPath;
  final Value<int> createdAt;
  final Value<int> rowid;
  const LotsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.drinkId = const Value.absent(),
    this.vintage = const Value.absent(),
    this.volumeMl = const Value.absent(),
    this.barcode = const Value.absent(),
    this.stock = const Value.absent(),
    this.location = const Value.absent(),
    this.drinkFrom = const Value.absent(),
    this.drinkBefore = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotsCompanion.insert({
    required String id,
    required int updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String drinkId,
    this.vintage = const Value.absent(),
    required int volumeMl,
    this.barcode = const Value.absent(),
    this.stock = const Value.absent(),
    this.location = const Value.absent(),
    this.drinkFrom = const Value.absent(),
    this.drinkBefore = const Value.absent(),
    this.photoPath = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       drinkId = Value(drinkId),
       volumeMl = Value(volumeMl),
       createdAt = Value(createdAt);
  static Insertable<Lot> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? deletedAt,
    Expression<String>? drinkId,
    Expression<int>? vintage,
    Expression<int>? volumeMl,
    Expression<String>? barcode,
    Expression<int>? stock,
    Expression<String>? location,
    Expression<int>? drinkFrom,
    Expression<int>? drinkBefore,
    Expression<String>? photoPath,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (drinkId != null) 'drink_id': drinkId,
      if (vintage != null) 'vintage': vintage,
      if (volumeMl != null) 'volume_ml': volumeMl,
      if (barcode != null) 'barcode': barcode,
      if (stock != null) 'stock': stock,
      if (location != null) 'location': location,
      if (drinkFrom != null) 'drink_from': drinkFrom,
      if (drinkBefore != null) 'drink_before': drinkBefore,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int?>? deletedAt,
    Value<String>? drinkId,
    Value<int?>? vintage,
    Value<int>? volumeMl,
    Value<String?>? barcode,
    Value<int>? stock,
    Value<String?>? location,
    Value<int?>? drinkFrom,
    Value<int?>? drinkBefore,
    Value<String?>? photoPath,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return LotsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      drinkId: drinkId ?? this.drinkId,
      vintage: vintage ?? this.vintage,
      volumeMl: volumeMl ?? this.volumeMl,
      barcode: barcode ?? this.barcode,
      stock: stock ?? this.stock,
      location: location ?? this.location,
      drinkFrom: drinkFrom ?? this.drinkFrom,
      drinkBefore: drinkBefore ?? this.drinkBefore,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (drinkId.present) {
      map['drink_id'] = Variable<String>(drinkId.value);
    }
    if (vintage.present) {
      map['vintage'] = Variable<int>(vintage.value);
    }
    if (volumeMl.present) {
      map['volume_ml'] = Variable<int>(volumeMl.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (drinkFrom.present) {
      map['drink_from'] = Variable<int>(drinkFrom.value);
    }
    if (drinkBefore.present) {
      map['drink_before'] = Variable<int>(drinkBefore.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('drinkId: $drinkId, ')
          ..write('vintage: $vintage, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('barcode: $barcode, ')
          ..write('stock: $stock, ')
          ..write('location: $location, ')
          ..write('drinkFrom: $drinkFrom, ')
          ..write('drinkBefore: $drinkBefore, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementsTable extends Movements
    with TableInfo<$MovementsTable, Movement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lots (id)',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MovementKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MovementKind>($MovementsTable.$converterkind);
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExitReason?, String> reason =
      GeneratedColumn<String>(
        'reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ExitReason?>($MovementsTable.$converterreasonn);
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    lotId,
    occurredAt,
    kind,
    quantity,
    reason,
    comment,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Movement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Movement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Movement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      kind: $MovementsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      reason: $MovementsTable.$converterreasonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reason'],
        ),
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $MovementsTable createAlias(String alias) {
    return $MovementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MovementKind, String, String> $converterkind =
      const EnumNameConverter<MovementKind>(MovementKind.values);
  static JsonTypeConverter2<ExitReason, String, String> $converterreason =
      const EnumNameConverter<ExitReason>(ExitReason.values);
  static JsonTypeConverter2<ExitReason?, String?, String?> $converterreasonn =
      JsonTypeConverter2.asNullable($converterreason);
}

class Movement extends DataClass implements Insertable<Movement> {
  /// UUID créé sur l'appareil.
  final String id;

  /// Date de dernière modification : la plus récente l'emporte à la fusion.
  final int updatedAt;

  /// Appareil auteur de la dernière modification (départage les égalités).
  final String updatedBy;

  /// Suppression logique : la ligne reste pour que la suppression se propage.
  final int? deletedAt;
  final String lotId;
  final int occurredAt;
  final MovementKind kind;

  /// Entrée / sortie : nombre de bouteilles ; inventaire : nombre constaté.
  final int quantity;

  /// Uniquement pour les sorties.
  final ExitReason? reason;
  final String? comment;

  /// Appareil qui a créé le mouvement.
  final String deviceId;
  const Movement({
    required this.id,
    required this.updatedAt,
    required this.updatedBy,
    this.deletedAt,
    required this.lotId,
    required this.occurredAt,
    required this.kind,
    required this.quantity,
    this.reason,
    this.comment,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['lot_id'] = Variable<String>(lotId);
    map['occurred_at'] = Variable<int>(occurredAt);
    {
      map['kind'] = Variable<String>(
        $MovementsTable.$converterkind.toSql(kind),
      );
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(
        $MovementsTable.$converterreasonn.toSql(reason),
      );
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  MovementsCompanion toCompanion(bool nullToAbsent) {
    return MovementsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lotId: Value(lotId),
      occurredAt: Value(occurredAt),
      kind: Value(kind),
      quantity: Value(quantity),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      deviceId: Value(deviceId),
    );
  }

  factory Movement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Movement(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      lotId: serializer.fromJson<String>(json['lotId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      kind: $MovementsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      quantity: serializer.fromJson<int>(json['quantity']),
      reason: $MovementsTable.$converterreasonn.fromJson(
        serializer.fromJson<String?>(json['reason']),
      ),
      comment: serializer.fromJson<String?>(json['comment']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'lotId': serializer.toJson<String>(lotId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'kind': serializer.toJson<String>(
        $MovementsTable.$converterkind.toJson(kind),
      ),
      'quantity': serializer.toJson<int>(quantity),
      'reason': serializer.toJson<String?>(
        $MovementsTable.$converterreasonn.toJson(reason),
      ),
      'comment': serializer.toJson<String?>(comment),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  Movement copyWith({
    String? id,
    int? updatedAt,
    String? updatedBy,
    Value<int?> deletedAt = const Value.absent(),
    String? lotId,
    int? occurredAt,
    MovementKind? kind,
    int? quantity,
    Value<ExitReason?> reason = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    String? deviceId,
  }) => Movement(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    lotId: lotId ?? this.lotId,
    occurredAt: occurredAt ?? this.occurredAt,
    kind: kind ?? this.kind,
    quantity: quantity ?? this.quantity,
    reason: reason.present ? reason.value : this.reason,
    comment: comment.present ? comment.value : this.comment,
    deviceId: deviceId ?? this.deviceId,
  );
  Movement copyWithCompanion(MovementsCompanion data) {
    return Movement(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      comment: data.comment.present ? data.comment.value : this.comment,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Movement(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lotId: $lotId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('comment: $comment, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    updatedBy,
    deletedAt,
    lotId,
    occurredAt,
    kind,
    quantity,
    reason,
    comment,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Movement &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.deletedAt == this.deletedAt &&
          other.lotId == this.lotId &&
          other.occurredAt == this.occurredAt &&
          other.kind == this.kind &&
          other.quantity == this.quantity &&
          other.reason == this.reason &&
          other.comment == this.comment &&
          other.deviceId == this.deviceId);
}

class MovementsCompanion extends UpdateCompanion<Movement> {
  final Value<String> id;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int?> deletedAt;
  final Value<String> lotId;
  final Value<int> occurredAt;
  final Value<MovementKind> kind;
  final Value<int> quantity;
  final Value<ExitReason?> reason;
  final Value<String?> comment;
  final Value<String> deviceId;
  final Value<int> rowid;
  const MovementsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lotId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.comment = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementsCompanion.insert({
    required String id,
    required int updatedAt,
    required String updatedBy,
    this.deletedAt = const Value.absent(),
    required String lotId,
    required int occurredAt,
    required MovementKind kind,
    required int quantity,
    this.reason = const Value.absent(),
    this.comment = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy),
       lotId = Value(lotId),
       occurredAt = Value(occurredAt),
       kind = Value(kind),
       quantity = Value(quantity),
       deviceId = Value(deviceId);
  static Insertable<Movement> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? deletedAt,
    Expression<String>? lotId,
    Expression<int>? occurredAt,
    Expression<String>? kind,
    Expression<int>? quantity,
    Expression<String>? reason,
    Expression<String>? comment,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lotId != null) 'lot_id': lotId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (kind != null) 'kind': kind,
      if (quantity != null) 'quantity': quantity,
      if (reason != null) 'reason': reason,
      if (comment != null) 'comment': comment,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementsCompanion copyWith({
    Value<String>? id,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int?>? deletedAt,
    Value<String>? lotId,
    Value<int>? occurredAt,
    Value<MovementKind>? kind,
    Value<int>? quantity,
    Value<ExitReason?>? reason,
    Value<String?>? comment,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return MovementsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      lotId: lotId ?? this.lotId,
      occurredAt: occurredAt ?? this.occurredAt,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      comment: comment ?? this.comment,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $MovementsTable.$converterkind.toSql(kind.value),
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(
        $MovementsTable.$converterreasonn.toSql(reason.value),
      );
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lotId: $lotId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('comment: $comment, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt, updatedBy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final int updatedAt;
  final String updatedBy;
  const Setting({
    required this.key,
    required this.value,
    required this.updatedAt,
    required this.updatedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
    };
  }

  Setting copyWith({
    String? key,
    String? value,
    int? updatedAt,
    String? updatedBy,
  }) => Setting(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt, updatedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required int updatedAt,
    required String updatedBy,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt),
       updatedBy = Value(updatedBy);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaEntry extends DataClass implements Insertable<MetaEntry> {
  final String key;
  final String value;
  const MetaEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory MetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaEntry copyWith({String? key, String? value}) =>
      MetaEntry(key: key ?? this.key, value: value ?? this.value);
  MetaEntry copyWithCompanion(MetaCompanion data) {
    return MetaEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CaveDatabase extends GeneratedDatabase {
  _$CaveDatabase(QueryExecutor e) : super(e);
  $CaveDatabaseManager get managers => $CaveDatabaseManager(this);
  late final DrinksFts drinksFts = DrinksFts(this);
  late final $DrinkTypesTable drinkTypes = $DrinkTypesTable(this);
  late final $DrinksTable drinks = $DrinksTable(this);
  late final $CharacteristicFamiliesTable characteristicFamilies =
      $CharacteristicFamiliesTable(this);
  late final $CharacteristicsTable characteristics = $CharacteristicsTable(
    this,
  );
  late final $DrinkCharacteristicsTable drinkCharacteristics =
      $DrinkCharacteristicsTable(this);
  late final Trigger drinksFtsInsert = Trigger(
    'CREATE TRIGGER drinks_fts_insert AFTER INSERT ON drinks BEGIN DELETE FROM drinks_fts WHERE drink_id = new.id;INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, country, grapes, type_name, characteristics) SELECT d.id, d.name, d.producer, d.appellation, d.region, d.country, d.grapes, (SELECT t.name FROM drink_types AS t WHERE t.id = d.type_id AND t.deleted_at IS NULL), (SELECT group_concat(c.name, \' \') FROM drink_characteristics AS dc JOIN characteristics AS c ON c.id = dc.characteristic_id WHERE dc.drink_id = d.id AND dc.deleted_at IS NULL AND c.deleted_at IS NULL) FROM drinks AS d WHERE d.id = new.id;END',
    'drinks_fts_insert',
  );
  late final Trigger drinksFtsUpdate = Trigger(
    'CREATE TRIGGER drinks_fts_update AFTER UPDATE ON drinks BEGIN DELETE FROM drinks_fts WHERE drink_id = new.id;INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, country, grapes, type_name, characteristics) SELECT d.id, d.name, d.producer, d.appellation, d.region, d.country, d.grapes, (SELECT t.name FROM drink_types AS t WHERE t.id = d.type_id AND t.deleted_at IS NULL), (SELECT group_concat(c.name, \' \') FROM drink_characteristics AS dc JOIN characteristics AS c ON c.id = dc.characteristic_id WHERE dc.drink_id = d.id AND dc.deleted_at IS NULL AND c.deleted_at IS NULL) FROM drinks AS d WHERE d.id = new.id;END',
    'drinks_fts_update',
  );
  late final Trigger drinksFtsDelete = Trigger(
    'CREATE TRIGGER drinks_fts_delete AFTER DELETE ON drinks BEGIN DELETE FROM drinks_fts WHERE drink_id = old.id;END',
    'drinks_fts_delete',
  );
  late final Trigger drinksFtsLinkInsert = Trigger(
    'CREATE TRIGGER drinks_fts_link_insert AFTER INSERT ON drink_characteristics BEGIN DELETE FROM drinks_fts WHERE drink_id = new.drink_id;INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, country, grapes, type_name, characteristics) SELECT d.id, d.name, d.producer, d.appellation, d.region, d.country, d.grapes, (SELECT t.name FROM drink_types AS t WHERE t.id = d.type_id AND t.deleted_at IS NULL), (SELECT group_concat(c.name, \' \') FROM drink_characteristics AS dc JOIN characteristics AS c ON c.id = dc.characteristic_id WHERE dc.drink_id = d.id AND dc.deleted_at IS NULL AND c.deleted_at IS NULL) FROM drinks AS d WHERE d.id = new.drink_id;END',
    'drinks_fts_link_insert',
  );
  late final Trigger drinksFtsLinkUpdate = Trigger(
    'CREATE TRIGGER drinks_fts_link_update AFTER UPDATE ON drink_characteristics BEGIN DELETE FROM drinks_fts WHERE drink_id = new.drink_id;INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, country, grapes, type_name, characteristics) SELECT d.id, d.name, d.producer, d.appellation, d.region, d.country, d.grapes, (SELECT t.name FROM drink_types AS t WHERE t.id = d.type_id AND t.deleted_at IS NULL), (SELECT group_concat(c.name, \' \') FROM drink_characteristics AS dc JOIN characteristics AS c ON c.id = dc.characteristic_id WHERE dc.drink_id = d.id AND dc.deleted_at IS NULL AND c.deleted_at IS NULL) FROM drinks AS d WHERE d.id = new.drink_id;END',
    'drinks_fts_link_update',
  );
  late final Trigger drinksFtsTypeUpdate = Trigger(
    'CREATE TRIGGER drinks_fts_type_update AFTER UPDATE ON drink_types BEGIN DELETE FROM drinks_fts WHERE drink_id IN (SELECT id FROM drinks WHERE type_id = new.id);INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, country, grapes, type_name, characteristics) SELECT d.id, d.name, d.producer, d.appellation, d.region, d.country, d.grapes, (SELECT t.name FROM drink_types AS t WHERE t.id = d.type_id AND t.deleted_at IS NULL), (SELECT group_concat(c.name, \' \') FROM drink_characteristics AS dc JOIN characteristics AS c ON c.id = dc.characteristic_id WHERE dc.drink_id = d.id AND dc.deleted_at IS NULL AND c.deleted_at IS NULL) FROM drinks AS d WHERE d.type_id = new.id;END',
    'drinks_fts_type_update',
  );
  late final Trigger drinksFtsCharacteristicUpdate = Trigger(
    'CREATE TRIGGER drinks_fts_characteristic_update AFTER UPDATE ON characteristics BEGIN DELETE FROM drinks_fts WHERE drink_id IN (SELECT drink_id FROM drink_characteristics WHERE characteristic_id = new.id);INSERT INTO drinks_fts (drink_id, name, producer, appellation, region, country, grapes, type_name, characteristics) SELECT d.id, d.name, d.producer, d.appellation, d.region, d.country, d.grapes, (SELECT t.name FROM drink_types AS t WHERE t.id = d.type_id AND t.deleted_at IS NULL), (SELECT group_concat(c.name, \' \') FROM drink_characteristics AS dc JOIN characteristics AS c ON c.id = dc.characteristic_id WHERE dc.drink_id = d.id AND dc.deleted_at IS NULL AND c.deleted_at IS NULL) FROM drinks AS d WHERE d.id IN (SELECT drink_id FROM drink_characteristics WHERE characteristic_id = new.id);END',
    'drinks_fts_characteristic_update',
  );
  late final $LotsTable lots = $LotsTable(this);
  late final $MovementsTable movements = $MovementsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $MetaTable meta = $MetaTable(this);
  late final Index idxFamiliesType = Index(
    'idx_families_type',
    'CREATE INDEX idx_families_type ON characteristic_families (type_id)',
  );
  late final Index idxCharacteristicsFamily = Index(
    'idx_characteristics_family',
    'CREATE INDEX idx_characteristics_family ON characteristics (family_id)',
  );
  late final Index idxDrinksType = Index(
    'idx_drinks_type',
    'CREATE INDEX idx_drinks_type ON drinks (type_id)',
  );
  late final Index idxDrinkCharacteristicsDrink = Index(
    'idx_drink_characteristics_drink',
    'CREATE INDEX idx_drink_characteristics_drink ON drink_characteristics (drink_id)',
  );
  late final Index idxLotsDrink = Index(
    'idx_lots_drink',
    'CREATE INDEX idx_lots_drink ON lots (drink_id)',
  );
  late final Index idxLotsBarcode = Index(
    'idx_lots_barcode',
    'CREATE INDEX idx_lots_barcode ON lots (barcode)',
  );
  late final Index idxMovementsLot = Index(
    'idx_movements_lot',
    'CREATE INDEX idx_movements_lot ON movements (lot_id, occurred_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    drinksFts,
    drinkTypes,
    drinks,
    characteristicFamilies,
    characteristics,
    drinkCharacteristics,
    drinksFtsInsert,
    drinksFtsUpdate,
    drinksFtsDelete,
    drinksFtsLinkInsert,
    drinksFtsLinkUpdate,
    drinksFtsTypeUpdate,
    drinksFtsCharacteristicUpdate,
    lots,
    movements,
    settings,
    meta,
    idxFamiliesType,
    idxCharacteristicsFamily,
    idxDrinksType,
    idxDrinkCharacteristicsDrink,
    idxLotsDrink,
    idxLotsBarcode,
    idxMovementsLot,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'drinks',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('drinks_fts', kind: UpdateKind.delete),
        TableUpdate('drinks_fts', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'drinks',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('drinks_fts', kind: UpdateKind.delete),
        TableUpdate('drinks_fts', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'drinks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('drinks_fts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'drink_characteristics',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [
        TableUpdate('drinks_fts', kind: UpdateKind.delete),
        TableUpdate('drinks_fts', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'drink_characteristics',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('drinks_fts', kind: UpdateKind.delete),
        TableUpdate('drinks_fts', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'drink_types',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('drinks_fts', kind: UpdateKind.delete),
        TableUpdate('drinks_fts', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characteristics',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('drinks_fts', kind: UpdateKind.delete),
        TableUpdate('drinks_fts', kind: UpdateKind.insert),
      ],
    ),
  ]);
}

typedef $DrinksFtsCreateCompanionBuilder = DrinksFtsCompanion Function({
  required String drinkId,
  required String name,
  required String producer,
  required String appellation,
  required String region,
  required String country,
  required String grapes,
  required String typeName,
  required String characteristics,
  Value<int> rowid,
});
typedef $DrinksFtsUpdateCompanionBuilder = DrinksFtsCompanion Function({
  Value<String> drinkId,
  Value<String> name,
  Value<String> producer,
  Value<String> appellation,
  Value<String> region,
  Value<String> country,
  Value<String> grapes,
  Value<String> typeName,
  Value<String> characteristics,
  Value<int> rowid,
});

class $DrinksFtsFilterComposer extends Composer<_$CaveDatabase, DrinksFts> {
  $DrinksFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get drinkId => $composableBuilder(
    column: $table.drinkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grapes => $composableBuilder(
    column: $table.grapes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get characteristics => $composableBuilder(
    column: $table.characteristics,
    builder: (column) => ColumnFilters(column),
  );
}

class $DrinksFtsOrderingComposer extends Composer<_$CaveDatabase, DrinksFts> {
  $DrinksFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get drinkId => $composableBuilder(
    column: $table.drinkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grapes => $composableBuilder(
    column: $table.grapes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get characteristics => $composableBuilder(
    column: $table.characteristics,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DrinksFtsAnnotationComposer extends Composer<_$CaveDatabase, DrinksFts> {
  $DrinksFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get drinkId =>
      $composableBuilder(column: $table.drinkId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get producer =>
      $composableBuilder(column: $table.producer, builder: (column) => column);

  GeneratedColumn<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get grapes =>
      $composableBuilder(column: $table.grapes, builder: (column) => column);

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);

  GeneratedColumn<String> get characteristics => $composableBuilder(
    column: $table.characteristics,
    builder: (column) => column,
  );
}

class $DrinksFtsTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          DrinksFts,
          DrinksFt,
          $DrinksFtsFilterComposer,
          $DrinksFtsOrderingComposer,
          $DrinksFtsAnnotationComposer,
          $DrinksFtsCreateCompanionBuilder,
          $DrinksFtsUpdateCompanionBuilder,
          (DrinksFt, BaseReferences<_$CaveDatabase, DrinksFts, DrinksFt>),
          DrinksFt,
          PrefetchHooks Function()
        > {
  $DrinksFtsTableManager(_$CaveDatabase db, DrinksFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DrinksFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DrinksFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DrinksFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> drinkId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> producer = const Value.absent(),
                Value<String> appellation = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> grapes = const Value.absent(),
                Value<String> typeName = const Value.absent(),
                Value<String> characteristics = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrinksFtsCompanion(
                drinkId: drinkId,
                name: name,
                producer: producer,
                appellation: appellation,
                region: region,
                country: country,
                grapes: grapes,
                typeName: typeName,
                characteristics: characteristics,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String drinkId,
                required String name,
                required String producer,
                required String appellation,
                required String region,
                required String country,
                required String grapes,
                required String typeName,
                required String characteristics,
                Value<int> rowid = const Value.absent(),
              }) => DrinksFtsCompanion.insert(
                drinkId: drinkId,
                name: name,
                producer: producer,
                appellation: appellation,
                region: region,
                country: country,
                grapes: grapes,
                typeName: typeName,
                characteristics: characteristics,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DrinksFts, DrinksFt>(table),
                  BaseReferences<_$CaveDatabase, DrinksFts, DrinksFt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DrinksFtsProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      DrinksFts,
      DrinksFt,
      $DrinksFtsFilterComposer,
      $DrinksFtsOrderingComposer,
      $DrinksFtsAnnotationComposer,
      $DrinksFtsCreateCompanionBuilder,
      $DrinksFtsUpdateCompanionBuilder,
      (DrinksFt, BaseReferences<_$CaveDatabase, DrinksFts, DrinksFt>),
      DrinksFt,
      PrefetchHooks Function()
    >;
typedef $$DrinkTypesTableCreateCompanionBuilder = DrinkTypesCompanion Function({
  required String id,
  required int updatedAt,
  required String updatedBy,
  Value<int?> deletedAt,
  required String name,
  required FieldProfile fieldProfile,
  required int defaultVolumeMl,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$DrinkTypesTableUpdateCompanionBuilder = DrinkTypesCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<int?> deletedAt,
  Value<String> name,
  Value<FieldProfile> fieldProfile,
  Value<int> defaultVolumeMl,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$DrinkTypesTableReferences
    extends BaseReferences<_$CaveDatabase, $DrinkTypesTable, DrinkType> {
  $$DrinkTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DrinksTable, List<Drink>> _drinksRefsTable(
    _$CaveDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.drinks,
    aliasName: 'drink_types__id__drinks__type_id',
  );

  $$DrinksTableProcessedTableManager get drinksRefs {
    final manager = $$DrinksTableTableManager(
      $_db,
      $_db.drinks,
    ).filter((f) => f.typeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_drinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CharacteristicFamiliesTable,
    List<CharacteristicFamily>
  >
  _characteristicFamiliesRefsTable(_$CaveDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.characteristicFamilies,
        aliasName: 'drink_types__id__characteristic_families__type_id',
      );

  $$CharacteristicFamiliesTableProcessedTableManager
  get characteristicFamiliesRefs {
    final manager = $$CharacteristicFamiliesTableTableManager(
      $_db,
      $_db.characteristicFamilies,
    ).filter((f) => f.typeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characteristicFamiliesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DrinkTypesTableFilterComposer
    extends Composer<_$CaveDatabase, $DrinkTypesTable> {
  $$DrinkTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FieldProfile, FieldProfile, String>
  get fieldProfile => $composableBuilder(
    column: $table.fieldProfile,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get defaultVolumeMl => $composableBuilder(
    column: $table.defaultVolumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> drinksRefs(
    Expression<bool> Function($$DrinksTableFilterComposer f) f,
  ) {
    final $$DrinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableFilterComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> characteristicFamiliesRefs(
    Expression<bool> Function($$CharacteristicFamiliesTableFilterComposer f) f,
  ) {
    final $$CharacteristicFamiliesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characteristicFamilies,
          getReferencedColumn: (t) => t.typeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacteristicFamiliesTableFilterComposer(
                $db: $db,
                $table: $db.characteristicFamilies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DrinkTypesTableOrderingComposer
    extends Composer<_$CaveDatabase, $DrinkTypesTable> {
  $$DrinkTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldProfile => $composableBuilder(
    column: $table.fieldProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultVolumeMl => $composableBuilder(
    column: $table.defaultVolumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DrinkTypesTableAnnotationComposer
    extends Composer<_$CaveDatabase, $DrinkTypesTable> {
  $$DrinkTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FieldProfile, String> get fieldProfile =>
      $composableBuilder(
        column: $table.fieldProfile,
        builder: (column) => column,
      );

  GeneratedColumn<int> get defaultVolumeMl => $composableBuilder(
    column: $table.defaultVolumeMl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> drinksRefs<T extends Object>(
    Expression<T> Function($$DrinksTableAnnotationComposer a) f,
  ) {
    final $$DrinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableAnnotationComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> characteristicFamiliesRefs<T extends Object>(
    Expression<T> Function($$CharacteristicFamiliesTableAnnotationComposer a) f,
  ) {
    final $$CharacteristicFamiliesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.characteristicFamilies,
          getReferencedColumn: (t) => t.typeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacteristicFamiliesTableAnnotationComposer(
                $db: $db,
                $table: $db.characteristicFamilies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DrinkTypesTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $DrinkTypesTable,
          DrinkType,
          $$DrinkTypesTableFilterComposer,
          $$DrinkTypesTableOrderingComposer,
          $$DrinkTypesTableAnnotationComposer,
          $$DrinkTypesTableCreateCompanionBuilder,
          $$DrinkTypesTableUpdateCompanionBuilder,
          (DrinkType, $$DrinkTypesTableReferences),
          DrinkType,
          PrefetchHooks Function({
            bool drinksRefs,
            bool characteristicFamiliesRefs,
          })
        > {
  $$DrinkTypesTableTableManager(_$CaveDatabase db, $DrinkTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrinkTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrinkTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrinkTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<FieldProfile> fieldProfile = const Value.absent(),
                Value<int> defaultVolumeMl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrinkTypesCompanion(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                name: name,
                fieldProfile: fieldProfile,
                defaultVolumeMl: defaultVolumeMl,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                required String updatedBy,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                required FieldProfile fieldProfile,
                required int defaultVolumeMl,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrinkTypesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                name: name,
                fieldProfile: fieldProfile,
                defaultVolumeMl: defaultVolumeMl,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DrinkTypesTable, DrinkType>(table),
                  $$DrinkTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({drinksRefs = false, characteristicFamiliesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (drinksRefs) db.drinks,
                    if (characteristicFamiliesRefs) db.characteristicFamilies,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (drinksRefs)
                        await $_getPrefetchedData<
                          DrinkType,
                          $DrinkTypesTable,
                          Drink
                        >(
                          currentTable: table,
                          referencedTable: $$DrinkTypesTableReferences
                              ._drinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DrinkTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).drinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.typeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (characteristicFamiliesRefs)
                        await $_getPrefetchedData<
                          DrinkType,
                          $DrinkTypesTable,
                          CharacteristicFamily
                        >(
                          currentTable: table,
                          referencedTable: $$DrinkTypesTableReferences
                              ._characteristicFamiliesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DrinkTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).characteristicFamiliesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.typeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DrinkTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $DrinkTypesTable,
      DrinkType,
      $$DrinkTypesTableFilterComposer,
      $$DrinkTypesTableOrderingComposer,
      $$DrinkTypesTableAnnotationComposer,
      $$DrinkTypesTableCreateCompanionBuilder,
      $$DrinkTypesTableUpdateCompanionBuilder,
      (DrinkType, $$DrinkTypesTableReferences),
      DrinkType,
      PrefetchHooks Function({bool drinksRefs, bool characteristicFamiliesRefs})
    >;
typedef $$DrinksTableCreateCompanionBuilder = DrinksCompanion Function({
  required String id,
  required int updatedAt,
  required String updatedBy,
  Value<int?> deletedAt,
  Value<String?> typeId,
  required String name,
  Value<String?> producer,
  Value<String?> appellation,
  Value<String?> region,
  Value<String?> country,
  Value<String?> grapes,
  Value<double?> abv,
  Value<int?> rating,
  Value<bool> favorite,
  Value<String?> comment,
  Value<bool> needsCompletion,
  Value<String?> foodPairing,
  required int createdAt,
  Value<int> rowid,
});
typedef $$DrinksTableUpdateCompanionBuilder = DrinksCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<int?> deletedAt,
  Value<String?> typeId,
  Value<String> name,
  Value<String?> producer,
  Value<String?> appellation,
  Value<String?> region,
  Value<String?> country,
  Value<String?> grapes,
  Value<double?> abv,
  Value<int?> rating,
  Value<bool> favorite,
  Value<String?> comment,
  Value<bool> needsCompletion,
  Value<String?> foodPairing,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$DrinksTableReferences
    extends BaseReferences<_$CaveDatabase, $DrinksTable, Drink> {
  $$DrinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DrinkTypesTable _typeIdTable(_$CaveDatabase db) =>
      db.drinkTypes.createAlias('drinks__type_id__drink_types__id');

  $$DrinkTypesTableProcessedTableManager? get typeId {
    final $_column = $_itemColumn<String>('type_id');
    if ($_column == null) return null;
    final manager = $$DrinkTypesTableTableManager(
      $_db,
      $_db.drinkTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $DrinkCharacteristicsTable,
    List<DrinkCharacteristic>
  >
  _drinkCharacteristicsRefsTable(_$CaveDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.drinkCharacteristics,
        aliasName: 'drinks__id__drink_characteristics__drink_id',
      );

  $$DrinkCharacteristicsTableProcessedTableManager
  get drinkCharacteristicsRefs {
    final manager = $$DrinkCharacteristicsTableTableManager(
      $_db,
      $_db.drinkCharacteristics,
    ).filter((f) => f.drinkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _drinkCharacteristicsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LotsTable, List<Lot>> _lotsRefsTable(
    _$CaveDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.lots,
    aliasName: 'drinks__id__lots__drink_id',
  );

  $$LotsTableProcessedTableManager get lotsRefs {
    final manager = $$LotsTableTableManager(
      $_db,
      $_db.lots,
    ).filter((f) => f.drinkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DrinksTableFilterComposer
    extends Composer<_$CaveDatabase, $DrinksTable> {
  $$DrinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grapes => $composableBuilder(
    column: $table.grapes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get abv => $composableBuilder(
    column: $table.abv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsCompletion => $composableBuilder(
    column: $table.needsCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodPairing => $composableBuilder(
    column: $table.foodPairing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DrinkTypesTableFilterComposer get typeId {
    final $$DrinkTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.drinkTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkTypesTableFilterComposer(
            $db: $db,
            $table: $db.drinkTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> drinkCharacteristicsRefs(
    Expression<bool> Function($$DrinkCharacteristicsTableFilterComposer f) f,
  ) {
    final $$DrinkCharacteristicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drinkCharacteristics,
      getReferencedColumn: (t) => t.drinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkCharacteristicsTableFilterComposer(
            $db: $db,
            $table: $db.drinkCharacteristics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lotsRefs(
    Expression<bool> Function($$LotsTableFilterComposer f) f,
  ) {
    final $$LotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.drinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableFilterComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DrinksTableOrderingComposer
    extends Composer<_$CaveDatabase, $DrinksTable> {
  $$DrinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grapes => $composableBuilder(
    column: $table.grapes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get abv => $composableBuilder(
    column: $table.abv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsCompletion => $composableBuilder(
    column: $table.needsCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodPairing => $composableBuilder(
    column: $table.foodPairing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DrinkTypesTableOrderingComposer get typeId {
    final $$DrinkTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.drinkTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkTypesTableOrderingComposer(
            $db: $db,
            $table: $db.drinkTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrinksTableAnnotationComposer
    extends Composer<_$CaveDatabase, $DrinksTable> {
  $$DrinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get producer =>
      $composableBuilder(column: $table.producer, builder: (column) => column);

  GeneratedColumn<String> get appellation => $composableBuilder(
    column: $table.appellation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get grapes =>
      $composableBuilder(column: $table.grapes, builder: (column) => column);

  GeneratedColumn<double> get abv =>
      $composableBuilder(column: $table.abv, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<bool> get needsCompletion => $composableBuilder(
    column: $table.needsCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodPairing => $composableBuilder(
    column: $table.foodPairing,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DrinkTypesTableAnnotationComposer get typeId {
    final $$DrinkTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.drinkTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.drinkTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> drinkCharacteristicsRefs<T extends Object>(
    Expression<T> Function($$DrinkCharacteristicsTableAnnotationComposer a) f,
  ) {
    final $$DrinkCharacteristicsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.drinkCharacteristics,
          getReferencedColumn: (t) => t.drinkId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DrinkCharacteristicsTableAnnotationComposer(
                $db: $db,
                $table: $db.drinkCharacteristics,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> lotsRefs<T extends Object>(
    Expression<T> Function($$LotsTableAnnotationComposer a) f,
  ) {
    final $$LotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.drinkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableAnnotationComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DrinksTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $DrinksTable,
          Drink,
          $$DrinksTableFilterComposer,
          $$DrinksTableOrderingComposer,
          $$DrinksTableAnnotationComposer,
          $$DrinksTableCreateCompanionBuilder,
          $$DrinksTableUpdateCompanionBuilder,
          (Drink, $$DrinksTableReferences),
          Drink,
          PrefetchHooks Function({
            bool typeId,
            bool drinkCharacteristicsRefs,
            bool lotsRefs,
          })
        > {
  $$DrinksTableTableManager(_$CaveDatabase db, $DrinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> typeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> producer = const Value.absent(),
                Value<String?> appellation = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> grapes = const Value.absent(),
                Value<double?> abv = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<bool> needsCompletion = const Value.absent(),
                Value<String?> foodPairing = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrinksCompanion(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                typeId: typeId,
                name: name,
                producer: producer,
                appellation: appellation,
                region: region,
                country: country,
                grapes: grapes,
                abv: abv,
                rating: rating,
                favorite: favorite,
                comment: comment,
                needsCompletion: needsCompletion,
                foodPairing: foodPairing,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                required String updatedBy,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> typeId = const Value.absent(),
                required String name,
                Value<String?> producer = const Value.absent(),
                Value<String?> appellation = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> grapes = const Value.absent(),
                Value<double?> abv = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<bool> needsCompletion = const Value.absent(),
                Value<String?> foodPairing = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DrinksCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                typeId: typeId,
                name: name,
                producer: producer,
                appellation: appellation,
                region: region,
                country: country,
                grapes: grapes,
                abv: abv,
                rating: rating,
                favorite: favorite,
                comment: comment,
                needsCompletion: needsCompletion,
                foodPairing: foodPairing,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DrinksTable, Drink>(table),
                  $$DrinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                typeId = false,
                drinkCharacteristicsRefs = false,
                lotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (drinkCharacteristicsRefs) db.drinkCharacteristics,
                    if (lotsRefs) db.lots,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (typeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.typeId,
                            referencedTable: $$DrinksTableReferences
                                ._typeIdTable(db),
                            referencedColumn: $$DrinksTableReferences
                                ._typeIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (drinkCharacteristicsRefs)
                        await $_getPrefetchedData<
                          Drink,
                          $DrinksTable,
                          DrinkCharacteristic
                        >(
                          currentTable: table,
                          referencedTable: $$DrinksTableReferences
                              ._drinkCharacteristicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DrinksTableReferences(
                                db,
                                table,
                                p0,
                              ).drinkCharacteristicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.drinkId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lotsRefs)
                        await $_getPrefetchedData<Drink, $DrinksTable, Lot>(
                          currentTable: table,
                          referencedTable: $$DrinksTableReferences
                              ._lotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DrinksTableReferences(db, table, p0).lotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.drinkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DrinksTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $DrinksTable,
      Drink,
      $$DrinksTableFilterComposer,
      $$DrinksTableOrderingComposer,
      $$DrinksTableAnnotationComposer,
      $$DrinksTableCreateCompanionBuilder,
      $$DrinksTableUpdateCompanionBuilder,
      (Drink, $$DrinksTableReferences),
      Drink,
      PrefetchHooks Function({
        bool typeId,
        bool drinkCharacteristicsRefs,
        bool lotsRefs,
      })
    >;
typedef $$CharacteristicFamiliesTableCreateCompanionBuilder =
    CharacteristicFamiliesCompanion Function({
      required String id,
      required int updatedAt,
      required String updatedBy,
      Value<int?> deletedAt,
      required String typeId,
      required String name,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CharacteristicFamiliesTableUpdateCompanionBuilder =
    CharacteristicFamiliesCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<int?> deletedAt,
      Value<String> typeId,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$CharacteristicFamiliesTableReferences
    extends
        BaseReferences<
          _$CaveDatabase,
          $CharacteristicFamiliesTable,
          CharacteristicFamily
        > {
  $$CharacteristicFamiliesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DrinkTypesTable _typeIdTable(_$CaveDatabase db) => db.drinkTypes
      .createAlias('characteristic_families__type_id__drink_types__id');

  $$DrinkTypesTableProcessedTableManager get typeId {
    final $_column = $_itemColumn<String>('type_id')!;

    final manager = $$DrinkTypesTableTableManager(
      $_db,
      $_db.drinkTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CharacteristicsTable, List<Characteristic>>
  _characteristicsRefsTable(_$CaveDatabase db) => MultiTypedResultKey.fromTable(
    db.characteristics,
    aliasName: 'characteristic_families__id__characteristics__family_id',
  );

  $$CharacteristicsTableProcessedTableManager get characteristicsRefs {
    final manager = $$CharacteristicsTableTableManager(
      $_db,
      $_db.characteristics,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _characteristicsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharacteristicFamiliesTableFilterComposer
    extends Composer<_$CaveDatabase, $CharacteristicFamiliesTable> {
  $$CharacteristicFamiliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$DrinkTypesTableFilterComposer get typeId {
    final $$DrinkTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.drinkTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkTypesTableFilterComposer(
            $db: $db,
            $table: $db.drinkTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> characteristicsRefs(
    Expression<bool> Function($$CharacteristicsTableFilterComposer f) f,
  ) {
    final $$CharacteristicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characteristics,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacteristicsTableFilterComposer(
            $db: $db,
            $table: $db.characteristics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharacteristicFamiliesTableOrderingComposer
    extends Composer<_$CaveDatabase, $CharacteristicFamiliesTable> {
  $$CharacteristicFamiliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$DrinkTypesTableOrderingComposer get typeId {
    final $$DrinkTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.drinkTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkTypesTableOrderingComposer(
            $db: $db,
            $table: $db.drinkTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharacteristicFamiliesTableAnnotationComposer
    extends Composer<_$CaveDatabase, $CharacteristicFamiliesTable> {
  $$CharacteristicFamiliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DrinkTypesTableAnnotationComposer get typeId {
    final $$DrinkTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.drinkTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.drinkTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> characteristicsRefs<T extends Object>(
    Expression<T> Function($$CharacteristicsTableAnnotationComposer a) f,
  ) {
    final $$CharacteristicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characteristics,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacteristicsTableAnnotationComposer(
            $db: $db,
            $table: $db.characteristics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharacteristicFamiliesTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $CharacteristicFamiliesTable,
          CharacteristicFamily,
          $$CharacteristicFamiliesTableFilterComposer,
          $$CharacteristicFamiliesTableOrderingComposer,
          $$CharacteristicFamiliesTableAnnotationComposer,
          $$CharacteristicFamiliesTableCreateCompanionBuilder,
          $$CharacteristicFamiliesTableUpdateCompanionBuilder,
          (CharacteristicFamily, $$CharacteristicFamiliesTableReferences),
          CharacteristicFamily,
          PrefetchHooks Function({bool typeId, bool characteristicsRefs})
        > {
  $$CharacteristicFamiliesTableTableManager(
    _$CaveDatabase db,
    $CharacteristicFamiliesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacteristicFamiliesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CharacteristicFamiliesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CharacteristicFamiliesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> typeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacteristicFamiliesCompanion(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                typeId: typeId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                required String updatedBy,
                Value<int?> deletedAt = const Value.absent(),
                required String typeId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacteristicFamiliesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                typeId: typeId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CharacteristicFamiliesTable,
                    CharacteristicFamily
                  >(table),
                  $$CharacteristicFamiliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({typeId = false, characteristicsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (characteristicsRefs) db.characteristics,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (typeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.typeId,
                            referencedTable:
                                $$CharacteristicFamiliesTableReferences
                                    ._typeIdTable(db),
                            referencedColumn:
                                $$CharacteristicFamiliesTableReferences
                                    ._typeIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (characteristicsRefs)
                        await $_getPrefetchedData<
                          CharacteristicFamily,
                          $CharacteristicFamiliesTable,
                          Characteristic
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CharacteristicFamiliesTableReferences
                                  ._characteristicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharacteristicFamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).characteristicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CharacteristicFamiliesTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $CharacteristicFamiliesTable,
      CharacteristicFamily,
      $$CharacteristicFamiliesTableFilterComposer,
      $$CharacteristicFamiliesTableOrderingComposer,
      $$CharacteristicFamiliesTableAnnotationComposer,
      $$CharacteristicFamiliesTableCreateCompanionBuilder,
      $$CharacteristicFamiliesTableUpdateCompanionBuilder,
      (CharacteristicFamily, $$CharacteristicFamiliesTableReferences),
      CharacteristicFamily,
      PrefetchHooks Function({bool typeId, bool characteristicsRefs})
    >;
typedef $$CharacteristicsTableCreateCompanionBuilder =
    CharacteristicsCompanion Function({
      required String id,
      required int updatedAt,
      required String updatedBy,
      Value<int?> deletedAt,
      required String familyId,
      required String name,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CharacteristicsTableUpdateCompanionBuilder =
    CharacteristicsCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<int?> deletedAt,
      Value<String> familyId,
      Value<String> name,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$CharacteristicsTableReferences
    extends
        BaseReferences<_$CaveDatabase, $CharacteristicsTable, Characteristic> {
  $$CharacteristicsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CharacteristicFamiliesTable _familyIdTable(_$CaveDatabase db) => db
      .characteristicFamilies
      .createAlias('characteristics__family_id__characteristic_families__id');

  $$CharacteristicFamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$CharacteristicFamiliesTableTableManager(
      $_db,
      $_db.characteristicFamilies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $DrinkCharacteristicsTable,
    List<DrinkCharacteristic>
  >
  _drinkCharacteristicsRefsTable(_$CaveDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.drinkCharacteristics,
        aliasName:
            'characteristics__id__drink_characteristics__characteristic_id',
      );

  $$DrinkCharacteristicsTableProcessedTableManager
  get drinkCharacteristicsRefs {
    final manager =
        $$DrinkCharacteristicsTableTableManager(
          $_db,
          $_db.drinkCharacteristics,
        ).filter(
          (f) => f.characteristicId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _drinkCharacteristicsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharacteristicsTableFilterComposer
    extends Composer<_$CaveDatabase, $CharacteristicsTable> {
  $$CharacteristicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$CharacteristicFamiliesTableFilterComposer get familyId {
    final $$CharacteristicFamiliesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.familyId,
          referencedTable: $db.characteristicFamilies,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacteristicFamiliesTableFilterComposer(
                $db: $db,
                $table: $db.characteristicFamilies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> drinkCharacteristicsRefs(
    Expression<bool> Function($$DrinkCharacteristicsTableFilterComposer f) f,
  ) {
    final $$DrinkCharacteristicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drinkCharacteristics,
      getReferencedColumn: (t) => t.characteristicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinkCharacteristicsTableFilterComposer(
            $db: $db,
            $table: $db.drinkCharacteristics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharacteristicsTableOrderingComposer
    extends Composer<_$CaveDatabase, $CharacteristicsTable> {
  $$CharacteristicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$CharacteristicFamiliesTableOrderingComposer get familyId {
    final $$CharacteristicFamiliesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.familyId,
          referencedTable: $db.characteristicFamilies,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacteristicFamiliesTableOrderingComposer(
                $db: $db,
                $table: $db.characteristicFamilies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CharacteristicsTableAnnotationComposer
    extends Composer<_$CaveDatabase, $CharacteristicsTable> {
  $$CharacteristicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$CharacteristicFamiliesTableAnnotationComposer get familyId {
    final $$CharacteristicFamiliesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.familyId,
          referencedTable: $db.characteristicFamilies,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CharacteristicFamiliesTableAnnotationComposer(
                $db: $db,
                $table: $db.characteristicFamilies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> drinkCharacteristicsRefs<T extends Object>(
    Expression<T> Function($$DrinkCharacteristicsTableAnnotationComposer a) f,
  ) {
    final $$DrinkCharacteristicsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.drinkCharacteristics,
          getReferencedColumn: (t) => t.characteristicId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DrinkCharacteristicsTableAnnotationComposer(
                $db: $db,
                $table: $db.drinkCharacteristics,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CharacteristicsTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $CharacteristicsTable,
          Characteristic,
          $$CharacteristicsTableFilterComposer,
          $$CharacteristicsTableOrderingComposer,
          $$CharacteristicsTableAnnotationComposer,
          $$CharacteristicsTableCreateCompanionBuilder,
          $$CharacteristicsTableUpdateCompanionBuilder,
          (Characteristic, $$CharacteristicsTableReferences),
          Characteristic,
          PrefetchHooks Function({bool familyId, bool drinkCharacteristicsRefs})
        > {
  $$CharacteristicsTableTableManager(
    _$CaveDatabase db,
    $CharacteristicsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacteristicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacteristicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacteristicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacteristicsCompanion(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                familyId: familyId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                required String updatedBy,
                Value<int?> deletedAt = const Value.absent(),
                required String familyId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacteristicsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                familyId: familyId,
                name: name,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CharacteristicsTable, Characteristic>(table),
                  $$CharacteristicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({familyId = false, drinkCharacteristicsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (drinkCharacteristicsRefs) db.drinkCharacteristics,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (familyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.familyId,
                            referencedTable: $$CharacteristicsTableReferences
                                ._familyIdTable(db),
                            referencedColumn: $$CharacteristicsTableReferences
                                ._familyIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (drinkCharacteristicsRefs)
                        await $_getPrefetchedData<
                          Characteristic,
                          $CharacteristicsTable,
                          DrinkCharacteristic
                        >(
                          currentTable: table,
                          referencedTable: $$CharacteristicsTableReferences
                              ._drinkCharacteristicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharacteristicsTableReferences(
                                db,
                                table,
                                p0,
                              ).drinkCharacteristicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characteristicId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CharacteristicsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $CharacteristicsTable,
      Characteristic,
      $$CharacteristicsTableFilterComposer,
      $$CharacteristicsTableOrderingComposer,
      $$CharacteristicsTableAnnotationComposer,
      $$CharacteristicsTableCreateCompanionBuilder,
      $$CharacteristicsTableUpdateCompanionBuilder,
      (Characteristic, $$CharacteristicsTableReferences),
      Characteristic,
      PrefetchHooks Function({bool familyId, bool drinkCharacteristicsRefs})
    >;
typedef $$DrinkCharacteristicsTableCreateCompanionBuilder =
    DrinkCharacteristicsCompanion Function({
      required String id,
      required int updatedAt,
      required String updatedBy,
      Value<int?> deletedAt,
      required String drinkId,
      required String characteristicId,
      Value<int> rowid,
    });
typedef $$DrinkCharacteristicsTableUpdateCompanionBuilder =
    DrinkCharacteristicsCompanion Function({
      Value<String> id,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<int?> deletedAt,
      Value<String> drinkId,
      Value<String> characteristicId,
      Value<int> rowid,
    });

final class $$DrinkCharacteristicsTableReferences
    extends
        BaseReferences<
          _$CaveDatabase,
          $DrinkCharacteristicsTable,
          DrinkCharacteristic
        > {
  $$DrinkCharacteristicsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DrinksTable _drinkIdTable(_$CaveDatabase db) =>
      db.drinks.createAlias('drink_characteristics__drink_id__drinks__id');

  $$DrinksTableProcessedTableManager get drinkId {
    final $_column = $_itemColumn<String>('drink_id')!;

    final manager = $$DrinksTableTableManager(
      $_db,
      $_db.drinks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_drinkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CharacteristicsTable _characteristicIdTable(_$CaveDatabase db) =>
      db.characteristics.createAlias(
        'drink_characteristics__characteristic_id__characteristics__id',
      );

  $$CharacteristicsTableProcessedTableManager get characteristicId {
    final $_column = $_itemColumn<String>('characteristic_id')!;

    final manager = $$CharacteristicsTableTableManager(
      $_db,
      $_db.characteristics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characteristicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DrinkCharacteristicsTableFilterComposer
    extends Composer<_$CaveDatabase, $DrinkCharacteristicsTable> {
  $$DrinkCharacteristicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DrinksTableFilterComposer get drinkId {
    final $$DrinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drinkId,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableFilterComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharacteristicsTableFilterComposer get characteristicId {
    final $$CharacteristicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characteristicId,
      referencedTable: $db.characteristics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacteristicsTableFilterComposer(
            $db: $db,
            $table: $db.characteristics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrinkCharacteristicsTableOrderingComposer
    extends Composer<_$CaveDatabase, $DrinkCharacteristicsTable> {
  $$DrinkCharacteristicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DrinksTableOrderingComposer get drinkId {
    final $$DrinksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drinkId,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableOrderingComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharacteristicsTableOrderingComposer get characteristicId {
    final $$CharacteristicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characteristicId,
      referencedTable: $db.characteristics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacteristicsTableOrderingComposer(
            $db: $db,
            $table: $db.characteristics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrinkCharacteristicsTableAnnotationComposer
    extends Composer<_$CaveDatabase, $DrinkCharacteristicsTable> {
  $$DrinkCharacteristicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DrinksTableAnnotationComposer get drinkId {
    final $$DrinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drinkId,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableAnnotationComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharacteristicsTableAnnotationComposer get characteristicId {
    final $$CharacteristicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characteristicId,
      referencedTable: $db.characteristics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharacteristicsTableAnnotationComposer(
            $db: $db,
            $table: $db.characteristics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DrinkCharacteristicsTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $DrinkCharacteristicsTable,
          DrinkCharacteristic,
          $$DrinkCharacteristicsTableFilterComposer,
          $$DrinkCharacteristicsTableOrderingComposer,
          $$DrinkCharacteristicsTableAnnotationComposer,
          $$DrinkCharacteristicsTableCreateCompanionBuilder,
          $$DrinkCharacteristicsTableUpdateCompanionBuilder,
          (DrinkCharacteristic, $$DrinkCharacteristicsTableReferences),
          DrinkCharacteristic,
          PrefetchHooks Function({bool drinkId, bool characteristicId})
        > {
  $$DrinkCharacteristicsTableTableManager(
    _$CaveDatabase db,
    $DrinkCharacteristicsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrinkCharacteristicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrinkCharacteristicsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DrinkCharacteristicsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> drinkId = const Value.absent(),
                Value<String> characteristicId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrinkCharacteristicsCompanion(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                drinkId: drinkId,
                characteristicId: characteristicId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                required String updatedBy,
                Value<int?> deletedAt = const Value.absent(),
                required String drinkId,
                required String characteristicId,
                Value<int> rowid = const Value.absent(),
              }) => DrinkCharacteristicsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                drinkId: drinkId,
                characteristicId: characteristicId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DrinkCharacteristicsTable, DrinkCharacteristic>(
                    table,
                  ),
                  $$DrinkCharacteristicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({drinkId = false, characteristicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (drinkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.drinkId,
                        referencedTable: $$DrinkCharacteristicsTableReferences
                            ._drinkIdTable(db),
                        referencedColumn: $$DrinkCharacteristicsTableReferences
                            ._drinkIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (characteristicId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.characteristicId,
                        referencedTable: $$DrinkCharacteristicsTableReferences
                            ._characteristicIdTable(db),
                        referencedColumn: $$DrinkCharacteristicsTableReferences
                            ._characteristicIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DrinkCharacteristicsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $DrinkCharacteristicsTable,
      DrinkCharacteristic,
      $$DrinkCharacteristicsTableFilterComposer,
      $$DrinkCharacteristicsTableOrderingComposer,
      $$DrinkCharacteristicsTableAnnotationComposer,
      $$DrinkCharacteristicsTableCreateCompanionBuilder,
      $$DrinkCharacteristicsTableUpdateCompanionBuilder,
      (DrinkCharacteristic, $$DrinkCharacteristicsTableReferences),
      DrinkCharacteristic,
      PrefetchHooks Function({bool drinkId, bool characteristicId})
    >;
typedef $$LotsTableCreateCompanionBuilder = LotsCompanion Function({
  required String id,
  required int updatedAt,
  required String updatedBy,
  Value<int?> deletedAt,
  required String drinkId,
  Value<int?> vintage,
  required int volumeMl,
  Value<String?> barcode,
  Value<int> stock,
  Value<String?> location,
  Value<int?> drinkFrom,
  Value<int?> drinkBefore,
  Value<String?> photoPath,
  required int createdAt,
  Value<int> rowid,
});
typedef $$LotsTableUpdateCompanionBuilder = LotsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<int?> deletedAt,
  Value<String> drinkId,
  Value<int?> vintage,
  Value<int> volumeMl,
  Value<String?> barcode,
  Value<int> stock,
  Value<String?> location,
  Value<int?> drinkFrom,
  Value<int?> drinkBefore,
  Value<String?> photoPath,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$LotsTableReferences
    extends BaseReferences<_$CaveDatabase, $LotsTable, Lot> {
  $$LotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DrinksTable _drinkIdTable(_$CaveDatabase db) =>
      db.drinks.createAlias('lots__drink_id__drinks__id');

  $$DrinksTableProcessedTableManager get drinkId {
    final $_column = $_itemColumn<String>('drink_id')!;

    final manager = $$DrinksTableTableManager(
      $_db,
      $_db.drinks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_drinkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MovementsTable, List<Movement>>
  _movementsRefsTable(_$CaveDatabase db) => MultiTypedResultKey.fromTable(
    db.movements,
    aliasName: 'lots__id__movements__lot_id',
  );

  $$MovementsTableProcessedTableManager get movementsRefs {
    final manager = $$MovementsTableTableManager(
      $_db,
      $_db.movements,
    ).filter((f) => f.lotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_movementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LotsTableFilterComposer extends Composer<_$CaveDatabase, $LotsTable> {
  $$LotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vintage => $composableBuilder(
    column: $table.vintage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drinkFrom => $composableBuilder(
    column: $table.drinkFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drinkBefore => $composableBuilder(
    column: $table.drinkBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DrinksTableFilterComposer get drinkId {
    final $$DrinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drinkId,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableFilterComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> movementsRefs(
    Expression<bool> Function($$MovementsTableFilterComposer f) f,
  ) {
    final $$MovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableFilterComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotsTableOrderingComposer extends Composer<_$CaveDatabase, $LotsTable> {
  $$LotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vintage => $composableBuilder(
    column: $table.vintage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drinkFrom => $composableBuilder(
    column: $table.drinkFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drinkBefore => $composableBuilder(
    column: $table.drinkBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DrinksTableOrderingComposer get drinkId {
    final $$DrinksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drinkId,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableOrderingComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LotsTableAnnotationComposer
    extends Composer<_$CaveDatabase, $LotsTable> {
  $$LotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get vintage =>
      $composableBuilder(column: $table.vintage, builder: (column) => column);

  GeneratedColumn<int> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get drinkFrom =>
      $composableBuilder(column: $table.drinkFrom, builder: (column) => column);

  GeneratedColumn<int> get drinkBefore => $composableBuilder(
    column: $table.drinkBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DrinksTableAnnotationComposer get drinkId {
    final $$DrinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.drinkId,
      referencedTable: $db.drinks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DrinksTableAnnotationComposer(
            $db: $db,
            $table: $db.drinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> movementsRefs<T extends Object>(
    Expression<T> Function($$MovementsTableAnnotationComposer a) f,
  ) {
    final $$MovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movements,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.movements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotsTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $LotsTable,
          Lot,
          $$LotsTableFilterComposer,
          $$LotsTableOrderingComposer,
          $$LotsTableAnnotationComposer,
          $$LotsTableCreateCompanionBuilder,
          $$LotsTableUpdateCompanionBuilder,
          (Lot, $$LotsTableReferences),
          Lot,
          PrefetchHooks Function({bool drinkId, bool movementsRefs})
        > {
  $$LotsTableTableManager(_$CaveDatabase db, $LotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> drinkId = const Value.absent(),
                Value<int?> vintage = const Value.absent(),
                Value<int> volumeMl = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int?> drinkFrom = const Value.absent(),
                Value<int?> drinkBefore = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                drinkId: drinkId,
                vintage: vintage,
                volumeMl: volumeMl,
                barcode: barcode,
                stock: stock,
                location: location,
                drinkFrom: drinkFrom,
                drinkBefore: drinkBefore,
                photoPath: photoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                required String updatedBy,
                Value<int?> deletedAt = const Value.absent(),
                required String drinkId,
                Value<int?> vintage = const Value.absent(),
                required int volumeMl,
                Value<String?> barcode = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int?> drinkFrom = const Value.absent(),
                Value<int?> drinkBefore = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                drinkId: drinkId,
                vintage: vintage,
                volumeMl: volumeMl,
                barcode: barcode,
                stock: stock,
                location: location,
                drinkFrom: drinkFrom,
                drinkBefore: drinkBefore,
                photoPath: photoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LotsTable, Lot>(table),
                  $$LotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({drinkId = false, movementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (movementsRefs) db.movements],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (drinkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.drinkId,
                        referencedTable: $$LotsTableReferences._drinkIdTable(
                          db,
                        ),
                        referencedColumn: $$LotsTableReferences
                            ._drinkIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (movementsRefs)
                    await $_getPrefetchedData<Lot, $LotsTable, Movement>(
                      currentTable: table,
                      referencedTable: $$LotsTableReferences
                          ._movementsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LotsTableReferences(db, table, p0).movementsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.lotId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LotsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $LotsTable,
      Lot,
      $$LotsTableFilterComposer,
      $$LotsTableOrderingComposer,
      $$LotsTableAnnotationComposer,
      $$LotsTableCreateCompanionBuilder,
      $$LotsTableUpdateCompanionBuilder,
      (Lot, $$LotsTableReferences),
      Lot,
      PrefetchHooks Function({bool drinkId, bool movementsRefs})
    >;
typedef $$MovementsTableCreateCompanionBuilder = MovementsCompanion Function({
  required String id,
  required int updatedAt,
  required String updatedBy,
  Value<int?> deletedAt,
  required String lotId,
  required int occurredAt,
  required MovementKind kind,
  required int quantity,
  Value<ExitReason?> reason,
  Value<String?> comment,
  required String deviceId,
  Value<int> rowid,
});
typedef $$MovementsTableUpdateCompanionBuilder = MovementsCompanion Function({
  Value<String> id,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<int?> deletedAt,
  Value<String> lotId,
  Value<int> occurredAt,
  Value<MovementKind> kind,
  Value<int> quantity,
  Value<ExitReason?> reason,
  Value<String?> comment,
  Value<String> deviceId,
  Value<int> rowid,
});

final class $$MovementsTableReferences
    extends BaseReferences<_$CaveDatabase, $MovementsTable, Movement> {
  $$MovementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LotsTable _lotIdTable(_$CaveDatabase db) =>
      db.lots.createAlias('movements__lot_id__lots__id');

  $$LotsTableProcessedTableManager get lotId {
    final $_column = $_itemColumn<String>('lot_id')!;

    final manager = $$LotsTableTableManager(
      $_db,
      $_db.lots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovementsTableFilterComposer
    extends Composer<_$CaveDatabase, $MovementsTable> {
  $$MovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MovementKind, MovementKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExitReason?, ExitReason, String> get reason =>
      $composableBuilder(
        column: $table.reason,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  $$LotsTableFilterComposer get lotId {
    final $$LotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableFilterComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementsTableOrderingComposer
    extends Composer<_$CaveDatabase, $MovementsTable> {
  $$MovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$LotsTableOrderingComposer get lotId {
    final $$LotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableOrderingComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementsTableAnnotationComposer
    extends Composer<_$CaveDatabase, $MovementsTable> {
  $$MovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MovementKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExitReason?, String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  $$LotsTableAnnotationComposer get lotId {
    final $$LotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableAnnotationComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementsTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $MovementsTable,
          Movement,
          $$MovementsTableFilterComposer,
          $$MovementsTableOrderingComposer,
          $$MovementsTableAnnotationComposer,
          $$MovementsTableCreateCompanionBuilder,
          $$MovementsTableUpdateCompanionBuilder,
          (Movement, $$MovementsTableReferences),
          Movement,
          PrefetchHooks Function({bool lotId})
        > {
  $$MovementsTableTableManager(_$CaveDatabase db, $MovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> lotId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<MovementKind> kind = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<ExitReason?> reason = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                lotId: lotId,
                occurredAt: occurredAt,
                kind: kind,
                quantity: quantity,
                reason: reason,
                comment: comment,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int updatedAt,
                required String updatedBy,
                Value<int?> deletedAt = const Value.absent(),
                required String lotId,
                required int occurredAt,
                required MovementKind kind,
                required int quantity,
                Value<ExitReason?> reason = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => MovementsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                deletedAt: deletedAt,
                lotId: lotId,
                occurredAt: occurredAt,
                kind: kind,
                quantity: quantity,
                reason: reason,
                comment: comment,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovementsTable, Movement>(table),
                  $$MovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.lotId,
                        referencedTable: $$MovementsTableReferences._lotIdTable(
                          db,
                        ),
                        referencedColumn: $$MovementsTableReferences
                            ._lotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $MovementsTable,
      Movement,
      $$MovementsTableFilterComposer,
      $$MovementsTableOrderingComposer,
      $$MovementsTableAnnotationComposer,
      $$MovementsTableCreateCompanionBuilder,
      $$MovementsTableUpdateCompanionBuilder,
      (Movement, $$MovementsTableReferences),
      Movement,
      PrefetchHooks Function({bool lotId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required int updatedAt,
  required String updatedBy,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$CaveDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$CaveDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$CaveDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$CaveDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$CaveDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int updatedAt,
                required String updatedBy,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$CaveDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$CaveDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$CaveDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableOrderingComposer extends Composer<_$CaveDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableAnnotationComposer
    extends Composer<_$CaveDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$CaveDatabase,
          $MetaTable,
          MetaEntry,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaEntry, BaseReferences<_$CaveDatabase, $MetaTable, MetaEntry>),
          MetaEntry,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$CaveDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaTable, MetaEntry>(table),
                  BaseReferences<_$CaveDatabase, $MetaTable, MetaEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$CaveDatabase,
      $MetaTable,
      MetaEntry,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaEntry, BaseReferences<_$CaveDatabase, $MetaTable, MetaEntry>),
      MetaEntry,
      PrefetchHooks Function()
    >;

class $CaveDatabaseManager {
  final _$CaveDatabase _db;
  $CaveDatabaseManager(this._db);
  $DrinksFtsTableManager get drinksFts =>
      $DrinksFtsTableManager(_db, _db.drinksFts);
  $$DrinkTypesTableTableManager get drinkTypes =>
      $$DrinkTypesTableTableManager(_db, _db.drinkTypes);
  $$DrinksTableTableManager get drinks =>
      $$DrinksTableTableManager(_db, _db.drinks);
  $$CharacteristicFamiliesTableTableManager get characteristicFamilies =>
      $$CharacteristicFamiliesTableTableManager(
        _db,
        _db.characteristicFamilies,
      );
  $$CharacteristicsTableTableManager get characteristics =>
      $$CharacteristicsTableTableManager(_db, _db.characteristics);
  $$DrinkCharacteristicsTableTableManager get drinkCharacteristics =>
      $$DrinkCharacteristicsTableTableManager(_db, _db.drinkCharacteristics);
  $$LotsTableTableManager get lots => $$LotsTableTableManager(_db, _db.lots);
  $$MovementsTableTableManager get movements =>
      $$MovementsTableTableManager(_db, _db.movements);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
}
