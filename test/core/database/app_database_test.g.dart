// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database_test.dart';

// ignore_for_file: type=lint
class $CurrenciesTable extends Currencies
    with TableInfo<$CurrenciesTable, Currency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minorUnitScaleMeta = const VerificationMeta(
    'minorUnitScale',
  );
  @override
  late final GeneratedColumn<int> minorUnitScale = GeneratedColumn<int>(
    'minor_unit_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, minorUnitScale, displayName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Currency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('currency_code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['currency_code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('minor_unit_scale')) {
      context.handle(
        _minorUnitScaleMeta,
        minorUnitScale.isAcceptableOrUnknown(
          data['minor_unit_scale']!,
          _minorUnitScaleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minorUnitScaleMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Currency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Currency(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      minorUnitScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minor_unit_scale'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
    );
  }

  @override
  $CurrenciesTable createAlias(String alias) {
    return $CurrenciesTable(attachedDatabase, alias);
  }
}

class Currency extends DataClass implements Insertable<Currency> {
  final String code;
  final int minorUnitScale;
  final String displayName;
  const Currency({
    required this.code,
    required this.minorUnitScale,
    required this.displayName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['currency_code'] = Variable<String>(code);
    map['minor_unit_scale'] = Variable<int>(minorUnitScale);
    map['display_name'] = Variable<String>(displayName);
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      code: Value(code),
      minorUnitScale: Value(minorUnitScale),
      displayName: Value(displayName),
    );
  }

  factory Currency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Currency(
      code: serializer.fromJson<String>(json['code']),
      minorUnitScale: serializer.fromJson<int>(json['minorUnitScale']),
      displayName: serializer.fromJson<String>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'minorUnitScale': serializer.toJson<int>(minorUnitScale),
      'displayName': serializer.toJson<String>(displayName),
    };
  }

  Currency copyWith({String? code, int? minorUnitScale, String? displayName}) =>
      Currency(
        code: code ?? this.code,
        minorUnitScale: minorUnitScale ?? this.minorUnitScale,
        displayName: displayName ?? this.displayName,
      );
  Currency copyWithCompanion(CurrenciesCompanion data) {
    return Currency(
      code: data.code.present ? data.code.value : this.code,
      minorUnitScale: data.minorUnitScale.present
          ? data.minorUnitScale.value
          : this.minorUnitScale,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Currency(')
          ..write('code: $code, ')
          ..write('minorUnitScale: $minorUnitScale, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, minorUnitScale, displayName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Currency &&
          other.code == this.code &&
          other.minorUnitScale == this.minorUnitScale &&
          other.displayName == this.displayName);
}

class CurrenciesCompanion extends UpdateCompanion<Currency> {
  final Value<String> code;
  final Value<int> minorUnitScale;
  final Value<String> displayName;
  final Value<int> rowid;
  const CurrenciesCompanion({
    this.code = const Value.absent(),
    this.minorUnitScale = const Value.absent(),
    this.displayName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    required String code,
    required int minorUnitScale,
    required String displayName,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       minorUnitScale = Value(minorUnitScale),
       displayName = Value(displayName);
  static Insertable<Currency> custom({
    Expression<String>? code,
    Expression<int>? minorUnitScale,
    Expression<String>? displayName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'currency_code': code,
      if (minorUnitScale != null) 'minor_unit_scale': minorUnitScale,
      if (displayName != null) 'display_name': displayName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrenciesCompanion copyWith({
    Value<String>? code,
    Value<int>? minorUnitScale,
    Value<String>? displayName,
    Value<int>? rowid,
  }) {
    return CurrenciesCompanion(
      code: code ?? this.code,
      minorUnitScale: minorUnitScale ?? this.minorUnitScale,
      displayName: displayName ?? this.displayName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['currency_code'] = Variable<String>(code.value);
    }
    if (minorUnitScale.present) {
      map['minor_unit_scale'] = Variable<int>(minorUnitScale.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrenciesCompanion(')
          ..write('code: $code, ')
          ..write('minorUnitScale: $minorUnitScale, ')
          ..write('displayName: $displayName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, displayName, createdAt, updatedAt];
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
    if (data.containsKey('party_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['party_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
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
        data['${effectivePrefix}party_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Party({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['party_id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Party copyWith({
    String? id,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Party(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String displayName,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'party_id': id,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['party_id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartyRolesTable extends PartyRoles
    with TableInfo<$PartyRolesTable, PartyRole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartyRolesTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [partyId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'party_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyRole> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {partyId, role};
  @override
  PartyRole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyRole(
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $PartyRolesTable createAlias(String alias) {
    return $PartyRolesTable(attachedDatabase, alias);
  }
}

class PartyRole extends DataClass implements Insertable<PartyRole> {
  final String partyId;
  final String role;
  const PartyRole({required this.partyId, required this.role});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['party_id'] = Variable<String>(partyId);
    map['role'] = Variable<String>(role);
    return map;
  }

  PartyRolesCompanion toCompanion(bool nullToAbsent) {
    return PartyRolesCompanion(partyId: Value(partyId), role: Value(role));
  }

  factory PartyRole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyRole(
      partyId: serializer.fromJson<String>(json['partyId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'partyId': serializer.toJson<String>(partyId),
      'role': serializer.toJson<String>(role),
    };
  }

  PartyRole copyWith({String? partyId, String? role}) =>
      PartyRole(partyId: partyId ?? this.partyId, role: role ?? this.role);
  PartyRole copyWithCompanion(PartyRolesCompanion data) {
    return PartyRole(
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyRole(')
          ..write('partyId: $partyId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(partyId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyRole &&
          other.partyId == this.partyId &&
          other.role == this.role);
}

class PartyRolesCompanion extends UpdateCompanion<PartyRole> {
  final Value<String> partyId;
  final Value<String> role;
  final Value<int> rowid;
  const PartyRolesCompanion({
    this.partyId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartyRolesCompanion.insert({
    required String partyId,
    required String role,
    this.rowid = const Value.absent(),
  }) : partyId = Value(partyId),
       role = Value(role);
  static Insertable<PartyRole> custom({
    Expression<String>? partyId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (partyId != null) 'party_id': partyId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartyRolesCompanion copyWith({
    Value<String>? partyId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return PartyRolesCompanion(
      partyId: partyId ?? this.partyId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartyRolesCompanion(')
          ..write('partyId: $partyId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialAccountsTable extends FinancialAccounts
    with TableInfo<$FinancialAccountsTable, FinancialAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'account_id',
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
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    partyId,
    role,
    currencyCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['account_id']!, _idMeta),
      );
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
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, partyId, role, currencyCode},
  ];
  @override
  FinancialAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FinancialAccountsTable createAlias(String alias) {
    return $FinancialAccountsTable(attachedDatabase, alias);
  }
}

class FinancialAccount extends DataClass
    implements Insertable<FinancialAccount> {
  final String id;
  final String partyId;
  final String role;
  final String currencyCode;
  final DateTime createdAt;
  const FinancialAccount({
    required this.id,
    required this.partyId,
    required this.role,
    required this.currencyCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(id);
    map['party_id'] = Variable<String>(partyId);
    map['role'] = Variable<String>(role);
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FinancialAccountsCompanion toCompanion(bool nullToAbsent) {
    return FinancialAccountsCompanion(
      id: Value(id),
      partyId: Value(partyId),
      role: Value(role),
      currencyCode: Value(currencyCode),
      createdAt: Value(createdAt),
    );
  }

  factory FinancialAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialAccount(
      id: serializer.fromJson<String>(json['id']),
      partyId: serializer.fromJson<String>(json['partyId']),
      role: serializer.fromJson<String>(json['role']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'partyId': serializer.toJson<String>(partyId),
      'role': serializer.toJson<String>(role),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FinancialAccount copyWith({
    String? id,
    String? partyId,
    String? role,
    String? currencyCode,
    DateTime? createdAt,
  }) => FinancialAccount(
    id: id ?? this.id,
    partyId: partyId ?? this.partyId,
    role: role ?? this.role,
    currencyCode: currencyCode ?? this.currencyCode,
    createdAt: createdAt ?? this.createdAt,
  );
  FinancialAccount copyWithCompanion(FinancialAccountsCompanion data) {
    return FinancialAccount(
      id: data.id.present ? data.id.value : this.id,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      role: data.role.present ? data.role.value : this.role,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialAccount(')
          ..write('id: $id, ')
          ..write('partyId: $partyId, ')
          ..write('role: $role, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partyId, role, currencyCode, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialAccount &&
          other.id == this.id &&
          other.partyId == this.partyId &&
          other.role == this.role &&
          other.currencyCode == this.currencyCode &&
          other.createdAt == this.createdAt);
}

class FinancialAccountsCompanion extends UpdateCompanion<FinancialAccount> {
  final Value<String> id;
  final Value<String> partyId;
  final Value<String> role;
  final Value<String> currencyCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FinancialAccountsCompanion({
    this.id = const Value.absent(),
    this.partyId = const Value.absent(),
    this.role = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialAccountsCompanion.insert({
    required String id,
    required String partyId,
    required String role,
    required String currencyCode,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       partyId = Value(partyId),
       role = Value(role),
       currencyCode = Value(currencyCode),
       createdAt = Value(createdAt);
  static Insertable<FinancialAccount> custom({
    Expression<String>? id,
    Expression<String>? partyId,
    Expression<String>? role,
    Expression<String>? currencyCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'account_id': id,
      if (partyId != null) 'party_id': partyId,
      if (role != null) 'role': role,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? partyId,
    Value<String>? role,
    Value<String>? currencyCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FinancialAccountsCompanion(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      role: role ?? this.role,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['account_id'] = Variable<String>(id.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialAccountsCompanion(')
          ..write('id: $id, ')
          ..write('partyId: $partyId, ')
          ..write('role: $role, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
    'invoice_serial',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legacyRecordKeyMeta = const VerificationMeta(
    'legacyRecordKey',
  );
  @override
  late final GeneratedColumn<String> legacyRecordKey = GeneratedColumn<String>(
    'legacy_record_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legacyInvoiceIdMeta = const VerificationMeta(
    'legacyInvoiceId',
  );
  @override
  late final GeneratedColumn<String> legacyInvoiceId = GeneratedColumn<String>(
    'legacy_invoice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceJsonMeta = const VerificationMeta(
    'sourceJson',
  );
  @override
  late final GeneratedColumn<String> sourceJson = GeneratedColumn<String>(
    'source_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  );
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _financialAccountIdMeta =
      const VerificationMeta('financialAccountId');
  @override
  late final GeneratedColumn<String> financialAccountId =
      GeneratedColumn<String>(
        'financial_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK ("action" IN (\'sale\', \'purchase\', \'storage\', \'unknown\'))',
  );
  static const VerificationMeta _legacyActionMeta = const VerificationMeta(
    'legacyAction',
  );
  @override
  late final GeneratedColumn<String> legacyAction = GeneratedColumn<String>(
    'legacy_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMinorMeta = const VerificationMeta(
    'totalMinor',
  );
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
    'total_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legacyTotalValueMeta = const VerificationMeta(
    'legacyTotalValue',
  );
  @override
  late final GeneratedColumn<String> legacyTotalValue = GeneratedColumn<String>(
    'legacy_total_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legacyPaidValueMeta = const VerificationMeta(
    'legacyPaidValue',
  );
  @override
  late final GeneratedColumn<String> legacyPaidValue = GeneratedColumn<String>(
    'legacy_paid_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legacyRemainingValueMeta =
      const VerificationMeta('legacyRemainingValue');
  @override
  late final GeneratedColumn<String> legacyRemainingValue =
      GeneratedColumn<String>(
        'legacy_remaining_value',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serial,
    legacyRecordKey,
    legacyInvoiceId,
    sourceJson,
    partyId,
    partyRole,
    financialAccountId,
    currencyCode,
    action,
    legacyAction,
    totalMinor,
    legacyTotalValue,
    legacyPaidValue,
    legacyRemainingValue,
    issuedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Invoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('invoice_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['invoice_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['invoice_serial']!, _serialMeta),
      );
    } else if (isInserting) {
      context.missing(_serialMeta);
    }
    if (data.containsKey('legacy_record_key')) {
      context.handle(
        _legacyRecordKeyMeta,
        legacyRecordKey.isAcceptableOrUnknown(
          data['legacy_record_key']!,
          _legacyRecordKeyMeta,
        ),
      );
    }
    if (data.containsKey('legacy_invoice_id')) {
      context.handle(
        _legacyInvoiceIdMeta,
        legacyInvoiceId.isAcceptableOrUnknown(
          data['legacy_invoice_id']!,
          _legacyInvoiceIdMeta,
        ),
      );
    }
    if (data.containsKey('source_json')) {
      context.handle(
        _sourceJsonMeta,
        sourceJson.isAcceptableOrUnknown(data['source_json']!, _sourceJsonMeta),
      );
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    }
    if (data.containsKey('financial_account_id')) {
      context.handle(
        _financialAccountIdMeta,
        financialAccountId.isAcceptableOrUnknown(
          data['financial_account_id']!,
          _financialAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('legacy_action')) {
      context.handle(
        _legacyActionMeta,
        legacyAction.isAcceptableOrUnknown(
          data['legacy_action']!,
          _legacyActionMeta,
        ),
      );
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    }
    if (data.containsKey('legacy_total_value')) {
      context.handle(
        _legacyTotalValueMeta,
        legacyTotalValue.isAcceptableOrUnknown(
          data['legacy_total_value']!,
          _legacyTotalValueMeta,
        ),
      );
    }
    if (data.containsKey('legacy_paid_value')) {
      context.handle(
        _legacyPaidValueMeta,
        legacyPaidValue.isAcceptableOrUnknown(
          data['legacy_paid_value']!,
          _legacyPaidValueMeta,
        ),
      );
    }
    if (data.containsKey('legacy_remaining_value')) {
      context.handle(
        _legacyRemainingValueMeta,
        legacyRemainingValue.isAcceptableOrUnknown(
          data['legacy_remaining_value']!,
          _legacyRemainingValueMeta,
        ),
      );
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {legacyRecordKey},
    {id, currencyCode},
  ];
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_serial'],
      )!,
      legacyRecordKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_record_key'],
      ),
      legacyInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_invoice_id'],
      ),
      sourceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_json'],
      ),
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      ),
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      ),
      financialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_account_id'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      legacyAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_action'],
      ),
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      ),
      legacyTotalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_total_value'],
      ),
      legacyPaidValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_paid_value'],
      ),
      legacyRemainingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_remaining_value'],
      ),
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String serial;
  final String? legacyRecordKey;
  final String? legacyInvoiceId;
  final String? sourceJson;
  final String? partyId;
  final String? partyRole;
  final String? financialAccountId;
  final String? currencyCode;
  final String action;
  final String? legacyAction;
  final int? totalMinor;
  final String? legacyTotalValue;
  final String? legacyPaidValue;
  final String? legacyRemainingValue;
  final DateTime? issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Invoice({
    required this.id,
    required this.serial,
    this.legacyRecordKey,
    this.legacyInvoiceId,
    this.sourceJson,
    this.partyId,
    this.partyRole,
    this.financialAccountId,
    this.currencyCode,
    required this.action,
    this.legacyAction,
    this.totalMinor,
    this.legacyTotalValue,
    this.legacyPaidValue,
    this.legacyRemainingValue,
    this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['invoice_id'] = Variable<String>(id);
    map['invoice_serial'] = Variable<String>(serial);
    if (!nullToAbsent || legacyRecordKey != null) {
      map['legacy_record_key'] = Variable<String>(legacyRecordKey);
    }
    if (!nullToAbsent || legacyInvoiceId != null) {
      map['legacy_invoice_id'] = Variable<String>(legacyInvoiceId);
    }
    if (!nullToAbsent || sourceJson != null) {
      map['source_json'] = Variable<String>(sourceJson);
    }
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    if (!nullToAbsent || partyRole != null) {
      map['party_role'] = Variable<String>(partyRole);
    }
    if (!nullToAbsent || financialAccountId != null) {
      map['financial_account_id'] = Variable<String>(financialAccountId);
    }
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || legacyAction != null) {
      map['legacy_action'] = Variable<String>(legacyAction);
    }
    if (!nullToAbsent || totalMinor != null) {
      map['total_minor'] = Variable<int>(totalMinor);
    }
    if (!nullToAbsent || legacyTotalValue != null) {
      map['legacy_total_value'] = Variable<String>(legacyTotalValue);
    }
    if (!nullToAbsent || legacyPaidValue != null) {
      map['legacy_paid_value'] = Variable<String>(legacyPaidValue);
    }
    if (!nullToAbsent || legacyRemainingValue != null) {
      map['legacy_remaining_value'] = Variable<String>(legacyRemainingValue);
    }
    if (!nullToAbsent || issuedAt != null) {
      map['issued_at'] = Variable<DateTime>(issuedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      serial: Value(serial),
      legacyRecordKey: legacyRecordKey == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyRecordKey),
      legacyInvoiceId: legacyInvoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyInvoiceId),
      sourceJson: sourceJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceJson),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      partyRole: partyRole == null && nullToAbsent
          ? const Value.absent()
          : Value(partyRole),
      financialAccountId: financialAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(financialAccountId),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      action: Value(action),
      legacyAction: legacyAction == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyAction),
      totalMinor: totalMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(totalMinor),
      legacyTotalValue: legacyTotalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyTotalValue),
      legacyPaidValue: legacyPaidValue == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyPaidValue),
      legacyRemainingValue: legacyRemainingValue == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyRemainingValue),
      issuedAt: issuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Invoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      serial: serializer.fromJson<String>(json['serial']),
      legacyRecordKey: serializer.fromJson<String?>(json['legacyRecordKey']),
      legacyInvoiceId: serializer.fromJson<String?>(json['legacyInvoiceId']),
      sourceJson: serializer.fromJson<String?>(json['sourceJson']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      partyRole: serializer.fromJson<String?>(json['partyRole']),
      financialAccountId: serializer.fromJson<String?>(
        json['financialAccountId'],
      ),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      action: serializer.fromJson<String>(json['action']),
      legacyAction: serializer.fromJson<String?>(json['legacyAction']),
      totalMinor: serializer.fromJson<int?>(json['totalMinor']),
      legacyTotalValue: serializer.fromJson<String?>(json['legacyTotalValue']),
      legacyPaidValue: serializer.fromJson<String?>(json['legacyPaidValue']),
      legacyRemainingValue: serializer.fromJson<String?>(
        json['legacyRemainingValue'],
      ),
      issuedAt: serializer.fromJson<DateTime?>(json['issuedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serial': serializer.toJson<String>(serial),
      'legacyRecordKey': serializer.toJson<String?>(legacyRecordKey),
      'legacyInvoiceId': serializer.toJson<String?>(legacyInvoiceId),
      'sourceJson': serializer.toJson<String?>(sourceJson),
      'partyId': serializer.toJson<String?>(partyId),
      'partyRole': serializer.toJson<String?>(partyRole),
      'financialAccountId': serializer.toJson<String?>(financialAccountId),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'action': serializer.toJson<String>(action),
      'legacyAction': serializer.toJson<String?>(legacyAction),
      'totalMinor': serializer.toJson<int?>(totalMinor),
      'legacyTotalValue': serializer.toJson<String?>(legacyTotalValue),
      'legacyPaidValue': serializer.toJson<String?>(legacyPaidValue),
      'legacyRemainingValue': serializer.toJson<String?>(legacyRemainingValue),
      'issuedAt': serializer.toJson<DateTime?>(issuedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Invoice copyWith({
    String? id,
    String? serial,
    Value<String?> legacyRecordKey = const Value.absent(),
    Value<String?> legacyInvoiceId = const Value.absent(),
    Value<String?> sourceJson = const Value.absent(),
    Value<String?> partyId = const Value.absent(),
    Value<String?> partyRole = const Value.absent(),
    Value<String?> financialAccountId = const Value.absent(),
    Value<String?> currencyCode = const Value.absent(),
    String? action,
    Value<String?> legacyAction = const Value.absent(),
    Value<int?> totalMinor = const Value.absent(),
    Value<String?> legacyTotalValue = const Value.absent(),
    Value<String?> legacyPaidValue = const Value.absent(),
    Value<String?> legacyRemainingValue = const Value.absent(),
    Value<DateTime?> issuedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Invoice(
    id: id ?? this.id,
    serial: serial ?? this.serial,
    legacyRecordKey: legacyRecordKey.present
        ? legacyRecordKey.value
        : this.legacyRecordKey,
    legacyInvoiceId: legacyInvoiceId.present
        ? legacyInvoiceId.value
        : this.legacyInvoiceId,
    sourceJson: sourceJson.present ? sourceJson.value : this.sourceJson,
    partyId: partyId.present ? partyId.value : this.partyId,
    partyRole: partyRole.present ? partyRole.value : this.partyRole,
    financialAccountId: financialAccountId.present
        ? financialAccountId.value
        : this.financialAccountId,
    currencyCode: currencyCode.present ? currencyCode.value : this.currencyCode,
    action: action ?? this.action,
    legacyAction: legacyAction.present ? legacyAction.value : this.legacyAction,
    totalMinor: totalMinor.present ? totalMinor.value : this.totalMinor,
    legacyTotalValue: legacyTotalValue.present
        ? legacyTotalValue.value
        : this.legacyTotalValue,
    legacyPaidValue: legacyPaidValue.present
        ? legacyPaidValue.value
        : this.legacyPaidValue,
    legacyRemainingValue: legacyRemainingValue.present
        ? legacyRemainingValue.value
        : this.legacyRemainingValue,
    issuedAt: issuedAt.present ? issuedAt.value : this.issuedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      serial: data.serial.present ? data.serial.value : this.serial,
      legacyRecordKey: data.legacyRecordKey.present
          ? data.legacyRecordKey.value
          : this.legacyRecordKey,
      legacyInvoiceId: data.legacyInvoiceId.present
          ? data.legacyInvoiceId.value
          : this.legacyInvoiceId,
      sourceJson: data.sourceJson.present
          ? data.sourceJson.value
          : this.sourceJson,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      financialAccountId: data.financialAccountId.present
          ? data.financialAccountId.value
          : this.financialAccountId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      action: data.action.present ? data.action.value : this.action,
      legacyAction: data.legacyAction.present
          ? data.legacyAction.value
          : this.legacyAction,
      totalMinor: data.totalMinor.present
          ? data.totalMinor.value
          : this.totalMinor,
      legacyTotalValue: data.legacyTotalValue.present
          ? data.legacyTotalValue.value
          : this.legacyTotalValue,
      legacyPaidValue: data.legacyPaidValue.present
          ? data.legacyPaidValue.value
          : this.legacyPaidValue,
      legacyRemainingValue: data.legacyRemainingValue.present
          ? data.legacyRemainingValue.value
          : this.legacyRemainingValue,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('serial: $serial, ')
          ..write('legacyRecordKey: $legacyRecordKey, ')
          ..write('legacyInvoiceId: $legacyInvoiceId, ')
          ..write('sourceJson: $sourceJson, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('action: $action, ')
          ..write('legacyAction: $legacyAction, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('legacyTotalValue: $legacyTotalValue, ')
          ..write('legacyPaidValue: $legacyPaidValue, ')
          ..write('legacyRemainingValue: $legacyRemainingValue, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serial,
    legacyRecordKey,
    legacyInvoiceId,
    sourceJson,
    partyId,
    partyRole,
    financialAccountId,
    currencyCode,
    action,
    legacyAction,
    totalMinor,
    legacyTotalValue,
    legacyPaidValue,
    legacyRemainingValue,
    issuedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.serial == this.serial &&
          other.legacyRecordKey == this.legacyRecordKey &&
          other.legacyInvoiceId == this.legacyInvoiceId &&
          other.sourceJson == this.sourceJson &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.financialAccountId == this.financialAccountId &&
          other.currencyCode == this.currencyCode &&
          other.action == this.action &&
          other.legacyAction == this.legacyAction &&
          other.totalMinor == this.totalMinor &&
          other.legacyTotalValue == this.legacyTotalValue &&
          other.legacyPaidValue == this.legacyPaidValue &&
          other.legacyRemainingValue == this.legacyRemainingValue &&
          other.issuedAt == this.issuedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> serial;
  final Value<String?> legacyRecordKey;
  final Value<String?> legacyInvoiceId;
  final Value<String?> sourceJson;
  final Value<String?> partyId;
  final Value<String?> partyRole;
  final Value<String?> financialAccountId;
  final Value<String?> currencyCode;
  final Value<String> action;
  final Value<String?> legacyAction;
  final Value<int?> totalMinor;
  final Value<String?> legacyTotalValue;
  final Value<String?> legacyPaidValue;
  final Value<String?> legacyRemainingValue;
  final Value<DateTime?> issuedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.serial = const Value.absent(),
    this.legacyRecordKey = const Value.absent(),
    this.legacyInvoiceId = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.action = const Value.absent(),
    this.legacyAction = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.legacyTotalValue = const Value.absent(),
    this.legacyPaidValue = const Value.absent(),
    this.legacyRemainingValue = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String serial,
    this.legacyRecordKey = const Value.absent(),
    this.legacyInvoiceId = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    required String action,
    this.legacyAction = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.legacyTotalValue = const Value.absent(),
    this.legacyPaidValue = const Value.absent(),
    this.legacyRemainingValue = const Value.absent(),
    this.issuedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serial = Value(serial),
       action = Value(action),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? serial,
    Expression<String>? legacyRecordKey,
    Expression<String>? legacyInvoiceId,
    Expression<String>? sourceJson,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? financialAccountId,
    Expression<String>? currencyCode,
    Expression<String>? action,
    Expression<String>? legacyAction,
    Expression<int>? totalMinor,
    Expression<String>? legacyTotalValue,
    Expression<String>? legacyPaidValue,
    Expression<String>? legacyRemainingValue,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'invoice_id': id,
      if (serial != null) 'invoice_serial': serial,
      if (legacyRecordKey != null) 'legacy_record_key': legacyRecordKey,
      if (legacyInvoiceId != null) 'legacy_invoice_id': legacyInvoiceId,
      if (sourceJson != null) 'source_json': sourceJson,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (financialAccountId != null)
        'financial_account_id': financialAccountId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (action != null) 'action': action,
      if (legacyAction != null) 'legacy_action': legacyAction,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (legacyTotalValue != null) 'legacy_total_value': legacyTotalValue,
      if (legacyPaidValue != null) 'legacy_paid_value': legacyPaidValue,
      if (legacyRemainingValue != null)
        'legacy_remaining_value': legacyRemainingValue,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? serial,
    Value<String?>? legacyRecordKey,
    Value<String?>? legacyInvoiceId,
    Value<String?>? sourceJson,
    Value<String?>? partyId,
    Value<String?>? partyRole,
    Value<String?>? financialAccountId,
    Value<String?>? currencyCode,
    Value<String>? action,
    Value<String?>? legacyAction,
    Value<int?>? totalMinor,
    Value<String?>? legacyTotalValue,
    Value<String?>? legacyPaidValue,
    Value<String?>? legacyRemainingValue,
    Value<DateTime?>? issuedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      serial: serial ?? this.serial,
      legacyRecordKey: legacyRecordKey ?? this.legacyRecordKey,
      legacyInvoiceId: legacyInvoiceId ?? this.legacyInvoiceId,
      sourceJson: sourceJson ?? this.sourceJson,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      financialAccountId: financialAccountId ?? this.financialAccountId,
      currencyCode: currencyCode ?? this.currencyCode,
      action: action ?? this.action,
      legacyAction: legacyAction ?? this.legacyAction,
      totalMinor: totalMinor ?? this.totalMinor,
      legacyTotalValue: legacyTotalValue ?? this.legacyTotalValue,
      legacyPaidValue: legacyPaidValue ?? this.legacyPaidValue,
      legacyRemainingValue: legacyRemainingValue ?? this.legacyRemainingValue,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['invoice_id'] = Variable<String>(id.value);
    }
    if (serial.present) {
      map['invoice_serial'] = Variable<String>(serial.value);
    }
    if (legacyRecordKey.present) {
      map['legacy_record_key'] = Variable<String>(legacyRecordKey.value);
    }
    if (legacyInvoiceId.present) {
      map['legacy_invoice_id'] = Variable<String>(legacyInvoiceId.value);
    }
    if (sourceJson.present) {
      map['source_json'] = Variable<String>(sourceJson.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (financialAccountId.present) {
      map['financial_account_id'] = Variable<String>(financialAccountId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (legacyAction.present) {
      map['legacy_action'] = Variable<String>(legacyAction.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (legacyTotalValue.present) {
      map['legacy_total_value'] = Variable<String>(legacyTotalValue.value);
    }
    if (legacyPaidValue.present) {
      map['legacy_paid_value'] = Variable<String>(legacyPaidValue.value);
    }
    if (legacyRemainingValue.present) {
      map['legacy_remaining_value'] = Variable<String>(
        legacyRemainingValue.value,
      );
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('serial: $serial, ')
          ..write('legacyRecordKey: $legacyRecordKey, ')
          ..write('legacyInvoiceId: $legacyInvoiceId, ')
          ..write('sourceJson: $sourceJson, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('action: $action, ')
          ..write('legacyAction: $legacyAction, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('legacyTotalValue: $legacyTotalValue, ')
          ..write('legacyPaidValue: $legacyPaidValue, ')
          ..write('legacyRemainingValue: $legacyRemainingValue, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceLinesTable extends InvoiceLines
    with TableInfo<$InvoiceLinesTable, InvoiceLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'invoice_line_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineIndexMeta = const VerificationMeta(
    'lineIndex',
  );
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
    'line_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityDecimalMeta = const VerificationMeta(
    'quantityDecimal',
  );
  @override
  late final GeneratedColumn<String> quantityDecimal = GeneratedColumn<String>(
    'quantity_decimal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageWeightDecimalMeta =
      const VerificationMeta('packageWeightDecimal');
  @override
  late final GeneratedColumn<String> packageWeightDecimal =
      GeneratedColumn<String>(
        'package_weight_decimal',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _packageCountMeta = const VerificationMeta(
    'packageCount',
  );
  @override
  late final GeneratedColumn<int> packageCount = GeneratedColumn<int>(
    'package_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitPriceDecimalMeta = const VerificationMeta(
    'unitPriceDecimal',
  );
  @override
  late final GeneratedColumn<String> unitPriceDecimal = GeneratedColumn<String>(
    'unit_price_decimal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineTotalMinorMeta = const VerificationMeta(
    'lineTotalMinor',
  );
  @override
  late final GeneratedColumn<int> lineTotalMinor = GeneratedColumn<int>(
    'line_total_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceJsonMeta = const VerificationMeta(
    'sourceJson',
  );
  @override
  late final GeneratedColumn<String> sourceJson = GeneratedColumn<String>(
    'source_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    lineIndex,
    productName,
    quantityDecimal,
    packageWeightDecimal,
    packageCount,
    unitPriceDecimal,
    lineTotalMinor,
    currencyCode,
    sourceJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('invoice_line_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['invoice_line_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(
        _lineIndexMeta,
        lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity_decimal')) {
      context.handle(
        _quantityDecimalMeta,
        quantityDecimal.isAcceptableOrUnknown(
          data['quantity_decimal']!,
          _quantityDecimalMeta,
        ),
      );
    }
    if (data.containsKey('package_weight_decimal')) {
      context.handle(
        _packageWeightDecimalMeta,
        packageWeightDecimal.isAcceptableOrUnknown(
          data['package_weight_decimal']!,
          _packageWeightDecimalMeta,
        ),
      );
    }
    if (data.containsKey('package_count')) {
      context.handle(
        _packageCountMeta,
        packageCount.isAcceptableOrUnknown(
          data['package_count']!,
          _packageCountMeta,
        ),
      );
    }
    if (data.containsKey('unit_price_decimal')) {
      context.handle(
        _unitPriceDecimalMeta,
        unitPriceDecimal.isAcceptableOrUnknown(
          data['unit_price_decimal']!,
          _unitPriceDecimalMeta,
        ),
      );
    }
    if (data.containsKey('line_total_minor')) {
      context.handle(
        _lineTotalMinorMeta,
        lineTotalMinor.isAcceptableOrUnknown(
          data['line_total_minor']!,
          _lineTotalMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('source_json')) {
      context.handle(
        _sourceJsonMeta,
        sourceJson.isAcceptableOrUnknown(data['source_json']!, _sourceJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {invoiceId, lineIndex},
  ];
  @override
  InvoiceLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_line_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      lineIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_index'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantityDecimal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_decimal'],
      ),
      packageWeightDecimal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_weight_decimal'],
      ),
      packageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}package_count'],
      ),
      unitPriceDecimal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_price_decimal'],
      ),
      lineTotalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_minor'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      ),
      sourceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_json'],
      ),
    );
  }

  @override
  $InvoiceLinesTable createAlias(String alias) {
    return $InvoiceLinesTable(attachedDatabase, alias);
  }
}

class InvoiceLine extends DataClass implements Insertable<InvoiceLine> {
  final String id;
  final String invoiceId;
  final int lineIndex;
  final String productName;
  final String? quantityDecimal;
  final String? packageWeightDecimal;
  final int? packageCount;
  final String? unitPriceDecimal;
  final int? lineTotalMinor;
  final String? currencyCode;
  final String? sourceJson;
  const InvoiceLine({
    required this.id,
    required this.invoiceId,
    required this.lineIndex,
    required this.productName,
    this.quantityDecimal,
    this.packageWeightDecimal,
    this.packageCount,
    this.unitPriceDecimal,
    this.lineTotalMinor,
    this.currencyCode,
    this.sourceJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['invoice_line_id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['line_index'] = Variable<int>(lineIndex);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || quantityDecimal != null) {
      map['quantity_decimal'] = Variable<String>(quantityDecimal);
    }
    if (!nullToAbsent || packageWeightDecimal != null) {
      map['package_weight_decimal'] = Variable<String>(packageWeightDecimal);
    }
    if (!nullToAbsent || packageCount != null) {
      map['package_count'] = Variable<int>(packageCount);
    }
    if (!nullToAbsent || unitPriceDecimal != null) {
      map['unit_price_decimal'] = Variable<String>(unitPriceDecimal);
    }
    if (!nullToAbsent || lineTotalMinor != null) {
      map['line_total_minor'] = Variable<int>(lineTotalMinor);
    }
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    if (!nullToAbsent || sourceJson != null) {
      map['source_json'] = Variable<String>(sourceJson);
    }
    return map;
  }

  InvoiceLinesCompanion toCompanion(bool nullToAbsent) {
    return InvoiceLinesCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      lineIndex: Value(lineIndex),
      productName: Value(productName),
      quantityDecimal: quantityDecimal == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityDecimal),
      packageWeightDecimal: packageWeightDecimal == null && nullToAbsent
          ? const Value.absent()
          : Value(packageWeightDecimal),
      packageCount: packageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(packageCount),
      unitPriceDecimal: unitPriceDecimal == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPriceDecimal),
      lineTotalMinor: lineTotalMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(lineTotalMinor),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      sourceJson: sourceJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceJson),
    );
  }

  factory InvoiceLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceLine(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
      productName: serializer.fromJson<String>(json['productName']),
      quantityDecimal: serializer.fromJson<String?>(json['quantityDecimal']),
      packageWeightDecimal: serializer.fromJson<String?>(
        json['packageWeightDecimal'],
      ),
      packageCount: serializer.fromJson<int?>(json['packageCount']),
      unitPriceDecimal: serializer.fromJson<String?>(json['unitPriceDecimal']),
      lineTotalMinor: serializer.fromJson<int?>(json['lineTotalMinor']),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      sourceJson: serializer.fromJson<String?>(json['sourceJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'lineIndex': serializer.toJson<int>(lineIndex),
      'productName': serializer.toJson<String>(productName),
      'quantityDecimal': serializer.toJson<String?>(quantityDecimal),
      'packageWeightDecimal': serializer.toJson<String?>(packageWeightDecimal),
      'packageCount': serializer.toJson<int?>(packageCount),
      'unitPriceDecimal': serializer.toJson<String?>(unitPriceDecimal),
      'lineTotalMinor': serializer.toJson<int?>(lineTotalMinor),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'sourceJson': serializer.toJson<String?>(sourceJson),
    };
  }

  InvoiceLine copyWith({
    String? id,
    String? invoiceId,
    int? lineIndex,
    String? productName,
    Value<String?> quantityDecimal = const Value.absent(),
    Value<String?> packageWeightDecimal = const Value.absent(),
    Value<int?> packageCount = const Value.absent(),
    Value<String?> unitPriceDecimal = const Value.absent(),
    Value<int?> lineTotalMinor = const Value.absent(),
    Value<String?> currencyCode = const Value.absent(),
    Value<String?> sourceJson = const Value.absent(),
  }) => InvoiceLine(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    lineIndex: lineIndex ?? this.lineIndex,
    productName: productName ?? this.productName,
    quantityDecimal: quantityDecimal.present
        ? quantityDecimal.value
        : this.quantityDecimal,
    packageWeightDecimal: packageWeightDecimal.present
        ? packageWeightDecimal.value
        : this.packageWeightDecimal,
    packageCount: packageCount.present ? packageCount.value : this.packageCount,
    unitPriceDecimal: unitPriceDecimal.present
        ? unitPriceDecimal.value
        : this.unitPriceDecimal,
    lineTotalMinor: lineTotalMinor.present
        ? lineTotalMinor.value
        : this.lineTotalMinor,
    currencyCode: currencyCode.present ? currencyCode.value : this.currencyCode,
    sourceJson: sourceJson.present ? sourceJson.value : this.sourceJson,
  );
  InvoiceLine copyWithCompanion(InvoiceLinesCompanion data) {
    return InvoiceLine(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantityDecimal: data.quantityDecimal.present
          ? data.quantityDecimal.value
          : this.quantityDecimal,
      packageWeightDecimal: data.packageWeightDecimal.present
          ? data.packageWeightDecimal.value
          : this.packageWeightDecimal,
      packageCount: data.packageCount.present
          ? data.packageCount.value
          : this.packageCount,
      unitPriceDecimal: data.unitPriceDecimal.present
          ? data.unitPriceDecimal.value
          : this.unitPriceDecimal,
      lineTotalMinor: data.lineTotalMinor.present
          ? data.lineTotalMinor.value
          : this.lineTotalMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      sourceJson: data.sourceJson.present
          ? data.sourceJson.value
          : this.sourceJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLine(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('productName: $productName, ')
          ..write('quantityDecimal: $quantityDecimal, ')
          ..write('packageWeightDecimal: $packageWeightDecimal, ')
          ..write('packageCount: $packageCount, ')
          ..write('unitPriceDecimal: $unitPriceDecimal, ')
          ..write('lineTotalMinor: $lineTotalMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('sourceJson: $sourceJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    lineIndex,
    productName,
    quantityDecimal,
    packageWeightDecimal,
    packageCount,
    unitPriceDecimal,
    lineTotalMinor,
    currencyCode,
    sourceJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceLine &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.lineIndex == this.lineIndex &&
          other.productName == this.productName &&
          other.quantityDecimal == this.quantityDecimal &&
          other.packageWeightDecimal == this.packageWeightDecimal &&
          other.packageCount == this.packageCount &&
          other.unitPriceDecimal == this.unitPriceDecimal &&
          other.lineTotalMinor == this.lineTotalMinor &&
          other.currencyCode == this.currencyCode &&
          other.sourceJson == this.sourceJson);
}

class InvoiceLinesCompanion extends UpdateCompanion<InvoiceLine> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<int> lineIndex;
  final Value<String> productName;
  final Value<String?> quantityDecimal;
  final Value<String?> packageWeightDecimal;
  final Value<int?> packageCount;
  final Value<String?> unitPriceDecimal;
  final Value<int?> lineTotalMinor;
  final Value<String?> currencyCode;
  final Value<String?> sourceJson;
  final Value<int> rowid;
  const InvoiceLinesCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantityDecimal = const Value.absent(),
    this.packageWeightDecimal = const Value.absent(),
    this.packageCount = const Value.absent(),
    this.unitPriceDecimal = const Value.absent(),
    this.lineTotalMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceLinesCompanion.insert({
    required String id,
    required String invoiceId,
    required int lineIndex,
    required String productName,
    this.quantityDecimal = const Value.absent(),
    this.packageWeightDecimal = const Value.absent(),
    this.packageCount = const Value.absent(),
    this.unitPriceDecimal = const Value.absent(),
    this.lineTotalMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.sourceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       lineIndex = Value(lineIndex),
       productName = Value(productName);
  static Insertable<InvoiceLine> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<int>? lineIndex,
    Expression<String>? productName,
    Expression<String>? quantityDecimal,
    Expression<String>? packageWeightDecimal,
    Expression<int>? packageCount,
    Expression<String>? unitPriceDecimal,
    Expression<int>? lineTotalMinor,
    Expression<String>? currencyCode,
    Expression<String>? sourceJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'invoice_line_id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (lineIndex != null) 'line_index': lineIndex,
      if (productName != null) 'product_name': productName,
      if (quantityDecimal != null) 'quantity_decimal': quantityDecimal,
      if (packageWeightDecimal != null)
        'package_weight_decimal': packageWeightDecimal,
      if (packageCount != null) 'package_count': packageCount,
      if (unitPriceDecimal != null) 'unit_price_decimal': unitPriceDecimal,
      if (lineTotalMinor != null) 'line_total_minor': lineTotalMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (sourceJson != null) 'source_json': sourceJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<int>? lineIndex,
    Value<String>? productName,
    Value<String?>? quantityDecimal,
    Value<String?>? packageWeightDecimal,
    Value<int?>? packageCount,
    Value<String?>? unitPriceDecimal,
    Value<int?>? lineTotalMinor,
    Value<String?>? currencyCode,
    Value<String?>? sourceJson,
    Value<int>? rowid,
  }) {
    return InvoiceLinesCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      lineIndex: lineIndex ?? this.lineIndex,
      productName: productName ?? this.productName,
      quantityDecimal: quantityDecimal ?? this.quantityDecimal,
      packageWeightDecimal: packageWeightDecimal ?? this.packageWeightDecimal,
      packageCount: packageCount ?? this.packageCount,
      unitPriceDecimal: unitPriceDecimal ?? this.unitPriceDecimal,
      lineTotalMinor: lineTotalMinor ?? this.lineTotalMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      sourceJson: sourceJson ?? this.sourceJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['invoice_line_id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantityDecimal.present) {
      map['quantity_decimal'] = Variable<String>(quantityDecimal.value);
    }
    if (packageWeightDecimal.present) {
      map['package_weight_decimal'] = Variable<String>(
        packageWeightDecimal.value,
      );
    }
    if (packageCount.present) {
      map['package_count'] = Variable<int>(packageCount.value);
    }
    if (unitPriceDecimal.present) {
      map['unit_price_decimal'] = Variable<String>(unitPriceDecimal.value);
    }
    if (lineTotalMinor.present) {
      map['line_total_minor'] = Variable<int>(lineTotalMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (sourceJson.present) {
      map['source_json'] = Variable<String>(sourceJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLinesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('productName: $productName, ')
          ..write('quantityDecimal: $quantityDecimal, ')
          ..write('packageWeightDecimal: $packageWeightDecimal, ')
          ..write('packageCount: $packageCount, ')
          ..write('unitPriceDecimal: $unitPriceDecimal, ')
          ..write('lineTotalMinor: $lineTotalMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('sourceJson: $sourceJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Stage2Database extends GeneratedDatabase {
  _$Stage2Database(QueryExecutor e) : super(e);
  $Stage2DatabaseManager get managers => $Stage2DatabaseManager(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $PartyRolesTable partyRoles = $PartyRolesTable(this);
  late final $FinancialAccountsTable financialAccounts =
      $FinancialAccountsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceLinesTable invoiceLines = $InvoiceLinesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    currencies,
    parties,
    partyRoles,
    financialAccounts,
    invoices,
    invoiceLines,
  ];
}

typedef $$CurrenciesTableCreateCompanionBuilder =
    CurrenciesCompanion Function({
      required String code,
      required int minorUnitScale,
      required String displayName,
      Value<int> rowid,
    });
typedef $$CurrenciesTableUpdateCompanionBuilder =
    CurrenciesCompanion Function({
      Value<String> code,
      Value<int> minorUnitScale,
      Value<String> displayName,
      Value<int> rowid,
    });

class $$CurrenciesTableFilterComposer
    extends Composer<_$Stage2Database, $CurrenciesTable> {
  $$CurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minorUnitScale => $composableBuilder(
    column: $table.minorUnitScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurrenciesTableOrderingComposer
    extends Composer<_$Stage2Database, $CurrenciesTable> {
  $$CurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minorUnitScale => $composableBuilder(
    column: $table.minorUnitScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrenciesTableAnnotationComposer
    extends Composer<_$Stage2Database, $CurrenciesTable> {
  $$CurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get minorUnitScale => $composableBuilder(
    column: $table.minorUnitScale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );
}

class $$CurrenciesTableTableManager
    extends
        RootTableManager<
          _$Stage2Database,
          $CurrenciesTable,
          Currency,
          $$CurrenciesTableFilterComposer,
          $$CurrenciesTableOrderingComposer,
          $$CurrenciesTableAnnotationComposer,
          $$CurrenciesTableCreateCompanionBuilder,
          $$CurrenciesTableUpdateCompanionBuilder,
          (
            Currency,
            BaseReferences<_$Stage2Database, $CurrenciesTable, Currency>,
          ),
          Currency,
          PrefetchHooks Function()
        > {
  $$CurrenciesTableTableManager(_$Stage2Database db, $CurrenciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<int> minorUnitScale = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion(
                code: code,
                minorUnitScale: minorUnitScale,
                displayName: displayName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required int minorUnitScale,
                required String displayName,
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion.insert(
                code: code,
                minorUnitScale: minorUnitScale,
                displayName: displayName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CurrenciesTable, Currency>(table),
                  BaseReferences<_$Stage2Database, $CurrenciesTable, Currency>(
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

typedef $$CurrenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$Stage2Database,
      $CurrenciesTable,
      Currency,
      $$CurrenciesTableFilterComposer,
      $$CurrenciesTableOrderingComposer,
      $$CurrenciesTableAnnotationComposer,
      $$CurrenciesTableCreateCompanionBuilder,
      $$CurrenciesTableUpdateCompanionBuilder,
      (Currency, BaseReferences<_$Stage2Database, $CurrenciesTable, Currency>),
      Currency,
      PrefetchHooks Function()
    >;
typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      required String id,
      required String displayName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PartiesTableFilterComposer
    extends Composer<_$Stage2Database, $PartiesTable> {
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
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
}

class $$PartiesTableOrderingComposer
    extends Composer<_$Stage2Database, $PartiesTable> {
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
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
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$Stage2Database, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$Stage2Database,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, BaseReferences<_$Stage2Database, $PartiesTable, Party>),
          Party,
          PrefetchHooks Function()
        > {
  $$PartiesTableTableManager(_$Stage2Database db, $PartiesTable table)
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
                Value<String> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PartiesTable, Party>(table),
                  BaseReferences<_$Stage2Database, $PartiesTable, Party>(
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

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$Stage2Database,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, BaseReferences<_$Stage2Database, $PartiesTable, Party>),
      Party,
      PrefetchHooks Function()
    >;
typedef $$PartyRolesTableCreateCompanionBuilder =
    PartyRolesCompanion Function({
      required String partyId,
      required String role,
      Value<int> rowid,
    });
typedef $$PartyRolesTableUpdateCompanionBuilder =
    PartyRolesCompanion Function({
      Value<String> partyId,
      Value<String> role,
      Value<int> rowid,
    });

class $$PartyRolesTableFilterComposer
    extends Composer<_$Stage2Database, $PartyRolesTable> {
  $$PartyRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartyRolesTableOrderingComposer
    extends Composer<_$Stage2Database, $PartyRolesTable> {
  $$PartyRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartyRolesTableAnnotationComposer
    extends Composer<_$Stage2Database, $PartyRolesTable> {
  $$PartyRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$PartyRolesTableTableManager
    extends
        RootTableManager<
          _$Stage2Database,
          $PartyRolesTable,
          PartyRole,
          $$PartyRolesTableFilterComposer,
          $$PartyRolesTableOrderingComposer,
          $$PartyRolesTableAnnotationComposer,
          $$PartyRolesTableCreateCompanionBuilder,
          $$PartyRolesTableUpdateCompanionBuilder,
          (
            PartyRole,
            BaseReferences<_$Stage2Database, $PartyRolesTable, PartyRole>,
          ),
          PartyRole,
          PrefetchHooks Function()
        > {
  $$PartyRolesTableTableManager(_$Stage2Database db, $PartyRolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartyRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartyRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartyRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> partyId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartyRolesCompanion(
                partyId: partyId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String partyId,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => PartyRolesCompanion.insert(
                partyId: partyId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PartyRolesTable, PartyRole>(table),
                  BaseReferences<_$Stage2Database, $PartyRolesTable, PartyRole>(
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

typedef $$PartyRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$Stage2Database,
      $PartyRolesTable,
      PartyRole,
      $$PartyRolesTableFilterComposer,
      $$PartyRolesTableOrderingComposer,
      $$PartyRolesTableAnnotationComposer,
      $$PartyRolesTableCreateCompanionBuilder,
      $$PartyRolesTableUpdateCompanionBuilder,
      (
        PartyRole,
        BaseReferences<_$Stage2Database, $PartyRolesTable, PartyRole>,
      ),
      PartyRole,
      PrefetchHooks Function()
    >;
typedef $$FinancialAccountsTableCreateCompanionBuilder =
    FinancialAccountsCompanion Function({
      required String id,
      required String partyId,
      required String role,
      required String currencyCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FinancialAccountsTableUpdateCompanionBuilder =
    FinancialAccountsCompanion Function({
      Value<String> id,
      Value<String> partyId,
      Value<String> role,
      Value<String> currencyCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FinancialAccountsTableFilterComposer
    extends Composer<_$Stage2Database, $FinancialAccountsTable> {
  $$FinancialAccountsTableFilterComposer({
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

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinancialAccountsTableOrderingComposer
    extends Composer<_$Stage2Database, $FinancialAccountsTable> {
  $$FinancialAccountsTableOrderingComposer({
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

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinancialAccountsTableAnnotationComposer
    extends Composer<_$Stage2Database, $FinancialAccountsTable> {
  $$FinancialAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FinancialAccountsTableTableManager
    extends
        RootTableManager<
          _$Stage2Database,
          $FinancialAccountsTable,
          FinancialAccount,
          $$FinancialAccountsTableFilterComposer,
          $$FinancialAccountsTableOrderingComposer,
          $$FinancialAccountsTableAnnotationComposer,
          $$FinancialAccountsTableCreateCompanionBuilder,
          $$FinancialAccountsTableUpdateCompanionBuilder,
          (
            FinancialAccount,
            BaseReferences<
              _$Stage2Database,
              $FinancialAccountsTable,
              FinancialAccount
            >,
          ),
          FinancialAccount,
          PrefetchHooks Function()
        > {
  $$FinancialAccountsTableTableManager(
    _$Stage2Database db,
    $FinancialAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialAccountsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialAccountsCompanion(
                id: id,
                partyId: partyId,
                role: role,
                currencyCode: currencyCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String partyId,
                required String role,
                required String currencyCode,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FinancialAccountsCompanion.insert(
                id: id,
                partyId: partyId,
                role: role,
                currencyCode: currencyCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FinancialAccountsTable, FinancialAccount>(table),
                  BaseReferences<
                    _$Stage2Database,
                    $FinancialAccountsTable,
                    FinancialAccount
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinancialAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$Stage2Database,
      $FinancialAccountsTable,
      FinancialAccount,
      $$FinancialAccountsTableFilterComposer,
      $$FinancialAccountsTableOrderingComposer,
      $$FinancialAccountsTableAnnotationComposer,
      $$FinancialAccountsTableCreateCompanionBuilder,
      $$FinancialAccountsTableUpdateCompanionBuilder,
      (
        FinancialAccount,
        BaseReferences<
          _$Stage2Database,
          $FinancialAccountsTable,
          FinancialAccount
        >,
      ),
      FinancialAccount,
      PrefetchHooks Function()
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      required String id,
      required String serial,
      Value<String?> legacyRecordKey,
      Value<String?> legacyInvoiceId,
      Value<String?> sourceJson,
      Value<String?> partyId,
      Value<String?> partyRole,
      Value<String?> financialAccountId,
      Value<String?> currencyCode,
      required String action,
      Value<String?> legacyAction,
      Value<int?> totalMinor,
      Value<String?> legacyTotalValue,
      Value<String?> legacyPaidValue,
      Value<String?> legacyRemainingValue,
      Value<DateTime?> issuedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<String> id,
      Value<String> serial,
      Value<String?> legacyRecordKey,
      Value<String?> legacyInvoiceId,
      Value<String?> sourceJson,
      Value<String?> partyId,
      Value<String?> partyRole,
      Value<String?> financialAccountId,
      Value<String?> currencyCode,
      Value<String> action,
      Value<String?> legacyAction,
      Value<int?> totalMinor,
      Value<String?> legacyTotalValue,
      Value<String?> legacyPaidValue,
      Value<String?> legacyRemainingValue,
      Value<DateTime?> issuedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$InvoicesTableFilterComposer
    extends Composer<_$Stage2Database, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
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

  ColumnFilters<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyRecordKey => $composableBuilder(
    column: $table.legacyRecordKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyInvoiceId => $composableBuilder(
    column: $table.legacyInvoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceJson => $composableBuilder(
    column: $table.sourceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyRole => $composableBuilder(
    column: $table.partyRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyAction => $composableBuilder(
    column: $table.legacyAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyTotalValue => $composableBuilder(
    column: $table.legacyTotalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyPaidValue => $composableBuilder(
    column: $table.legacyPaidValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyRemainingValue => $composableBuilder(
    column: $table.legacyRemainingValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
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
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$Stage2Database, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
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

  ColumnOrderings<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyRecordKey => $composableBuilder(
    column: $table.legacyRecordKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyInvoiceId => $composableBuilder(
    column: $table.legacyInvoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceJson => $composableBuilder(
    column: $table.sourceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyRole => $composableBuilder(
    column: $table.partyRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyAction => $composableBuilder(
    column: $table.legacyAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyTotalValue => $composableBuilder(
    column: $table.legacyTotalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyPaidValue => $composableBuilder(
    column: $table.legacyPaidValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyRemainingValue => $composableBuilder(
    column: $table.legacyRemainingValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
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
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$Stage2Database, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<String> get legacyRecordKey => $composableBuilder(
    column: $table.legacyRecordKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legacyInvoiceId => $composableBuilder(
    column: $table.legacyInvoiceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceJson => $composableBuilder(
    column: $table.sourceJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get legacyAction => $composableBuilder(
    column: $table.legacyAction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legacyTotalValue => $composableBuilder(
    column: $table.legacyTotalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legacyPaidValue => $composableBuilder(
    column: $table.legacyPaidValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legacyRemainingValue => $composableBuilder(
    column: $table.legacyRemainingValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$Stage2Database,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, BaseReferences<_$Stage2Database, $InvoicesTable, Invoice>),
          Invoice,
          PrefetchHooks Function()
        > {
  $$InvoicesTableTableManager(_$Stage2Database db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serial = const Value.absent(),
                Value<String?> legacyRecordKey = const Value.absent(),
                Value<String?> legacyInvoiceId = const Value.absent(),
                Value<String?> sourceJson = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<String?> partyRole = const Value.absent(),
                Value<String?> financialAccountId = const Value.absent(),
                Value<String?> currencyCode = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> legacyAction = const Value.absent(),
                Value<int?> totalMinor = const Value.absent(),
                Value<String?> legacyTotalValue = const Value.absent(),
                Value<String?> legacyPaidValue = const Value.absent(),
                Value<String?> legacyRemainingValue = const Value.absent(),
                Value<DateTime?> issuedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                serial: serial,
                legacyRecordKey: legacyRecordKey,
                legacyInvoiceId: legacyInvoiceId,
                sourceJson: sourceJson,
                partyId: partyId,
                partyRole: partyRole,
                financialAccountId: financialAccountId,
                currencyCode: currencyCode,
                action: action,
                legacyAction: legacyAction,
                totalMinor: totalMinor,
                legacyTotalValue: legacyTotalValue,
                legacyPaidValue: legacyPaidValue,
                legacyRemainingValue: legacyRemainingValue,
                issuedAt: issuedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serial,
                Value<String?> legacyRecordKey = const Value.absent(),
                Value<String?> legacyInvoiceId = const Value.absent(),
                Value<String?> sourceJson = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<String?> partyRole = const Value.absent(),
                Value<String?> financialAccountId = const Value.absent(),
                Value<String?> currencyCode = const Value.absent(),
                required String action,
                Value<String?> legacyAction = const Value.absent(),
                Value<int?> totalMinor = const Value.absent(),
                Value<String?> legacyTotalValue = const Value.absent(),
                Value<String?> legacyPaidValue = const Value.absent(),
                Value<String?> legacyRemainingValue = const Value.absent(),
                Value<DateTime?> issuedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                serial: serial,
                legacyRecordKey: legacyRecordKey,
                legacyInvoiceId: legacyInvoiceId,
                sourceJson: sourceJson,
                partyId: partyId,
                partyRole: partyRole,
                financialAccountId: financialAccountId,
                currencyCode: currencyCode,
                action: action,
                legacyAction: legacyAction,
                totalMinor: totalMinor,
                legacyTotalValue: legacyTotalValue,
                legacyPaidValue: legacyPaidValue,
                legacyRemainingValue: legacyRemainingValue,
                issuedAt: issuedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvoicesTable, Invoice>(table),
                  BaseReferences<_$Stage2Database, $InvoicesTable, Invoice>(
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

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$Stage2Database,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, BaseReferences<_$Stage2Database, $InvoicesTable, Invoice>),
      Invoice,
      PrefetchHooks Function()
    >;
typedef $$InvoiceLinesTableCreateCompanionBuilder =
    InvoiceLinesCompanion Function({
      required String id,
      required String invoiceId,
      required int lineIndex,
      required String productName,
      Value<String?> quantityDecimal,
      Value<String?> packageWeightDecimal,
      Value<int?> packageCount,
      Value<String?> unitPriceDecimal,
      Value<int?> lineTotalMinor,
      Value<String?> currencyCode,
      Value<String?> sourceJson,
      Value<int> rowid,
    });
typedef $$InvoiceLinesTableUpdateCompanionBuilder =
    InvoiceLinesCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<int> lineIndex,
      Value<String> productName,
      Value<String?> quantityDecimal,
      Value<String?> packageWeightDecimal,
      Value<int?> packageCount,
      Value<String?> unitPriceDecimal,
      Value<int?> lineTotalMinor,
      Value<String?> currencyCode,
      Value<String?> sourceJson,
      Value<int> rowid,
    });

class $$InvoiceLinesTableFilterComposer
    extends Composer<_$Stage2Database, $InvoiceLinesTable> {
  $$InvoiceLinesTableFilterComposer({
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

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineIndex => $composableBuilder(
    column: $table.lineIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityDecimal => $composableBuilder(
    column: $table.quantityDecimal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageWeightDecimal => $composableBuilder(
    column: $table.packageWeightDecimal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packageCount => $composableBuilder(
    column: $table.packageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitPriceDecimal => $composableBuilder(
    column: $table.unitPriceDecimal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalMinor => $composableBuilder(
    column: $table.lineTotalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceJson => $composableBuilder(
    column: $table.sourceJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoiceLinesTableOrderingComposer
    extends Composer<_$Stage2Database, $InvoiceLinesTable> {
  $$InvoiceLinesTableOrderingComposer({
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

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineIndex => $composableBuilder(
    column: $table.lineIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityDecimal => $composableBuilder(
    column: $table.quantityDecimal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageWeightDecimal => $composableBuilder(
    column: $table.packageWeightDecimal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packageCount => $composableBuilder(
    column: $table.packageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPriceDecimal => $composableBuilder(
    column: $table.unitPriceDecimal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalMinor => $composableBuilder(
    column: $table.lineTotalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceJson => $composableBuilder(
    column: $table.sourceJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoiceLinesTableAnnotationComposer
    extends Composer<_$Stage2Database, $InvoiceLinesTable> {
  $$InvoiceLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityDecimal => $composableBuilder(
    column: $table.quantityDecimal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageWeightDecimal => $composableBuilder(
    column: $table.packageWeightDecimal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get packageCount => $composableBuilder(
    column: $table.packageCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitPriceDecimal => $composableBuilder(
    column: $table.unitPriceDecimal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalMinor => $composableBuilder(
    column: $table.lineTotalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceJson => $composableBuilder(
    column: $table.sourceJson,
    builder: (column) => column,
  );
}

class $$InvoiceLinesTableTableManager
    extends
        RootTableManager<
          _$Stage2Database,
          $InvoiceLinesTable,
          InvoiceLine,
          $$InvoiceLinesTableFilterComposer,
          $$InvoiceLinesTableOrderingComposer,
          $$InvoiceLinesTableAnnotationComposer,
          $$InvoiceLinesTableCreateCompanionBuilder,
          $$InvoiceLinesTableUpdateCompanionBuilder,
          (
            InvoiceLine,
            BaseReferences<_$Stage2Database, $InvoiceLinesTable, InvoiceLine>,
          ),
          InvoiceLine,
          PrefetchHooks Function()
        > {
  $$InvoiceLinesTableTableManager(_$Stage2Database db, $InvoiceLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<int> lineIndex = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String?> quantityDecimal = const Value.absent(),
                Value<String?> packageWeightDecimal = const Value.absent(),
                Value<int?> packageCount = const Value.absent(),
                Value<String?> unitPriceDecimal = const Value.absent(),
                Value<int?> lineTotalMinor = const Value.absent(),
                Value<String?> currencyCode = const Value.absent(),
                Value<String?> sourceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceLinesCompanion(
                id: id,
                invoiceId: invoiceId,
                lineIndex: lineIndex,
                productName: productName,
                quantityDecimal: quantityDecimal,
                packageWeightDecimal: packageWeightDecimal,
                packageCount: packageCount,
                unitPriceDecimal: unitPriceDecimal,
                lineTotalMinor: lineTotalMinor,
                currencyCode: currencyCode,
                sourceJson: sourceJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                required int lineIndex,
                required String productName,
                Value<String?> quantityDecimal = const Value.absent(),
                Value<String?> packageWeightDecimal = const Value.absent(),
                Value<int?> packageCount = const Value.absent(),
                Value<String?> unitPriceDecimal = const Value.absent(),
                Value<int?> lineTotalMinor = const Value.absent(),
                Value<String?> currencyCode = const Value.absent(),
                Value<String?> sourceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceLinesCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                lineIndex: lineIndex,
                productName: productName,
                quantityDecimal: quantityDecimal,
                packageWeightDecimal: packageWeightDecimal,
                packageCount: packageCount,
                unitPriceDecimal: unitPriceDecimal,
                lineTotalMinor: lineTotalMinor,
                currencyCode: currencyCode,
                sourceJson: sourceJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvoiceLinesTable, InvoiceLine>(table),
                  BaseReferences<
                    _$Stage2Database,
                    $InvoiceLinesTable,
                    InvoiceLine
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoiceLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$Stage2Database,
      $InvoiceLinesTable,
      InvoiceLine,
      $$InvoiceLinesTableFilterComposer,
      $$InvoiceLinesTableOrderingComposer,
      $$InvoiceLinesTableAnnotationComposer,
      $$InvoiceLinesTableCreateCompanionBuilder,
      $$InvoiceLinesTableUpdateCompanionBuilder,
      (
        InvoiceLine,
        BaseReferences<_$Stage2Database, $InvoiceLinesTable, InvoiceLine>,
      ),
      InvoiceLine,
      PrefetchHooks Function()
    >;

class $Stage2DatabaseManager {
  final _$Stage2Database _db;
  $Stage2DatabaseManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db, _db.currencies);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$PartyRolesTableTableManager get partyRoles =>
      $$PartyRolesTableTableManager(_db, _db.partyRoles);
  $$FinancialAccountsTableTableManager get financialAccounts =>
      $$FinancialAccountsTableTableManager(_db, _db.financialAccounts);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceLinesTableTableManager get invoiceLines =>
      $$InvoiceLinesTableTableManager(_db, _db.invoiceLines);
}
