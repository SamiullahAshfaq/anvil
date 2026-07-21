// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  late final GeneratedColumnWithTypeConverter<PartyTypeDb, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PartyTypeDb>($PartiesTable.$convertertype);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingBalancePaisaMeta =
      const VerificationMeta('openingBalancePaisa');
  @override
  late final GeneratedColumn<int> openingBalancePaisa = GeneratedColumn<int>(
    'opening_balance_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    phone,
    openingBalancePaisa,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('opening_balance_paisa')) {
      context.handle(
        _openingBalancePaisaMeta,
        openingBalancePaisa.isAcceptableOrUnknown(
          data['opening_balance_paisa']!,
          _openingBalancePaisaMeta,
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $PartiesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      openingBalancePaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_paisa'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PartyTypeDb, String, String> $convertertype =
      const EnumNameConverter<PartyTypeDb>(PartyTypeDb.values);
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String name;
  final PartyTypeDb type;
  final String? phone;

  /// Onboarding dues are recorded as real dated OpeningBalance bills, not here —
  /// this stays for reference only and is never treated as an authoritative
  /// balance (03_RULES.md §1.26). Balances are always derived.
  final int openingBalancePaisa;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const Party({
    required this.id,
    required this.name,
    required this.type,
    this.phone,
    required this.openingBalancePaisa,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($PartiesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['opening_balance_paisa'] = Variable<int>(openingBalancePaisa);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      openingBalancePaisa: Value(openingBalancePaisa),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $PartiesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      phone: serializer.fromJson<String?>(json['phone']),
      openingBalancePaisa: serializer.fromJson<int>(
        json['openingBalancePaisa'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $PartiesTable.$convertertype.toJson(type),
      ),
      'phone': serializer.toJson<String?>(phone),
      'openingBalancePaisa': serializer.toJson<int>(openingBalancePaisa),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Party copyWith({
    String? id,
    String? name,
    PartyTypeDb? type,
    Value<String?> phone = const Value.absent(),
    int? openingBalancePaisa,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Party(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    phone: phone.present ? phone.value : this.phone,
    openingBalancePaisa: openingBalancePaisa ?? this.openingBalancePaisa,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      phone: data.phone.present ? data.phone.value : this.phone,
      openingBalancePaisa: data.openingBalancePaisa.present
          ? data.openingBalancePaisa.value
          : this.openingBalancePaisa,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone, ')
          ..write('openingBalancePaisa: $openingBalancePaisa, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    phone,
    openingBalancePaisa,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.phone == this.phone &&
          other.openingBalancePaisa == this.openingBalancePaisa &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> name;
  final Value<PartyTypeDb> type;
  final Value<String?> phone;
  final Value<int> openingBalancePaisa;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.phone = const Value.absent(),
    this.openingBalancePaisa = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String name,
    required PartyTypeDb type,
    this.phone = const Value.absent(),
    this.openingBalancePaisa = const Value.absent(),
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? phone,
    Expression<int>? openingBalancePaisa,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (phone != null) 'phone': phone,
      if (openingBalancePaisa != null)
        'opening_balance_paisa': openingBalancePaisa,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<PartyTypeDb>? type,
    Value<String?>? phone,
    Value<int>? openingBalancePaisa,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      openingBalancePaisa: openingBalancePaisa ?? this.openingBalancePaisa,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PartiesTable.$convertertype.toSql(type.value),
      );
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (openingBalancePaisa.present) {
      map['opening_balance_paisa'] = Variable<int>(openingBalancePaisa.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone, ')
          ..write('openingBalancePaisa: $openingBalancePaisa, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockCategoriesTable extends StockCategories
    with TableInfo<$StockCategoriesTable, StockCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _parentCategoryIdMeta = const VerificationMeta(
    'parentCategoryId',
  );
  @override
  late final GeneratedColumn<String> parentCategoryId = GeneratedColumn<String>(
    'parent_category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_categories (id)',
    ),
  );
  static const VerificationMeta _quantityGramsMeta = const VerificationMeta(
    'quantityGrams',
  );
  @override
  late final GeneratedColumn<int> quantityGrams = GeneratedColumn<int>(
    'quantity_grams',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCostBasisPaisaMeta =
      const VerificationMeta('totalCostBasisPaisa');
  @override
  late final GeneratedColumn<int> totalCostBasisPaisa = GeneratedColumn<int>(
    'total_cost_basis_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetMarginPctMeta = const VerificationMeta(
    'targetMarginPct',
  );
  @override
  late final GeneratedColumn<int> targetMarginPct = GeneratedColumn<int>(
    'target_margin_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isCustom,
    parentCategoryId,
    quantityGrams,
    totalCostBasisPaisa,
    targetMarginPct,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('parent_category_id')) {
      context.handle(
        _parentCategoryIdMeta,
        parentCategoryId.isAcceptableOrUnknown(
          data['parent_category_id']!,
          _parentCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('quantity_grams')) {
      context.handle(
        _quantityGramsMeta,
        quantityGrams.isAcceptableOrUnknown(
          data['quantity_grams']!,
          _quantityGramsMeta,
        ),
      );
    }
    if (data.containsKey('total_cost_basis_paisa')) {
      context.handle(
        _totalCostBasisPaisaMeta,
        totalCostBasisPaisa.isAcceptableOrUnknown(
          data['total_cost_basis_paisa']!,
          _totalCostBasisPaisaMeta,
        ),
      );
    }
    if (data.containsKey('target_margin_pct')) {
      context.handle(
        _targetMarginPctMeta,
        targetMarginPct.isAcceptableOrUnknown(
          data['target_margin_pct']!,
          _targetMarginPctMeta,
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      parentCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_category_id'],
      ),
      quantityGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_grams'],
      )!,
      totalCostBasisPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_basis_paisa'],
      )!,
      targetMarginPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_margin_pct'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StockCategoriesTable createAlias(String alias) {
    return $StockCategoriesTable(attachedDatabase, alias);
  }
}

class StockCategory extends DataClass implements Insertable<StockCategory> {
  final String id;
  final String name;
  final bool isCustom;
  final String? parentCategoryId;
  final int quantityGrams;
  final int totalCostBasisPaisa;

  /// Whole-number target margin % for the recommended selling rate. Editable.
  final int targetMarginPct;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const StockCategory({
    required this.id,
    required this.name,
    required this.isCustom,
    this.parentCategoryId,
    required this.quantityGrams,
    required this.totalCostBasisPaisa,
    required this.targetMarginPct,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || parentCategoryId != null) {
      map['parent_category_id'] = Variable<String>(parentCategoryId);
    }
    map['quantity_grams'] = Variable<int>(quantityGrams);
    map['total_cost_basis_paisa'] = Variable<int>(totalCostBasisPaisa);
    map['target_margin_pct'] = Variable<int>(targetMarginPct);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  StockCategoriesCompanion toCompanion(bool nullToAbsent) {
    return StockCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      isCustom: Value(isCustom),
      parentCategoryId: parentCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCategoryId),
      quantityGrams: Value(quantityGrams),
      totalCostBasisPaisa: Value(totalCostBasisPaisa),
      targetMarginPct: Value(targetMarginPct),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory StockCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      parentCategoryId: serializer.fromJson<String?>(json['parentCategoryId']),
      quantityGrams: serializer.fromJson<int>(json['quantityGrams']),
      totalCostBasisPaisa: serializer.fromJson<int>(
        json['totalCostBasisPaisa'],
      ),
      targetMarginPct: serializer.fromJson<int>(json['targetMarginPct']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isCustom': serializer.toJson<bool>(isCustom),
      'parentCategoryId': serializer.toJson<String?>(parentCategoryId),
      'quantityGrams': serializer.toJson<int>(quantityGrams),
      'totalCostBasisPaisa': serializer.toJson<int>(totalCostBasisPaisa),
      'targetMarginPct': serializer.toJson<int>(targetMarginPct),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  StockCategory copyWith({
    String? id,
    String? name,
    bool? isCustom,
    Value<String?> parentCategoryId = const Value.absent(),
    int? quantityGrams,
    int? totalCostBasisPaisa,
    int? targetMarginPct,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => StockCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    isCustom: isCustom ?? this.isCustom,
    parentCategoryId: parentCategoryId.present
        ? parentCategoryId.value
        : this.parentCategoryId,
    quantityGrams: quantityGrams ?? this.quantityGrams,
    totalCostBasisPaisa: totalCostBasisPaisa ?? this.totalCostBasisPaisa,
    targetMarginPct: targetMarginPct ?? this.targetMarginPct,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  StockCategory copyWithCompanion(StockCategoriesCompanion data) {
    return StockCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      parentCategoryId: data.parentCategoryId.present
          ? data.parentCategoryId.value
          : this.parentCategoryId,
      quantityGrams: data.quantityGrams.present
          ? data.quantityGrams.value
          : this.quantityGrams,
      totalCostBasisPaisa: data.totalCostBasisPaisa.present
          ? data.totalCostBasisPaisa.value
          : this.totalCostBasisPaisa,
      targetMarginPct: data.targetMarginPct.present
          ? data.targetMarginPct.value
          : this.targetMarginPct,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('quantityGrams: $quantityGrams, ')
          ..write('totalCostBasisPaisa: $totalCostBasisPaisa, ')
          ..write('targetMarginPct: $targetMarginPct, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    isCustom,
    parentCategoryId,
    quantityGrams,
    totalCostBasisPaisa,
    targetMarginPct,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.isCustom == this.isCustom &&
          other.parentCategoryId == this.parentCategoryId &&
          other.quantityGrams == this.quantityGrams &&
          other.totalCostBasisPaisa == this.totalCostBasisPaisa &&
          other.targetMarginPct == this.targetMarginPct &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class StockCategoriesCompanion extends UpdateCompanion<StockCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isCustom;
  final Value<String?> parentCategoryId;
  final Value<int> quantityGrams;
  final Value<int> totalCostBasisPaisa;
  final Value<int> targetMarginPct;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const StockCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.quantityGrams = const Value.absent(),
    this.totalCostBasisPaisa = const Value.absent(),
    this.targetMarginPct = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockCategoriesCompanion.insert({
    required String id,
    required String name,
    this.isCustom = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.quantityGrams = const Value.absent(),
    this.totalCostBasisPaisa = const Value.absent(),
    this.targetMarginPct = const Value.absent(),
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<StockCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isCustom,
    Expression<String>? parentCategoryId,
    Expression<int>? quantityGrams,
    Expression<int>? totalCostBasisPaisa,
    Expression<int>? targetMarginPct,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isCustom != null) 'is_custom': isCustom,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (quantityGrams != null) 'quantity_grams': quantityGrams,
      if (totalCostBasisPaisa != null)
        'total_cost_basis_paisa': totalCostBasisPaisa,
      if (targetMarginPct != null) 'target_margin_pct': targetMarginPct,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isCustom,
    Value<String?>? parentCategoryId,
    Value<int>? quantityGrams,
    Value<int>? totalCostBasisPaisa,
    Value<int>? targetMarginPct,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return StockCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      quantityGrams: quantityGrams ?? this.quantityGrams,
      totalCostBasisPaisa: totalCostBasisPaisa ?? this.totalCostBasisPaisa,
      targetMarginPct: targetMarginPct ?? this.targetMarginPct,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<String>(parentCategoryId.value);
    }
    if (quantityGrams.present) {
      map['quantity_grams'] = Variable<int>(quantityGrams.value);
    }
    if (totalCostBasisPaisa.present) {
      map['total_cost_basis_paisa'] = Variable<int>(totalCostBasisPaisa.value);
    }
    if (targetMarginPct.present) {
      map['target_margin_pct'] = Variable<int>(targetMarginPct.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('quantityGrams: $quantityGrams, ')
          ..write('totalCostBasisPaisa: $totalCostBasisPaisa, ')
          ..write('targetMarginPct: $targetMarginPct, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isCustom, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final String id;
  final String name;
  final bool isCustom;
  final DateTime? deletedAt;
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.isCustom,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      isCustom: Value(isCustom),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ExpenseCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isCustom': serializer.toJson<bool>(isCustom),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    bool? isCustom,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ExpenseCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    isCustom: isCustom ?? this.isCustom,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ExpenseCategory copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isCustom, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.isCustom == this.isCustom &&
          other.deletedAt == this.deletedAt);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isCustom;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    required String id,
    required String name,
    this.isCustom = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ExpenseCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isCustom,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isCustom != null) 'is_custom': isCustom,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isCustom,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillsTable extends Bills with TableInfo<$BillsTable, Bill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BillTypeDb, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BillTypeDb>($BillsTable.$convertertype);
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _expenseCategoryIdMeta = const VerificationMeta(
    'expenseCategoryId',
  );
  @override
  late final GeneratedColumn<String> expenseCategoryId =
      GeneratedColumn<String>(
        'expense_category_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES expense_categories (id)',
        ),
      );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  late final GeneratedColumnWithTypeConverter<RateModeDb, String> rateMode =
      GeneratedColumn<String>(
        'rate_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RateModeDb>($BillsTable.$converterrateMode);
  static const VerificationMeta _billLevelRatePaisaPerKgMeta =
      const VerificationMeta('billLevelRatePaisaPerKg');
  @override
  late final GeneratedColumn<int> billLevelRatePaisaPerKg =
      GeneratedColumn<int>(
        'bill_level_rate_paisa_per_kg',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalAmountPaisaMeta = const VerificationMeta(
    'totalAmountPaisa',
  );
  @override
  late final GeneratedColumn<int> totalAmountPaisa = GeneratedColumn<int>(
    'total_amount_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOpeningMeta = const VerificationMeta(
    'isOpening',
  );
  @override
  late final GeneratedColumn<bool> isOpening = GeneratedColumn<bool>(
    'is_opening',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_opening" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    partyId,
    expenseCategoryId,
    date,
    photoPath,
    rateMode,
    billLevelRatePaisaPerKg,
    totalAmountPaisa,
    isOpening,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    }
    if (data.containsKey('expense_category_id')) {
      context.handle(
        _expenseCategoryIdMeta,
        expenseCategoryId.isAcceptableOrUnknown(
          data['expense_category_id']!,
          _expenseCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('bill_level_rate_paisa_per_kg')) {
      context.handle(
        _billLevelRatePaisaPerKgMeta,
        billLevelRatePaisaPerKg.isAcceptableOrUnknown(
          data['bill_level_rate_paisa_per_kg']!,
          _billLevelRatePaisaPerKgMeta,
        ),
      );
    }
    if (data.containsKey('total_amount_paisa')) {
      context.handle(
        _totalAmountPaisaMeta,
        totalAmountPaisa.isAcceptableOrUnknown(
          data['total_amount_paisa']!,
          _totalAmountPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountPaisaMeta);
    }
    if (data.containsKey('is_opening')) {
      context.handle(
        _isOpeningMeta,
        isOpening.isAcceptableOrUnknown(data['is_opening']!, _isOpeningMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $BillsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      ),
      expenseCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_category_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      rateMode: $BillsTable.$converterrateMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rate_mode'],
        )!,
      ),
      billLevelRatePaisaPerKg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_level_rate_paisa_per_kg'],
      ),
      totalAmountPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount_paisa'],
      )!,
      isOpening: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_opening'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $BillsTable createAlias(String alias) {
    return $BillsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BillTypeDb, String, String> $convertertype =
      const EnumNameConverter<BillTypeDb>(BillTypeDb.values);
  static JsonTypeConverter2<RateModeDb, String, String> $converterrateMode =
      const EnumNameConverter<RateModeDb>(RateModeDb.values);
}

class Bill extends DataClass implements Insertable<Bill> {
  final String id;
  final BillTypeDb type;
  final String? partyId;
  final String? expenseCategoryId;
  final DateTime date;
  final String? photoPath;
  final RateModeDb rateMode;
  final int? billLevelRatePaisaPerKg;
  final int totalAmountPaisa;

  /// True for Day-0 opening bills. They seed standing receivable/payable and
  /// stock, but must be excluded from period P&L (they are pre-app history, not
  /// sales/purchases of any reporting month).
  final bool isOpening;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Bill({
    required this.id,
    required this.type,
    this.partyId,
    this.expenseCategoryId,
    required this.date,
    this.photoPath,
    required this.rateMode,
    this.billLevelRatePaisaPerKg,
    required this.totalAmountPaisa,
    required this.isOpening,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>($BillsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    if (!nullToAbsent || expenseCategoryId != null) {
      map['expense_category_id'] = Variable<String>(expenseCategoryId);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    {
      map['rate_mode'] = Variable<String>(
        $BillsTable.$converterrateMode.toSql(rateMode),
      );
    }
    if (!nullToAbsent || billLevelRatePaisaPerKg != null) {
      map['bill_level_rate_paisa_per_kg'] = Variable<int>(
        billLevelRatePaisaPerKg,
      );
    }
    map['total_amount_paisa'] = Variable<int>(totalAmountPaisa);
    map['is_opening'] = Variable<bool>(isOpening);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  BillsCompanion toCompanion(bool nullToAbsent) {
    return BillsCompanion(
      id: Value(id),
      type: Value(type),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      expenseCategoryId: expenseCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseCategoryId),
      date: Value(date),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      rateMode: Value(rateMode),
      billLevelRatePaisaPerKg: billLevelRatePaisaPerKg == null && nullToAbsent
          ? const Value.absent()
          : Value(billLevelRatePaisaPerKg),
      totalAmountPaisa: Value(totalAmountPaisa),
      isOpening: Value(isOpening),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Bill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bill(
      id: serializer.fromJson<String>(json['id']),
      type: $BillsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      partyId: serializer.fromJson<String?>(json['partyId']),
      expenseCategoryId: serializer.fromJson<String?>(
        json['expenseCategoryId'],
      ),
      date: serializer.fromJson<DateTime>(json['date']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      rateMode: $BillsTable.$converterrateMode.fromJson(
        serializer.fromJson<String>(json['rateMode']),
      ),
      billLevelRatePaisaPerKg: serializer.fromJson<int?>(
        json['billLevelRatePaisaPerKg'],
      ),
      totalAmountPaisa: serializer.fromJson<int>(json['totalAmountPaisa']),
      isOpening: serializer.fromJson<bool>(json['isOpening']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $BillsTable.$convertertype.toJson(type),
      ),
      'partyId': serializer.toJson<String?>(partyId),
      'expenseCategoryId': serializer.toJson<String?>(expenseCategoryId),
      'date': serializer.toJson<DateTime>(date),
      'photoPath': serializer.toJson<String?>(photoPath),
      'rateMode': serializer.toJson<String>(
        $BillsTable.$converterrateMode.toJson(rateMode),
      ),
      'billLevelRatePaisaPerKg': serializer.toJson<int?>(
        billLevelRatePaisaPerKg,
      ),
      'totalAmountPaisa': serializer.toJson<int>(totalAmountPaisa),
      'isOpening': serializer.toJson<bool>(isOpening),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Bill copyWith({
    String? id,
    BillTypeDb? type,
    Value<String?> partyId = const Value.absent(),
    Value<String?> expenseCategoryId = const Value.absent(),
    DateTime? date,
    Value<String?> photoPath = const Value.absent(),
    RateModeDb? rateMode,
    Value<int?> billLevelRatePaisaPerKg = const Value.absent(),
    int? totalAmountPaisa,
    bool? isOpening,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Bill(
    id: id ?? this.id,
    type: type ?? this.type,
    partyId: partyId.present ? partyId.value : this.partyId,
    expenseCategoryId: expenseCategoryId.present
        ? expenseCategoryId.value
        : this.expenseCategoryId,
    date: date ?? this.date,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    rateMode: rateMode ?? this.rateMode,
    billLevelRatePaisaPerKg: billLevelRatePaisaPerKg.present
        ? billLevelRatePaisaPerKg.value
        : this.billLevelRatePaisaPerKg,
    totalAmountPaisa: totalAmountPaisa ?? this.totalAmountPaisa,
    isOpening: isOpening ?? this.isOpening,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Bill copyWithCompanion(BillsCompanion data) {
    return Bill(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      expenseCategoryId: data.expenseCategoryId.present
          ? data.expenseCategoryId.value
          : this.expenseCategoryId,
      date: data.date.present ? data.date.value : this.date,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      rateMode: data.rateMode.present ? data.rateMode.value : this.rateMode,
      billLevelRatePaisaPerKg: data.billLevelRatePaisaPerKg.present
          ? data.billLevelRatePaisaPerKg.value
          : this.billLevelRatePaisaPerKg,
      totalAmountPaisa: data.totalAmountPaisa.present
          ? data.totalAmountPaisa.value
          : this.totalAmountPaisa,
      isOpening: data.isOpening.present ? data.isOpening.value : this.isOpening,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bill(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('partyId: $partyId, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('date: $date, ')
          ..write('photoPath: $photoPath, ')
          ..write('rateMode: $rateMode, ')
          ..write('billLevelRatePaisaPerKg: $billLevelRatePaisaPerKg, ')
          ..write('totalAmountPaisa: $totalAmountPaisa, ')
          ..write('isOpening: $isOpening, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    partyId,
    expenseCategoryId,
    date,
    photoPath,
    rateMode,
    billLevelRatePaisaPerKg,
    totalAmountPaisa,
    isOpening,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill &&
          other.id == this.id &&
          other.type == this.type &&
          other.partyId == this.partyId &&
          other.expenseCategoryId == this.expenseCategoryId &&
          other.date == this.date &&
          other.photoPath == this.photoPath &&
          other.rateMode == this.rateMode &&
          other.billLevelRatePaisaPerKg == this.billLevelRatePaisaPerKg &&
          other.totalAmountPaisa == this.totalAmountPaisa &&
          other.isOpening == this.isOpening &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class BillsCompanion extends UpdateCompanion<Bill> {
  final Value<String> id;
  final Value<BillTypeDb> type;
  final Value<String?> partyId;
  final Value<String?> expenseCategoryId;
  final Value<DateTime> date;
  final Value<String?> photoPath;
  final Value<RateModeDb> rateMode;
  final Value<int?> billLevelRatePaisaPerKg;
  final Value<int> totalAmountPaisa;
  final Value<bool> isOpening;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const BillsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.partyId = const Value.absent(),
    this.expenseCategoryId = const Value.absent(),
    this.date = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rateMode = const Value.absent(),
    this.billLevelRatePaisaPerKg = const Value.absent(),
    this.totalAmountPaisa = const Value.absent(),
    this.isOpening = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillsCompanion.insert({
    required String id,
    required BillTypeDb type,
    this.partyId = const Value.absent(),
    this.expenseCategoryId = const Value.absent(),
    required DateTime date,
    this.photoPath = const Value.absent(),
    required RateModeDb rateMode,
    this.billLevelRatePaisaPerKg = const Value.absent(),
    required int totalAmountPaisa,
    this.isOpening = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       date = Value(date),
       rateMode = Value(rateMode),
       totalAmountPaisa = Value(totalAmountPaisa),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Bill> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? partyId,
    Expression<String>? expenseCategoryId,
    Expression<DateTime>? date,
    Expression<String>? photoPath,
    Expression<String>? rateMode,
    Expression<int>? billLevelRatePaisaPerKg,
    Expression<int>? totalAmountPaisa,
    Expression<bool>? isOpening,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (partyId != null) 'party_id': partyId,
      if (expenseCategoryId != null) 'expense_category_id': expenseCategoryId,
      if (date != null) 'date': date,
      if (photoPath != null) 'photo_path': photoPath,
      if (rateMode != null) 'rate_mode': rateMode,
      if (billLevelRatePaisaPerKg != null)
        'bill_level_rate_paisa_per_kg': billLevelRatePaisaPerKg,
      if (totalAmountPaisa != null) 'total_amount_paisa': totalAmountPaisa,
      if (isOpening != null) 'is_opening': isOpening,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillsCompanion copyWith({
    Value<String>? id,
    Value<BillTypeDb>? type,
    Value<String?>? partyId,
    Value<String?>? expenseCategoryId,
    Value<DateTime>? date,
    Value<String?>? photoPath,
    Value<RateModeDb>? rateMode,
    Value<int?>? billLevelRatePaisaPerKg,
    Value<int>? totalAmountPaisa,
    Value<bool>? isOpening,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return BillsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      partyId: partyId ?? this.partyId,
      expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
      date: date ?? this.date,
      photoPath: photoPath ?? this.photoPath,
      rateMode: rateMode ?? this.rateMode,
      billLevelRatePaisaPerKg:
          billLevelRatePaisaPerKg ?? this.billLevelRatePaisaPerKg,
      totalAmountPaisa: totalAmountPaisa ?? this.totalAmountPaisa,
      isOpening: isOpening ?? this.isOpening,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $BillsTable.$convertertype.toSql(type.value),
      );
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (expenseCategoryId.present) {
      map['expense_category_id'] = Variable<String>(expenseCategoryId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rateMode.present) {
      map['rate_mode'] = Variable<String>(
        $BillsTable.$converterrateMode.toSql(rateMode.value),
      );
    }
    if (billLevelRatePaisaPerKg.present) {
      map['bill_level_rate_paisa_per_kg'] = Variable<int>(
        billLevelRatePaisaPerKg.value,
      );
    }
    if (totalAmountPaisa.present) {
      map['total_amount_paisa'] = Variable<int>(totalAmountPaisa.value);
    }
    if (isOpening.present) {
      map['is_opening'] = Variable<bool>(isOpening.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('partyId: $partyId, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('date: $date, ')
          ..write('photoPath: $photoPath, ')
          ..write('rateMode: $rateMode, ')
          ..write('billLevelRatePaisaPerKg: $billLevelRatePaisaPerKg, ')
          ..write('totalAmountPaisa: $totalAmountPaisa, ')
          ..write('isOpening: $isOpening, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillLineItemsTable extends BillLineItems
    with TableInfo<$BillLineItemsTable, BillLineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillLineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id)',
    ),
  );
  static const VerificationMeta _parentCategoryIdMeta = const VerificationMeta(
    'parentCategoryId',
  );
  @override
  late final GeneratedColumn<String> parentCategoryId = GeneratedColumn<String>(
    'parent_category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_categories (id)',
    ),
  );
  static const VerificationMeta _subCategoryLabelMeta = const VerificationMeta(
    'subCategoryLabel',
  );
  @override
  late final GeneratedColumn<String> subCategoryLabel = GeneratedColumn<String>(
    'sub_category_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<int> weightGrams = GeneratedColumn<int>(
    'weight_grams',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePaisaPerKgMeta = const VerificationMeta(
    'ratePaisaPerKg',
  );
  @override
  late final GeneratedColumn<int> ratePaisaPerKg = GeneratedColumn<int>(
    'rate_paisa_per_kg',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalPaisaMeta = const VerificationMeta(
    'lineTotalPaisa',
  );
  @override
  late final GeneratedColumn<int> lineTotalPaisa = GeneratedColumn<int>(
    'line_total_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cogsPaisaMeta = const VerificationMeta(
    'cogsPaisa',
  );
  @override
  late final GeneratedColumn<int> cogsPaisa = GeneratedColumn<int>(
    'cogs_paisa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    billId,
    parentCategoryId,
    subCategoryLabel,
    weightGrams,
    ratePaisaPerKg,
    lineTotalPaisa,
    cogsPaisa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_line_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillLineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('parent_category_id')) {
      context.handle(
        _parentCategoryIdMeta,
        parentCategoryId.isAcceptableOrUnknown(
          data['parent_category_id']!,
          _parentCategoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parentCategoryIdMeta);
    }
    if (data.containsKey('sub_category_label')) {
      context.handle(
        _subCategoryLabelMeta,
        subCategoryLabel.isAcceptableOrUnknown(
          data['sub_category_label']!,
          _subCategoryLabelMeta,
        ),
      );
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightGramsMeta);
    }
    if (data.containsKey('rate_paisa_per_kg')) {
      context.handle(
        _ratePaisaPerKgMeta,
        ratePaisaPerKg.isAcceptableOrUnknown(
          data['rate_paisa_per_kg']!,
          _ratePaisaPerKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratePaisaPerKgMeta);
    }
    if (data.containsKey('line_total_paisa')) {
      context.handle(
        _lineTotalPaisaMeta,
        lineTotalPaisa.isAcceptableOrUnknown(
          data['line_total_paisa']!,
          _lineTotalPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalPaisaMeta);
    }
    if (data.containsKey('cogs_paisa')) {
      context.handle(
        _cogsPaisaMeta,
        cogsPaisa.isAcceptableOrUnknown(data['cogs_paisa']!, _cogsPaisaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillLineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillLineItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      )!,
      parentCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_category_id'],
      )!,
      subCategoryLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_category_label'],
      ),
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_grams'],
      )!,
      ratePaisaPerKg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_paisa_per_kg'],
      )!,
      lineTotalPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_paisa'],
      )!,
      cogsPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cogs_paisa'],
      ),
    );
  }

  @override
  $BillLineItemsTable createAlias(String alias) {
    return $BillLineItemsTable(attachedDatabase, alias);
  }
}

class BillLineItem extends DataClass implements Insertable<BillLineItem> {
  final String id;
  final String billId;
  final String parentCategoryId;

  /// Descriptive tag only — filtering/reporting. Never a separate stock ledger.
  final String? subCategoryLabel;
  final int weightGrams;
  final int ratePaisaPerKg;
  final int lineTotalPaisa;

  /// COGS at the moving-average cost at the moment of a SALE line, for profit.
  /// Null on purchase lines.
  final int? cogsPaisa;
  const BillLineItem({
    required this.id,
    required this.billId,
    required this.parentCategoryId,
    this.subCategoryLabel,
    required this.weightGrams,
    required this.ratePaisaPerKg,
    required this.lineTotalPaisa,
    this.cogsPaisa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bill_id'] = Variable<String>(billId);
    map['parent_category_id'] = Variable<String>(parentCategoryId);
    if (!nullToAbsent || subCategoryLabel != null) {
      map['sub_category_label'] = Variable<String>(subCategoryLabel);
    }
    map['weight_grams'] = Variable<int>(weightGrams);
    map['rate_paisa_per_kg'] = Variable<int>(ratePaisaPerKg);
    map['line_total_paisa'] = Variable<int>(lineTotalPaisa);
    if (!nullToAbsent || cogsPaisa != null) {
      map['cogs_paisa'] = Variable<int>(cogsPaisa);
    }
    return map;
  }

  BillLineItemsCompanion toCompanion(bool nullToAbsent) {
    return BillLineItemsCompanion(
      id: Value(id),
      billId: Value(billId),
      parentCategoryId: Value(parentCategoryId),
      subCategoryLabel: subCategoryLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(subCategoryLabel),
      weightGrams: Value(weightGrams),
      ratePaisaPerKg: Value(ratePaisaPerKg),
      lineTotalPaisa: Value(lineTotalPaisa),
      cogsPaisa: cogsPaisa == null && nullToAbsent
          ? const Value.absent()
          : Value(cogsPaisa),
    );
  }

  factory BillLineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillLineItem(
      id: serializer.fromJson<String>(json['id']),
      billId: serializer.fromJson<String>(json['billId']),
      parentCategoryId: serializer.fromJson<String>(json['parentCategoryId']),
      subCategoryLabel: serializer.fromJson<String?>(json['subCategoryLabel']),
      weightGrams: serializer.fromJson<int>(json['weightGrams']),
      ratePaisaPerKg: serializer.fromJson<int>(json['ratePaisaPerKg']),
      lineTotalPaisa: serializer.fromJson<int>(json['lineTotalPaisa']),
      cogsPaisa: serializer.fromJson<int?>(json['cogsPaisa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'billId': serializer.toJson<String>(billId),
      'parentCategoryId': serializer.toJson<String>(parentCategoryId),
      'subCategoryLabel': serializer.toJson<String?>(subCategoryLabel),
      'weightGrams': serializer.toJson<int>(weightGrams),
      'ratePaisaPerKg': serializer.toJson<int>(ratePaisaPerKg),
      'lineTotalPaisa': serializer.toJson<int>(lineTotalPaisa),
      'cogsPaisa': serializer.toJson<int?>(cogsPaisa),
    };
  }

  BillLineItem copyWith({
    String? id,
    String? billId,
    String? parentCategoryId,
    Value<String?> subCategoryLabel = const Value.absent(),
    int? weightGrams,
    int? ratePaisaPerKg,
    int? lineTotalPaisa,
    Value<int?> cogsPaisa = const Value.absent(),
  }) => BillLineItem(
    id: id ?? this.id,
    billId: billId ?? this.billId,
    parentCategoryId: parentCategoryId ?? this.parentCategoryId,
    subCategoryLabel: subCategoryLabel.present
        ? subCategoryLabel.value
        : this.subCategoryLabel,
    weightGrams: weightGrams ?? this.weightGrams,
    ratePaisaPerKg: ratePaisaPerKg ?? this.ratePaisaPerKg,
    lineTotalPaisa: lineTotalPaisa ?? this.lineTotalPaisa,
    cogsPaisa: cogsPaisa.present ? cogsPaisa.value : this.cogsPaisa,
  );
  BillLineItem copyWithCompanion(BillLineItemsCompanion data) {
    return BillLineItem(
      id: data.id.present ? data.id.value : this.id,
      billId: data.billId.present ? data.billId.value : this.billId,
      parentCategoryId: data.parentCategoryId.present
          ? data.parentCategoryId.value
          : this.parentCategoryId,
      subCategoryLabel: data.subCategoryLabel.present
          ? data.subCategoryLabel.value
          : this.subCategoryLabel,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      ratePaisaPerKg: data.ratePaisaPerKg.present
          ? data.ratePaisaPerKg.value
          : this.ratePaisaPerKg,
      lineTotalPaisa: data.lineTotalPaisa.present
          ? data.lineTotalPaisa.value
          : this.lineTotalPaisa,
      cogsPaisa: data.cogsPaisa.present ? data.cogsPaisa.value : this.cogsPaisa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillLineItem(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('subCategoryLabel: $subCategoryLabel, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('ratePaisaPerKg: $ratePaisaPerKg, ')
          ..write('lineTotalPaisa: $lineTotalPaisa, ')
          ..write('cogsPaisa: $cogsPaisa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    billId,
    parentCategoryId,
    subCategoryLabel,
    weightGrams,
    ratePaisaPerKg,
    lineTotalPaisa,
    cogsPaisa,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillLineItem &&
          other.id == this.id &&
          other.billId == this.billId &&
          other.parentCategoryId == this.parentCategoryId &&
          other.subCategoryLabel == this.subCategoryLabel &&
          other.weightGrams == this.weightGrams &&
          other.ratePaisaPerKg == this.ratePaisaPerKg &&
          other.lineTotalPaisa == this.lineTotalPaisa &&
          other.cogsPaisa == this.cogsPaisa);
}

class BillLineItemsCompanion extends UpdateCompanion<BillLineItem> {
  final Value<String> id;
  final Value<String> billId;
  final Value<String> parentCategoryId;
  final Value<String?> subCategoryLabel;
  final Value<int> weightGrams;
  final Value<int> ratePaisaPerKg;
  final Value<int> lineTotalPaisa;
  final Value<int?> cogsPaisa;
  final Value<int> rowid;
  const BillLineItemsCompanion({
    this.id = const Value.absent(),
    this.billId = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.subCategoryLabel = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.ratePaisaPerKg = const Value.absent(),
    this.lineTotalPaisa = const Value.absent(),
    this.cogsPaisa = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillLineItemsCompanion.insert({
    required String id,
    required String billId,
    required String parentCategoryId,
    this.subCategoryLabel = const Value.absent(),
    required int weightGrams,
    required int ratePaisaPerKg,
    required int lineTotalPaisa,
    this.cogsPaisa = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       billId = Value(billId),
       parentCategoryId = Value(parentCategoryId),
       weightGrams = Value(weightGrams),
       ratePaisaPerKg = Value(ratePaisaPerKg),
       lineTotalPaisa = Value(lineTotalPaisa);
  static Insertable<BillLineItem> custom({
    Expression<String>? id,
    Expression<String>? billId,
    Expression<String>? parentCategoryId,
    Expression<String>? subCategoryLabel,
    Expression<int>? weightGrams,
    Expression<int>? ratePaisaPerKg,
    Expression<int>? lineTotalPaisa,
    Expression<int>? cogsPaisa,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billId != null) 'bill_id': billId,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (subCategoryLabel != null) 'sub_category_label': subCategoryLabel,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (ratePaisaPerKg != null) 'rate_paisa_per_kg': ratePaisaPerKg,
      if (lineTotalPaisa != null) 'line_total_paisa': lineTotalPaisa,
      if (cogsPaisa != null) 'cogs_paisa': cogsPaisa,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillLineItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? billId,
    Value<String>? parentCategoryId,
    Value<String?>? subCategoryLabel,
    Value<int>? weightGrams,
    Value<int>? ratePaisaPerKg,
    Value<int>? lineTotalPaisa,
    Value<int?>? cogsPaisa,
    Value<int>? rowid,
  }) {
    return BillLineItemsCompanion(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      subCategoryLabel: subCategoryLabel ?? this.subCategoryLabel,
      weightGrams: weightGrams ?? this.weightGrams,
      ratePaisaPerKg: ratePaisaPerKg ?? this.ratePaisaPerKg,
      lineTotalPaisa: lineTotalPaisa ?? this.lineTotalPaisa,
      cogsPaisa: cogsPaisa ?? this.cogsPaisa,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<String>(parentCategoryId.value);
    }
    if (subCategoryLabel.present) {
      map['sub_category_label'] = Variable<String>(subCategoryLabel.value);
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<int>(weightGrams.value);
    }
    if (ratePaisaPerKg.present) {
      map['rate_paisa_per_kg'] = Variable<int>(ratePaisaPerKg.value);
    }
    if (lineTotalPaisa.present) {
      map['line_total_paisa'] = Variable<int>(lineTotalPaisa.value);
    }
    if (cogsPaisa.present) {
      map['cogs_paisa'] = Variable<int>(cogsPaisa.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillLineItemsCompanion(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('subCategoryLabel: $subCategoryLabel, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('ratePaisaPerKg: $ratePaisaPerKg, ')
          ..write('lineTotalPaisa: $lineTotalPaisa, ')
          ..write('cogsPaisa: $cogsPaisa, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashPoolsTable extends CashPools
    with TableInfo<$CashPoolsTable, CashPool> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashPoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PoolNameDb, String> name =
      GeneratedColumn<String>(
        'name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PoolNameDb>($CashPoolsTable.$convertername);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_pools';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashPool> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashPool map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashPool(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: $CashPoolsTable.$convertername.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}name'],
        )!,
      ),
    );
  }

  @override
  $CashPoolsTable createAlias(String alias) {
    return $CashPoolsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PoolNameDb, String, String> $convertername =
      const EnumNameConverter<PoolNameDb>(PoolNameDb.values);
}

class CashPool extends DataClass implements Insertable<CashPool> {
  final String id;
  final PoolNameDb name;
  const CashPool({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['name'] = Variable<String>(
        $CashPoolsTable.$convertername.toSql(name),
      );
    }
    return map;
  }

  CashPoolsCompanion toCompanion(bool nullToAbsent) {
    return CashPoolsCompanion(id: Value(id), name: Value(name));
  }

  factory CashPool.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashPool(
      id: serializer.fromJson<String>(json['id']),
      name: $CashPoolsTable.$convertername.fromJson(
        serializer.fromJson<String>(json['name']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(
        $CashPoolsTable.$convertername.toJson(name),
      ),
    };
  }

  CashPool copyWith({String? id, PoolNameDb? name}) =>
      CashPool(id: id ?? this.id, name: name ?? this.name);
  CashPool copyWithCompanion(CashPoolsCompanion data) {
    return CashPool(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashPool(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashPool && other.id == this.id && other.name == this.name);
}

class CashPoolsCompanion extends UpdateCompanion<CashPool> {
  final Value<String> id;
  final Value<PoolNameDb> name;
  final Value<int> rowid;
  const CashPoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashPoolsCompanion.insert({
    required String id,
    required PoolNameDb name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CashPool> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashPoolsCompanion copyWith({
    Value<String>? id,
    Value<PoolNameDb>? name,
    Value<int>? rowid,
  }) {
    return CashPoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(
        $CashPoolsTable.$convertername.toSql(name.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashPoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _amountPaisaMeta = const VerificationMeta(
    'amountPaisa',
  );
  @override
  late final GeneratedColumn<int> amountPaisa = GeneratedColumn<int>(
    'amount_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentDirectionDb, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentDirectionDb>($PaymentsTable.$converterdirection);
  static const VerificationMeta _poolIdMeta = const VerificationMeta('poolId');
  @override
  late final GeneratedColumn<String> poolId = GeneratedColumn<String>(
    'pool_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cash_pools (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAdvanceMeta = const VerificationMeta(
    'isAdvance',
  );
  @override
  late final GeneratedColumn<bool> isAdvance = GeneratedColumn<bool>(
    'is_advance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_advance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reversedMeta = const VerificationMeta(
    'reversed',
  );
  @override
  late final GeneratedColumn<bool> reversed = GeneratedColumn<bool>(
    'reversed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reversed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reversedAtMeta = const VerificationMeta(
    'reversedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reversedAt = GeneratedColumn<DateTime>(
    'reversed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversalReasonMeta = const VerificationMeta(
    'reversalReason',
  );
  @override
  late final GeneratedColumn<String> reversalReason = GeneratedColumn<String>(
    'reversal_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    partyId,
    amountPaisa,
    direction,
    poolId,
    date,
    isAdvance,
    reversed,
    reversedAt,
    reversalReason,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('amount_paisa')) {
      context.handle(
        _amountPaisaMeta,
        amountPaisa.isAcceptableOrUnknown(
          data['amount_paisa']!,
          _amountPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaisaMeta);
    }
    if (data.containsKey('pool_id')) {
      context.handle(
        _poolIdMeta,
        poolId.isAcceptableOrUnknown(data['pool_id']!, _poolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poolIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_advance')) {
      context.handle(
        _isAdvanceMeta,
        isAdvance.isAcceptableOrUnknown(data['is_advance']!, _isAdvanceMeta),
      );
    }
    if (data.containsKey('reversed')) {
      context.handle(
        _reversedMeta,
        reversed.isAcceptableOrUnknown(data['reversed']!, _reversedMeta),
      );
    }
    if (data.containsKey('reversed_at')) {
      context.handle(
        _reversedAtMeta,
        reversedAt.isAcceptableOrUnknown(data['reversed_at']!, _reversedAtMeta),
      );
    }
    if (data.containsKey('reversal_reason')) {
      context.handle(
        _reversalReasonMeta,
        reversalReason.isAcceptableOrUnknown(
          data['reversal_reason']!,
          _reversalReasonMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      amountPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paisa'],
      )!,
      direction: $PaymentsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      poolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      isAdvance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_advance'],
      )!,
      reversed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reversed'],
      )!,
      reversedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reversed_at'],
      ),
      reversalReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reversal_reason'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentDirectionDb, String, String>
  $converterdirection = const EnumNameConverter<PaymentDirectionDb>(
    PaymentDirectionDb.values,
  );
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String partyId;
  final int amountPaisa;
  final PaymentDirectionDb direction;
  final String poolId;
  final DateTime date;
  final bool isAdvance;

  /// Reversed (bounced/failed) payments are flagged, NEVER deleted
  /// (03_RULES.md §1.24).
  final bool reversed;
  final DateTime? reversedAt;
  final String? reversalReason;
  final DateTime? deletedAt;
  const Payment({
    required this.id,
    required this.partyId,
    required this.amountPaisa,
    required this.direction,
    required this.poolId,
    required this.date,
    required this.isAdvance,
    required this.reversed,
    this.reversedAt,
    this.reversalReason,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['party_id'] = Variable<String>(partyId);
    map['amount_paisa'] = Variable<int>(amountPaisa);
    {
      map['direction'] = Variable<String>(
        $PaymentsTable.$converterdirection.toSql(direction),
      );
    }
    map['pool_id'] = Variable<String>(poolId);
    map['date'] = Variable<DateTime>(date);
    map['is_advance'] = Variable<bool>(isAdvance);
    map['reversed'] = Variable<bool>(reversed);
    if (!nullToAbsent || reversedAt != null) {
      map['reversed_at'] = Variable<DateTime>(reversedAt);
    }
    if (!nullToAbsent || reversalReason != null) {
      map['reversal_reason'] = Variable<String>(reversalReason);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      partyId: Value(partyId),
      amountPaisa: Value(amountPaisa),
      direction: Value(direction),
      poolId: Value(poolId),
      date: Value(date),
      isAdvance: Value(isAdvance),
      reversed: Value(reversed),
      reversedAt: reversedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reversedAt),
      reversalReason: reversalReason == null && nullToAbsent
          ? const Value.absent()
          : Value(reversalReason),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      partyId: serializer.fromJson<String>(json['partyId']),
      amountPaisa: serializer.fromJson<int>(json['amountPaisa']),
      direction: $PaymentsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      poolId: serializer.fromJson<String>(json['poolId']),
      date: serializer.fromJson<DateTime>(json['date']),
      isAdvance: serializer.fromJson<bool>(json['isAdvance']),
      reversed: serializer.fromJson<bool>(json['reversed']),
      reversedAt: serializer.fromJson<DateTime?>(json['reversedAt']),
      reversalReason: serializer.fromJson<String?>(json['reversalReason']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'partyId': serializer.toJson<String>(partyId),
      'amountPaisa': serializer.toJson<int>(amountPaisa),
      'direction': serializer.toJson<String>(
        $PaymentsTable.$converterdirection.toJson(direction),
      ),
      'poolId': serializer.toJson<String>(poolId),
      'date': serializer.toJson<DateTime>(date),
      'isAdvance': serializer.toJson<bool>(isAdvance),
      'reversed': serializer.toJson<bool>(reversed),
      'reversedAt': serializer.toJson<DateTime?>(reversedAt),
      'reversalReason': serializer.toJson<String?>(reversalReason),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Payment copyWith({
    String? id,
    String? partyId,
    int? amountPaisa,
    PaymentDirectionDb? direction,
    String? poolId,
    DateTime? date,
    bool? isAdvance,
    bool? reversed,
    Value<DateTime?> reversedAt = const Value.absent(),
    Value<String?> reversalReason = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Payment(
    id: id ?? this.id,
    partyId: partyId ?? this.partyId,
    amountPaisa: amountPaisa ?? this.amountPaisa,
    direction: direction ?? this.direction,
    poolId: poolId ?? this.poolId,
    date: date ?? this.date,
    isAdvance: isAdvance ?? this.isAdvance,
    reversed: reversed ?? this.reversed,
    reversedAt: reversedAt.present ? reversedAt.value : this.reversedAt,
    reversalReason: reversalReason.present
        ? reversalReason.value
        : this.reversalReason,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      amountPaisa: data.amountPaisa.present
          ? data.amountPaisa.value
          : this.amountPaisa,
      direction: data.direction.present ? data.direction.value : this.direction,
      poolId: data.poolId.present ? data.poolId.value : this.poolId,
      date: data.date.present ? data.date.value : this.date,
      isAdvance: data.isAdvance.present ? data.isAdvance.value : this.isAdvance,
      reversed: data.reversed.present ? data.reversed.value : this.reversed,
      reversedAt: data.reversedAt.present
          ? data.reversedAt.value
          : this.reversedAt,
      reversalReason: data.reversalReason.present
          ? data.reversalReason.value
          : this.reversalReason,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('partyId: $partyId, ')
          ..write('amountPaisa: $amountPaisa, ')
          ..write('direction: $direction, ')
          ..write('poolId: $poolId, ')
          ..write('date: $date, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('reversed: $reversed, ')
          ..write('reversedAt: $reversedAt, ')
          ..write('reversalReason: $reversalReason, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    partyId,
    amountPaisa,
    direction,
    poolId,
    date,
    isAdvance,
    reversed,
    reversedAt,
    reversalReason,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.partyId == this.partyId &&
          other.amountPaisa == this.amountPaisa &&
          other.direction == this.direction &&
          other.poolId == this.poolId &&
          other.date == this.date &&
          other.isAdvance == this.isAdvance &&
          other.reversed == this.reversed &&
          other.reversedAt == this.reversedAt &&
          other.reversalReason == this.reversalReason &&
          other.deletedAt == this.deletedAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> partyId;
  final Value<int> amountPaisa;
  final Value<PaymentDirectionDb> direction;
  final Value<String> poolId;
  final Value<DateTime> date;
  final Value<bool> isAdvance;
  final Value<bool> reversed;
  final Value<DateTime?> reversedAt;
  final Value<String?> reversalReason;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.partyId = const Value.absent(),
    this.amountPaisa = const Value.absent(),
    this.direction = const Value.absent(),
    this.poolId = const Value.absent(),
    this.date = const Value.absent(),
    this.isAdvance = const Value.absent(),
    this.reversed = const Value.absent(),
    this.reversedAt = const Value.absent(),
    this.reversalReason = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String partyId,
    required int amountPaisa,
    required PaymentDirectionDb direction,
    required String poolId,
    required DateTime date,
    this.isAdvance = const Value.absent(),
    this.reversed = const Value.absent(),
    this.reversedAt = const Value.absent(),
    this.reversalReason = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       partyId = Value(partyId),
       amountPaisa = Value(amountPaisa),
       direction = Value(direction),
       poolId = Value(poolId),
       date = Value(date);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? partyId,
    Expression<int>? amountPaisa,
    Expression<String>? direction,
    Expression<String>? poolId,
    Expression<DateTime>? date,
    Expression<bool>? isAdvance,
    Expression<bool>? reversed,
    Expression<DateTime>? reversedAt,
    Expression<String>? reversalReason,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partyId != null) 'party_id': partyId,
      if (amountPaisa != null) 'amount_paisa': amountPaisa,
      if (direction != null) 'direction': direction,
      if (poolId != null) 'pool_id': poolId,
      if (date != null) 'date': date,
      if (isAdvance != null) 'is_advance': isAdvance,
      if (reversed != null) 'reversed': reversed,
      if (reversedAt != null) 'reversed_at': reversedAt,
      if (reversalReason != null) 'reversal_reason': reversalReason,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? partyId,
    Value<int>? amountPaisa,
    Value<PaymentDirectionDb>? direction,
    Value<String>? poolId,
    Value<DateTime>? date,
    Value<bool>? isAdvance,
    Value<bool>? reversed,
    Value<DateTime?>? reversedAt,
    Value<String?>? reversalReason,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      amountPaisa: amountPaisa ?? this.amountPaisa,
      direction: direction ?? this.direction,
      poolId: poolId ?? this.poolId,
      date: date ?? this.date,
      isAdvance: isAdvance ?? this.isAdvance,
      reversed: reversed ?? this.reversed,
      reversedAt: reversedAt ?? this.reversedAt,
      reversalReason: reversalReason ?? this.reversalReason,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (amountPaisa.present) {
      map['amount_paisa'] = Variable<int>(amountPaisa.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $PaymentsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (poolId.present) {
      map['pool_id'] = Variable<String>(poolId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isAdvance.present) {
      map['is_advance'] = Variable<bool>(isAdvance.value);
    }
    if (reversed.present) {
      map['reversed'] = Variable<bool>(reversed.value);
    }
    if (reversedAt.present) {
      map['reversed_at'] = Variable<DateTime>(reversedAt.value);
    }
    if (reversalReason.present) {
      map['reversal_reason'] = Variable<String>(reversalReason.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('partyId: $partyId, ')
          ..write('amountPaisa: $amountPaisa, ')
          ..write('direction: $direction, ')
          ..write('poolId: $poolId, ')
          ..write('date: $date, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('reversed: $reversed, ')
          ..write('reversedAt: $reversedAt, ')
          ..write('reversalReason: $reversalReason, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentAllocationsTable extends PaymentAllocations
    with TableInfo<$PaymentAllocationsTable, PaymentAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payments (id)',
    ),
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id)',
    ),
  );
  static const VerificationMeta _amountAllocatedPaisaMeta =
      const VerificationMeta('amountAllocatedPaisa');
  @override
  late final GeneratedColumn<int> amountAllocatedPaisa = GeneratedColumn<int>(
    'amount_allocated_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    paymentId,
    billId,
    amountAllocatedPaisa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('amount_allocated_paisa')) {
      context.handle(
        _amountAllocatedPaisaMeta,
        amountAllocatedPaisa.isAcceptableOrUnknown(
          data['amount_allocated_paisa']!,
          _amountAllocatedPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountAllocatedPaisaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentAllocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      )!,
      amountAllocatedPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_allocated_paisa'],
      )!,
    );
  }

  @override
  $PaymentAllocationsTable createAlias(String alias) {
    return $PaymentAllocationsTable(attachedDatabase, alias);
  }
}

class PaymentAllocation extends DataClass
    implements Insertable<PaymentAllocation> {
  final String id;
  final String paymentId;
  final String billId;
  final int amountAllocatedPaisa;
  const PaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.billId,
    required this.amountAllocatedPaisa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payment_id'] = Variable<String>(paymentId);
    map['bill_id'] = Variable<String>(billId);
    map['amount_allocated_paisa'] = Variable<int>(amountAllocatedPaisa);
    return map;
  }

  PaymentAllocationsCompanion toCompanion(bool nullToAbsent) {
    return PaymentAllocationsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      billId: Value(billId),
      amountAllocatedPaisa: Value(amountAllocatedPaisa),
    );
  }

  factory PaymentAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentAllocation(
      id: serializer.fromJson<String>(json['id']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      billId: serializer.fromJson<String>(json['billId']),
      amountAllocatedPaisa: serializer.fromJson<int>(
        json['amountAllocatedPaisa'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'paymentId': serializer.toJson<String>(paymentId),
      'billId': serializer.toJson<String>(billId),
      'amountAllocatedPaisa': serializer.toJson<int>(amountAllocatedPaisa),
    };
  }

  PaymentAllocation copyWith({
    String? id,
    String? paymentId,
    String? billId,
    int? amountAllocatedPaisa,
  }) => PaymentAllocation(
    id: id ?? this.id,
    paymentId: paymentId ?? this.paymentId,
    billId: billId ?? this.billId,
    amountAllocatedPaisa: amountAllocatedPaisa ?? this.amountAllocatedPaisa,
  );
  PaymentAllocation copyWithCompanion(PaymentAllocationsCompanion data) {
    return PaymentAllocation(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      billId: data.billId.present ? data.billId.value : this.billId,
      amountAllocatedPaisa: data.amountAllocatedPaisa.present
          ? data.amountAllocatedPaisa.value
          : this.amountAllocatedPaisa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocation(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('billId: $billId, ')
          ..write('amountAllocatedPaisa: $amountAllocatedPaisa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, paymentId, billId, amountAllocatedPaisa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentAllocation &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.billId == this.billId &&
          other.amountAllocatedPaisa == this.amountAllocatedPaisa);
}

class PaymentAllocationsCompanion extends UpdateCompanion<PaymentAllocation> {
  final Value<String> id;
  final Value<String> paymentId;
  final Value<String> billId;
  final Value<int> amountAllocatedPaisa;
  final Value<int> rowid;
  const PaymentAllocationsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.billId = const Value.absent(),
    this.amountAllocatedPaisa = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentAllocationsCompanion.insert({
    required String id,
    required String paymentId,
    required String billId,
    required int amountAllocatedPaisa,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       paymentId = Value(paymentId),
       billId = Value(billId),
       amountAllocatedPaisa = Value(amountAllocatedPaisa);
  static Insertable<PaymentAllocation> custom({
    Expression<String>? id,
    Expression<String>? paymentId,
    Expression<String>? billId,
    Expression<int>? amountAllocatedPaisa,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (billId != null) 'bill_id': billId,
      if (amountAllocatedPaisa != null)
        'amount_allocated_paisa': amountAllocatedPaisa,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentAllocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? paymentId,
    Value<String>? billId,
    Value<int>? amountAllocatedPaisa,
    Value<int>? rowid,
  }) {
    return PaymentAllocationsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      billId: billId ?? this.billId,
      amountAllocatedPaisa: amountAllocatedPaisa ?? this.amountAllocatedPaisa,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (amountAllocatedPaisa.present) {
      map['amount_allocated_paisa'] = Variable<int>(amountAllocatedPaisa.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('billId: $billId, ')
          ..write('amountAllocatedPaisa: $amountAllocatedPaisa, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMovementsTable extends CashMovements
    with TableInfo<$CashMovementsTable, CashMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poolIdMeta = const VerificationMeta('poolId');
  @override
  late final GeneratedColumn<String> poolId = GeneratedColumn<String>(
    'pool_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cash_pools (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CashDirectionDb, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CashDirectionDb>($CashMovementsTable.$converterdirection);
  static const VerificationMeta _amountPaisaMeta = const VerificationMeta(
    'amountPaisa',
  );
  @override
  late final GeneratedColumn<int> amountPaisa = GeneratedColumn<int>(
    'amount_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _transferIdMeta = const VerificationMeta(
    'transferId',
  );
  @override
  late final GeneratedColumn<String> transferId = GeneratedColumn<String>(
    'transfer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pairedMovementIdMeta = const VerificationMeta(
    'pairedMovementId',
  );
  @override
  late final GeneratedColumn<String> pairedMovementId = GeneratedColumn<String>(
    'paired_movement_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedBillIdMeta = const VerificationMeta(
    'relatedBillId',
  );
  @override
  late final GeneratedColumn<String> relatedBillId = GeneratedColumn<String>(
    'related_bill_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bills (id)',
    ),
  );
  static const VerificationMeta _relatedPaymentIdMeta = const VerificationMeta(
    'relatedPaymentId',
  );
  @override
  late final GeneratedColumn<String> relatedPaymentId = GeneratedColumn<String>(
    'related_payment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payments (id)',
    ),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    poolId,
    direction,
    amountPaisa,
    date,
    sequence,
    transferId,
    pairedMovementId,
    relatedBillId,
    relatedPaymentId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pool_id')) {
      context.handle(
        _poolIdMeta,
        poolId.isAcceptableOrUnknown(data['pool_id']!, _poolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poolIdMeta);
    }
    if (data.containsKey('amount_paisa')) {
      context.handle(
        _amountPaisaMeta,
        amountPaisa.isAcceptableOrUnknown(
          data['amount_paisa']!,
          _amountPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaisaMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('transfer_id')) {
      context.handle(
        _transferIdMeta,
        transferId.isAcceptableOrUnknown(data['transfer_id']!, _transferIdMeta),
      );
    }
    if (data.containsKey('paired_movement_id')) {
      context.handle(
        _pairedMovementIdMeta,
        pairedMovementId.isAcceptableOrUnknown(
          data['paired_movement_id']!,
          _pairedMovementIdMeta,
        ),
      );
    }
    if (data.containsKey('related_bill_id')) {
      context.handle(
        _relatedBillIdMeta,
        relatedBillId.isAcceptableOrUnknown(
          data['related_bill_id']!,
          _relatedBillIdMeta,
        ),
      );
    }
    if (data.containsKey('related_payment_id')) {
      context.handle(
        _relatedPaymentIdMeta,
        relatedPaymentId.isAcceptableOrUnknown(
          data['related_payment_id']!,
          _relatedPaymentIdMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      poolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_id'],
      )!,
      direction: $CashMovementsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      amountPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paisa'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      transferId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_id'],
      ),
      pairedMovementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paired_movement_id'],
      ),
      relatedBillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_bill_id'],
      ),
      relatedPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_payment_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CashMovementsTable createAlias(String alias) {
    return $CashMovementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CashDirectionDb, String, String>
  $converterdirection = const EnumNameConverter<CashDirectionDb>(
    CashDirectionDb.values,
  );
}

class CashMovement extends DataClass implements Insertable<CashMovement> {
  final String id;
  final String poolId;
  final CashDirectionDb direction;
  final int amountPaisa;
  final DateTime date;

  /// Tiebreaker for same-instant ordering, so FIFO consumption is deterministic.
  final int sequence;
  final String? transferId;
  final String? pairedMovementId;
  final String? relatedBillId;
  final String? relatedPaymentId;
  final DateTime? deletedAt;
  const CashMovement({
    required this.id,
    required this.poolId,
    required this.direction,
    required this.amountPaisa,
    required this.date,
    required this.sequence,
    this.transferId,
    this.pairedMovementId,
    this.relatedBillId,
    this.relatedPaymentId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pool_id'] = Variable<String>(poolId);
    {
      map['direction'] = Variable<String>(
        $CashMovementsTable.$converterdirection.toSql(direction),
      );
    }
    map['amount_paisa'] = Variable<int>(amountPaisa);
    map['date'] = Variable<DateTime>(date);
    map['sequence'] = Variable<int>(sequence);
    if (!nullToAbsent || transferId != null) {
      map['transfer_id'] = Variable<String>(transferId);
    }
    if (!nullToAbsent || pairedMovementId != null) {
      map['paired_movement_id'] = Variable<String>(pairedMovementId);
    }
    if (!nullToAbsent || relatedBillId != null) {
      map['related_bill_id'] = Variable<String>(relatedBillId);
    }
    if (!nullToAbsent || relatedPaymentId != null) {
      map['related_payment_id'] = Variable<String>(relatedPaymentId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CashMovementsCompanion toCompanion(bool nullToAbsent) {
    return CashMovementsCompanion(
      id: Value(id),
      poolId: Value(poolId),
      direction: Value(direction),
      amountPaisa: Value(amountPaisa),
      date: Value(date),
      sequence: Value(sequence),
      transferId: transferId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferId),
      pairedMovementId: pairedMovementId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairedMovementId),
      relatedBillId: relatedBillId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedBillId),
      relatedPaymentId: relatedPaymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedPaymentId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CashMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovement(
      id: serializer.fromJson<String>(json['id']),
      poolId: serializer.fromJson<String>(json['poolId']),
      direction: $CashMovementsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      amountPaisa: serializer.fromJson<int>(json['amountPaisa']),
      date: serializer.fromJson<DateTime>(json['date']),
      sequence: serializer.fromJson<int>(json['sequence']),
      transferId: serializer.fromJson<String?>(json['transferId']),
      pairedMovementId: serializer.fromJson<String?>(json['pairedMovementId']),
      relatedBillId: serializer.fromJson<String?>(json['relatedBillId']),
      relatedPaymentId: serializer.fromJson<String?>(json['relatedPaymentId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poolId': serializer.toJson<String>(poolId),
      'direction': serializer.toJson<String>(
        $CashMovementsTable.$converterdirection.toJson(direction),
      ),
      'amountPaisa': serializer.toJson<int>(amountPaisa),
      'date': serializer.toJson<DateTime>(date),
      'sequence': serializer.toJson<int>(sequence),
      'transferId': serializer.toJson<String?>(transferId),
      'pairedMovementId': serializer.toJson<String?>(pairedMovementId),
      'relatedBillId': serializer.toJson<String?>(relatedBillId),
      'relatedPaymentId': serializer.toJson<String?>(relatedPaymentId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CashMovement copyWith({
    String? id,
    String? poolId,
    CashDirectionDb? direction,
    int? amountPaisa,
    DateTime? date,
    int? sequence,
    Value<String?> transferId = const Value.absent(),
    Value<String?> pairedMovementId = const Value.absent(),
    Value<String?> relatedBillId = const Value.absent(),
    Value<String?> relatedPaymentId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CashMovement(
    id: id ?? this.id,
    poolId: poolId ?? this.poolId,
    direction: direction ?? this.direction,
    amountPaisa: amountPaisa ?? this.amountPaisa,
    date: date ?? this.date,
    sequence: sequence ?? this.sequence,
    transferId: transferId.present ? transferId.value : this.transferId,
    pairedMovementId: pairedMovementId.present
        ? pairedMovementId.value
        : this.pairedMovementId,
    relatedBillId: relatedBillId.present
        ? relatedBillId.value
        : this.relatedBillId,
    relatedPaymentId: relatedPaymentId.present
        ? relatedPaymentId.value
        : this.relatedPaymentId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CashMovement copyWithCompanion(CashMovementsCompanion data) {
    return CashMovement(
      id: data.id.present ? data.id.value : this.id,
      poolId: data.poolId.present ? data.poolId.value : this.poolId,
      direction: data.direction.present ? data.direction.value : this.direction,
      amountPaisa: data.amountPaisa.present
          ? data.amountPaisa.value
          : this.amountPaisa,
      date: data.date.present ? data.date.value : this.date,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      transferId: data.transferId.present
          ? data.transferId.value
          : this.transferId,
      pairedMovementId: data.pairedMovementId.present
          ? data.pairedMovementId.value
          : this.pairedMovementId,
      relatedBillId: data.relatedBillId.present
          ? data.relatedBillId.value
          : this.relatedBillId,
      relatedPaymentId: data.relatedPaymentId.present
          ? data.relatedPaymentId.value
          : this.relatedPaymentId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovement(')
          ..write('id: $id, ')
          ..write('poolId: $poolId, ')
          ..write('direction: $direction, ')
          ..write('amountPaisa: $amountPaisa, ')
          ..write('date: $date, ')
          ..write('sequence: $sequence, ')
          ..write('transferId: $transferId, ')
          ..write('pairedMovementId: $pairedMovementId, ')
          ..write('relatedBillId: $relatedBillId, ')
          ..write('relatedPaymentId: $relatedPaymentId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    poolId,
    direction,
    amountPaisa,
    date,
    sequence,
    transferId,
    pairedMovementId,
    relatedBillId,
    relatedPaymentId,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovement &&
          other.id == this.id &&
          other.poolId == this.poolId &&
          other.direction == this.direction &&
          other.amountPaisa == this.amountPaisa &&
          other.date == this.date &&
          other.sequence == this.sequence &&
          other.transferId == this.transferId &&
          other.pairedMovementId == this.pairedMovementId &&
          other.relatedBillId == this.relatedBillId &&
          other.relatedPaymentId == this.relatedPaymentId &&
          other.deletedAt == this.deletedAt);
}

class CashMovementsCompanion extends UpdateCompanion<CashMovement> {
  final Value<String> id;
  final Value<String> poolId;
  final Value<CashDirectionDb> direction;
  final Value<int> amountPaisa;
  final Value<DateTime> date;
  final Value<int> sequence;
  final Value<String?> transferId;
  final Value<String?> pairedMovementId;
  final Value<String?> relatedBillId;
  final Value<String?> relatedPaymentId;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CashMovementsCompanion({
    this.id = const Value.absent(),
    this.poolId = const Value.absent(),
    this.direction = const Value.absent(),
    this.amountPaisa = const Value.absent(),
    this.date = const Value.absent(),
    this.sequence = const Value.absent(),
    this.transferId = const Value.absent(),
    this.pairedMovementId = const Value.absent(),
    this.relatedBillId = const Value.absent(),
    this.relatedPaymentId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementsCompanion.insert({
    required String id,
    required String poolId,
    required CashDirectionDb direction,
    required int amountPaisa,
    required DateTime date,
    this.sequence = const Value.absent(),
    this.transferId = const Value.absent(),
    this.pairedMovementId = const Value.absent(),
    this.relatedBillId = const Value.absent(),
    this.relatedPaymentId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       poolId = Value(poolId),
       direction = Value(direction),
       amountPaisa = Value(amountPaisa),
       date = Value(date);
  static Insertable<CashMovement> custom({
    Expression<String>? id,
    Expression<String>? poolId,
    Expression<String>? direction,
    Expression<int>? amountPaisa,
    Expression<DateTime>? date,
    Expression<int>? sequence,
    Expression<String>? transferId,
    Expression<String>? pairedMovementId,
    Expression<String>? relatedBillId,
    Expression<String>? relatedPaymentId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poolId != null) 'pool_id': poolId,
      if (direction != null) 'direction': direction,
      if (amountPaisa != null) 'amount_paisa': amountPaisa,
      if (date != null) 'date': date,
      if (sequence != null) 'sequence': sequence,
      if (transferId != null) 'transfer_id': transferId,
      if (pairedMovementId != null) 'paired_movement_id': pairedMovementId,
      if (relatedBillId != null) 'related_bill_id': relatedBillId,
      if (relatedPaymentId != null) 'related_payment_id': relatedPaymentId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? poolId,
    Value<CashDirectionDb>? direction,
    Value<int>? amountPaisa,
    Value<DateTime>? date,
    Value<int>? sequence,
    Value<String?>? transferId,
    Value<String?>? pairedMovementId,
    Value<String?>? relatedBillId,
    Value<String?>? relatedPaymentId,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CashMovementsCompanion(
      id: id ?? this.id,
      poolId: poolId ?? this.poolId,
      direction: direction ?? this.direction,
      amountPaisa: amountPaisa ?? this.amountPaisa,
      date: date ?? this.date,
      sequence: sequence ?? this.sequence,
      transferId: transferId ?? this.transferId,
      pairedMovementId: pairedMovementId ?? this.pairedMovementId,
      relatedBillId: relatedBillId ?? this.relatedBillId,
      relatedPaymentId: relatedPaymentId ?? this.relatedPaymentId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poolId.present) {
      map['pool_id'] = Variable<String>(poolId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $CashMovementsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (amountPaisa.present) {
      map['amount_paisa'] = Variable<int>(amountPaisa.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (transferId.present) {
      map['transfer_id'] = Variable<String>(transferId.value);
    }
    if (pairedMovementId.present) {
      map['paired_movement_id'] = Variable<String>(pairedMovementId.value);
    }
    if (relatedBillId.present) {
      map['related_bill_id'] = Variable<String>(relatedBillId.value);
    }
    if (relatedPaymentId.present) {
      map['related_payment_id'] = Variable<String>(relatedPaymentId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsCompanion(')
          ..write('id: $id, ')
          ..write('poolId: $poolId, ')
          ..write('direction: $direction, ')
          ..write('amountPaisa: $amountPaisa, ')
          ..write('date: $date, ')
          ..write('sequence: $sequence, ')
          ..write('transferId: $transferId, ')
          ..write('pairedMovementId: $pairedMovementId, ')
          ..write('relatedBillId: $relatedBillId, ')
          ..write('relatedPaymentId: $relatedPaymentId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockWriteOffsTable extends StockWriteOffs
    with TableInfo<$StockWriteOffsTable, StockWriteOff> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockWriteOffsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentCategoryIdMeta = const VerificationMeta(
    'parentCategoryId',
  );
  @override
  late final GeneratedColumn<String> parentCategoryId = GeneratedColumn<String>(
    'parent_category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_categories (id)',
    ),
  );
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<int> weightGrams = GeneratedColumn<int>(
    'weight_grams',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WriteOffModeDb, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WriteOffModeDb>($StockWriteOffsTable.$convertermode);
  static const VerificationMeta _relatedExpenseCategoryIdMeta =
      const VerificationMeta('relatedExpenseCategoryId');
  @override
  late final GeneratedColumn<String> relatedExpenseCategoryId =
      GeneratedColumn<String>(
        'related_expense_category_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES expense_categories (id)',
        ),
      );
  static const VerificationMeta _expensePaisaMeta = const VerificationMeta(
    'expensePaisa',
  );
  @override
  late final GeneratedColumn<int> expensePaisa = GeneratedColumn<int>(
    'expense_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentCategoryId,
    weightGrams,
    mode,
    relatedExpenseCategoryId,
    expensePaisa,
    note,
    date,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_write_offs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockWriteOff> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_category_id')) {
      context.handle(
        _parentCategoryIdMeta,
        parentCategoryId.isAcceptableOrUnknown(
          data['parent_category_id']!,
          _parentCategoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parentCategoryIdMeta);
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightGramsMeta);
    }
    if (data.containsKey('related_expense_category_id')) {
      context.handle(
        _relatedExpenseCategoryIdMeta,
        relatedExpenseCategoryId.isAcceptableOrUnknown(
          data['related_expense_category_id']!,
          _relatedExpenseCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('expense_paisa')) {
      context.handle(
        _expensePaisaMeta,
        expensePaisa.isAcceptableOrUnknown(
          data['expense_paisa']!,
          _expensePaisaMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockWriteOff map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockWriteOff(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_category_id'],
      )!,
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_grams'],
      )!,
      mode: $StockWriteOffsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      relatedExpenseCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_expense_category_id'],
      ),
      expensePaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expense_paisa'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StockWriteOffsTable createAlias(String alias) {
    return $StockWriteOffsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WriteOffModeDb, String, String> $convertermode =
      const EnumNameConverter<WriteOffModeDb>(WriteOffModeDb.values);
}

class StockWriteOff extends DataClass implements Insertable<StockWriteOff> {
  final String id;
  final String parentCategoryId;
  final int weightGrams;
  final WriteOffModeDb mode;
  final String? relatedExpenseCategoryId;

  /// For expenseWastage mode: the Paisa expensed to the P&L (weight × avg cost).
  final int expensePaisa;
  final String? note;
  final DateTime date;
  final DateTime? deletedAt;
  const StockWriteOff({
    required this.id,
    required this.parentCategoryId,
    required this.weightGrams,
    required this.mode,
    this.relatedExpenseCategoryId,
    required this.expensePaisa,
    this.note,
    required this.date,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['parent_category_id'] = Variable<String>(parentCategoryId);
    map['weight_grams'] = Variable<int>(weightGrams);
    {
      map['mode'] = Variable<String>(
        $StockWriteOffsTable.$convertermode.toSql(mode),
      );
    }
    if (!nullToAbsent || relatedExpenseCategoryId != null) {
      map['related_expense_category_id'] = Variable<String>(
        relatedExpenseCategoryId,
      );
    }
    map['expense_paisa'] = Variable<int>(expensePaisa);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  StockWriteOffsCompanion toCompanion(bool nullToAbsent) {
    return StockWriteOffsCompanion(
      id: Value(id),
      parentCategoryId: Value(parentCategoryId),
      weightGrams: Value(weightGrams),
      mode: Value(mode),
      relatedExpenseCategoryId: relatedExpenseCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedExpenseCategoryId),
      expensePaisa: Value(expensePaisa),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory StockWriteOff.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockWriteOff(
      id: serializer.fromJson<String>(json['id']),
      parentCategoryId: serializer.fromJson<String>(json['parentCategoryId']),
      weightGrams: serializer.fromJson<int>(json['weightGrams']),
      mode: $StockWriteOffsTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      relatedExpenseCategoryId: serializer.fromJson<String?>(
        json['relatedExpenseCategoryId'],
      ),
      expensePaisa: serializer.fromJson<int>(json['expensePaisa']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentCategoryId': serializer.toJson<String>(parentCategoryId),
      'weightGrams': serializer.toJson<int>(weightGrams),
      'mode': serializer.toJson<String>(
        $StockWriteOffsTable.$convertermode.toJson(mode),
      ),
      'relatedExpenseCategoryId': serializer.toJson<String?>(
        relatedExpenseCategoryId,
      ),
      'expensePaisa': serializer.toJson<int>(expensePaisa),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<DateTime>(date),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  StockWriteOff copyWith({
    String? id,
    String? parentCategoryId,
    int? weightGrams,
    WriteOffModeDb? mode,
    Value<String?> relatedExpenseCategoryId = const Value.absent(),
    int? expensePaisa,
    Value<String?> note = const Value.absent(),
    DateTime? date,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => StockWriteOff(
    id: id ?? this.id,
    parentCategoryId: parentCategoryId ?? this.parentCategoryId,
    weightGrams: weightGrams ?? this.weightGrams,
    mode: mode ?? this.mode,
    relatedExpenseCategoryId: relatedExpenseCategoryId.present
        ? relatedExpenseCategoryId.value
        : this.relatedExpenseCategoryId,
    expensePaisa: expensePaisa ?? this.expensePaisa,
    note: note.present ? note.value : this.note,
    date: date ?? this.date,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  StockWriteOff copyWithCompanion(StockWriteOffsCompanion data) {
    return StockWriteOff(
      id: data.id.present ? data.id.value : this.id,
      parentCategoryId: data.parentCategoryId.present
          ? data.parentCategoryId.value
          : this.parentCategoryId,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      mode: data.mode.present ? data.mode.value : this.mode,
      relatedExpenseCategoryId: data.relatedExpenseCategoryId.present
          ? data.relatedExpenseCategoryId.value
          : this.relatedExpenseCategoryId,
      expensePaisa: data.expensePaisa.present
          ? data.expensePaisa.value
          : this.expensePaisa,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockWriteOff(')
          ..write('id: $id, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('mode: $mode, ')
          ..write('relatedExpenseCategoryId: $relatedExpenseCategoryId, ')
          ..write('expensePaisa: $expensePaisa, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentCategoryId,
    weightGrams,
    mode,
    relatedExpenseCategoryId,
    expensePaisa,
    note,
    date,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockWriteOff &&
          other.id == this.id &&
          other.parentCategoryId == this.parentCategoryId &&
          other.weightGrams == this.weightGrams &&
          other.mode == this.mode &&
          other.relatedExpenseCategoryId == this.relatedExpenseCategoryId &&
          other.expensePaisa == this.expensePaisa &&
          other.note == this.note &&
          other.date == this.date &&
          other.deletedAt == this.deletedAt);
}

class StockWriteOffsCompanion extends UpdateCompanion<StockWriteOff> {
  final Value<String> id;
  final Value<String> parentCategoryId;
  final Value<int> weightGrams;
  final Value<WriteOffModeDb> mode;
  final Value<String?> relatedExpenseCategoryId;
  final Value<int> expensePaisa;
  final Value<String?> note;
  final Value<DateTime> date;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const StockWriteOffsCompanion({
    this.id = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.mode = const Value.absent(),
    this.relatedExpenseCategoryId = const Value.absent(),
    this.expensePaisa = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockWriteOffsCompanion.insert({
    required String id,
    required String parentCategoryId,
    required int weightGrams,
    required WriteOffModeDb mode,
    this.relatedExpenseCategoryId = const Value.absent(),
    this.expensePaisa = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime date,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       parentCategoryId = Value(parentCategoryId),
       weightGrams = Value(weightGrams),
       mode = Value(mode),
       date = Value(date);
  static Insertable<StockWriteOff> custom({
    Expression<String>? id,
    Expression<String>? parentCategoryId,
    Expression<int>? weightGrams,
    Expression<String>? mode,
    Expression<String>? relatedExpenseCategoryId,
    Expression<int>? expensePaisa,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (mode != null) 'mode': mode,
      if (relatedExpenseCategoryId != null)
        'related_expense_category_id': relatedExpenseCategoryId,
      if (expensePaisa != null) 'expense_paisa': expensePaisa,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockWriteOffsCompanion copyWith({
    Value<String>? id,
    Value<String>? parentCategoryId,
    Value<int>? weightGrams,
    Value<WriteOffModeDb>? mode,
    Value<String?>? relatedExpenseCategoryId,
    Value<int>? expensePaisa,
    Value<String?>? note,
    Value<DateTime>? date,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return StockWriteOffsCompanion(
      id: id ?? this.id,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      weightGrams: weightGrams ?? this.weightGrams,
      mode: mode ?? this.mode,
      relatedExpenseCategoryId:
          relatedExpenseCategoryId ?? this.relatedExpenseCategoryId,
      expensePaisa: expensePaisa ?? this.expensePaisa,
      note: note ?? this.note,
      date: date ?? this.date,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<String>(parentCategoryId.value);
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<int>(weightGrams.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $StockWriteOffsTable.$convertermode.toSql(mode.value),
      );
    }
    if (relatedExpenseCategoryId.present) {
      map['related_expense_category_id'] = Variable<String>(
        relatedExpenseCategoryId.value,
      );
    }
    if (expensePaisa.present) {
      map['expense_paisa'] = Variable<int>(expensePaisa.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockWriteOffsCompanion(')
          ..write('id: $id, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('mode: $mode, ')
          ..write('relatedExpenseCategoryId: $relatedExpenseCategoryId, ')
          ..write('expensePaisa: $expensePaisa, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UpdateHistoriesTable extends UpdateHistories
    with TableInfo<$UpdateHistoriesTable, UpdateHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UpdateHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldChangedMeta = const VerificationMeta(
    'fieldChanged',
  );
  @override
  late final GeneratedColumn<String> fieldChanged = GeneratedColumn<String>(
    'field_changed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    fieldChanged,
    oldValue,
    newValue,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'update_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<UpdateHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field_changed')) {
      context.handle(
        _fieldChangedMeta,
        fieldChanged.isAcceptableOrUnknown(
          data['field_changed']!,
          _fieldChangedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fieldChangedMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UpdateHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UpdateHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      fieldChanged: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_changed'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
    );
  }

  @override
  $UpdateHistoriesTable createAlias(String alias) {
    return $UpdateHistoriesTable(attachedDatabase, alias);
  }
}

class UpdateHistory extends DataClass implements Insertable<UpdateHistory> {
  final String id;
  final String entityType;
  final String entityId;
  final String fieldChanged;
  final String? oldValue;
  final String? newValue;
  final DateTime changedAt;
  const UpdateHistory({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.fieldChanged,
    this.oldValue,
    this.newValue,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field_changed'] = Variable<String>(fieldChanged);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['changed_at'] = Variable<DateTime>(changedAt);
    return map;
  }

  UpdateHistoriesCompanion toCompanion(bool nullToAbsent) {
    return UpdateHistoriesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      fieldChanged: Value(fieldChanged),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      changedAt: Value(changedAt),
    );
  }

  factory UpdateHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UpdateHistory(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      fieldChanged: serializer.fromJson<String>(json['fieldChanged']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'fieldChanged': serializer.toJson<String>(fieldChanged),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  UpdateHistory copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? fieldChanged,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    DateTime? changedAt,
  }) => UpdateHistory(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    fieldChanged: fieldChanged ?? this.fieldChanged,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    changedAt: changedAt ?? this.changedAt,
  );
  UpdateHistory copyWithCompanion(UpdateHistoriesCompanion data) {
    return UpdateHistory(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      fieldChanged: data.fieldChanged.present
          ? data.fieldChanged.value
          : this.fieldChanged,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UpdateHistory(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldChanged: $fieldChanged, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    fieldChanged,
    oldValue,
    newValue,
    changedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpdateHistory &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.fieldChanged == this.fieldChanged &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.changedAt == this.changedAt);
}

class UpdateHistoriesCompanion extends UpdateCompanion<UpdateHistory> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> fieldChanged;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<DateTime> changedAt;
  final Value<int> rowid;
  const UpdateHistoriesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.fieldChanged = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UpdateHistoriesCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String fieldChanged,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    required DateTime changedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       fieldChanged = Value(fieldChanged),
       changedAt = Value(changedAt);
  static Insertable<UpdateHistory> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? fieldChanged,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<DateTime>? changedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (fieldChanged != null) 'field_changed': fieldChanged,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (changedAt != null) 'changed_at': changedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UpdateHistoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? fieldChanged,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<DateTime>? changedAt,
    Value<int>? rowid,
  }) {
    return UpdateHistoriesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      fieldChanged: fieldChanged ?? this.fieldChanged,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      changedAt: changedAt ?? this.changedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (fieldChanged.present) {
      map['field_changed'] = Variable<String>(fieldChanged.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UpdateHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldChanged: $fieldChanged, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('changedAt: $changedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrashRecordsTable extends TrashRecords
    with TableInfo<$TrashRecordsTable, TrashRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrashRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purgeAtMeta = const VerificationMeta(
    'purgeAt',
  );
  @override
  late final GeneratedColumn<DateTime> purgeAt = GeneratedColumn<DateTime>(
    'purge_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    deletedAt,
    purgeAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trash_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrashRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    if (data.containsKey('purge_at')) {
      context.handle(
        _purgeAtMeta,
        purgeAt.isAcceptableOrUnknown(data['purge_at']!, _purgeAtMeta),
      );
    } else if (isInserting) {
      context.missing(_purgeAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrashRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrashRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
      purgeAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purge_at'],
      )!,
    );
  }

  @override
  $TrashRecordsTable createAlias(String alias) {
    return $TrashRecordsTable(attachedDatabase, alias);
  }
}

class TrashRecord extends DataClass implements Insertable<TrashRecord> {
  final String id;
  final String entityType;
  final String entityId;
  final DateTime deletedAt;
  final DateTime purgeAt;
  const TrashRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.deletedAt,
    required this.purgeAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    map['purge_at'] = Variable<DateTime>(purgeAt);
    return map;
  }

  TrashRecordsCompanion toCompanion(bool nullToAbsent) {
    return TrashRecordsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      deletedAt: Value(deletedAt),
      purgeAt: Value(purgeAt),
    );
  }

  factory TrashRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrashRecord(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
      purgeAt: serializer.fromJson<DateTime>(json['purgeAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
      'purgeAt': serializer.toJson<DateTime>(purgeAt),
    };
  }

  TrashRecord copyWith({
    String? id,
    String? entityType,
    String? entityId,
    DateTime? deletedAt,
    DateTime? purgeAt,
  }) => TrashRecord(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    deletedAt: deletedAt ?? this.deletedAt,
    purgeAt: purgeAt ?? this.purgeAt,
  );
  TrashRecord copyWithCompanion(TrashRecordsCompanion data) {
    return TrashRecord(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      purgeAt: data.purgeAt.present ? data.purgeAt.value : this.purgeAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrashRecord(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('purgeAt: $purgeAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, deletedAt, purgeAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrashRecord &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.deletedAt == this.deletedAt &&
          other.purgeAt == this.purgeAt);
}

class TrashRecordsCompanion extends UpdateCompanion<TrashRecord> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<DateTime> deletedAt;
  final Value<DateTime> purgeAt;
  final Value<int> rowid;
  const TrashRecordsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.purgeAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrashRecordsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required DateTime deletedAt,
    required DateTime purgeAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       deletedAt = Value(deletedAt),
       purgeAt = Value(purgeAt);
  static Insertable<TrashRecord> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? purgeAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (purgeAt != null) 'purge_at': purgeAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrashRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<DateTime>? deletedAt,
    Value<DateTime>? purgeAt,
    Value<int>? rowid,
  }) {
    return TrashRecordsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deletedAt: deletedAt ?? this.deletedAt,
      purgeAt: purgeAt ?? this.purgeAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (purgeAt.present) {
      map['purge_at'] = Variable<DateTime>(purgeAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrashRecordsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('purgeAt: $purgeAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayZeroMigrationsTable extends DayZeroMigrations
    with TableInfo<$DayZeroMigrationsTable, DayZeroMigration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayZeroMigrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, performedAt, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_zero_migrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayZeroMigration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayZeroMigration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayZeroMigration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $DayZeroMigrationsTable createAlias(String alias) {
    return $DayZeroMigrationsTable(attachedDatabase, alias);
  }
}

class DayZeroMigration extends DataClass
    implements Insertable<DayZeroMigration> {
  final String id;
  final DateTime performedAt;
  final String? note;
  const DayZeroMigration({
    required this.id,
    required this.performedAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['performed_at'] = Variable<DateTime>(performedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  DayZeroMigrationsCompanion toCompanion(bool nullToAbsent) {
    return DayZeroMigrationsCompanion(
      id: Value(id),
      performedAt: Value(performedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory DayZeroMigration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayZeroMigration(
      id: serializer.fromJson<String>(json['id']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  DayZeroMigration copyWith({
    String? id,
    DateTime? performedAt,
    Value<String?> note = const Value.absent(),
  }) => DayZeroMigration(
    id: id ?? this.id,
    performedAt: performedAt ?? this.performedAt,
    note: note.present ? note.value : this.note,
  );
  DayZeroMigration copyWithCompanion(DayZeroMigrationsCompanion data) {
    return DayZeroMigration(
      id: data.id.present ? data.id.value : this.id,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayZeroMigration(')
          ..write('id: $id, ')
          ..write('performedAt: $performedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, performedAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayZeroMigration &&
          other.id == this.id &&
          other.performedAt == this.performedAt &&
          other.note == this.note);
}

class DayZeroMigrationsCompanion extends UpdateCompanion<DayZeroMigration> {
  final Value<String> id;
  final Value<DateTime> performedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const DayZeroMigrationsCompanion({
    this.id = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayZeroMigrationsCompanion.insert({
    required String id,
    required DateTime performedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       performedAt = Value(performedAt);
  static Insertable<DayZeroMigration> custom({
    Expression<String>? id,
    Expression<DateTime>? performedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (performedAt != null) 'performed_at': performedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayZeroMigrationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? performedAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return DayZeroMigrationsCompanion(
      id: id ?? this.id,
      performedAt: performedAt ?? this.performedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayZeroMigrationsCompanion(')
          ..write('id: $id, ')
          ..write('performedAt: $performedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $StockCategoriesTable stockCategories = $StockCategoriesTable(
    this,
  );
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $BillsTable bills = $BillsTable(this);
  late final $BillLineItemsTable billLineItems = $BillLineItemsTable(this);
  late final $CashPoolsTable cashPools = $CashPoolsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PaymentAllocationsTable paymentAllocations =
      $PaymentAllocationsTable(this);
  late final $CashMovementsTable cashMovements = $CashMovementsTable(this);
  late final $StockWriteOffsTable stockWriteOffs = $StockWriteOffsTable(this);
  late final $UpdateHistoriesTable updateHistories = $UpdateHistoriesTable(
    this,
  );
  late final $TrashRecordsTable trashRecords = $TrashRecordsTable(this);
  late final $DayZeroMigrationsTable dayZeroMigrations =
      $DayZeroMigrationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    parties,
    stockCategories,
    expenseCategories,
    bills,
    billLineItems,
    cashPools,
    payments,
    paymentAllocations,
    cashMovements,
    stockWriteOffs,
    updateHistories,
    trashRecords,
    dayZeroMigrations,
  ];
}

typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      required String id,
      required String name,
      required PartyTypeDb type,
      Value<String?> phone,
      Value<int> openingBalancePaisa,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<PartyTypeDb> type,
      Value<String?> phone,
      Value<int> openingBalancePaisa,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PartiesTableReferences
    extends BaseReferences<_$AppDatabase, $PartiesTable, Party> {
  $$PartiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BillsTable, List<Bill>> _billsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bills,
    aliasName: $_aliasNameGenerator(db.parties.id, db.bills.partyId),
  );

  $$BillsTableProcessedTableManager get billsRefs {
    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_billsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(db.parties.id, db.payments.partyId),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PartyTypeDb, PartyTypeDb, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalancePaisa => $composableBuilder(
    column: $table.openingBalancePaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> billsRefs(
    Expression<bool> Function($$BillsTableFilterComposer f) f,
  ) {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalancePaisa => $composableBuilder(
    column: $table.openingBalancePaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PartyTypeDb, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get openingBalancePaisa => $composableBuilder(
    column: $table.openingBalancePaisa,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> billsRefs<T extends Object>(
    Expression<T> Function($$BillsTableAnnotationComposer a) f,
  ) {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, $$PartiesTableReferences),
          Party,
          PrefetchHooks Function({bool billsRefs, bool paymentsRefs})
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<PartyTypeDb> type = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> openingBalancePaisa = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                name: name,
                type: type,
                phone: phone,
                openingBalancePaisa: openingBalancePaisa,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required PartyTypeDb type,
                Value<String?> phone = const Value.absent(),
                Value<int> openingBalancePaisa = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                name: name,
                type: type,
                phone: phone,
                openingBalancePaisa: openingBalancePaisa,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({billsRefs = false, paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (billsRefs) db.bills,
                if (paymentsRefs) db.payments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (billsRefs)
                    await $_getPrefetchedData<Party, $PartiesTable, Bill>(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences._billsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$PartiesTableReferences(db, table, p0).billsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.partyId == item.id),
                      typedResults: items,
                    ),
                  if (paymentsRefs)
                    await $_getPrefetchedData<Party, $PartiesTable, Payment>(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PartiesTableReferences(db, table, p0).paymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.partyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, $$PartiesTableReferences),
      Party,
      PrefetchHooks Function({bool billsRefs, bool paymentsRefs})
    >;
typedef $$StockCategoriesTableCreateCompanionBuilder =
    StockCategoriesCompanion Function({
      required String id,
      required String name,
      Value<bool> isCustom,
      Value<String?> parentCategoryId,
      Value<int> quantityGrams,
      Value<int> totalCostBasisPaisa,
      Value<int> targetMarginPct,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$StockCategoriesTableUpdateCompanionBuilder =
    StockCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isCustom,
      Value<String?> parentCategoryId,
      Value<int> quantityGrams,
      Value<int> totalCostBasisPaisa,
      Value<int> targetMarginPct,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$StockCategoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $StockCategoriesTable, StockCategory> {
  $$StockCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StockCategoriesTable _parentCategoryIdTable(_$AppDatabase db) =>
      db.stockCategories.createAlias(
        $_aliasNameGenerator(
          db.stockCategories.parentCategoryId,
          db.stockCategories.id,
        ),
      );

  $$StockCategoriesTableProcessedTableManager? get parentCategoryId {
    final $_column = $_itemColumn<String>('parent_category_id');
    if ($_column == null) return null;
    final manager = $$StockCategoriesTableTableManager(
      $_db,
      $_db.stockCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BillLineItemsTable, List<BillLineItem>>
  _billLineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.billLineItems,
    aliasName: $_aliasNameGenerator(
      db.stockCategories.id,
      db.billLineItems.parentCategoryId,
    ),
  );

  $$BillLineItemsTableProcessedTableManager get billLineItemsRefs {
    final manager = $$BillLineItemsTableTableManager($_db, $_db.billLineItems)
        .filter(
          (f) => f.parentCategoryId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_billLineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockWriteOffsTable, List<StockWriteOff>>
  _stockWriteOffsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockWriteOffs,
    aliasName: $_aliasNameGenerator(
      db.stockCategories.id,
      db.stockWriteOffs.parentCategoryId,
    ),
  );

  $$StockWriteOffsTableProcessedTableManager get stockWriteOffsRefs {
    final manager = $$StockWriteOffsTableTableManager($_db, $_db.stockWriteOffs)
        .filter(
          (f) => f.parentCategoryId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_stockWriteOffsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StockCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $StockCategoriesTable> {
  $$StockCategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityGrams => $composableBuilder(
    column: $table.quantityGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostBasisPaisa => $composableBuilder(
    column: $table.totalCostBasisPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMarginPct => $composableBuilder(
    column: $table.targetMarginPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StockCategoriesTableFilterComposer get parentCategoryId {
    final $$StockCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> billLineItemsRefs(
    Expression<bool> Function($$BillLineItemsTableFilterComposer f) f,
  ) {
    final $$BillLineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billLineItems,
      getReferencedColumn: (t) => t.parentCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillLineItemsTableFilterComposer(
            $db: $db,
            $table: $db.billLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockWriteOffsRefs(
    Expression<bool> Function($$StockWriteOffsTableFilterComposer f) f,
  ) {
    final $$StockWriteOffsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockWriteOffs,
      getReferencedColumn: (t) => t.parentCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockWriteOffsTableFilterComposer(
            $db: $db,
            $table: $db.stockWriteOffs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StockCategoriesTable> {
  $$StockCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityGrams => $composableBuilder(
    column: $table.quantityGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostBasisPaisa => $composableBuilder(
    column: $table.totalCostBasisPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMarginPct => $composableBuilder(
    column: $table.targetMarginPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockCategoriesTableOrderingComposer get parentCategoryId {
    final $$StockCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockCategoriesTable> {
  $$StockCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<int> get quantityGrams => $composableBuilder(
    column: $table.quantityGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostBasisPaisa => $composableBuilder(
    column: $table.totalCostBasisPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetMarginPct => $composableBuilder(
    column: $table.targetMarginPct,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$StockCategoriesTableAnnotationComposer get parentCategoryId {
    final $$StockCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> billLineItemsRefs<T extends Object>(
    Expression<T> Function($$BillLineItemsTableAnnotationComposer a) f,
  ) {
    final $$BillLineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billLineItems,
      getReferencedColumn: (t) => t.parentCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillLineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.billLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockWriteOffsRefs<T extends Object>(
    Expression<T> Function($$StockWriteOffsTableAnnotationComposer a) f,
  ) {
    final $$StockWriteOffsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockWriteOffs,
      getReferencedColumn: (t) => t.parentCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockWriteOffsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockWriteOffs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockCategoriesTable,
          StockCategory,
          $$StockCategoriesTableFilterComposer,
          $$StockCategoriesTableOrderingComposer,
          $$StockCategoriesTableAnnotationComposer,
          $$StockCategoriesTableCreateCompanionBuilder,
          $$StockCategoriesTableUpdateCompanionBuilder,
          (StockCategory, $$StockCategoriesTableReferences),
          StockCategory,
          PrefetchHooks Function({
            bool parentCategoryId,
            bool billLineItemsRefs,
            bool stockWriteOffsRefs,
          })
        > {
  $$StockCategoriesTableTableManager(
    _$AppDatabase db,
    $StockCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> parentCategoryId = const Value.absent(),
                Value<int> quantityGrams = const Value.absent(),
                Value<int> totalCostBasisPaisa = const Value.absent(),
                Value<int> targetMarginPct = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockCategoriesCompanion(
                id: id,
                name: name,
                isCustom: isCustom,
                parentCategoryId: parentCategoryId,
                quantityGrams: quantityGrams,
                totalCostBasisPaisa: totalCostBasisPaisa,
                targetMarginPct: targetMarginPct,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isCustom = const Value.absent(),
                Value<String?> parentCategoryId = const Value.absent(),
                Value<int> quantityGrams = const Value.absent(),
                Value<int> totalCostBasisPaisa = const Value.absent(),
                Value<int> targetMarginPct = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockCategoriesCompanion.insert(
                id: id,
                name: name,
                isCustom: isCustom,
                parentCategoryId: parentCategoryId,
                quantityGrams: quantityGrams,
                totalCostBasisPaisa: totalCostBasisPaisa,
                targetMarginPct: targetMarginPct,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentCategoryId = false,
                billLineItemsRefs = false,
                stockWriteOffsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (billLineItemsRefs) db.billLineItems,
                    if (stockWriteOffsRefs) db.stockWriteOffs,
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
                        if (parentCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentCategoryId,
                                    referencedTable:
                                        $$StockCategoriesTableReferences
                                            ._parentCategoryIdTable(db),
                                    referencedColumn:
                                        $$StockCategoriesTableReferences
                                            ._parentCategoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (billLineItemsRefs)
                        await $_getPrefetchedData<
                          StockCategory,
                          $StockCategoriesTable,
                          BillLineItem
                        >(
                          currentTable: table,
                          referencedTable: $$StockCategoriesTableReferences
                              ._billLineItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).billLineItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.parentCategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockWriteOffsRefs)
                        await $_getPrefetchedData<
                          StockCategory,
                          $StockCategoriesTable,
                          StockWriteOff
                        >(
                          currentTable: table,
                          referencedTable: $$StockCategoriesTableReferences
                              ._stockWriteOffsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).stockWriteOffsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.parentCategoryId == item.id,
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

typedef $$StockCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockCategoriesTable,
      StockCategory,
      $$StockCategoriesTableFilterComposer,
      $$StockCategoriesTableOrderingComposer,
      $$StockCategoriesTableAnnotationComposer,
      $$StockCategoriesTableCreateCompanionBuilder,
      $$StockCategoriesTableUpdateCompanionBuilder,
      (StockCategory, $$StockCategoriesTableReferences),
      StockCategory,
      PrefetchHooks Function({
        bool parentCategoryId,
        bool billLineItemsRefs,
        bool stockWriteOffsRefs,
      })
    >;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      required String id,
      required String name,
      Value<bool> isCustom,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isCustom,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ExpenseCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategory
        > {
  $$ExpenseCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BillsTable, List<Bill>> _billsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bills,
    aliasName: $_aliasNameGenerator(
      db.expenseCategories.id,
      db.bills.expenseCategoryId,
    ),
  );

  $$BillsTableProcessedTableManager get billsRefs {
    final manager = $$BillsTableTableManager($_db, $_db.bills).filter(
      (f) => f.expenseCategoryId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_billsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockWriteOffsTable, List<StockWriteOff>>
  _stockWriteOffsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockWriteOffs,
    aliasName: $_aliasNameGenerator(
      db.expenseCategories.id,
      db.stockWriteOffs.relatedExpenseCategoryId,
    ),
  );

  $$StockWriteOffsTableProcessedTableManager get stockWriteOffsRefs {
    final manager = $$StockWriteOffsTableTableManager($_db, $_db.stockWriteOffs)
        .filter(
          (f) => f.relatedExpenseCategoryId.id.sqlEquals(
            $_itemColumn<String>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_stockWriteOffsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> billsRefs(
    Expression<bool> Function($$BillsTableFilterComposer f) f,
  ) {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.expenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockWriteOffsRefs(
    Expression<bool> Function($$StockWriteOffsTableFilterComposer f) f,
  ) {
    final $$StockWriteOffsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockWriteOffs,
      getReferencedColumn: (t) => t.relatedExpenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockWriteOffsTableFilterComposer(
            $db: $db,
            $table: $db.stockWriteOffs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> billsRefs<T extends Object>(
    Expression<T> Function($$BillsTableAnnotationComposer a) f,
  ) {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.expenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockWriteOffsRefs<T extends Object>(
    Expression<T> Function($$StockWriteOffsTableAnnotationComposer a) f,
  ) {
    final $$StockWriteOffsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockWriteOffs,
      getReferencedColumn: (t) => t.relatedExpenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockWriteOffsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockWriteOffs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategory,
          $$ExpenseCategoriesTableFilterComposer,
          $$ExpenseCategoriesTableOrderingComposer,
          $$ExpenseCategoriesTableAnnotationComposer,
          $$ExpenseCategoriesTableCreateCompanionBuilder,
          $$ExpenseCategoriesTableUpdateCompanionBuilder,
          (ExpenseCategory, $$ExpenseCategoriesTableReferences),
          ExpenseCategory,
          PrefetchHooks Function({bool billsRefs, bool stockWriteOffsRefs})
        > {
  $$ExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                name: name,
                isCustom: isCustom,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                name: name,
                isCustom: isCustom,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpenseCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({billsRefs = false, stockWriteOffsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (billsRefs) db.bills,
                    if (stockWriteOffsRefs) db.stockWriteOffs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (billsRefs)
                        await $_getPrefetchedData<
                          ExpenseCategory,
                          $ExpenseCategoriesTable,
                          Bill
                        >(
                          currentTable: table,
                          referencedTable: $$ExpenseCategoriesTableReferences
                              ._billsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpenseCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).billsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.expenseCategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockWriteOffsRefs)
                        await $_getPrefetchedData<
                          ExpenseCategory,
                          $ExpenseCategoriesTable,
                          StockWriteOff
                        >(
                          currentTable: table,
                          referencedTable: $$ExpenseCategoriesTableReferences
                              ._stockWriteOffsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpenseCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).stockWriteOffsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.relatedExpenseCategoryId == item.id,
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

typedef $$ExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoriesTable,
      ExpenseCategory,
      $$ExpenseCategoriesTableFilterComposer,
      $$ExpenseCategoriesTableOrderingComposer,
      $$ExpenseCategoriesTableAnnotationComposer,
      $$ExpenseCategoriesTableCreateCompanionBuilder,
      $$ExpenseCategoriesTableUpdateCompanionBuilder,
      (ExpenseCategory, $$ExpenseCategoriesTableReferences),
      ExpenseCategory,
      PrefetchHooks Function({bool billsRefs, bool stockWriteOffsRefs})
    >;
typedef $$BillsTableCreateCompanionBuilder =
    BillsCompanion Function({
      required String id,
      required BillTypeDb type,
      Value<String?> partyId,
      Value<String?> expenseCategoryId,
      required DateTime date,
      Value<String?> photoPath,
      required RateModeDb rateMode,
      Value<int?> billLevelRatePaisaPerKg,
      required int totalAmountPaisa,
      Value<bool> isOpening,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$BillsTableUpdateCompanionBuilder =
    BillsCompanion Function({
      Value<String> id,
      Value<BillTypeDb> type,
      Value<String?> partyId,
      Value<String?> expenseCategoryId,
      Value<DateTime> date,
      Value<String?> photoPath,
      Value<RateModeDb> rateMode,
      Value<int?> billLevelRatePaisaPerKg,
      Value<int> totalAmountPaisa,
      Value<bool> isOpening,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$BillsTableReferences
    extends BaseReferences<_$AppDatabase, $BillsTable, Bill> {
  $$BillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartiesTable _partyIdTable(_$AppDatabase db) => db.parties
      .createAlias($_aliasNameGenerator(db.bills.partyId, db.parties.id));

  $$PartiesTableProcessedTableManager? get partyId {
    final $_column = $_itemColumn<String>('party_id');
    if ($_column == null) return null;
    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpenseCategoriesTable _expenseCategoryIdTable(_$AppDatabase db) =>
      db.expenseCategories.createAlias(
        $_aliasNameGenerator(
          db.bills.expenseCategoryId,
          db.expenseCategories.id,
        ),
      );

  $$ExpenseCategoriesTableProcessedTableManager? get expenseCategoryId {
    final $_column = $_itemColumn<String>('expense_category_id');
    if ($_column == null) return null;
    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BillLineItemsTable, List<BillLineItem>>
  _billLineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.billLineItems,
    aliasName: $_aliasNameGenerator(db.bills.id, db.billLineItems.billId),
  );

  $$BillLineItemsTableProcessedTableManager get billLineItemsRefs {
    final manager = $$BillLineItemsTableTableManager(
      $_db,
      $_db.billLineItems,
    ).filter((f) => f.billId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_billLineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentAllocationsTable, List<PaymentAllocation>>
  _paymentAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentAllocations,
        aliasName: $_aliasNameGenerator(
          db.bills.id,
          db.paymentAllocations.billId,
        ),
      );

  $$PaymentAllocationsTableProcessedTableManager get paymentAllocationsRefs {
    final manager = $$PaymentAllocationsTableTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.billId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashMovementsTable, List<CashMovement>>
  _cashMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashMovements,
    aliasName: $_aliasNameGenerator(
      db.bills.id,
      db.cashMovements.relatedBillId,
    ),
  );

  $$CashMovementsTableProcessedTableManager get cashMovementsRefs {
    final manager = $$CashMovementsTableTableManager(
      $_db,
      $_db.cashMovements,
    ).filter((f) => f.relatedBillId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BillsTableFilterComposer extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<BillTypeDb, BillTypeDb, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RateModeDb, RateModeDb, String> get rateMode =>
      $composableBuilder(
        column: $table.rateMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get billLevelRatePaisaPerKg => $composableBuilder(
    column: $table.billLevelRatePaisaPerKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmountPaisa => $composableBuilder(
    column: $table.totalAmountPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpening => $composableBuilder(
    column: $table.isOpening,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableFilterComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseCategoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> billLineItemsRefs(
    Expression<bool> Function($$BillLineItemsTableFilterComposer f) f,
  ) {
    final $$BillLineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billLineItems,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillLineItemsTableFilterComposer(
            $db: $db,
            $table: $db.billLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentAllocationsRefs(
    Expression<bool> Function($$PaymentAllocationsTableFilterComposer f) f,
  ) {
    final $$PaymentAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cashMovementsRefs(
    Expression<bool> Function($$CashMovementsTableFilterComposer f) f,
  ) {
    final $$CashMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovements,
      getReferencedColumn: (t) => t.relatedBillId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementsTableFilterComposer(
            $db: $db,
            $table: $db.cashMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateMode => $composableBuilder(
    column: $table.rateMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billLevelRatePaisaPerKg => $composableBuilder(
    column: $table.billLevelRatePaisaPerKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmountPaisa => $composableBuilder(
    column: $table.totalAmountPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpening => $composableBuilder(
    column: $table.isOpening,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableOrderingComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseCategoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillsTable> {
  $$BillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BillTypeDb, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RateModeDb, String> get rateMode =>
      $composableBuilder(column: $table.rateMode, builder: (column) => column);

  GeneratedColumn<int> get billLevelRatePaisaPerKg => $composableBuilder(
    column: $table.billLevelRatePaisaPerKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAmountPaisa => $composableBuilder(
    column: $table.totalAmountPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOpening =>
      $composableBuilder(column: $table.isOpening, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableAnnotationComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.expenseCategoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> billLineItemsRefs<T extends Object>(
    Expression<T> Function($$BillLineItemsTableAnnotationComposer a) f,
  ) {
    final $$BillLineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.billLineItems,
      getReferencedColumn: (t) => t.billId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillLineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.billLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaymentAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaymentAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentAllocations,
          getReferencedColumn: (t) => t.billId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cashMovementsRefs<T extends Object>(
    Expression<T> Function($$CashMovementsTableAnnotationComposer a) f,
  ) {
    final $$CashMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovements,
      getReferencedColumn: (t) => t.relatedBillId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.cashMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillsTable,
          Bill,
          $$BillsTableFilterComposer,
          $$BillsTableOrderingComposer,
          $$BillsTableAnnotationComposer,
          $$BillsTableCreateCompanionBuilder,
          $$BillsTableUpdateCompanionBuilder,
          (Bill, $$BillsTableReferences),
          Bill,
          PrefetchHooks Function({
            bool partyId,
            bool expenseCategoryId,
            bool billLineItemsRefs,
            bool paymentAllocationsRefs,
            bool cashMovementsRefs,
          })
        > {
  $$BillsTableTableManager(_$AppDatabase db, $BillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BillTypeDb> type = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<String?> expenseCategoryId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<RateModeDb> rateMode = const Value.absent(),
                Value<int?> billLevelRatePaisaPerKg = const Value.absent(),
                Value<int> totalAmountPaisa = const Value.absent(),
                Value<bool> isOpening = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion(
                id: id,
                type: type,
                partyId: partyId,
                expenseCategoryId: expenseCategoryId,
                date: date,
                photoPath: photoPath,
                rateMode: rateMode,
                billLevelRatePaisaPerKg: billLevelRatePaisaPerKg,
                totalAmountPaisa: totalAmountPaisa,
                isOpening: isOpening,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required BillTypeDb type,
                Value<String?> partyId = const Value.absent(),
                Value<String?> expenseCategoryId = const Value.absent(),
                required DateTime date,
                Value<String?> photoPath = const Value.absent(),
                required RateModeDb rateMode,
                Value<int?> billLevelRatePaisaPerKg = const Value.absent(),
                required int totalAmountPaisa,
                Value<bool> isOpening = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillsCompanion.insert(
                id: id,
                type: type,
                partyId: partyId,
                expenseCategoryId: expenseCategoryId,
                date: date,
                photoPath: photoPath,
                rateMode: rateMode,
                billLevelRatePaisaPerKg: billLevelRatePaisaPerKg,
                totalAmountPaisa: totalAmountPaisa,
                isOpening: isOpening,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BillsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                partyId = false,
                expenseCategoryId = false,
                billLineItemsRefs = false,
                paymentAllocationsRefs = false,
                cashMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (billLineItemsRefs) db.billLineItems,
                    if (paymentAllocationsRefs) db.paymentAllocations,
                    if (cashMovementsRefs) db.cashMovements,
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
                        if (partyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyId,
                                    referencedTable: $$BillsTableReferences
                                        ._partyIdTable(db),
                                    referencedColumn: $$BillsTableReferences
                                        ._partyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (expenseCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.expenseCategoryId,
                                    referencedTable: $$BillsTableReferences
                                        ._expenseCategoryIdTable(db),
                                    referencedColumn: $$BillsTableReferences
                                        ._expenseCategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (billLineItemsRefs)
                        await $_getPrefetchedData<
                          Bill,
                          $BillsTable,
                          BillLineItem
                        >(
                          currentTable: table,
                          referencedTable: $$BillsTableReferences
                              ._billLineItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillsTableReferences(
                                db,
                                table,
                                p0,
                              ).billLineItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.billId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentAllocationsRefs)
                        await $_getPrefetchedData<
                          Bill,
                          $BillsTable,
                          PaymentAllocation
                        >(
                          currentTable: table,
                          referencedTable: $$BillsTableReferences
                              ._paymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.billId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cashMovementsRefs)
                        await $_getPrefetchedData<
                          Bill,
                          $BillsTable,
                          CashMovement
                        >(
                          currentTable: table,
                          referencedTable: $$BillsTableReferences
                              ._cashMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BillsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.relatedBillId == item.id,
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

typedef $$BillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillsTable,
      Bill,
      $$BillsTableFilterComposer,
      $$BillsTableOrderingComposer,
      $$BillsTableAnnotationComposer,
      $$BillsTableCreateCompanionBuilder,
      $$BillsTableUpdateCompanionBuilder,
      (Bill, $$BillsTableReferences),
      Bill,
      PrefetchHooks Function({
        bool partyId,
        bool expenseCategoryId,
        bool billLineItemsRefs,
        bool paymentAllocationsRefs,
        bool cashMovementsRefs,
      })
    >;
typedef $$BillLineItemsTableCreateCompanionBuilder =
    BillLineItemsCompanion Function({
      required String id,
      required String billId,
      required String parentCategoryId,
      Value<String?> subCategoryLabel,
      required int weightGrams,
      required int ratePaisaPerKg,
      required int lineTotalPaisa,
      Value<int?> cogsPaisa,
      Value<int> rowid,
    });
typedef $$BillLineItemsTableUpdateCompanionBuilder =
    BillLineItemsCompanion Function({
      Value<String> id,
      Value<String> billId,
      Value<String> parentCategoryId,
      Value<String?> subCategoryLabel,
      Value<int> weightGrams,
      Value<int> ratePaisaPerKg,
      Value<int> lineTotalPaisa,
      Value<int?> cogsPaisa,
      Value<int> rowid,
    });

final class $$BillLineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $BillLineItemsTable, BillLineItem> {
  $$BillLineItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BillsTable _billIdTable(_$AppDatabase db) => db.bills.createAlias(
    $_aliasNameGenerator(db.billLineItems.billId, db.bills.id),
  );

  $$BillsTableProcessedTableManager get billId {
    final $_column = $_itemColumn<String>('bill_id')!;

    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_billIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StockCategoriesTable _parentCategoryIdTable(_$AppDatabase db) =>
      db.stockCategories.createAlias(
        $_aliasNameGenerator(
          db.billLineItems.parentCategoryId,
          db.stockCategories.id,
        ),
      );

  $$StockCategoriesTableProcessedTableManager get parentCategoryId {
    final $_column = $_itemColumn<String>('parent_category_id')!;

    final manager = $$StockCategoriesTableTableManager(
      $_db,
      $_db.stockCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BillLineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $BillLineItemsTable> {
  $$BillLineItemsTableFilterComposer({
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

  ColumnFilters<String> get subCategoryLabel => $composableBuilder(
    column: $table.subCategoryLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePaisaPerKg => $composableBuilder(
    column: $table.ratePaisaPerKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalPaisa => $composableBuilder(
    column: $table.lineTotalPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cogsPaisa => $composableBuilder(
    column: $table.cogsPaisa,
    builder: (column) => ColumnFilters(column),
  );

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StockCategoriesTableFilterComposer get parentCategoryId {
    final $$StockCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillLineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillLineItemsTable> {
  $$BillLineItemsTableOrderingComposer({
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

  ColumnOrderings<String> get subCategoryLabel => $composableBuilder(
    column: $table.subCategoryLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePaisaPerKg => $composableBuilder(
    column: $table.ratePaisaPerKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalPaisa => $composableBuilder(
    column: $table.lineTotalPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cogsPaisa => $composableBuilder(
    column: $table.cogsPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StockCategoriesTableOrderingComposer get parentCategoryId {
    final $$StockCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillLineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillLineItemsTable> {
  $$BillLineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subCategoryLabel => $composableBuilder(
    column: $table.subCategoryLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ratePaisaPerKg => $composableBuilder(
    column: $table.ratePaisaPerKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalPaisa => $composableBuilder(
    column: $table.lineTotalPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cogsPaisa =>
      $composableBuilder(column: $table.cogsPaisa, builder: (column) => column);

  $$BillsTableAnnotationComposer get billId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StockCategoriesTableAnnotationComposer get parentCategoryId {
    final $$StockCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BillLineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillLineItemsTable,
          BillLineItem,
          $$BillLineItemsTableFilterComposer,
          $$BillLineItemsTableOrderingComposer,
          $$BillLineItemsTableAnnotationComposer,
          $$BillLineItemsTableCreateCompanionBuilder,
          $$BillLineItemsTableUpdateCompanionBuilder,
          (BillLineItem, $$BillLineItemsTableReferences),
          BillLineItem,
          PrefetchHooks Function({bool billId, bool parentCategoryId})
        > {
  $$BillLineItemsTableTableManager(_$AppDatabase db, $BillLineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillLineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillLineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillLineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> billId = const Value.absent(),
                Value<String> parentCategoryId = const Value.absent(),
                Value<String?> subCategoryLabel = const Value.absent(),
                Value<int> weightGrams = const Value.absent(),
                Value<int> ratePaisaPerKg = const Value.absent(),
                Value<int> lineTotalPaisa = const Value.absent(),
                Value<int?> cogsPaisa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillLineItemsCompanion(
                id: id,
                billId: billId,
                parentCategoryId: parentCategoryId,
                subCategoryLabel: subCategoryLabel,
                weightGrams: weightGrams,
                ratePaisaPerKg: ratePaisaPerKg,
                lineTotalPaisa: lineTotalPaisa,
                cogsPaisa: cogsPaisa,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String billId,
                required String parentCategoryId,
                Value<String?> subCategoryLabel = const Value.absent(),
                required int weightGrams,
                required int ratePaisaPerKg,
                required int lineTotalPaisa,
                Value<int?> cogsPaisa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillLineItemsCompanion.insert(
                id: id,
                billId: billId,
                parentCategoryId: parentCategoryId,
                subCategoryLabel: subCategoryLabel,
                weightGrams: weightGrams,
                ratePaisaPerKg: ratePaisaPerKg,
                lineTotalPaisa: lineTotalPaisa,
                cogsPaisa: cogsPaisa,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BillLineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({billId = false, parentCategoryId = false}) {
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
                    if (billId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.billId,
                                referencedTable: $$BillLineItemsTableReferences
                                    ._billIdTable(db),
                                referencedColumn: $$BillLineItemsTableReferences
                                    ._billIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (parentCategoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentCategoryId,
                                referencedTable: $$BillLineItemsTableReferences
                                    ._parentCategoryIdTable(db),
                                referencedColumn: $$BillLineItemsTableReferences
                                    ._parentCategoryIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$BillLineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillLineItemsTable,
      BillLineItem,
      $$BillLineItemsTableFilterComposer,
      $$BillLineItemsTableOrderingComposer,
      $$BillLineItemsTableAnnotationComposer,
      $$BillLineItemsTableCreateCompanionBuilder,
      $$BillLineItemsTableUpdateCompanionBuilder,
      (BillLineItem, $$BillLineItemsTableReferences),
      BillLineItem,
      PrefetchHooks Function({bool billId, bool parentCategoryId})
    >;
typedef $$CashPoolsTableCreateCompanionBuilder =
    CashPoolsCompanion Function({
      required String id,
      required PoolNameDb name,
      Value<int> rowid,
    });
typedef $$CashPoolsTableUpdateCompanionBuilder =
    CashPoolsCompanion Function({
      Value<String> id,
      Value<PoolNameDb> name,
      Value<int> rowid,
    });

final class $$CashPoolsTableReferences
    extends BaseReferences<_$AppDatabase, $CashPoolsTable, CashPool> {
  $$CashPoolsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(db.cashPools.id, db.payments.poolId),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.poolId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashMovementsTable, List<CashMovement>>
  _cashMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashMovements,
    aliasName: $_aliasNameGenerator(db.cashPools.id, db.cashMovements.poolId),
  );

  $$CashMovementsTableProcessedTableManager get cashMovementsRefs {
    final manager = $$CashMovementsTableTableManager(
      $_db,
      $_db.cashMovements,
    ).filter((f) => f.poolId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cashMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CashPoolsTableFilterComposer
    extends Composer<_$AppDatabase, $CashPoolsTable> {
  $$CashPoolsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<PoolNameDb, PoolNameDb, String> get name =>
      $composableBuilder(
        column: $table.name,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.poolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cashMovementsRefs(
    Expression<bool> Function($$CashMovementsTableFilterComposer f) f,
  ) {
    final $$CashMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovements,
      getReferencedColumn: (t) => t.poolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementsTableFilterComposer(
            $db: $db,
            $table: $db.cashMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CashPoolsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashPoolsTable> {
  $$CashPoolsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashPoolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashPoolsTable> {
  $$CashPoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PoolNameDb, String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.poolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cashMovementsRefs<T extends Object>(
    Expression<T> Function($$CashMovementsTableAnnotationComposer a) f,
  ) {
    final $$CashMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovements,
      getReferencedColumn: (t) => t.poolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.cashMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CashPoolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashPoolsTable,
          CashPool,
          $$CashPoolsTableFilterComposer,
          $$CashPoolsTableOrderingComposer,
          $$CashPoolsTableAnnotationComposer,
          $$CashPoolsTableCreateCompanionBuilder,
          $$CashPoolsTableUpdateCompanionBuilder,
          (CashPool, $$CashPoolsTableReferences),
          CashPool,
          PrefetchHooks Function({bool paymentsRefs, bool cashMovementsRefs})
        > {
  $$CashPoolsTableTableManager(_$AppDatabase db, $CashPoolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashPoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashPoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashPoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<PoolNameDb> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashPoolsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required PoolNameDb name,
                Value<int> rowid = const Value.absent(),
              }) => CashPoolsCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CashPoolsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({paymentsRefs = false, cashMovementsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsRefs) db.payments,
                    if (cashMovementsRefs) db.cashMovements,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          CashPool,
                          $CashPoolsTable,
                          Payment
                        >(
                          currentTable: table,
                          referencedTable: $$CashPoolsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CashPoolsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poolId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cashMovementsRefs)
                        await $_getPrefetchedData<
                          CashPool,
                          $CashPoolsTable,
                          CashMovement
                        >(
                          currentTable: table,
                          referencedTable: $$CashPoolsTableReferences
                              ._cashMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CashPoolsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poolId == item.id,
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

typedef $$CashPoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashPoolsTable,
      CashPool,
      $$CashPoolsTableFilterComposer,
      $$CashPoolsTableOrderingComposer,
      $$CashPoolsTableAnnotationComposer,
      $$CashPoolsTableCreateCompanionBuilder,
      $$CashPoolsTableUpdateCompanionBuilder,
      (CashPool, $$CashPoolsTableReferences),
      CashPool,
      PrefetchHooks Function({bool paymentsRefs, bool cashMovementsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String partyId,
      required int amountPaisa,
      required PaymentDirectionDb direction,
      required String poolId,
      required DateTime date,
      Value<bool> isAdvance,
      Value<bool> reversed,
      Value<DateTime?> reversedAt,
      Value<String?> reversalReason,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> partyId,
      Value<int> amountPaisa,
      Value<PaymentDirectionDb> direction,
      Value<String> poolId,
      Value<DateTime> date,
      Value<bool> isAdvance,
      Value<bool> reversed,
      Value<DateTime?> reversedAt,
      Value<String?> reversalReason,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartiesTable _partyIdTable(_$AppDatabase db) => db.parties
      .createAlias($_aliasNameGenerator(db.payments.partyId, db.parties.id));

  $$PartiesTableProcessedTableManager get partyId {
    final $_column = $_itemColumn<String>('party_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CashPoolsTable _poolIdTable(_$AppDatabase db) => db.cashPools
      .createAlias($_aliasNameGenerator(db.payments.poolId, db.cashPools.id));

  $$CashPoolsTableProcessedTableManager get poolId {
    final $_column = $_itemColumn<String>('pool_id')!;

    final manager = $$CashPoolsTableTableManager(
      $_db,
      $_db.cashPools,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poolIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentAllocationsTable, List<PaymentAllocation>>
  _paymentAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentAllocations,
        aliasName: $_aliasNameGenerator(
          db.payments.id,
          db.paymentAllocations.paymentId,
        ),
      );

  $$PaymentAllocationsTableProcessedTableManager get paymentAllocationsRefs {
    final manager = $$PaymentAllocationsTableTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashMovementsTable, List<CashMovement>>
  _cashMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashMovements,
    aliasName: $_aliasNameGenerator(
      db.payments.id,
      db.cashMovements.relatedPaymentId,
    ),
  );

  $$CashMovementsTableProcessedTableManager get cashMovementsRefs {
    final manager = $$CashMovementsTableTableManager($_db, $_db.cashMovements)
        .filter(
          (f) => f.relatedPaymentId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_cashMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentDirectionDb, PaymentDirectionDb, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdvance => $composableBuilder(
    column: $table.isAdvance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversalReason => $composableBuilder(
    column: $table.reversalReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CashPoolsTableFilterComposer get poolId {
    final $$CashPoolsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.cashPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashPoolsTableFilterComposer(
            $db: $db,
            $table: $db.cashPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentAllocationsRefs(
    Expression<bool> Function($$PaymentAllocationsTableFilterComposer f) f,
  ) {
    final $$PaymentAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cashMovementsRefs(
    Expression<bool> Function($$CashMovementsTableFilterComposer f) f,
  ) {
    final $$CashMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovements,
      getReferencedColumn: (t) => t.relatedPaymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementsTableFilterComposer(
            $db: $db,
            $table: $db.cashMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdvance => $composableBuilder(
    column: $table.isAdvance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversalReason => $composableBuilder(
    column: $table.reversalReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CashPoolsTableOrderingComposer get poolId {
    final $$CashPoolsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.cashPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashPoolsTableOrderingComposer(
            $db: $db,
            $table: $db.cashPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentDirectionDb, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isAdvance =>
      $composableBuilder(column: $table.isAdvance, builder: (column) => column);

  GeneratedColumn<bool> get reversed =>
      $composableBuilder(column: $table.reversed, builder: (column) => column);

  GeneratedColumn<DateTime> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reversalReason => $composableBuilder(
    column: $table.reversalReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CashPoolsTableAnnotationComposer get poolId {
    final $$CashPoolsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.cashPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashPoolsTableAnnotationComposer(
            $db: $db,
            $table: $db.cashPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaymentAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaymentAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentAllocations,
          getReferencedColumn: (t) => t.paymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cashMovementsRefs<T extends Object>(
    Expression<T> Function($$CashMovementsTableAnnotationComposer a) f,
  ) {
    final $$CashMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovements,
      getReferencedColumn: (t) => t.relatedPaymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.cashMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({
            bool partyId,
            bool poolId,
            bool paymentAllocationsRefs,
            bool cashMovementsRefs,
          })
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<int> amountPaisa = const Value.absent(),
                Value<PaymentDirectionDb> direction = const Value.absent(),
                Value<String> poolId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isAdvance = const Value.absent(),
                Value<bool> reversed = const Value.absent(),
                Value<DateTime?> reversedAt = const Value.absent(),
                Value<String?> reversalReason = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                partyId: partyId,
                amountPaisa: amountPaisa,
                direction: direction,
                poolId: poolId,
                date: date,
                isAdvance: isAdvance,
                reversed: reversed,
                reversedAt: reversedAt,
                reversalReason: reversalReason,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String partyId,
                required int amountPaisa,
                required PaymentDirectionDb direction,
                required String poolId,
                required DateTime date,
                Value<bool> isAdvance = const Value.absent(),
                Value<bool> reversed = const Value.absent(),
                Value<DateTime?> reversedAt = const Value.absent(),
                Value<String?> reversalReason = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                partyId: partyId,
                amountPaisa: amountPaisa,
                direction: direction,
                poolId: poolId,
                date: date,
                isAdvance: isAdvance,
                reversed: reversed,
                reversedAt: reversedAt,
                reversalReason: reversalReason,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                partyId = false,
                poolId = false,
                paymentAllocationsRefs = false,
                cashMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentAllocationsRefs) db.paymentAllocations,
                    if (cashMovementsRefs) db.cashMovements,
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
                        if (partyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyId,
                                    referencedTable: $$PaymentsTableReferences
                                        ._partyIdTable(db),
                                    referencedColumn: $$PaymentsTableReferences
                                        ._partyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (poolId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.poolId,
                                    referencedTable: $$PaymentsTableReferences
                                        ._poolIdTable(db),
                                    referencedColumn: $$PaymentsTableReferences
                                        ._poolIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentAllocationsRefs)
                        await $_getPrefetchedData<
                          Payment,
                          $PaymentsTable,
                          PaymentAllocation
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentsTableReferences
                              ._paymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paymentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cashMovementsRefs)
                        await $_getPrefetchedData<
                          Payment,
                          $PaymentsTable,
                          CashMovement
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentsTableReferences
                              ._cashMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.relatedPaymentId == item.id,
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({
        bool partyId,
        bool poolId,
        bool paymentAllocationsRefs,
        bool cashMovementsRefs,
      })
    >;
typedef $$PaymentAllocationsTableCreateCompanionBuilder =
    PaymentAllocationsCompanion Function({
      required String id,
      required String paymentId,
      required String billId,
      required int amountAllocatedPaisa,
      Value<int> rowid,
    });
typedef $$PaymentAllocationsTableUpdateCompanionBuilder =
    PaymentAllocationsCompanion Function({
      Value<String> id,
      Value<String> paymentId,
      Value<String> billId,
      Value<int> amountAllocatedPaisa,
      Value<int> rowid,
    });

final class $$PaymentAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaymentAllocationsTable,
          PaymentAllocation
        > {
  $$PaymentAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias(
        $_aliasNameGenerator(db.paymentAllocations.paymentId, db.payments.id),
      );

  $$PaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<String>('payment_id')!;

    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BillsTable _billIdTable(_$AppDatabase db) => db.bills.createAlias(
    $_aliasNameGenerator(db.paymentAllocations.billId, db.bills.id),
  );

  $$BillsTableProcessedTableManager get billId {
    final $_column = $_itemColumn<String>('bill_id')!;

    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_billIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableFilterComposer({
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

  ColumnFilters<int> get amountAllocatedPaisa => $composableBuilder(
    column: $table.amountAllocatedPaisa,
    builder: (column) => ColumnFilters(column),
  );

  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableFilterComposer get billId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableOrderingComposer({
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

  ColumnOrderings<int> get amountAllocatedPaisa => $composableBuilder(
    column: $table.amountAllocatedPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableOrderingComposer get billId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountAllocatedPaisa => $composableBuilder(
    column: $table.amountAllocatedPaisa,
    builder: (column) => column,
  );

  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableAnnotationComposer get billId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.billId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentAllocationsTable,
          PaymentAllocation,
          $$PaymentAllocationsTableFilterComposer,
          $$PaymentAllocationsTableOrderingComposer,
          $$PaymentAllocationsTableAnnotationComposer,
          $$PaymentAllocationsTableCreateCompanionBuilder,
          $$PaymentAllocationsTableUpdateCompanionBuilder,
          (PaymentAllocation, $$PaymentAllocationsTableReferences),
          PaymentAllocation,
          PrefetchHooks Function({bool paymentId, bool billId})
        > {
  $$PaymentAllocationsTableTableManager(
    _$AppDatabase db,
    $PaymentAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> billId = const Value.absent(),
                Value<int> amountAllocatedPaisa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentAllocationsCompanion(
                id: id,
                paymentId: paymentId,
                billId: billId,
                amountAllocatedPaisa: amountAllocatedPaisa,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String paymentId,
                required String billId,
                required int amountAllocatedPaisa,
                Value<int> rowid = const Value.absent(),
              }) => PaymentAllocationsCompanion.insert(
                id: id,
                paymentId: paymentId,
                billId: billId,
                amountAllocatedPaisa: amountAllocatedPaisa,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentId = false, billId = false}) {
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
                    if (paymentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.paymentId,
                                referencedTable:
                                    $$PaymentAllocationsTableReferences
                                        ._paymentIdTable(db),
                                referencedColumn:
                                    $$PaymentAllocationsTableReferences
                                        ._paymentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (billId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.billId,
                                referencedTable:
                                    $$PaymentAllocationsTableReferences
                                        ._billIdTable(db),
                                referencedColumn:
                                    $$PaymentAllocationsTableReferences
                                        ._billIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$PaymentAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentAllocationsTable,
      PaymentAllocation,
      $$PaymentAllocationsTableFilterComposer,
      $$PaymentAllocationsTableOrderingComposer,
      $$PaymentAllocationsTableAnnotationComposer,
      $$PaymentAllocationsTableCreateCompanionBuilder,
      $$PaymentAllocationsTableUpdateCompanionBuilder,
      (PaymentAllocation, $$PaymentAllocationsTableReferences),
      PaymentAllocation,
      PrefetchHooks Function({bool paymentId, bool billId})
    >;
typedef $$CashMovementsTableCreateCompanionBuilder =
    CashMovementsCompanion Function({
      required String id,
      required String poolId,
      required CashDirectionDb direction,
      required int amountPaisa,
      required DateTime date,
      Value<int> sequence,
      Value<String?> transferId,
      Value<String?> pairedMovementId,
      Value<String?> relatedBillId,
      Value<String?> relatedPaymentId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CashMovementsTableUpdateCompanionBuilder =
    CashMovementsCompanion Function({
      Value<String> id,
      Value<String> poolId,
      Value<CashDirectionDb> direction,
      Value<int> amountPaisa,
      Value<DateTime> date,
      Value<int> sequence,
      Value<String?> transferId,
      Value<String?> pairedMovementId,
      Value<String?> relatedBillId,
      Value<String?> relatedPaymentId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CashMovementsTableReferences
    extends BaseReferences<_$AppDatabase, $CashMovementsTable, CashMovement> {
  $$CashMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CashPoolsTable _poolIdTable(_$AppDatabase db) =>
      db.cashPools.createAlias(
        $_aliasNameGenerator(db.cashMovements.poolId, db.cashPools.id),
      );

  $$CashPoolsTableProcessedTableManager get poolId {
    final $_column = $_itemColumn<String>('pool_id')!;

    final manager = $$CashPoolsTableTableManager(
      $_db,
      $_db.cashPools,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poolIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BillsTable _relatedBillIdTable(_$AppDatabase db) =>
      db.bills.createAlias(
        $_aliasNameGenerator(db.cashMovements.relatedBillId, db.bills.id),
      );

  $$BillsTableProcessedTableManager? get relatedBillId {
    final $_column = $_itemColumn<String>('related_bill_id');
    if ($_column == null) return null;
    final manager = $$BillsTableTableManager(
      $_db,
      $_db.bills,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_relatedBillIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentsTable _relatedPaymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias(
        $_aliasNameGenerator(db.cashMovements.relatedPaymentId, db.payments.id),
      );

  $$PaymentsTableProcessedTableManager? get relatedPaymentId {
    final $_column = $_itemColumn<String>('related_payment_id');
    if ($_column == null) return null;
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_relatedPaymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CashMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<CashDirectionDb, CashDirectionDb, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pairedMovementId => $composableBuilder(
    column: $table.pairedMovementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CashPoolsTableFilterComposer get poolId {
    final $$CashPoolsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.cashPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashPoolsTableFilterComposer(
            $db: $db,
            $table: $db.cashPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableFilterComposer get relatedBillId {
    final $$BillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedBillId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableFilterComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentsTableFilterComposer get relatedPaymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedPaymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableOrderingComposer({
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

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pairedMovementId => $composableBuilder(
    column: $table.pairedMovementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CashPoolsTableOrderingComposer get poolId {
    final $$CashPoolsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.cashPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashPoolsTableOrderingComposer(
            $db: $db,
            $table: $db.cashPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableOrderingComposer get relatedBillId {
    final $$BillsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedBillId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableOrderingComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentsTableOrderingComposer get relatedPaymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedPaymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementsTable> {
  $$CashMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CashDirectionDb, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pairedMovementId => $composableBuilder(
    column: $table.pairedMovementId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CashPoolsTableAnnotationComposer get poolId {
    final $$CashPoolsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.cashPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashPoolsTableAnnotationComposer(
            $db: $db,
            $table: $db.cashPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BillsTableAnnotationComposer get relatedBillId {
    final $$BillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedBillId,
      referencedTable: $db.bills,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BillsTableAnnotationComposer(
            $db: $db,
            $table: $db.bills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentsTableAnnotationComposer get relatedPaymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedPaymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashMovementsTable,
          CashMovement,
          $$CashMovementsTableFilterComposer,
          $$CashMovementsTableOrderingComposer,
          $$CashMovementsTableAnnotationComposer,
          $$CashMovementsTableCreateCompanionBuilder,
          $$CashMovementsTableUpdateCompanionBuilder,
          (CashMovement, $$CashMovementsTableReferences),
          CashMovement,
          PrefetchHooks Function({
            bool poolId,
            bool relatedBillId,
            bool relatedPaymentId,
          })
        > {
  $$CashMovementsTableTableManager(_$AppDatabase db, $CashMovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> poolId = const Value.absent(),
                Value<CashDirectionDb> direction = const Value.absent(),
                Value<int> amountPaisa = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String?> transferId = const Value.absent(),
                Value<String?> pairedMovementId = const Value.absent(),
                Value<String?> relatedBillId = const Value.absent(),
                Value<String?> relatedPaymentId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion(
                id: id,
                poolId: poolId,
                direction: direction,
                amountPaisa: amountPaisa,
                date: date,
                sequence: sequence,
                transferId: transferId,
                pairedMovementId: pairedMovementId,
                relatedBillId: relatedBillId,
                relatedPaymentId: relatedPaymentId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String poolId,
                required CashDirectionDb direction,
                required int amountPaisa,
                required DateTime date,
                Value<int> sequence = const Value.absent(),
                Value<String?> transferId = const Value.absent(),
                Value<String?> pairedMovementId = const Value.absent(),
                Value<String?> relatedBillId = const Value.absent(),
                Value<String?> relatedPaymentId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementsCompanion.insert(
                id: id,
                poolId: poolId,
                direction: direction,
                amountPaisa: amountPaisa,
                date: date,
                sequence: sequence,
                transferId: transferId,
                pairedMovementId: pairedMovementId,
                relatedBillId: relatedBillId,
                relatedPaymentId: relatedPaymentId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CashMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                poolId = false,
                relatedBillId = false,
                relatedPaymentId = false,
              }) {
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
                        if (poolId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.poolId,
                                    referencedTable:
                                        $$CashMovementsTableReferences
                                            ._poolIdTable(db),
                                    referencedColumn:
                                        $$CashMovementsTableReferences
                                            ._poolIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (relatedBillId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.relatedBillId,
                                    referencedTable:
                                        $$CashMovementsTableReferences
                                            ._relatedBillIdTable(db),
                                    referencedColumn:
                                        $$CashMovementsTableReferences
                                            ._relatedBillIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (relatedPaymentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.relatedPaymentId,
                                    referencedTable:
                                        $$CashMovementsTableReferences
                                            ._relatedPaymentIdTable(db),
                                    referencedColumn:
                                        $$CashMovementsTableReferences
                                            ._relatedPaymentIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$CashMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashMovementsTable,
      CashMovement,
      $$CashMovementsTableFilterComposer,
      $$CashMovementsTableOrderingComposer,
      $$CashMovementsTableAnnotationComposer,
      $$CashMovementsTableCreateCompanionBuilder,
      $$CashMovementsTableUpdateCompanionBuilder,
      (CashMovement, $$CashMovementsTableReferences),
      CashMovement,
      PrefetchHooks Function({
        bool poolId,
        bool relatedBillId,
        bool relatedPaymentId,
      })
    >;
typedef $$StockWriteOffsTableCreateCompanionBuilder =
    StockWriteOffsCompanion Function({
      required String id,
      required String parentCategoryId,
      required int weightGrams,
      required WriteOffModeDb mode,
      Value<String?> relatedExpenseCategoryId,
      Value<int> expensePaisa,
      Value<String?> note,
      required DateTime date,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$StockWriteOffsTableUpdateCompanionBuilder =
    StockWriteOffsCompanion Function({
      Value<String> id,
      Value<String> parentCategoryId,
      Value<int> weightGrams,
      Value<WriteOffModeDb> mode,
      Value<String?> relatedExpenseCategoryId,
      Value<int> expensePaisa,
      Value<String?> note,
      Value<DateTime> date,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$StockWriteOffsTableReferences
    extends BaseReferences<_$AppDatabase, $StockWriteOffsTable, StockWriteOff> {
  $$StockWriteOffsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StockCategoriesTable _parentCategoryIdTable(_$AppDatabase db) =>
      db.stockCategories.createAlias(
        $_aliasNameGenerator(
          db.stockWriteOffs.parentCategoryId,
          db.stockCategories.id,
        ),
      );

  $$StockCategoriesTableProcessedTableManager get parentCategoryId {
    final $_column = $_itemColumn<String>('parent_category_id')!;

    final manager = $$StockCategoriesTableTableManager(
      $_db,
      $_db.stockCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpenseCategoriesTable _relatedExpenseCategoryIdTable(
    _$AppDatabase db,
  ) => db.expenseCategories.createAlias(
    $_aliasNameGenerator(
      db.stockWriteOffs.relatedExpenseCategoryId,
      db.expenseCategories.id,
    ),
  );

  $$ExpenseCategoriesTableProcessedTableManager? get relatedExpenseCategoryId {
    final $_column = $_itemColumn<String>('related_expense_category_id');
    if ($_column == null) return null;
    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _relatedExpenseCategoryIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockWriteOffsTableFilterComposer
    extends Composer<_$AppDatabase, $StockWriteOffsTable> {
  $$StockWriteOffsTableFilterComposer({
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

  ColumnFilters<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WriteOffModeDb, WriteOffModeDb, String>
  get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get expensePaisa => $composableBuilder(
    column: $table.expensePaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StockCategoriesTableFilterComposer get parentCategoryId {
    final $$StockCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableFilterComposer get relatedExpenseCategoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedExpenseCategoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockWriteOffsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockWriteOffsTable> {
  $$StockWriteOffsTableOrderingComposer({
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

  ColumnOrderings<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expensePaisa => $composableBuilder(
    column: $table.expensePaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockCategoriesTableOrderingComposer get parentCategoryId {
    final $$StockCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableOrderingComposer get relatedExpenseCategoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedExpenseCategoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockWriteOffsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockWriteOffsTable> {
  $$StockWriteOffsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WriteOffModeDb, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get expensePaisa => $composableBuilder(
    column: $table.expensePaisa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$StockCategoriesTableAnnotationComposer get parentCategoryId {
    final $$StockCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentCategoryId,
      referencedTable: $db.stockCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableAnnotationComposer get relatedExpenseCategoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.relatedExpenseCategoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StockWriteOffsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockWriteOffsTable,
          StockWriteOff,
          $$StockWriteOffsTableFilterComposer,
          $$StockWriteOffsTableOrderingComposer,
          $$StockWriteOffsTableAnnotationComposer,
          $$StockWriteOffsTableCreateCompanionBuilder,
          $$StockWriteOffsTableUpdateCompanionBuilder,
          (StockWriteOff, $$StockWriteOffsTableReferences),
          StockWriteOff,
          PrefetchHooks Function({
            bool parentCategoryId,
            bool relatedExpenseCategoryId,
          })
        > {
  $$StockWriteOffsTableTableManager(
    _$AppDatabase db,
    $StockWriteOffsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockWriteOffsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockWriteOffsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockWriteOffsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> parentCategoryId = const Value.absent(),
                Value<int> weightGrams = const Value.absent(),
                Value<WriteOffModeDb> mode = const Value.absent(),
                Value<String?> relatedExpenseCategoryId = const Value.absent(),
                Value<int> expensePaisa = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockWriteOffsCompanion(
                id: id,
                parentCategoryId: parentCategoryId,
                weightGrams: weightGrams,
                mode: mode,
                relatedExpenseCategoryId: relatedExpenseCategoryId,
                expensePaisa: expensePaisa,
                note: note,
                date: date,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String parentCategoryId,
                required int weightGrams,
                required WriteOffModeDb mode,
                Value<String?> relatedExpenseCategoryId = const Value.absent(),
                Value<int> expensePaisa = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime date,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockWriteOffsCompanion.insert(
                id: id,
                parentCategoryId: parentCategoryId,
                weightGrams: weightGrams,
                mode: mode,
                relatedExpenseCategoryId: relatedExpenseCategoryId,
                expensePaisa: expensePaisa,
                note: note,
                date: date,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockWriteOffsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({parentCategoryId = false, relatedExpenseCategoryId = false}) {
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
                        if (parentCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentCategoryId,
                                    referencedTable:
                                        $$StockWriteOffsTableReferences
                                            ._parentCategoryIdTable(db),
                                    referencedColumn:
                                        $$StockWriteOffsTableReferences
                                            ._parentCategoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (relatedExpenseCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.relatedExpenseCategoryId,
                                    referencedTable:
                                        $$StockWriteOffsTableReferences
                                            ._relatedExpenseCategoryIdTable(db),
                                    referencedColumn:
                                        $$StockWriteOffsTableReferences
                                            ._relatedExpenseCategoryIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$StockWriteOffsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockWriteOffsTable,
      StockWriteOff,
      $$StockWriteOffsTableFilterComposer,
      $$StockWriteOffsTableOrderingComposer,
      $$StockWriteOffsTableAnnotationComposer,
      $$StockWriteOffsTableCreateCompanionBuilder,
      $$StockWriteOffsTableUpdateCompanionBuilder,
      (StockWriteOff, $$StockWriteOffsTableReferences),
      StockWriteOff,
      PrefetchHooks Function({
        bool parentCategoryId,
        bool relatedExpenseCategoryId,
      })
    >;
typedef $$UpdateHistoriesTableCreateCompanionBuilder =
    UpdateHistoriesCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String fieldChanged,
      Value<String?> oldValue,
      Value<String?> newValue,
      required DateTime changedAt,
      Value<int> rowid,
    });
typedef $$UpdateHistoriesTableUpdateCompanionBuilder =
    UpdateHistoriesCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> fieldChanged,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<DateTime> changedAt,
      Value<int> rowid,
    });

class $$UpdateHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTable> {
  $$UpdateHistoriesTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldChanged => $composableBuilder(
    column: $table.fieldChanged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UpdateHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTable> {
  $$UpdateHistoriesTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldChanged => $composableBuilder(
    column: $table.fieldChanged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UpdateHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTable> {
  $$UpdateHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get fieldChanged => $composableBuilder(
    column: $table.fieldChanged,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);
}

class $$UpdateHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UpdateHistoriesTable,
          UpdateHistory,
          $$UpdateHistoriesTableFilterComposer,
          $$UpdateHistoriesTableOrderingComposer,
          $$UpdateHistoriesTableAnnotationComposer,
          $$UpdateHistoriesTableCreateCompanionBuilder,
          $$UpdateHistoriesTableUpdateCompanionBuilder,
          (
            UpdateHistory,
            BaseReferences<_$AppDatabase, $UpdateHistoriesTable, UpdateHistory>,
          ),
          UpdateHistory,
          PrefetchHooks Function()
        > {
  $$UpdateHistoriesTableTableManager(
    _$AppDatabase db,
    $UpdateHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UpdateHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UpdateHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UpdateHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> fieldChanged = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UpdateHistoriesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                fieldChanged: fieldChanged,
                oldValue: oldValue,
                newValue: newValue,
                changedAt: changedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String fieldChanged,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                required DateTime changedAt,
                Value<int> rowid = const Value.absent(),
              }) => UpdateHistoriesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                fieldChanged: fieldChanged,
                oldValue: oldValue,
                newValue: newValue,
                changedAt: changedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UpdateHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UpdateHistoriesTable,
      UpdateHistory,
      $$UpdateHistoriesTableFilterComposer,
      $$UpdateHistoriesTableOrderingComposer,
      $$UpdateHistoriesTableAnnotationComposer,
      $$UpdateHistoriesTableCreateCompanionBuilder,
      $$UpdateHistoriesTableUpdateCompanionBuilder,
      (
        UpdateHistory,
        BaseReferences<_$AppDatabase, $UpdateHistoriesTable, UpdateHistory>,
      ),
      UpdateHistory,
      PrefetchHooks Function()
    >;
typedef $$TrashRecordsTableCreateCompanionBuilder =
    TrashRecordsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required DateTime deletedAt,
      required DateTime purgeAt,
      Value<int> rowid,
    });
typedef $$TrashRecordsTableUpdateCompanionBuilder =
    TrashRecordsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<DateTime> deletedAt,
      Value<DateTime> purgeAt,
      Value<int> rowid,
    });

class $$TrashRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TrashRecordsTable> {
  $$TrashRecordsTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purgeAt => $composableBuilder(
    column: $table.purgeAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrashRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrashRecordsTable> {
  $$TrashRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purgeAt => $composableBuilder(
    column: $table.purgeAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrashRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrashRecordsTable> {
  $$TrashRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get purgeAt =>
      $composableBuilder(column: $table.purgeAt, builder: (column) => column);
}

class $$TrashRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrashRecordsTable,
          TrashRecord,
          $$TrashRecordsTableFilterComposer,
          $$TrashRecordsTableOrderingComposer,
          $$TrashRecordsTableAnnotationComposer,
          $$TrashRecordsTableCreateCompanionBuilder,
          $$TrashRecordsTableUpdateCompanionBuilder,
          (
            TrashRecord,
            BaseReferences<_$AppDatabase, $TrashRecordsTable, TrashRecord>,
          ),
          TrashRecord,
          PrefetchHooks Function()
        > {
  $$TrashRecordsTableTableManager(_$AppDatabase db, $TrashRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrashRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrashRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrashRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<DateTime> purgeAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrashRecordsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                purgeAt: purgeAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required DateTime deletedAt,
                required DateTime purgeAt,
                Value<int> rowid = const Value.absent(),
              }) => TrashRecordsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                purgeAt: purgeAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrashRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrashRecordsTable,
      TrashRecord,
      $$TrashRecordsTableFilterComposer,
      $$TrashRecordsTableOrderingComposer,
      $$TrashRecordsTableAnnotationComposer,
      $$TrashRecordsTableCreateCompanionBuilder,
      $$TrashRecordsTableUpdateCompanionBuilder,
      (
        TrashRecord,
        BaseReferences<_$AppDatabase, $TrashRecordsTable, TrashRecord>,
      ),
      TrashRecord,
      PrefetchHooks Function()
    >;
typedef $$DayZeroMigrationsTableCreateCompanionBuilder =
    DayZeroMigrationsCompanion Function({
      required String id,
      required DateTime performedAt,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$DayZeroMigrationsTableUpdateCompanionBuilder =
    DayZeroMigrationsCompanion Function({
      Value<String> id,
      Value<DateTime> performedAt,
      Value<String?> note,
      Value<int> rowid,
    });

class $$DayZeroMigrationsTableFilterComposer
    extends Composer<_$AppDatabase, $DayZeroMigrationsTable> {
  $$DayZeroMigrationsTableFilterComposer({
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

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayZeroMigrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DayZeroMigrationsTable> {
  $$DayZeroMigrationsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayZeroMigrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayZeroMigrationsTable> {
  $$DayZeroMigrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DayZeroMigrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayZeroMigrationsTable,
          DayZeroMigration,
          $$DayZeroMigrationsTableFilterComposer,
          $$DayZeroMigrationsTableOrderingComposer,
          $$DayZeroMigrationsTableAnnotationComposer,
          $$DayZeroMigrationsTableCreateCompanionBuilder,
          $$DayZeroMigrationsTableUpdateCompanionBuilder,
          (
            DayZeroMigration,
            BaseReferences<
              _$AppDatabase,
              $DayZeroMigrationsTable,
              DayZeroMigration
            >,
          ),
          DayZeroMigration,
          PrefetchHooks Function()
        > {
  $$DayZeroMigrationsTableTableManager(
    _$AppDatabase db,
    $DayZeroMigrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayZeroMigrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayZeroMigrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayZeroMigrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayZeroMigrationsCompanion(
                id: id,
                performedAt: performedAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime performedAt,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayZeroMigrationsCompanion.insert(
                id: id,
                performedAt: performedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayZeroMigrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayZeroMigrationsTable,
      DayZeroMigration,
      $$DayZeroMigrationsTableFilterComposer,
      $$DayZeroMigrationsTableOrderingComposer,
      $$DayZeroMigrationsTableAnnotationComposer,
      $$DayZeroMigrationsTableCreateCompanionBuilder,
      $$DayZeroMigrationsTableUpdateCompanionBuilder,
      (
        DayZeroMigration,
        BaseReferences<
          _$AppDatabase,
          $DayZeroMigrationsTable,
          DayZeroMigration
        >,
      ),
      DayZeroMigration,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$StockCategoriesTableTableManager get stockCategories =>
      $$StockCategoriesTableTableManager(_db, _db.stockCategories);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$BillsTableTableManager get bills =>
      $$BillsTableTableManager(_db, _db.bills);
  $$BillLineItemsTableTableManager get billLineItems =>
      $$BillLineItemsTableTableManager(_db, _db.billLineItems);
  $$CashPoolsTableTableManager get cashPools =>
      $$CashPoolsTableTableManager(_db, _db.cashPools);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PaymentAllocationsTableTableManager get paymentAllocations =>
      $$PaymentAllocationsTableTableManager(_db, _db.paymentAllocations);
  $$CashMovementsTableTableManager get cashMovements =>
      $$CashMovementsTableTableManager(_db, _db.cashMovements);
  $$StockWriteOffsTableTableManager get stockWriteOffs =>
      $$StockWriteOffsTableTableManager(_db, _db.stockWriteOffs);
  $$UpdateHistoriesTableTableManager get updateHistories =>
      $$UpdateHistoriesTableTableManager(_db, _db.updateHistories);
  $$TrashRecordsTableTableManager get trashRecords =>
      $$TrashRecordsTableTableManager(_db, _db.trashRecords);
  $$DayZeroMigrationsTableTableManager get dayZeroMigrations =>
      $$DayZeroMigrationsTableTableManager(_db, _db.dayZeroMigrations);
}
