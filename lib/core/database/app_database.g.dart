// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

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

class $PaymentIdentitiesTable extends PaymentIdentities
    with TableInfo<$PaymentIdentitiesTable, PaymentIdentity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentIdentitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _financialAccountIdMeta =
      const VerificationMeta('financialAccountId');
  @override
  late final GeneratedColumn<String> financialAccountId =
      GeneratedColumn<String>(
        'financial_account_id',
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
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
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
  static const VerificationMeta _financialDirectionMeta =
      const VerificationMeta('financialDirection');
  @override
  late final GeneratedColumn<String> financialDirection =
      GeneratedColumn<String>(
        'financial_direction',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdByActorIdMeta = const VerificationMeta(
    'createdByActorId',
  );
  @override
  late final GeneratedColumn<String> createdByActorId = GeneratedColumn<String>(
    'created_by_actor_id',
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
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    financialDirection,
    createdByActorId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentIdentity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payment_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['payment_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('financial_account_id')) {
      context.handle(
        _financialAccountIdMeta,
        financialAccountId.isAcceptableOrUnknown(
          data['financial_account_id']!,
          _financialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialAccountIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_partyRoleMeta);
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
    if (data.containsKey('financial_direction')) {
      context.handle(
        _financialDirectionMeta,
        financialDirection.isAcceptableOrUnknown(
          data['financial_direction']!,
          _financialDirectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialDirectionMeta);
    }
    if (data.containsKey('created_by_actor_id')) {
      context.handle(
        _createdByActorIdMeta,
        createdByActorId.isAcceptableOrUnknown(
          data['created_by_actor_id']!,
          _createdByActorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByActorIdMeta);
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
    {id, financialAccountId, partyId, partyRole, currencyCode},
  ];
  @override
  PaymentIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentIdentity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      financialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_account_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      financialDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_direction'],
      )!,
      createdByActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_actor_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentIdentitiesTable createAlias(String alias) {
    return $PaymentIdentitiesTable(attachedDatabase, alias);
  }
}

class PaymentIdentity extends DataClass implements Insertable<PaymentIdentity> {
  final String id;
  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final String financialDirection;
  final String createdByActorId;
  final DateTime createdAt;
  const PaymentIdentity({
    required this.id,
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.financialDirection,
    required this.createdByActorId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payment_id'] = Variable<String>(id);
    map['financial_account_id'] = Variable<String>(financialAccountId);
    map['party_id'] = Variable<String>(partyId);
    map['party_role'] = Variable<String>(partyRole);
    map['currency_code'] = Variable<String>(currencyCode);
    map['financial_direction'] = Variable<String>(financialDirection);
    map['created_by_actor_id'] = Variable<String>(createdByActorId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentIdentitiesCompanion toCompanion(bool nullToAbsent) {
    return PaymentIdentitiesCompanion(
      id: Value(id),
      financialAccountId: Value(financialAccountId),
      partyId: Value(partyId),
      partyRole: Value(partyRole),
      currencyCode: Value(currencyCode),
      financialDirection: Value(financialDirection),
      createdByActorId: Value(createdByActorId),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentIdentity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentIdentity(
      id: serializer.fromJson<String>(json['id']),
      financialAccountId: serializer.fromJson<String>(
        json['financialAccountId'],
      ),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyRole: serializer.fromJson<String>(json['partyRole']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      financialDirection: serializer.fromJson<String>(
        json['financialDirection'],
      ),
      createdByActorId: serializer.fromJson<String>(json['createdByActorId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'financialAccountId': serializer.toJson<String>(financialAccountId),
      'partyId': serializer.toJson<String>(partyId),
      'partyRole': serializer.toJson<String>(partyRole),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'financialDirection': serializer.toJson<String>(financialDirection),
      'createdByActorId': serializer.toJson<String>(createdByActorId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentIdentity copyWith({
    String? id,
    String? financialAccountId,
    String? partyId,
    String? partyRole,
    String? currencyCode,
    String? financialDirection,
    String? createdByActorId,
    DateTime? createdAt,
  }) => PaymentIdentity(
    id: id ?? this.id,
    financialAccountId: financialAccountId ?? this.financialAccountId,
    partyId: partyId ?? this.partyId,
    partyRole: partyRole ?? this.partyRole,
    currencyCode: currencyCode ?? this.currencyCode,
    financialDirection: financialDirection ?? this.financialDirection,
    createdByActorId: createdByActorId ?? this.createdByActorId,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentIdentity copyWithCompanion(PaymentIdentitiesCompanion data) {
    return PaymentIdentity(
      id: data.id.present ? data.id.value : this.id,
      financialAccountId: data.financialAccountId.present
          ? data.financialAccountId.value
          : this.financialAccountId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      financialDirection: data.financialDirection.present
          ? data.financialDirection.value
          : this.financialDirection,
      createdByActorId: data.createdByActorId.present
          ? data.createdByActorId.value
          : this.createdByActorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentIdentity(')
          ..write('id: $id, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('financialDirection: $financialDirection, ')
          ..write('createdByActorId: $createdByActorId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    financialDirection,
    createdByActorId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentIdentity &&
          other.id == this.id &&
          other.financialAccountId == this.financialAccountId &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.currencyCode == this.currencyCode &&
          other.financialDirection == this.financialDirection &&
          other.createdByActorId == this.createdByActorId &&
          other.createdAt == this.createdAt);
}

class PaymentIdentitiesCompanion extends UpdateCompanion<PaymentIdentity> {
  final Value<String> id;
  final Value<String> financialAccountId;
  final Value<String> partyId;
  final Value<String> partyRole;
  final Value<String> currencyCode;
  final Value<String> financialDirection;
  final Value<String> createdByActorId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentIdentitiesCompanion({
    this.id = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.financialDirection = const Value.absent(),
    this.createdByActorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentIdentitiesCompanion.insert({
    required String id,
    required String financialAccountId,
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required String financialDirection,
    required String createdByActorId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       financialAccountId = Value(financialAccountId),
       partyId = Value(partyId),
       partyRole = Value(partyRole),
       currencyCode = Value(currencyCode),
       financialDirection = Value(financialDirection),
       createdByActorId = Value(createdByActorId),
       createdAt = Value(createdAt);
  static Insertable<PaymentIdentity> custom({
    Expression<String>? id,
    Expression<String>? financialAccountId,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? currencyCode,
    Expression<String>? financialDirection,
    Expression<String>? createdByActorId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'payment_id': id,
      if (financialAccountId != null)
        'financial_account_id': financialAccountId,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (financialDirection != null) 'financial_direction': financialDirection,
      if (createdByActorId != null) 'created_by_actor_id': createdByActorId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentIdentitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? financialAccountId,
    Value<String>? partyId,
    Value<String>? partyRole,
    Value<String>? currencyCode,
    Value<String>? financialDirection,
    Value<String>? createdByActorId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentIdentitiesCompanion(
      id: id ?? this.id,
      financialAccountId: financialAccountId ?? this.financialAccountId,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      currencyCode: currencyCode ?? this.currencyCode,
      financialDirection: financialDirection ?? this.financialDirection,
      createdByActorId: createdByActorId ?? this.createdByActorId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['payment_id'] = Variable<String>(id.value);
    }
    if (financialAccountId.present) {
      map['financial_account_id'] = Variable<String>(financialAccountId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (financialDirection.present) {
      map['financial_direction'] = Variable<String>(financialDirection.value);
    }
    if (createdByActorId.present) {
      map['created_by_actor_id'] = Variable<String>(createdByActorId.value);
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
    return (StringBuffer('PaymentIdentitiesCompanion(')
          ..write('id: $id, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('financialDirection: $financialDirection, ')
          ..write('createdByActorId: $createdByActorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashEventsTable extends CashEvents
    with TableInfo<$CashEventsTable, CashEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'cash_event_id',
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
  );
  static const VerificationMeta _createdByActorIdMeta = const VerificationMeta(
    'createdByActorId',
  );
  @override
  late final GeneratedColumn<String> createdByActorId = GeneratedColumn<String>(
    'created_by_actor_id',
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
    paymentId,
    createdByActorId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['cash_event_id']!, _idMeta),
      );
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
    if (data.containsKey('created_by_actor_id')) {
      context.handle(
        _createdByActorIdMeta,
        createdByActorId.isAcceptableOrUnknown(
          data['created_by_actor_id']!,
          _createdByActorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByActorIdMeta);
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
    {paymentId},
    {id, paymentId},
  ];
  @override
  CashEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      createdByActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_actor_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CashEventsTable createAlias(String alias) {
    return $CashEventsTable(attachedDatabase, alias);
  }
}

class CashEvent extends DataClass implements Insertable<CashEvent> {
  final String id;
  final String paymentId;
  final String createdByActorId;
  final DateTime createdAt;
  const CashEvent({
    required this.id,
    required this.paymentId,
    required this.createdByActorId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cash_event_id'] = Variable<String>(id);
    map['payment_id'] = Variable<String>(paymentId);
    map['created_by_actor_id'] = Variable<String>(createdByActorId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CashEventsCompanion toCompanion(bool nullToAbsent) {
    return CashEventsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      createdByActorId: Value(createdByActorId),
      createdAt: Value(createdAt),
    );
  }

  factory CashEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashEvent(
      id: serializer.fromJson<String>(json['id']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      createdByActorId: serializer.fromJson<String>(json['createdByActorId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'paymentId': serializer.toJson<String>(paymentId),
      'createdByActorId': serializer.toJson<String>(createdByActorId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CashEvent copyWith({
    String? id,
    String? paymentId,
    String? createdByActorId,
    DateTime? createdAt,
  }) => CashEvent(
    id: id ?? this.id,
    paymentId: paymentId ?? this.paymentId,
    createdByActorId: createdByActorId ?? this.createdByActorId,
    createdAt: createdAt ?? this.createdAt,
  );
  CashEvent copyWithCompanion(CashEventsCompanion data) {
    return CashEvent(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      createdByActorId: data.createdByActorId.present
          ? data.createdByActorId.value
          : this.createdByActorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashEvent(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('createdByActorId: $createdByActorId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, paymentId, createdByActorId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashEvent &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.createdByActorId == this.createdByActorId &&
          other.createdAt == this.createdAt);
}

class CashEventsCompanion extends UpdateCompanion<CashEvent> {
  final Value<String> id;
  final Value<String> paymentId;
  final Value<String> createdByActorId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CashEventsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.createdByActorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashEventsCompanion.insert({
    required String id,
    required String paymentId,
    required String createdByActorId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       paymentId = Value(paymentId),
       createdByActorId = Value(createdByActorId),
       createdAt = Value(createdAt);
  static Insertable<CashEvent> custom({
    Expression<String>? id,
    Expression<String>? paymentId,
    Expression<String>? createdByActorId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'cash_event_id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (createdByActorId != null) 'created_by_actor_id': createdByActorId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? paymentId,
    Value<String>? createdByActorId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CashEventsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      createdByActorId: createdByActorId ?? this.createdByActorId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['cash_event_id'] = Variable<String>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (createdByActorId.present) {
      map['created_by_actor_id'] = Variable<String>(createdByActorId.value);
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
    return (StringBuffer('CashEventsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('createdByActorId: $createdByActorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialTransactionsTable extends FinancialTransactions
    with TableInfo<$FinancialTransactionsTable, FinancialTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashEventIdMeta = const VerificationMeta(
    'cashEventId',
  );
  @override
  late final GeneratedColumn<String> cashEventId = GeneratedColumn<String>(
    'cash_event_id',
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
  );
  static const VerificationMeta _financialAccountIdMeta =
      const VerificationMeta('financialAccountId');
  @override
  late final GeneratedColumn<String> financialAccountId =
      GeneratedColumn<String>(
        'financial_account_id',
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
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
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
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedTransactionIdMeta =
      const VerificationMeta('relatedTransactionId');
  @override
  late final GeneratedColumn<String> relatedTransactionId =
      GeneratedColumn<String>(
        'related_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    transactionType,
    direction,
    amountMinor,
    relatedTransactionId,
    actorId,
    reason,
    idempotencyKey,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['transaction_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _cashEventIdMeta,
        cashEventId.isAcceptableOrUnknown(
          data['cash_event_id']!,
          _cashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashEventIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('financial_account_id')) {
      context.handle(
        _financialAccountIdMeta,
        financialAccountId.isAcceptableOrUnknown(
          data['financial_account_id']!,
          _financialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialAccountIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_partyRoleMeta);
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
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('related_transaction_id')) {
      context.handle(
        _relatedTransactionIdMeta,
        relatedTransactionId.isAcceptableOrUnknown(
          data['related_transaction_id']!,
          _relatedTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, cashEventId, paymentId},
    {idempotencyKey},
  ];
  @override
  FinancialTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      cashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      financialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_account_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      relatedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_transaction_id'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $FinancialTransactionsTable createAlias(String alias) {
    return $FinancialTransactionsTable(attachedDatabase, alias);
  }
}

class FinancialTransaction extends DataClass
    implements Insertable<FinancialTransaction> {
  final String id;
  final String cashEventId;
  final String paymentId;
  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final String transactionType;
  final String direction;
  final int amountMinor;
  final String? relatedTransactionId;
  final String actorId;
  final String reason;
  final String? idempotencyKey;
  final DateTime occurredAt;
  const FinancialTransaction({
    required this.id,
    required this.cashEventId,
    required this.paymentId,
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.transactionType,
    required this.direction,
    required this.amountMinor,
    this.relatedTransactionId,
    required this.actorId,
    required this.reason,
    this.idempotencyKey,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(id);
    map['cash_event_id'] = Variable<String>(cashEventId);
    map['payment_id'] = Variable<String>(paymentId);
    map['financial_account_id'] = Variable<String>(financialAccountId);
    map['party_id'] = Variable<String>(partyId);
    map['party_role'] = Variable<String>(partyRole);
    map['currency_code'] = Variable<String>(currencyCode);
    map['transaction_type'] = Variable<String>(transactionType);
    map['direction'] = Variable<String>(direction);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || relatedTransactionId != null) {
      map['related_transaction_id'] = Variable<String>(relatedTransactionId);
    }
    map['actor_id'] = Variable<String>(actorId);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  FinancialTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FinancialTransactionsCompanion(
      id: Value(id),
      cashEventId: Value(cashEventId),
      paymentId: Value(paymentId),
      financialAccountId: Value(financialAccountId),
      partyId: Value(partyId),
      partyRole: Value(partyRole),
      currencyCode: Value(currencyCode),
      transactionType: Value(transactionType),
      direction: Value(direction),
      amountMinor: Value(amountMinor),
      relatedTransactionId: relatedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedTransactionId),
      actorId: Value(actorId),
      reason: Value(reason),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      occurredAt: Value(occurredAt),
    );
  }

  factory FinancialTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialTransaction(
      id: serializer.fromJson<String>(json['id']),
      cashEventId: serializer.fromJson<String>(json['cashEventId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      financialAccountId: serializer.fromJson<String>(
        json['financialAccountId'],
      ),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyRole: serializer.fromJson<String>(json['partyRole']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      direction: serializer.fromJson<String>(json['direction']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      relatedTransactionId: serializer.fromJson<String?>(
        json['relatedTransactionId'],
      ),
      actorId: serializer.fromJson<String>(json['actorId']),
      reason: serializer.fromJson<String>(json['reason']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cashEventId': serializer.toJson<String>(cashEventId),
      'paymentId': serializer.toJson<String>(paymentId),
      'financialAccountId': serializer.toJson<String>(financialAccountId),
      'partyId': serializer.toJson<String>(partyId),
      'partyRole': serializer.toJson<String>(partyRole),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'transactionType': serializer.toJson<String>(transactionType),
      'direction': serializer.toJson<String>(direction),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'relatedTransactionId': serializer.toJson<String?>(relatedTransactionId),
      'actorId': serializer.toJson<String>(actorId),
      'reason': serializer.toJson<String>(reason),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  FinancialTransaction copyWith({
    String? id,
    String? cashEventId,
    String? paymentId,
    String? financialAccountId,
    String? partyId,
    String? partyRole,
    String? currencyCode,
    String? transactionType,
    String? direction,
    int? amountMinor,
    Value<String?> relatedTransactionId = const Value.absent(),
    String? actorId,
    String? reason,
    Value<String?> idempotencyKey = const Value.absent(),
    DateTime? occurredAt,
  }) => FinancialTransaction(
    id: id ?? this.id,
    cashEventId: cashEventId ?? this.cashEventId,
    paymentId: paymentId ?? this.paymentId,
    financialAccountId: financialAccountId ?? this.financialAccountId,
    partyId: partyId ?? this.partyId,
    partyRole: partyRole ?? this.partyRole,
    currencyCode: currencyCode ?? this.currencyCode,
    transactionType: transactionType ?? this.transactionType,
    direction: direction ?? this.direction,
    amountMinor: amountMinor ?? this.amountMinor,
    relatedTransactionId: relatedTransactionId.present
        ? relatedTransactionId.value
        : this.relatedTransactionId,
    actorId: actorId ?? this.actorId,
    reason: reason ?? this.reason,
    idempotencyKey: idempotencyKey.present
        ? idempotencyKey.value
        : this.idempotencyKey,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  FinancialTransaction copyWithCompanion(FinancialTransactionsCompanion data) {
    return FinancialTransaction(
      id: data.id.present ? data.id.value : this.id,
      cashEventId: data.cashEventId.present
          ? data.cashEventId.value
          : this.cashEventId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      financialAccountId: data.financialAccountId.present
          ? data.financialAccountId.value
          : this.financialAccountId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      direction: data.direction.present ? data.direction.value : this.direction,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      relatedTransactionId: data.relatedTransactionId.present
          ? data.relatedTransactionId.value
          : this.relatedTransactionId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialTransaction(')
          ..write('id: $id, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('transactionType: $transactionType, ')
          ..write('direction: $direction, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('relatedTransactionId: $relatedTransactionId, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    transactionType,
    direction,
    amountMinor,
    relatedTransactionId,
    actorId,
    reason,
    idempotencyKey,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialTransaction &&
          other.id == this.id &&
          other.cashEventId == this.cashEventId &&
          other.paymentId == this.paymentId &&
          other.financialAccountId == this.financialAccountId &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.currencyCode == this.currencyCode &&
          other.transactionType == this.transactionType &&
          other.direction == this.direction &&
          other.amountMinor == this.amountMinor &&
          other.relatedTransactionId == this.relatedTransactionId &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.idempotencyKey == this.idempotencyKey &&
          other.occurredAt == this.occurredAt);
}

class FinancialTransactionsCompanion
    extends UpdateCompanion<FinancialTransaction> {
  final Value<String> id;
  final Value<String> cashEventId;
  final Value<String> paymentId;
  final Value<String> financialAccountId;
  final Value<String> partyId;
  final Value<String> partyRole;
  final Value<String> currencyCode;
  final Value<String> transactionType;
  final Value<String> direction;
  final Value<int> amountMinor;
  final Value<String?> relatedTransactionId;
  final Value<String> actorId;
  final Value<String> reason;
  final Value<String?> idempotencyKey;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const FinancialTransactionsCompanion({
    this.id = const Value.absent(),
    this.cashEventId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.direction = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.relatedTransactionId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialTransactionsCompanion.insert({
    required String id,
    required String cashEventId,
    required String paymentId,
    required String financialAccountId,
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required String transactionType,
    required String direction,
    required int amountMinor,
    this.relatedTransactionId = const Value.absent(),
    required String actorId,
    required String reason,
    this.idempotencyKey = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cashEventId = Value(cashEventId),
       paymentId = Value(paymentId),
       financialAccountId = Value(financialAccountId),
       partyId = Value(partyId),
       partyRole = Value(partyRole),
       currencyCode = Value(currencyCode),
       transactionType = Value(transactionType),
       direction = Value(direction),
       amountMinor = Value(amountMinor),
       actorId = Value(actorId),
       reason = Value(reason),
       occurredAt = Value(occurredAt);
  static Insertable<FinancialTransaction> custom({
    Expression<String>? id,
    Expression<String>? cashEventId,
    Expression<String>? paymentId,
    Expression<String>? financialAccountId,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? currencyCode,
    Expression<String>? transactionType,
    Expression<String>? direction,
    Expression<int>? amountMinor,
    Expression<String>? relatedTransactionId,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'transaction_id': id,
      if (cashEventId != null) 'cash_event_id': cashEventId,
      if (paymentId != null) 'payment_id': paymentId,
      if (financialAccountId != null)
        'financial_account_id': financialAccountId,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (transactionType != null) 'transaction_type': transactionType,
      if (direction != null) 'direction': direction,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (relatedTransactionId != null)
        'related_transaction_id': relatedTransactionId,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? cashEventId,
    Value<String>? paymentId,
    Value<String>? financialAccountId,
    Value<String>? partyId,
    Value<String>? partyRole,
    Value<String>? currencyCode,
    Value<String>? transactionType,
    Value<String>? direction,
    Value<int>? amountMinor,
    Value<String?>? relatedTransactionId,
    Value<String>? actorId,
    Value<String>? reason,
    Value<String?>? idempotencyKey,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return FinancialTransactionsCompanion(
      id: id ?? this.id,
      cashEventId: cashEventId ?? this.cashEventId,
      paymentId: paymentId ?? this.paymentId,
      financialAccountId: financialAccountId ?? this.financialAccountId,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      currencyCode: currencyCode ?? this.currencyCode,
      transactionType: transactionType ?? this.transactionType,
      direction: direction ?? this.direction,
      amountMinor: amountMinor ?? this.amountMinor,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['transaction_id'] = Variable<String>(id.value);
    }
    if (cashEventId.present) {
      map['cash_event_id'] = Variable<String>(cashEventId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (financialAccountId.present) {
      map['financial_account_id'] = Variable<String>(financialAccountId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (relatedTransactionId.present) {
      map['related_transaction_id'] = Variable<String>(
        relatedTransactionId.value,
      );
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('transactionType: $transactionType, ')
          ..write('direction: $direction, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('relatedTransactionId: $relatedTransactionId, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashEventVersionsTable extends CashEventVersions
    with TableInfo<$CashEventVersionsTable, CashEventVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashEventVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashEventIdMeta = const VerificationMeta(
    'cashEventId',
  );
  @override
  late final GeneratedColumn<String> cashEventId = GeneratedColumn<String>(
    'cash_event_id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredMeta = const VerificationMeta(
    'occurred',
  );
  @override
  late final GeneratedColumn<String> occurred = GeneratedColumn<String>(
    'occurred',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashDirectionMeta = const VerificationMeta(
    'cashDirection',
  );
  @override
  late final GeneratedColumn<String> cashDirection = GeneratedColumn<String>(
    'cash_direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _physicalAmountMinorMeta =
      const VerificationMeta('physicalAmountMinor');
  @override
  late final GeneratedColumn<int> physicalAmountMinor = GeneratedColumn<int>(
    'physical_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveRecognizedMinorMeta =
      const VerificationMeta('effectiveRecognizedMinor');
  @override
  late final GeneratedColumn<int> effectiveRecognizedMinor =
      GeneratedColumn<int>(
        'effective_recognized_minor',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousVersionIdMeta = const VerificationMeta(
    'previousVersionId',
  );
  @override
  late final GeneratedColumn<String> previousVersionId =
      GeneratedColumn<String>(
        'previous_version_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestPayloadMeta = const VerificationMeta(
    'requestPayload',
  );
  @override
  late final GeneratedColumn<String> requestPayload = GeneratedColumn<String>(
    'request_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cashEventId,
    paymentId,
    sequence,
    operation,
    occurred,
    cashDirection,
    physicalAmountMinor,
    effectiveRecognizedMinor,
    transactionId,
    previousVersionId,
    idempotencyKey,
    requestPayload,
    actorId,
    reason,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_event_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashEventVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['version_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _cashEventIdMeta,
        cashEventId.isAcceptableOrUnknown(
          data['cash_event_id']!,
          _cashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashEventIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('occurred')) {
      context.handle(
        _occurredMeta,
        occurred.isAcceptableOrUnknown(data['occurred']!, _occurredMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredMeta);
    }
    if (data.containsKey('cash_direction')) {
      context.handle(
        _cashDirectionMeta,
        cashDirection.isAcceptableOrUnknown(
          data['cash_direction']!,
          _cashDirectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashDirectionMeta);
    }
    if (data.containsKey('physical_amount_minor')) {
      context.handle(
        _physicalAmountMinorMeta,
        physicalAmountMinor.isAcceptableOrUnknown(
          data['physical_amount_minor']!,
          _physicalAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_physicalAmountMinorMeta);
    }
    if (data.containsKey('effective_recognized_minor')) {
      context.handle(
        _effectiveRecognizedMinorMeta,
        effectiveRecognizedMinor.isAcceptableOrUnknown(
          data['effective_recognized_minor']!,
          _effectiveRecognizedMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveRecognizedMinorMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('previous_version_id')) {
      context.handle(
        _previousVersionIdMeta,
        previousVersionId.isAcceptableOrUnknown(
          data['previous_version_id']!,
          _previousVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_payload')) {
      context.handle(
        _requestPayloadMeta,
        requestPayload.isAcceptableOrUnknown(
          data['request_payload']!,
          _requestPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestPayloadMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cashEventId, sequence},
    {id, cashEventId, paymentId},
    {idempotencyKey},
  ];
  @override
  CashEventVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashEventVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      cashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      occurred: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred'],
      )!,
      cashDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_direction'],
      )!,
      physicalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}physical_amount_minor'],
      )!,
      effectiveRecognizedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_recognized_minor'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      previousVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_version_id'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_payload'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $CashEventVersionsTable createAlias(String alias) {
    return $CashEventVersionsTable(attachedDatabase, alias);
  }
}

class CashEventVersion extends DataClass
    implements Insertable<CashEventVersion> {
  final String id;
  final String cashEventId;
  final String paymentId;
  final int sequence;
  final String operation;
  final String occurred;
  final String cashDirection;
  final int physicalAmountMinor;
  final int effectiveRecognizedMinor;
  final String? transactionId;
  final String? previousVersionId;
  final String idempotencyKey;
  final String requestPayload;
  final String actorId;
  final String reason;
  final DateTime recordedAt;
  const CashEventVersion({
    required this.id,
    required this.cashEventId,
    required this.paymentId,
    required this.sequence,
    required this.operation,
    required this.occurred,
    required this.cashDirection,
    required this.physicalAmountMinor,
    required this.effectiveRecognizedMinor,
    this.transactionId,
    this.previousVersionId,
    required this.idempotencyKey,
    required this.requestPayload,
    required this.actorId,
    required this.reason,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version_id'] = Variable<String>(id);
    map['cash_event_id'] = Variable<String>(cashEventId);
    map['payment_id'] = Variable<String>(paymentId);
    map['sequence'] = Variable<int>(sequence);
    map['operation'] = Variable<String>(operation);
    map['occurred'] = Variable<String>(occurred);
    map['cash_direction'] = Variable<String>(cashDirection);
    map['physical_amount_minor'] = Variable<int>(physicalAmountMinor);
    map['effective_recognized_minor'] = Variable<int>(effectiveRecognizedMinor);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    if (!nullToAbsent || previousVersionId != null) {
      map['previous_version_id'] = Variable<String>(previousVersionId);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_payload'] = Variable<String>(requestPayload);
    map['actor_id'] = Variable<String>(actorId);
    map['reason'] = Variable<String>(reason);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  CashEventVersionsCompanion toCompanion(bool nullToAbsent) {
    return CashEventVersionsCompanion(
      id: Value(id),
      cashEventId: Value(cashEventId),
      paymentId: Value(paymentId),
      sequence: Value(sequence),
      operation: Value(operation),
      occurred: Value(occurred),
      cashDirection: Value(cashDirection),
      physicalAmountMinor: Value(physicalAmountMinor),
      effectiveRecognizedMinor: Value(effectiveRecognizedMinor),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      previousVersionId: previousVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousVersionId),
      idempotencyKey: Value(idempotencyKey),
      requestPayload: Value(requestPayload),
      actorId: Value(actorId),
      reason: Value(reason),
      recordedAt: Value(recordedAt),
    );
  }

  factory CashEventVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashEventVersion(
      id: serializer.fromJson<String>(json['id']),
      cashEventId: serializer.fromJson<String>(json['cashEventId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      operation: serializer.fromJson<String>(json['operation']),
      occurred: serializer.fromJson<String>(json['occurred']),
      cashDirection: serializer.fromJson<String>(json['cashDirection']),
      physicalAmountMinor: serializer.fromJson<int>(
        json['physicalAmountMinor'],
      ),
      effectiveRecognizedMinor: serializer.fromJson<int>(
        json['effectiveRecognizedMinor'],
      ),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      previousVersionId: serializer.fromJson<String?>(
        json['previousVersionId'],
      ),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestPayload: serializer.fromJson<String>(json['requestPayload']),
      actorId: serializer.fromJson<String>(json['actorId']),
      reason: serializer.fromJson<String>(json['reason']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cashEventId': serializer.toJson<String>(cashEventId),
      'paymentId': serializer.toJson<String>(paymentId),
      'sequence': serializer.toJson<int>(sequence),
      'operation': serializer.toJson<String>(operation),
      'occurred': serializer.toJson<String>(occurred),
      'cashDirection': serializer.toJson<String>(cashDirection),
      'physicalAmountMinor': serializer.toJson<int>(physicalAmountMinor),
      'effectiveRecognizedMinor': serializer.toJson<int>(
        effectiveRecognizedMinor,
      ),
      'transactionId': serializer.toJson<String?>(transactionId),
      'previousVersionId': serializer.toJson<String?>(previousVersionId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestPayload': serializer.toJson<String>(requestPayload),
      'actorId': serializer.toJson<String>(actorId),
      'reason': serializer.toJson<String>(reason),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  CashEventVersion copyWith({
    String? id,
    String? cashEventId,
    String? paymentId,
    int? sequence,
    String? operation,
    String? occurred,
    String? cashDirection,
    int? physicalAmountMinor,
    int? effectiveRecognizedMinor,
    Value<String?> transactionId = const Value.absent(),
    Value<String?> previousVersionId = const Value.absent(),
    String? idempotencyKey,
    String? requestPayload,
    String? actorId,
    String? reason,
    DateTime? recordedAt,
  }) => CashEventVersion(
    id: id ?? this.id,
    cashEventId: cashEventId ?? this.cashEventId,
    paymentId: paymentId ?? this.paymentId,
    sequence: sequence ?? this.sequence,
    operation: operation ?? this.operation,
    occurred: occurred ?? this.occurred,
    cashDirection: cashDirection ?? this.cashDirection,
    physicalAmountMinor: physicalAmountMinor ?? this.physicalAmountMinor,
    effectiveRecognizedMinor:
        effectiveRecognizedMinor ?? this.effectiveRecognizedMinor,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    previousVersionId: previousVersionId.present
        ? previousVersionId.value
        : this.previousVersionId,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestPayload: requestPayload ?? this.requestPayload,
    actorId: actorId ?? this.actorId,
    reason: reason ?? this.reason,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  CashEventVersion copyWithCompanion(CashEventVersionsCompanion data) {
    return CashEventVersion(
      id: data.id.present ? data.id.value : this.id,
      cashEventId: data.cashEventId.present
          ? data.cashEventId.value
          : this.cashEventId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      operation: data.operation.present ? data.operation.value : this.operation,
      occurred: data.occurred.present ? data.occurred.value : this.occurred,
      cashDirection: data.cashDirection.present
          ? data.cashDirection.value
          : this.cashDirection,
      physicalAmountMinor: data.physicalAmountMinor.present
          ? data.physicalAmountMinor.value
          : this.physicalAmountMinor,
      effectiveRecognizedMinor: data.effectiveRecognizedMinor.present
          ? data.effectiveRecognizedMinor.value
          : this.effectiveRecognizedMinor,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      previousVersionId: data.previousVersionId.present
          ? data.previousVersionId.value
          : this.previousVersionId,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestPayload: data.requestPayload.present
          ? data.requestPayload.value
          : this.requestPayload,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashEventVersion(')
          ..write('id: $id, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('sequence: $sequence, ')
          ..write('operation: $operation, ')
          ..write('occurred: $occurred, ')
          ..write('cashDirection: $cashDirection, ')
          ..write('physicalAmountMinor: $physicalAmountMinor, ')
          ..write('effectiveRecognizedMinor: $effectiveRecognizedMinor, ')
          ..write('transactionId: $transactionId, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayload: $requestPayload, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cashEventId,
    paymentId,
    sequence,
    operation,
    occurred,
    cashDirection,
    physicalAmountMinor,
    effectiveRecognizedMinor,
    transactionId,
    previousVersionId,
    idempotencyKey,
    requestPayload,
    actorId,
    reason,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashEventVersion &&
          other.id == this.id &&
          other.cashEventId == this.cashEventId &&
          other.paymentId == this.paymentId &&
          other.sequence == this.sequence &&
          other.operation == this.operation &&
          other.occurred == this.occurred &&
          other.cashDirection == this.cashDirection &&
          other.physicalAmountMinor == this.physicalAmountMinor &&
          other.effectiveRecognizedMinor == this.effectiveRecognizedMinor &&
          other.transactionId == this.transactionId &&
          other.previousVersionId == this.previousVersionId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestPayload == this.requestPayload &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.recordedAt == this.recordedAt);
}

class CashEventVersionsCompanion extends UpdateCompanion<CashEventVersion> {
  final Value<String> id;
  final Value<String> cashEventId;
  final Value<String> paymentId;
  final Value<int> sequence;
  final Value<String> operation;
  final Value<String> occurred;
  final Value<String> cashDirection;
  final Value<int> physicalAmountMinor;
  final Value<int> effectiveRecognizedMinor;
  final Value<String?> transactionId;
  final Value<String?> previousVersionId;
  final Value<String> idempotencyKey;
  final Value<String> requestPayload;
  final Value<String> actorId;
  final Value<String> reason;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const CashEventVersionsCompanion({
    this.id = const Value.absent(),
    this.cashEventId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.operation = const Value.absent(),
    this.occurred = const Value.absent(),
    this.cashDirection = const Value.absent(),
    this.physicalAmountMinor = const Value.absent(),
    this.effectiveRecognizedMinor = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.previousVersionId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestPayload = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashEventVersionsCompanion.insert({
    required String id,
    required String cashEventId,
    required String paymentId,
    required int sequence,
    required String operation,
    required String occurred,
    required String cashDirection,
    required int physicalAmountMinor,
    required int effectiveRecognizedMinor,
    this.transactionId = const Value.absent(),
    this.previousVersionId = const Value.absent(),
    required String idempotencyKey,
    required String requestPayload,
    required String actorId,
    required String reason,
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cashEventId = Value(cashEventId),
       paymentId = Value(paymentId),
       sequence = Value(sequence),
       operation = Value(operation),
       occurred = Value(occurred),
       cashDirection = Value(cashDirection),
       physicalAmountMinor = Value(physicalAmountMinor),
       effectiveRecognizedMinor = Value(effectiveRecognizedMinor),
       idempotencyKey = Value(idempotencyKey),
       requestPayload = Value(requestPayload),
       actorId = Value(actorId),
       reason = Value(reason),
       recordedAt = Value(recordedAt);
  static Insertable<CashEventVersion> custom({
    Expression<String>? id,
    Expression<String>? cashEventId,
    Expression<String>? paymentId,
    Expression<int>? sequence,
    Expression<String>? operation,
    Expression<String>? occurred,
    Expression<String>? cashDirection,
    Expression<int>? physicalAmountMinor,
    Expression<int>? effectiveRecognizedMinor,
    Expression<String>? transactionId,
    Expression<String>? previousVersionId,
    Expression<String>? idempotencyKey,
    Expression<String>? requestPayload,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'version_id': id,
      if (cashEventId != null) 'cash_event_id': cashEventId,
      if (paymentId != null) 'payment_id': paymentId,
      if (sequence != null) 'sequence': sequence,
      if (operation != null) 'operation': operation,
      if (occurred != null) 'occurred': occurred,
      if (cashDirection != null) 'cash_direction': cashDirection,
      if (physicalAmountMinor != null)
        'physical_amount_minor': physicalAmountMinor,
      if (effectiveRecognizedMinor != null)
        'effective_recognized_minor': effectiveRecognizedMinor,
      if (transactionId != null) 'transaction_id': transactionId,
      if (previousVersionId != null) 'previous_version_id': previousVersionId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestPayload != null) 'request_payload': requestPayload,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashEventVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? cashEventId,
    Value<String>? paymentId,
    Value<int>? sequence,
    Value<String>? operation,
    Value<String>? occurred,
    Value<String>? cashDirection,
    Value<int>? physicalAmountMinor,
    Value<int>? effectiveRecognizedMinor,
    Value<String?>? transactionId,
    Value<String?>? previousVersionId,
    Value<String>? idempotencyKey,
    Value<String>? requestPayload,
    Value<String>? actorId,
    Value<String>? reason,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return CashEventVersionsCompanion(
      id: id ?? this.id,
      cashEventId: cashEventId ?? this.cashEventId,
      paymentId: paymentId ?? this.paymentId,
      sequence: sequence ?? this.sequence,
      operation: operation ?? this.operation,
      occurred: occurred ?? this.occurred,
      cashDirection: cashDirection ?? this.cashDirection,
      physicalAmountMinor: physicalAmountMinor ?? this.physicalAmountMinor,
      effectiveRecognizedMinor:
          effectiveRecognizedMinor ?? this.effectiveRecognizedMinor,
      transactionId: transactionId ?? this.transactionId,
      previousVersionId: previousVersionId ?? this.previousVersionId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestPayload: requestPayload ?? this.requestPayload,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['version_id'] = Variable<String>(id.value);
    }
    if (cashEventId.present) {
      map['cash_event_id'] = Variable<String>(cashEventId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (occurred.present) {
      map['occurred'] = Variable<String>(occurred.value);
    }
    if (cashDirection.present) {
      map['cash_direction'] = Variable<String>(cashDirection.value);
    }
    if (physicalAmountMinor.present) {
      map['physical_amount_minor'] = Variable<int>(physicalAmountMinor.value);
    }
    if (effectiveRecognizedMinor.present) {
      map['effective_recognized_minor'] = Variable<int>(
        effectiveRecognizedMinor.value,
      );
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (previousVersionId.present) {
      map['previous_version_id'] = Variable<String>(previousVersionId.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestPayload.present) {
      map['request_payload'] = Variable<String>(requestPayload.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashEventVersionsCompanion(')
          ..write('id: $id, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('sequence: $sequence, ')
          ..write('operation: $operation, ')
          ..write('occurred: $occurred, ')
          ..write('cashDirection: $cashDirection, ')
          ..write('physicalAmountMinor: $physicalAmountMinor, ')
          ..write('effectiveRecognizedMinor: $effectiveRecognizedMinor, ')
          ..write('transactionId: $transactionId, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayload: $requestPayload, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashEventHeadsTable extends CashEventHeads
    with TableInfo<$CashEventHeadsTable, CashEventHead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashEventHeadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cashEventIdMeta = const VerificationMeta(
    'cashEventId',
  );
  @override
  late final GeneratedColumn<String> cashEventId = GeneratedColumn<String>(
    'cash_event_id',
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
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    cashEventId,
    paymentId,
    versionId,
    revision,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_event_heads';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashEventHead> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _cashEventIdMeta,
        cashEventId.isAcceptableOrUnknown(
          data['cash_event_id']!,
          _cashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashEventIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
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
  Set<GeneratedColumn> get $primaryKey => {cashEventId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cashEventId, paymentId},
  ];
  @override
  CashEventHead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashEventHead(
      cashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CashEventHeadsTable createAlias(String alias) {
    return $CashEventHeadsTable(attachedDatabase, alias);
  }
}

class CashEventHead extends DataClass implements Insertable<CashEventHead> {
  final String cashEventId;
  final String paymentId;
  final String versionId;
  final int revision;
  final DateTime updatedAt;
  const CashEventHead({
    required this.cashEventId,
    required this.paymentId,
    required this.versionId,
    required this.revision,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cash_event_id'] = Variable<String>(cashEventId);
    map['payment_id'] = Variable<String>(paymentId);
    map['version_id'] = Variable<String>(versionId);
    map['revision'] = Variable<int>(revision);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CashEventHeadsCompanion toCompanion(bool nullToAbsent) {
    return CashEventHeadsCompanion(
      cashEventId: Value(cashEventId),
      paymentId: Value(paymentId),
      versionId: Value(versionId),
      revision: Value(revision),
      updatedAt: Value(updatedAt),
    );
  }

  factory CashEventHead.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashEventHead(
      cashEventId: serializer.fromJson<String>(json['cashEventId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      versionId: serializer.fromJson<String>(json['versionId']),
      revision: serializer.fromJson<int>(json['revision']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cashEventId': serializer.toJson<String>(cashEventId),
      'paymentId': serializer.toJson<String>(paymentId),
      'versionId': serializer.toJson<String>(versionId),
      'revision': serializer.toJson<int>(revision),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CashEventHead copyWith({
    String? cashEventId,
    String? paymentId,
    String? versionId,
    int? revision,
    DateTime? updatedAt,
  }) => CashEventHead(
    cashEventId: cashEventId ?? this.cashEventId,
    paymentId: paymentId ?? this.paymentId,
    versionId: versionId ?? this.versionId,
    revision: revision ?? this.revision,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CashEventHead copyWithCompanion(CashEventHeadsCompanion data) {
    return CashEventHead(
      cashEventId: data.cashEventId.present
          ? data.cashEventId.value
          : this.cashEventId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashEventHead(')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('versionId: $versionId, ')
          ..write('revision: $revision, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cashEventId, paymentId, versionId, revision, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashEventHead &&
          other.cashEventId == this.cashEventId &&
          other.paymentId == this.paymentId &&
          other.versionId == this.versionId &&
          other.revision == this.revision &&
          other.updatedAt == this.updatedAt);
}

class CashEventHeadsCompanion extends UpdateCompanion<CashEventHead> {
  final Value<String> cashEventId;
  final Value<String> paymentId;
  final Value<String> versionId;
  final Value<int> revision;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CashEventHeadsCompanion({
    this.cashEventId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.versionId = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashEventHeadsCompanion.insert({
    required String cashEventId,
    required String paymentId,
    required String versionId,
    required int revision,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : cashEventId = Value(cashEventId),
       paymentId = Value(paymentId),
       versionId = Value(versionId),
       revision = Value(revision),
       updatedAt = Value(updatedAt);
  static Insertable<CashEventHead> custom({
    Expression<String>? cashEventId,
    Expression<String>? paymentId,
    Expression<String>? versionId,
    Expression<int>? revision,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cashEventId != null) 'cash_event_id': cashEventId,
      if (paymentId != null) 'payment_id': paymentId,
      if (versionId != null) 'version_id': versionId,
      if (revision != null) 'revision': revision,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashEventHeadsCompanion copyWith({
    Value<String>? cashEventId,
    Value<String>? paymentId,
    Value<String>? versionId,
    Value<int>? revision,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CashEventHeadsCompanion(
      cashEventId: cashEventId ?? this.cashEventId,
      paymentId: paymentId ?? this.paymentId,
      versionId: versionId ?? this.versionId,
      revision: revision ?? this.revision,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cashEventId.present) {
      map['cash_event_id'] = Variable<String>(cashEventId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
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
    return (StringBuffer('CashEventHeadsCompanion(')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('versionId: $versionId, ')
          ..write('revision: $revision, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReconciliationCasesTable extends ReconciliationCases
    with TableInfo<$ReconciliationCasesTable, ReconciliationCase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReconciliationCasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashEventIdMeta = const VerificationMeta(
    'cashEventId',
  );
  @override
  late final GeneratedColumn<String> cashEventId = GeneratedColumn<String>(
    'cash_event_id',
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
  );
  static const VerificationMeta _financialAccountIdMeta =
      const VerificationMeta('financialAccountId');
  @override
  late final GeneratedColumn<String> financialAccountId =
      GeneratedColumn<String>(
        'financial_account_id',
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
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
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
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByActorIdMeta = const VerificationMeta(
    'createdByActorId',
  );
  @override
  late final GeneratedColumn<String> createdByActorId = GeneratedColumn<String>(
    'created_by_actor_id',
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
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    reason,
    createdByActorId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reconciliation_cases';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReconciliationCase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('case_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['case_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _cashEventIdMeta,
        cashEventId.isAcceptableOrUnknown(
          data['cash_event_id']!,
          _cashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashEventIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('financial_account_id')) {
      context.handle(
        _financialAccountIdMeta,
        financialAccountId.isAcceptableOrUnknown(
          data['financial_account_id']!,
          _financialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialAccountIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_partyRoleMeta);
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
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_by_actor_id')) {
      context.handle(
        _createdByActorIdMeta,
        createdByActorId.isAcceptableOrUnknown(
          data['created_by_actor_id']!,
          _createdByActorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByActorIdMeta);
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
    {
      id,
      cashEventId,
      paymentId,
      financialAccountId,
      partyId,
      partyRole,
      currencyCode,
    },
  ];
  @override
  ReconciliationCase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReconciliationCase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      cashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      financialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_account_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdByActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_actor_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReconciliationCasesTable createAlias(String alias) {
    return $ReconciliationCasesTable(attachedDatabase, alias);
  }
}

class ReconciliationCase extends DataClass
    implements Insertable<ReconciliationCase> {
  final String id;
  final String cashEventId;
  final String paymentId;
  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final String reason;
  final String createdByActorId;
  final DateTime createdAt;
  const ReconciliationCase({
    required this.id,
    required this.cashEventId,
    required this.paymentId,
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.reason,
    required this.createdByActorId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['case_id'] = Variable<String>(id);
    map['cash_event_id'] = Variable<String>(cashEventId);
    map['payment_id'] = Variable<String>(paymentId);
    map['financial_account_id'] = Variable<String>(financialAccountId);
    map['party_id'] = Variable<String>(partyId);
    map['party_role'] = Variable<String>(partyRole);
    map['currency_code'] = Variable<String>(currencyCode);
    map['reason'] = Variable<String>(reason);
    map['created_by_actor_id'] = Variable<String>(createdByActorId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReconciliationCasesCompanion toCompanion(bool nullToAbsent) {
    return ReconciliationCasesCompanion(
      id: Value(id),
      cashEventId: Value(cashEventId),
      paymentId: Value(paymentId),
      financialAccountId: Value(financialAccountId),
      partyId: Value(partyId),
      partyRole: Value(partyRole),
      currencyCode: Value(currencyCode),
      reason: Value(reason),
      createdByActorId: Value(createdByActorId),
      createdAt: Value(createdAt),
    );
  }

  factory ReconciliationCase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReconciliationCase(
      id: serializer.fromJson<String>(json['id']),
      cashEventId: serializer.fromJson<String>(json['cashEventId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      financialAccountId: serializer.fromJson<String>(
        json['financialAccountId'],
      ),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyRole: serializer.fromJson<String>(json['partyRole']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      reason: serializer.fromJson<String>(json['reason']),
      createdByActorId: serializer.fromJson<String>(json['createdByActorId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cashEventId': serializer.toJson<String>(cashEventId),
      'paymentId': serializer.toJson<String>(paymentId),
      'financialAccountId': serializer.toJson<String>(financialAccountId),
      'partyId': serializer.toJson<String>(partyId),
      'partyRole': serializer.toJson<String>(partyRole),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'reason': serializer.toJson<String>(reason),
      'createdByActorId': serializer.toJson<String>(createdByActorId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReconciliationCase copyWith({
    String? id,
    String? cashEventId,
    String? paymentId,
    String? financialAccountId,
    String? partyId,
    String? partyRole,
    String? currencyCode,
    String? reason,
    String? createdByActorId,
    DateTime? createdAt,
  }) => ReconciliationCase(
    id: id ?? this.id,
    cashEventId: cashEventId ?? this.cashEventId,
    paymentId: paymentId ?? this.paymentId,
    financialAccountId: financialAccountId ?? this.financialAccountId,
    partyId: partyId ?? this.partyId,
    partyRole: partyRole ?? this.partyRole,
    currencyCode: currencyCode ?? this.currencyCode,
    reason: reason ?? this.reason,
    createdByActorId: createdByActorId ?? this.createdByActorId,
    createdAt: createdAt ?? this.createdAt,
  );
  ReconciliationCase copyWithCompanion(ReconciliationCasesCompanion data) {
    return ReconciliationCase(
      id: data.id.present ? data.id.value : this.id,
      cashEventId: data.cashEventId.present
          ? data.cashEventId.value
          : this.cashEventId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      financialAccountId: data.financialAccountId.present
          ? data.financialAccountId.value
          : this.financialAccountId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdByActorId: data.createdByActorId.present
          ? data.createdByActorId.value
          : this.createdByActorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReconciliationCase(')
          ..write('id: $id, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('reason: $reason, ')
          ..write('createdByActorId: $createdByActorId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    reason,
    createdByActorId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReconciliationCase &&
          other.id == this.id &&
          other.cashEventId == this.cashEventId &&
          other.paymentId == this.paymentId &&
          other.financialAccountId == this.financialAccountId &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.currencyCode == this.currencyCode &&
          other.reason == this.reason &&
          other.createdByActorId == this.createdByActorId &&
          other.createdAt == this.createdAt);
}

class ReconciliationCasesCompanion extends UpdateCompanion<ReconciliationCase> {
  final Value<String> id;
  final Value<String> cashEventId;
  final Value<String> paymentId;
  final Value<String> financialAccountId;
  final Value<String> partyId;
  final Value<String> partyRole;
  final Value<String> currencyCode;
  final Value<String> reason;
  final Value<String> createdByActorId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReconciliationCasesCompanion({
    this.id = const Value.absent(),
    this.cashEventId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdByActorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReconciliationCasesCompanion.insert({
    required String id,
    required String cashEventId,
    required String paymentId,
    required String financialAccountId,
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required String reason,
    required String createdByActorId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cashEventId = Value(cashEventId),
       paymentId = Value(paymentId),
       financialAccountId = Value(financialAccountId),
       partyId = Value(partyId),
       partyRole = Value(partyRole),
       currencyCode = Value(currencyCode),
       reason = Value(reason),
       createdByActorId = Value(createdByActorId),
       createdAt = Value(createdAt);
  static Insertable<ReconciliationCase> custom({
    Expression<String>? id,
    Expression<String>? cashEventId,
    Expression<String>? paymentId,
    Expression<String>? financialAccountId,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? currencyCode,
    Expression<String>? reason,
    Expression<String>? createdByActorId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'case_id': id,
      if (cashEventId != null) 'cash_event_id': cashEventId,
      if (paymentId != null) 'payment_id': paymentId,
      if (financialAccountId != null)
        'financial_account_id': financialAccountId,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (reason != null) 'reason': reason,
      if (createdByActorId != null) 'created_by_actor_id': createdByActorId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReconciliationCasesCompanion copyWith({
    Value<String>? id,
    Value<String>? cashEventId,
    Value<String>? paymentId,
    Value<String>? financialAccountId,
    Value<String>? partyId,
    Value<String>? partyRole,
    Value<String>? currencyCode,
    Value<String>? reason,
    Value<String>? createdByActorId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReconciliationCasesCompanion(
      id: id ?? this.id,
      cashEventId: cashEventId ?? this.cashEventId,
      paymentId: paymentId ?? this.paymentId,
      financialAccountId: financialAccountId ?? this.financialAccountId,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      currencyCode: currencyCode ?? this.currencyCode,
      reason: reason ?? this.reason,
      createdByActorId: createdByActorId ?? this.createdByActorId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['case_id'] = Variable<String>(id.value);
    }
    if (cashEventId.present) {
      map['cash_event_id'] = Variable<String>(cashEventId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (financialAccountId.present) {
      map['financial_account_id'] = Variable<String>(financialAccountId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdByActorId.present) {
      map['created_by_actor_id'] = Variable<String>(createdByActorId.value);
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
    return (StringBuffer('ReconciliationCasesCompanion(')
          ..write('id: $id, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('reason: $reason, ')
          ..write('createdByActorId: $createdByActorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuspenseResolutionsTable extends SuspenseResolutions
    with TableInfo<$SuspenseResolutionsTable, SuspenseResolution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuspenseResolutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'resolution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashEventIdMeta = const VerificationMeta(
    'cashEventId',
  );
  @override
  late final GeneratedColumn<String> cashEventId = GeneratedColumn<String>(
    'cash_event_id',
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
  );
  static const VerificationMeta _financialAccountIdMeta =
      const VerificationMeta('financialAccountId');
  @override
  late final GeneratedColumn<String> financialAccountId =
      GeneratedColumn<String>(
        'financial_account_id',
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
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorizedByActorIdMeta =
      const VerificationMeta('authorizedByActorId');
  @override
  late final GeneratedColumn<String> authorizedByActorId =
      GeneratedColumn<String>(
        'authorized_by_actor_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _authorizationReferenceMeta =
      const VerificationMeta('authorizationReference');
  @override
  late final GeneratedColumn<String> authorizationReference =
      GeneratedColumn<String>(
        'authorization_reference',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestPayloadMeta = const VerificationMeta(
    'requestPayload',
  );
  @override
  late final GeneratedColumn<String> requestPayload = GeneratedColumn<String>(
    'request_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    caseId,
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    amountMinor,
    actorId,
    authorizedByActorId,
    authorizationReference,
    reason,
    idempotencyKey,
    requestPayload,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suspense_resolutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuspenseResolution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resolution_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['resolution_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _cashEventIdMeta,
        cashEventId.isAcceptableOrUnknown(
          data['cash_event_id']!,
          _cashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashEventIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('financial_account_id')) {
      context.handle(
        _financialAccountIdMeta,
        financialAccountId.isAcceptableOrUnknown(
          data['financial_account_id']!,
          _financialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialAccountIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_partyRoleMeta);
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
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('authorized_by_actor_id')) {
      context.handle(
        _authorizedByActorIdMeta,
        authorizedByActorId.isAcceptableOrUnknown(
          data['authorized_by_actor_id']!,
          _authorizedByActorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorizedByActorIdMeta);
    }
    if (data.containsKey('authorization_reference')) {
      context.handle(
        _authorizationReferenceMeta,
        authorizationReference.isAcceptableOrUnknown(
          data['authorization_reference']!,
          _authorizationReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorizationReferenceMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_payload')) {
      context.handle(
        _requestPayloadMeta,
        requestPayload.isAcceptableOrUnknown(
          data['request_payload']!,
          _requestPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestPayloadMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_resolvedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {
      id,
      caseId,
      cashEventId,
      paymentId,
      financialAccountId,
      partyId,
      partyRole,
      currencyCode,
    },
    {idempotencyKey},
  ];
  @override
  SuspenseResolution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuspenseResolution(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      cashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      financialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_account_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      authorizedByActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authorized_by_actor_id'],
      )!,
      authorizationReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authorization_reference'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_payload'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      )!,
    );
  }

  @override
  $SuspenseResolutionsTable createAlias(String alias) {
    return $SuspenseResolutionsTable(attachedDatabase, alias);
  }
}

class SuspenseResolution extends DataClass
    implements Insertable<SuspenseResolution> {
  final String id;
  final String caseId;
  final String cashEventId;
  final String paymentId;
  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final int amountMinor;
  final String actorId;
  final String authorizedByActorId;
  final String authorizationReference;
  final String reason;
  final String idempotencyKey;
  final String requestPayload;
  final DateTime resolvedAt;
  const SuspenseResolution({
    required this.id,
    required this.caseId,
    required this.cashEventId,
    required this.paymentId,
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.amountMinor,
    required this.actorId,
    required this.authorizedByActorId,
    required this.authorizationReference,
    required this.reason,
    required this.idempotencyKey,
    required this.requestPayload,
    required this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resolution_id'] = Variable<String>(id);
    map['case_id'] = Variable<String>(caseId);
    map['cash_event_id'] = Variable<String>(cashEventId);
    map['payment_id'] = Variable<String>(paymentId);
    map['financial_account_id'] = Variable<String>(financialAccountId);
    map['party_id'] = Variable<String>(partyId);
    map['party_role'] = Variable<String>(partyRole);
    map['currency_code'] = Variable<String>(currencyCode);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['actor_id'] = Variable<String>(actorId);
    map['authorized_by_actor_id'] = Variable<String>(authorizedByActorId);
    map['authorization_reference'] = Variable<String>(authorizationReference);
    map['reason'] = Variable<String>(reason);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_payload'] = Variable<String>(requestPayload);
    map['resolved_at'] = Variable<DateTime>(resolvedAt);
    return map;
  }

  SuspenseResolutionsCompanion toCompanion(bool nullToAbsent) {
    return SuspenseResolutionsCompanion(
      id: Value(id),
      caseId: Value(caseId),
      cashEventId: Value(cashEventId),
      paymentId: Value(paymentId),
      financialAccountId: Value(financialAccountId),
      partyId: Value(partyId),
      partyRole: Value(partyRole),
      currencyCode: Value(currencyCode),
      amountMinor: Value(amountMinor),
      actorId: Value(actorId),
      authorizedByActorId: Value(authorizedByActorId),
      authorizationReference: Value(authorizationReference),
      reason: Value(reason),
      idempotencyKey: Value(idempotencyKey),
      requestPayload: Value(requestPayload),
      resolvedAt: Value(resolvedAt),
    );
  }

  factory SuspenseResolution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuspenseResolution(
      id: serializer.fromJson<String>(json['id']),
      caseId: serializer.fromJson<String>(json['caseId']),
      cashEventId: serializer.fromJson<String>(json['cashEventId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      financialAccountId: serializer.fromJson<String>(
        json['financialAccountId'],
      ),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyRole: serializer.fromJson<String>(json['partyRole']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      actorId: serializer.fromJson<String>(json['actorId']),
      authorizedByActorId: serializer.fromJson<String>(
        json['authorizedByActorId'],
      ),
      authorizationReference: serializer.fromJson<String>(
        json['authorizationReference'],
      ),
      reason: serializer.fromJson<String>(json['reason']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestPayload: serializer.fromJson<String>(json['requestPayload']),
      resolvedAt: serializer.fromJson<DateTime>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'caseId': serializer.toJson<String>(caseId),
      'cashEventId': serializer.toJson<String>(cashEventId),
      'paymentId': serializer.toJson<String>(paymentId),
      'financialAccountId': serializer.toJson<String>(financialAccountId),
      'partyId': serializer.toJson<String>(partyId),
      'partyRole': serializer.toJson<String>(partyRole),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'actorId': serializer.toJson<String>(actorId),
      'authorizedByActorId': serializer.toJson<String>(authorizedByActorId),
      'authorizationReference': serializer.toJson<String>(
        authorizationReference,
      ),
      'reason': serializer.toJson<String>(reason),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestPayload': serializer.toJson<String>(requestPayload),
      'resolvedAt': serializer.toJson<DateTime>(resolvedAt),
    };
  }

  SuspenseResolution copyWith({
    String? id,
    String? caseId,
    String? cashEventId,
    String? paymentId,
    String? financialAccountId,
    String? partyId,
    String? partyRole,
    String? currencyCode,
    int? amountMinor,
    String? actorId,
    String? authorizedByActorId,
    String? authorizationReference,
    String? reason,
    String? idempotencyKey,
    String? requestPayload,
    DateTime? resolvedAt,
  }) => SuspenseResolution(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    cashEventId: cashEventId ?? this.cashEventId,
    paymentId: paymentId ?? this.paymentId,
    financialAccountId: financialAccountId ?? this.financialAccountId,
    partyId: partyId ?? this.partyId,
    partyRole: partyRole ?? this.partyRole,
    currencyCode: currencyCode ?? this.currencyCode,
    amountMinor: amountMinor ?? this.amountMinor,
    actorId: actorId ?? this.actorId,
    authorizedByActorId: authorizedByActorId ?? this.authorizedByActorId,
    authorizationReference:
        authorizationReference ?? this.authorizationReference,
    reason: reason ?? this.reason,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestPayload: requestPayload ?? this.requestPayload,
    resolvedAt: resolvedAt ?? this.resolvedAt,
  );
  SuspenseResolution copyWithCompanion(SuspenseResolutionsCompanion data) {
    return SuspenseResolution(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      cashEventId: data.cashEventId.present
          ? data.cashEventId.value
          : this.cashEventId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      financialAccountId: data.financialAccountId.present
          ? data.financialAccountId.value
          : this.financialAccountId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      authorizedByActorId: data.authorizedByActorId.present
          ? data.authorizedByActorId.value
          : this.authorizedByActorId,
      authorizationReference: data.authorizationReference.present
          ? data.authorizationReference.value
          : this.authorizationReference,
      reason: data.reason.present ? data.reason.value : this.reason,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestPayload: data.requestPayload.present
          ? data.requestPayload.value
          : this.requestPayload,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuspenseResolution(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('actorId: $actorId, ')
          ..write('authorizedByActorId: $authorizedByActorId, ')
          ..write('authorizationReference: $authorizationReference, ')
          ..write('reason: $reason, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayload: $requestPayload, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    caseId,
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    amountMinor,
    actorId,
    authorizedByActorId,
    authorizationReference,
    reason,
    idempotencyKey,
    requestPayload,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuspenseResolution &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.cashEventId == this.cashEventId &&
          other.paymentId == this.paymentId &&
          other.financialAccountId == this.financialAccountId &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.currencyCode == this.currencyCode &&
          other.amountMinor == this.amountMinor &&
          other.actorId == this.actorId &&
          other.authorizedByActorId == this.authorizedByActorId &&
          other.authorizationReference == this.authorizationReference &&
          other.reason == this.reason &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestPayload == this.requestPayload &&
          other.resolvedAt == this.resolvedAt);
}

class SuspenseResolutionsCompanion extends UpdateCompanion<SuspenseResolution> {
  final Value<String> id;
  final Value<String> caseId;
  final Value<String> cashEventId;
  final Value<String> paymentId;
  final Value<String> financialAccountId;
  final Value<String> partyId;
  final Value<String> partyRole;
  final Value<String> currencyCode;
  final Value<int> amountMinor;
  final Value<String> actorId;
  final Value<String> authorizedByActorId;
  final Value<String> authorizationReference;
  final Value<String> reason;
  final Value<String> idempotencyKey;
  final Value<String> requestPayload;
  final Value<DateTime> resolvedAt;
  final Value<int> rowid;
  const SuspenseResolutionsCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.cashEventId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.actorId = const Value.absent(),
    this.authorizedByActorId = const Value.absent(),
    this.authorizationReference = const Value.absent(),
    this.reason = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestPayload = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuspenseResolutionsCompanion.insert({
    required String id,
    required String caseId,
    required String cashEventId,
    required String paymentId,
    required String financialAccountId,
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required int amountMinor,
    required String actorId,
    required String authorizedByActorId,
    required String authorizationReference,
    required String reason,
    required String idempotencyKey,
    required String requestPayload,
    required DateTime resolvedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       caseId = Value(caseId),
       cashEventId = Value(cashEventId),
       paymentId = Value(paymentId),
       financialAccountId = Value(financialAccountId),
       partyId = Value(partyId),
       partyRole = Value(partyRole),
       currencyCode = Value(currencyCode),
       amountMinor = Value(amountMinor),
       actorId = Value(actorId),
       authorizedByActorId = Value(authorizedByActorId),
       authorizationReference = Value(authorizationReference),
       reason = Value(reason),
       idempotencyKey = Value(idempotencyKey),
       requestPayload = Value(requestPayload),
       resolvedAt = Value(resolvedAt);
  static Insertable<SuspenseResolution> custom({
    Expression<String>? id,
    Expression<String>? caseId,
    Expression<String>? cashEventId,
    Expression<String>? paymentId,
    Expression<String>? financialAccountId,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? currencyCode,
    Expression<int>? amountMinor,
    Expression<String>? actorId,
    Expression<String>? authorizedByActorId,
    Expression<String>? authorizationReference,
    Expression<String>? reason,
    Expression<String>? idempotencyKey,
    Expression<String>? requestPayload,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'resolution_id': id,
      if (caseId != null) 'case_id': caseId,
      if (cashEventId != null) 'cash_event_id': cashEventId,
      if (paymentId != null) 'payment_id': paymentId,
      if (financialAccountId != null)
        'financial_account_id': financialAccountId,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (actorId != null) 'actor_id': actorId,
      if (authorizedByActorId != null)
        'authorized_by_actor_id': authorizedByActorId,
      if (authorizationReference != null)
        'authorization_reference': authorizationReference,
      if (reason != null) 'reason': reason,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestPayload != null) 'request_payload': requestPayload,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuspenseResolutionsCompanion copyWith({
    Value<String>? id,
    Value<String>? caseId,
    Value<String>? cashEventId,
    Value<String>? paymentId,
    Value<String>? financialAccountId,
    Value<String>? partyId,
    Value<String>? partyRole,
    Value<String>? currencyCode,
    Value<int>? amountMinor,
    Value<String>? actorId,
    Value<String>? authorizedByActorId,
    Value<String>? authorizationReference,
    Value<String>? reason,
    Value<String>? idempotencyKey,
    Value<String>? requestPayload,
    Value<DateTime>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SuspenseResolutionsCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      cashEventId: cashEventId ?? this.cashEventId,
      paymentId: paymentId ?? this.paymentId,
      financialAccountId: financialAccountId ?? this.financialAccountId,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      currencyCode: currencyCode ?? this.currencyCode,
      amountMinor: amountMinor ?? this.amountMinor,
      actorId: actorId ?? this.actorId,
      authorizedByActorId: authorizedByActorId ?? this.authorizedByActorId,
      authorizationReference:
          authorizationReference ?? this.authorizationReference,
      reason: reason ?? this.reason,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestPayload: requestPayload ?? this.requestPayload,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['resolution_id'] = Variable<String>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (cashEventId.present) {
      map['cash_event_id'] = Variable<String>(cashEventId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (financialAccountId.present) {
      map['financial_account_id'] = Variable<String>(financialAccountId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (authorizedByActorId.present) {
      map['authorized_by_actor_id'] = Variable<String>(
        authorizedByActorId.value,
      );
    }
    if (authorizationReference.present) {
      map['authorization_reference'] = Variable<String>(
        authorizationReference.value,
      );
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestPayload.present) {
      map['request_payload'] = Variable<String>(requestPayload.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuspenseResolutionsCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('actorId: $actorId, ')
          ..write('authorizedByActorId: $authorizedByActorId, ')
          ..write('authorizationReference: $authorizationReference, ')
          ..write('reason: $reason, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayload: $requestPayload, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuspenseEntriesTable extends SuspenseEntries
    with TableInfo<$SuspenseEntriesTable, SuspenseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuspenseEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'suspense_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashEventIdMeta = const VerificationMeta(
    'cashEventId',
  );
  @override
  late final GeneratedColumn<String> cashEventId = GeneratedColumn<String>(
    'cash_event_id',
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
  );
  static const VerificationMeta _financialAccountIdMeta =
      const VerificationMeta('financialAccountId');
  @override
  late final GeneratedColumn<String> financialAccountId =
      GeneratedColumn<String>(
        'financial_account_id',
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
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
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
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionIdMeta = const VerificationMeta(
    'resolutionId',
  );
  @override
  late final GeneratedColumn<String> resolutionId = GeneratedColumn<String>(
    'resolution_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestPayloadMeta = const VerificationMeta(
    'requestPayload',
  );
  @override
  late final GeneratedColumn<String> requestPayload = GeneratedColumn<String>(
    'request_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    caseId,
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    movementType,
    amountMinor,
    resolutionId,
    actorId,
    reason,
    idempotencyKey,
    requestPayload,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suspense_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuspenseEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('suspense_entry_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['suspense_entry_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _cashEventIdMeta,
        cashEventId.isAcceptableOrUnknown(
          data['cash_event_id']!,
          _cashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashEventIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('financial_account_id')) {
      context.handle(
        _financialAccountIdMeta,
        financialAccountId.isAcceptableOrUnknown(
          data['financial_account_id']!,
          _financialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_financialAccountIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_partyRoleMeta);
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
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('resolution_id')) {
      context.handle(
        _resolutionIdMeta,
        resolutionId.isAcceptableOrUnknown(
          data['resolution_id']!,
          _resolutionIdMeta,
        ),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_payload')) {
      context.handle(
        _requestPayloadMeta,
        requestPayload.isAcceptableOrUnknown(
          data['request_payload']!,
          _requestPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestPayloadMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {idempotencyKey},
  ];
  @override
  SuspenseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuspenseEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suspense_entry_id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      cashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      financialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}financial_account_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      resolutionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_id'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_payload'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $SuspenseEntriesTable createAlias(String alias) {
    return $SuspenseEntriesTable(attachedDatabase, alias);
  }
}

class SuspenseEntry extends DataClass implements Insertable<SuspenseEntry> {
  final String id;
  final String caseId;
  final String cashEventId;
  final String paymentId;
  final String financialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final String movementType;
  final int amountMinor;
  final String? resolutionId;
  final String actorId;
  final String reason;
  final String idempotencyKey;
  final String requestPayload;
  final DateTime recordedAt;
  const SuspenseEntry({
    required this.id,
    required this.caseId,
    required this.cashEventId,
    required this.paymentId,
    required this.financialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.movementType,
    required this.amountMinor,
    this.resolutionId,
    required this.actorId,
    required this.reason,
    required this.idempotencyKey,
    required this.requestPayload,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['suspense_entry_id'] = Variable<String>(id);
    map['case_id'] = Variable<String>(caseId);
    map['cash_event_id'] = Variable<String>(cashEventId);
    map['payment_id'] = Variable<String>(paymentId);
    map['financial_account_id'] = Variable<String>(financialAccountId);
    map['party_id'] = Variable<String>(partyId);
    map['party_role'] = Variable<String>(partyRole);
    map['currency_code'] = Variable<String>(currencyCode);
    map['movement_type'] = Variable<String>(movementType);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || resolutionId != null) {
      map['resolution_id'] = Variable<String>(resolutionId);
    }
    map['actor_id'] = Variable<String>(actorId);
    map['reason'] = Variable<String>(reason);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_payload'] = Variable<String>(requestPayload);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  SuspenseEntriesCompanion toCompanion(bool nullToAbsent) {
    return SuspenseEntriesCompanion(
      id: Value(id),
      caseId: Value(caseId),
      cashEventId: Value(cashEventId),
      paymentId: Value(paymentId),
      financialAccountId: Value(financialAccountId),
      partyId: Value(partyId),
      partyRole: Value(partyRole),
      currencyCode: Value(currencyCode),
      movementType: Value(movementType),
      amountMinor: Value(amountMinor),
      resolutionId: resolutionId == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionId),
      actorId: Value(actorId),
      reason: Value(reason),
      idempotencyKey: Value(idempotencyKey),
      requestPayload: Value(requestPayload),
      recordedAt: Value(recordedAt),
    );
  }

  factory SuspenseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuspenseEntry(
      id: serializer.fromJson<String>(json['id']),
      caseId: serializer.fromJson<String>(json['caseId']),
      cashEventId: serializer.fromJson<String>(json['cashEventId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      financialAccountId: serializer.fromJson<String>(
        json['financialAccountId'],
      ),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyRole: serializer.fromJson<String>(json['partyRole']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      movementType: serializer.fromJson<String>(json['movementType']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      resolutionId: serializer.fromJson<String?>(json['resolutionId']),
      actorId: serializer.fromJson<String>(json['actorId']),
      reason: serializer.fromJson<String>(json['reason']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestPayload: serializer.fromJson<String>(json['requestPayload']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'caseId': serializer.toJson<String>(caseId),
      'cashEventId': serializer.toJson<String>(cashEventId),
      'paymentId': serializer.toJson<String>(paymentId),
      'financialAccountId': serializer.toJson<String>(financialAccountId),
      'partyId': serializer.toJson<String>(partyId),
      'partyRole': serializer.toJson<String>(partyRole),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'movementType': serializer.toJson<String>(movementType),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'resolutionId': serializer.toJson<String?>(resolutionId),
      'actorId': serializer.toJson<String>(actorId),
      'reason': serializer.toJson<String>(reason),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestPayload': serializer.toJson<String>(requestPayload),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  SuspenseEntry copyWith({
    String? id,
    String? caseId,
    String? cashEventId,
    String? paymentId,
    String? financialAccountId,
    String? partyId,
    String? partyRole,
    String? currencyCode,
    String? movementType,
    int? amountMinor,
    Value<String?> resolutionId = const Value.absent(),
    String? actorId,
    String? reason,
    String? idempotencyKey,
    String? requestPayload,
    DateTime? recordedAt,
  }) => SuspenseEntry(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    cashEventId: cashEventId ?? this.cashEventId,
    paymentId: paymentId ?? this.paymentId,
    financialAccountId: financialAccountId ?? this.financialAccountId,
    partyId: partyId ?? this.partyId,
    partyRole: partyRole ?? this.partyRole,
    currencyCode: currencyCode ?? this.currencyCode,
    movementType: movementType ?? this.movementType,
    amountMinor: amountMinor ?? this.amountMinor,
    resolutionId: resolutionId.present ? resolutionId.value : this.resolutionId,
    actorId: actorId ?? this.actorId,
    reason: reason ?? this.reason,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestPayload: requestPayload ?? this.requestPayload,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  SuspenseEntry copyWithCompanion(SuspenseEntriesCompanion data) {
    return SuspenseEntry(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      cashEventId: data.cashEventId.present
          ? data.cashEventId.value
          : this.cashEventId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      financialAccountId: data.financialAccountId.present
          ? data.financialAccountId.value
          : this.financialAccountId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      resolutionId: data.resolutionId.present
          ? data.resolutionId.value
          : this.resolutionId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestPayload: data.requestPayload.present
          ? data.requestPayload.value
          : this.requestPayload,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuspenseEntry(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('movementType: $movementType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('resolutionId: $resolutionId, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayload: $requestPayload, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    caseId,
    cashEventId,
    paymentId,
    financialAccountId,
    partyId,
    partyRole,
    currencyCode,
    movementType,
    amountMinor,
    resolutionId,
    actorId,
    reason,
    idempotencyKey,
    requestPayload,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuspenseEntry &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.cashEventId == this.cashEventId &&
          other.paymentId == this.paymentId &&
          other.financialAccountId == this.financialAccountId &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.currencyCode == this.currencyCode &&
          other.movementType == this.movementType &&
          other.amountMinor == this.amountMinor &&
          other.resolutionId == this.resolutionId &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestPayload == this.requestPayload &&
          other.recordedAt == this.recordedAt);
}

class SuspenseEntriesCompanion extends UpdateCompanion<SuspenseEntry> {
  final Value<String> id;
  final Value<String> caseId;
  final Value<String> cashEventId;
  final Value<String> paymentId;
  final Value<String> financialAccountId;
  final Value<String> partyId;
  final Value<String> partyRole;
  final Value<String> currencyCode;
  final Value<String> movementType;
  final Value<int> amountMinor;
  final Value<String?> resolutionId;
  final Value<String> actorId;
  final Value<String> reason;
  final Value<String> idempotencyKey;
  final Value<String> requestPayload;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const SuspenseEntriesCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.cashEventId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.financialAccountId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.movementType = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.resolutionId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestPayload = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuspenseEntriesCompanion.insert({
    required String id,
    required String caseId,
    required String cashEventId,
    required String paymentId,
    required String financialAccountId,
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required String movementType,
    required int amountMinor,
    this.resolutionId = const Value.absent(),
    required String actorId,
    required String reason,
    required String idempotencyKey,
    required String requestPayload,
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       caseId = Value(caseId),
       cashEventId = Value(cashEventId),
       paymentId = Value(paymentId),
       financialAccountId = Value(financialAccountId),
       partyId = Value(partyId),
       partyRole = Value(partyRole),
       currencyCode = Value(currencyCode),
       movementType = Value(movementType),
       amountMinor = Value(amountMinor),
       actorId = Value(actorId),
       reason = Value(reason),
       idempotencyKey = Value(idempotencyKey),
       requestPayload = Value(requestPayload),
       recordedAt = Value(recordedAt);
  static Insertable<SuspenseEntry> custom({
    Expression<String>? id,
    Expression<String>? caseId,
    Expression<String>? cashEventId,
    Expression<String>? paymentId,
    Expression<String>? financialAccountId,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? currencyCode,
    Expression<String>? movementType,
    Expression<int>? amountMinor,
    Expression<String>? resolutionId,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<String>? idempotencyKey,
    Expression<String>? requestPayload,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'suspense_entry_id': id,
      if (caseId != null) 'case_id': caseId,
      if (cashEventId != null) 'cash_event_id': cashEventId,
      if (paymentId != null) 'payment_id': paymentId,
      if (financialAccountId != null)
        'financial_account_id': financialAccountId,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (movementType != null) 'movement_type': movementType,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (resolutionId != null) 'resolution_id': resolutionId,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestPayload != null) 'request_payload': requestPayload,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuspenseEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? caseId,
    Value<String>? cashEventId,
    Value<String>? paymentId,
    Value<String>? financialAccountId,
    Value<String>? partyId,
    Value<String>? partyRole,
    Value<String>? currencyCode,
    Value<String>? movementType,
    Value<int>? amountMinor,
    Value<String?>? resolutionId,
    Value<String>? actorId,
    Value<String>? reason,
    Value<String>? idempotencyKey,
    Value<String>? requestPayload,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return SuspenseEntriesCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      cashEventId: cashEventId ?? this.cashEventId,
      paymentId: paymentId ?? this.paymentId,
      financialAccountId: financialAccountId ?? this.financialAccountId,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      currencyCode: currencyCode ?? this.currencyCode,
      movementType: movementType ?? this.movementType,
      amountMinor: amountMinor ?? this.amountMinor,
      resolutionId: resolutionId ?? this.resolutionId,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestPayload: requestPayload ?? this.requestPayload,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['suspense_entry_id'] = Variable<String>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (cashEventId.present) {
      map['cash_event_id'] = Variable<String>(cashEventId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (financialAccountId.present) {
      map['financial_account_id'] = Variable<String>(financialAccountId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (resolutionId.present) {
      map['resolution_id'] = Variable<String>(resolutionId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestPayload.present) {
      map['request_payload'] = Variable<String>(requestPayload.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuspenseEntriesCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('financialAccountId: $financialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('movementType: $movementType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('resolutionId: $resolutionId, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestPayload: $requestPayload, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceAllocationsTable extends InvoiceAllocations
    with TableInfo<$InvoiceAllocationsTable, InvoiceAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'allocation_id',
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
  static const VerificationMeta _paymentFinancialAccountIdMeta =
      const VerificationMeta('paymentFinancialAccountId');
  @override
  late final GeneratedColumn<String> paymentFinancialAccountId =
      GeneratedColumn<String>(
        'payment_financial_account_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _invoiceFinancialAccountIdMeta =
      const VerificationMeta('invoiceFinancialAccountId');
  @override
  late final GeneratedColumn<String> invoiceFinancialAccountId =
      GeneratedColumn<String>(
        'invoice_financial_account_id',
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
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestFingerprintMeta =
      const VerificationMeta('requestFingerprint');
  @override
  late final GeneratedColumn<String> requestFingerprint =
      GeneratedColumn<String>(
        'request_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictGroupIdMeta = const VerificationMeta(
    'conflictGroupId',
  );
  @override
  late final GeneratedColumn<String> conflictGroupId = GeneratedColumn<String>(
    'conflict_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    paymentId,
    invoiceId,
    paymentFinancialAccountId,
    invoiceFinancialAccountId,
    partyId,
    partyRole,
    currencyCode,
    amountMinor,
    idempotencyKey,
    requestFingerprint,
    originDeviceId,
    conflictGroupId,
    actorId,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('allocation_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['allocation_id']!, _idMeta),
      );
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
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('payment_financial_account_id')) {
      context.handle(
        _paymentFinancialAccountIdMeta,
        paymentFinancialAccountId.isAcceptableOrUnknown(
          data['payment_financial_account_id']!,
          _paymentFinancialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentFinancialAccountIdMeta);
    }
    if (data.containsKey('invoice_financial_account_id')) {
      context.handle(
        _invoiceFinancialAccountIdMeta,
        invoiceFinancialAccountId.isAcceptableOrUnknown(
          data['invoice_financial_account_id']!,
          _invoiceFinancialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceFinancialAccountIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_partyRoleMeta);
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
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_fingerprint')) {
      context.handle(
        _requestFingerprintMeta,
        requestFingerprint.isAcceptableOrUnknown(
          data['request_fingerprint']!,
          _requestFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestFingerprintMeta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('conflict_group_id')) {
      context.handle(
        _conflictGroupIdMeta,
        conflictGroupId.isAcceptableOrUnknown(
          data['conflict_group_id']!,
          _conflictGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, paymentId, invoiceId},
    {idempotencyKey},
  ];
  @override
  InvoiceAllocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceAllocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      paymentFinancialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_financial_account_id'],
      )!,
      invoiceFinancialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_financial_account_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_fingerprint'],
      )!,
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      conflictGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_group_id'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvoiceAllocationsTable createAlias(String alias) {
    return $InvoiceAllocationsTable(attachedDatabase, alias);
  }
}

class InvoiceAllocation extends DataClass
    implements Insertable<InvoiceAllocation> {
  final String id;
  final String paymentId;
  final String invoiceId;
  final String paymentFinancialAccountId;
  final String invoiceFinancialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final int amountMinor;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? originDeviceId;
  final String? conflictGroupId;
  final String? actorId;
  final String? reason;
  final DateTime createdAt;
  const InvoiceAllocation({
    required this.id,
    required this.paymentId,
    required this.invoiceId,
    required this.paymentFinancialAccountId,
    required this.invoiceFinancialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.amountMinor,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.originDeviceId,
    this.conflictGroupId,
    this.actorId,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['allocation_id'] = Variable<String>(id);
    map['payment_id'] = Variable<String>(paymentId);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['payment_financial_account_id'] = Variable<String>(
      paymentFinancialAccountId,
    );
    map['invoice_financial_account_id'] = Variable<String>(
      invoiceFinancialAccountId,
    );
    map['party_id'] = Variable<String>(partyId);
    map['party_role'] = Variable<String>(partyRole);
    map['currency_code'] = Variable<String>(currencyCode);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_fingerprint'] = Variable<String>(requestFingerprint);
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || conflictGroupId != null) {
      map['conflict_group_id'] = Variable<String>(conflictGroupId);
    }
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvoiceAllocationsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceAllocationsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      invoiceId: Value(invoiceId),
      paymentFinancialAccountId: Value(paymentFinancialAccountId),
      invoiceFinancialAccountId: Value(invoiceFinancialAccountId),
      partyId: Value(partyId),
      partyRole: Value(partyRole),
      currencyCode: Value(currencyCode),
      amountMinor: Value(amountMinor),
      idempotencyKey: Value(idempotencyKey),
      requestFingerprint: Value(requestFingerprint),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      conflictGroupId: conflictGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictGroupId),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory InvoiceAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceAllocation(
      id: serializer.fromJson<String>(json['id']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      paymentFinancialAccountId: serializer.fromJson<String>(
        json['paymentFinancialAccountId'],
      ),
      invoiceFinancialAccountId: serializer.fromJson<String>(
        json['invoiceFinancialAccountId'],
      ),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyRole: serializer.fromJson<String>(json['partyRole']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestFingerprint: serializer.fromJson<String>(
        json['requestFingerprint'],
      ),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      conflictGroupId: serializer.fromJson<String?>(json['conflictGroupId']),
      actorId: serializer.fromJson<String?>(json['actorId']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'paymentId': serializer.toJson<String>(paymentId),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'paymentFinancialAccountId': serializer.toJson<String>(
        paymentFinancialAccountId,
      ),
      'invoiceFinancialAccountId': serializer.toJson<String>(
        invoiceFinancialAccountId,
      ),
      'partyId': serializer.toJson<String>(partyId),
      'partyRole': serializer.toJson<String>(partyRole),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestFingerprint': serializer.toJson<String>(requestFingerprint),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'conflictGroupId': serializer.toJson<String?>(conflictGroupId),
      'actorId': serializer.toJson<String?>(actorId),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvoiceAllocation copyWith({
    String? id,
    String? paymentId,
    String? invoiceId,
    String? paymentFinancialAccountId,
    String? invoiceFinancialAccountId,
    String? partyId,
    String? partyRole,
    String? currencyCode,
    int? amountMinor,
    String? idempotencyKey,
    String? requestFingerprint,
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> conflictGroupId = const Value.absent(),
    Value<String?> actorId = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => InvoiceAllocation(
    id: id ?? this.id,
    paymentId: paymentId ?? this.paymentId,
    invoiceId: invoiceId ?? this.invoiceId,
    paymentFinancialAccountId:
        paymentFinancialAccountId ?? this.paymentFinancialAccountId,
    invoiceFinancialAccountId:
        invoiceFinancialAccountId ?? this.invoiceFinancialAccountId,
    partyId: partyId ?? this.partyId,
    partyRole: partyRole ?? this.partyRole,
    currencyCode: currencyCode ?? this.currencyCode,
    amountMinor: amountMinor ?? this.amountMinor,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestFingerprint: requestFingerprint ?? this.requestFingerprint,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    conflictGroupId: conflictGroupId.present
        ? conflictGroupId.value
        : this.conflictGroupId,
    actorId: actorId.present ? actorId.value : this.actorId,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  InvoiceAllocation copyWithCompanion(InvoiceAllocationsCompanion data) {
    return InvoiceAllocation(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      paymentFinancialAccountId: data.paymentFinancialAccountId.present
          ? data.paymentFinancialAccountId.value
          : this.paymentFinancialAccountId,
      invoiceFinancialAccountId: data.invoiceFinancialAccountId.present
          ? data.invoiceFinancialAccountId.value
          : this.invoiceFinancialAccountId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestFingerprint: data.requestFingerprint.present
          ? data.requestFingerprint.value
          : this.requestFingerprint,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      conflictGroupId: data.conflictGroupId.present
          ? data.conflictGroupId.value
          : this.conflictGroupId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceAllocation(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('paymentFinancialAccountId: $paymentFinancialAccountId, ')
          ..write('invoiceFinancialAccountId: $invoiceFinancialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('conflictGroupId: $conflictGroupId, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    paymentId,
    invoiceId,
    paymentFinancialAccountId,
    invoiceFinancialAccountId,
    partyId,
    partyRole,
    currencyCode,
    amountMinor,
    idempotencyKey,
    requestFingerprint,
    originDeviceId,
    conflictGroupId,
    actorId,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceAllocation &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.invoiceId == this.invoiceId &&
          other.paymentFinancialAccountId == this.paymentFinancialAccountId &&
          other.invoiceFinancialAccountId == this.invoiceFinancialAccountId &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.currencyCode == this.currencyCode &&
          other.amountMinor == this.amountMinor &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestFingerprint == this.requestFingerprint &&
          other.originDeviceId == this.originDeviceId &&
          other.conflictGroupId == this.conflictGroupId &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class InvoiceAllocationsCompanion extends UpdateCompanion<InvoiceAllocation> {
  final Value<String> id;
  final Value<String> paymentId;
  final Value<String> invoiceId;
  final Value<String> paymentFinancialAccountId;
  final Value<String> invoiceFinancialAccountId;
  final Value<String> partyId;
  final Value<String> partyRole;
  final Value<String> currencyCode;
  final Value<int> amountMinor;
  final Value<String> idempotencyKey;
  final Value<String> requestFingerprint;
  final Value<String?> originDeviceId;
  final Value<String?> conflictGroupId;
  final Value<String?> actorId;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvoiceAllocationsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.paymentFinancialAccountId = const Value.absent(),
    this.invoiceFinancialAccountId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestFingerprint = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.conflictGroupId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceAllocationsCompanion.insert({
    required String id,
    required String paymentId,
    required String invoiceId,
    required String paymentFinancialAccountId,
    required String invoiceFinancialAccountId,
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required int amountMinor,
    required String idempotencyKey,
    required String requestFingerprint,
    this.originDeviceId = const Value.absent(),
    this.conflictGroupId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       paymentId = Value(paymentId),
       invoiceId = Value(invoiceId),
       paymentFinancialAccountId = Value(paymentFinancialAccountId),
       invoiceFinancialAccountId = Value(invoiceFinancialAccountId),
       partyId = Value(partyId),
       partyRole = Value(partyRole),
       currencyCode = Value(currencyCode),
       amountMinor = Value(amountMinor),
       idempotencyKey = Value(idempotencyKey),
       requestFingerprint = Value(requestFingerprint),
       createdAt = Value(createdAt);
  static Insertable<InvoiceAllocation> custom({
    Expression<String>? id,
    Expression<String>? paymentId,
    Expression<String>? invoiceId,
    Expression<String>? paymentFinancialAccountId,
    Expression<String>? invoiceFinancialAccountId,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? currencyCode,
    Expression<int>? amountMinor,
    Expression<String>? idempotencyKey,
    Expression<String>? requestFingerprint,
    Expression<String>? originDeviceId,
    Expression<String>? conflictGroupId,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'allocation_id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (paymentFinancialAccountId != null)
        'payment_financial_account_id': paymentFinancialAccountId,
      if (invoiceFinancialAccountId != null)
        'invoice_financial_account_id': invoiceFinancialAccountId,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestFingerprint != null) 'request_fingerprint': requestFingerprint,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (conflictGroupId != null) 'conflict_group_id': conflictGroupId,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceAllocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? paymentId,
    Value<String>? invoiceId,
    Value<String>? paymentFinancialAccountId,
    Value<String>? invoiceFinancialAccountId,
    Value<String>? partyId,
    Value<String>? partyRole,
    Value<String>? currencyCode,
    Value<int>? amountMinor,
    Value<String>? idempotencyKey,
    Value<String>? requestFingerprint,
    Value<String?>? originDeviceId,
    Value<String?>? conflictGroupId,
    Value<String?>? actorId,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvoiceAllocationsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentFinancialAccountId:
          paymentFinancialAccountId ?? this.paymentFinancialAccountId,
      invoiceFinancialAccountId:
          invoiceFinancialAccountId ?? this.invoiceFinancialAccountId,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      currencyCode: currencyCode ?? this.currencyCode,
      amountMinor: amountMinor ?? this.amountMinor,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestFingerprint: requestFingerprint ?? this.requestFingerprint,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      conflictGroupId: conflictGroupId ?? this.conflictGroupId,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['allocation_id'] = Variable<String>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (paymentFinancialAccountId.present) {
      map['payment_financial_account_id'] = Variable<String>(
        paymentFinancialAccountId.value,
      );
    }
    if (invoiceFinancialAccountId.present) {
      map['invoice_financial_account_id'] = Variable<String>(
        invoiceFinancialAccountId.value,
      );
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestFingerprint.present) {
      map['request_fingerprint'] = Variable<String>(requestFingerprint.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (conflictGroupId.present) {
      map['conflict_group_id'] = Variable<String>(conflictGroupId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
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
    return (StringBuffer('InvoiceAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('paymentFinancialAccountId: $paymentFinancialAccountId, ')
          ..write('invoiceFinancialAccountId: $invoiceFinancialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('conflictGroupId: $conflictGroupId, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllocationReversalsTable extends AllocationReversals
    with TableInfo<$AllocationReversalsTable, AllocationReversal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllocationReversalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'allocation_reversal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allocationIdMeta = const VerificationMeta(
    'allocationId',
  );
  @override
  late final GeneratedColumn<String> allocationId = GeneratedColumn<String>(
    'allocation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestFingerprintMeta =
      const VerificationMeta('requestFingerprint');
  @override
  late final GeneratedColumn<String> requestFingerprint =
      GeneratedColumn<String>(
        'request_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
    allocationId,
    amountMinor,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allocation_reversals';
  @override
  VerificationContext validateIntegrity(
    Insertable<AllocationReversal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('allocation_reversal_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['allocation_reversal_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('allocation_id')) {
      context.handle(
        _allocationIdMeta,
        allocationId.isAcceptableOrUnknown(
          data['allocation_id']!,
          _allocationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocationIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_fingerprint')) {
      context.handle(
        _requestFingerprintMeta,
        requestFingerprint.isAcceptableOrUnknown(
          data['request_fingerprint']!,
          _requestFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestFingerprintMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
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
    {id, allocationId},
    {idempotencyKey},
  ];
  @override
  AllocationReversal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllocationReversal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_reversal_id'],
      )!,
      allocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_fingerprint'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AllocationReversalsTable createAlias(String alias) {
    return $AllocationReversalsTable(attachedDatabase, alias);
  }
}

class AllocationReversal extends DataClass
    implements Insertable<AllocationReversal> {
  final String id;
  final String allocationId;
  final int amountMinor;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String reason;
  final DateTime createdAt;
  const AllocationReversal({
    required this.id,
    required this.allocationId,
    required this.amountMinor,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.actorId,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['allocation_reversal_id'] = Variable<String>(id);
    map['allocation_id'] = Variable<String>(allocationId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_fingerprint'] = Variable<String>(requestFingerprint);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AllocationReversalsCompanion toCompanion(bool nullToAbsent) {
    return AllocationReversalsCompanion(
      id: Value(id),
      allocationId: Value(allocationId),
      amountMinor: Value(amountMinor),
      idempotencyKey: Value(idempotencyKey),
      requestFingerprint: Value(requestFingerprint),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory AllocationReversal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllocationReversal(
      id: serializer.fromJson<String>(json['id']),
      allocationId: serializer.fromJson<String>(json['allocationId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestFingerprint: serializer.fromJson<String>(
        json['requestFingerprint'],
      ),
      actorId: serializer.fromJson<String?>(json['actorId']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'allocationId': serializer.toJson<String>(allocationId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestFingerprint': serializer.toJson<String>(requestFingerprint),
      'actorId': serializer.toJson<String?>(actorId),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AllocationReversal copyWith({
    String? id,
    String? allocationId,
    int? amountMinor,
    String? idempotencyKey,
    String? requestFingerprint,
    Value<String?> actorId = const Value.absent(),
    String? reason,
    DateTime? createdAt,
  }) => AllocationReversal(
    id: id ?? this.id,
    allocationId: allocationId ?? this.allocationId,
    amountMinor: amountMinor ?? this.amountMinor,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestFingerprint: requestFingerprint ?? this.requestFingerprint,
    actorId: actorId.present ? actorId.value : this.actorId,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  AllocationReversal copyWithCompanion(AllocationReversalsCompanion data) {
    return AllocationReversal(
      id: data.id.present ? data.id.value : this.id,
      allocationId: data.allocationId.present
          ? data.allocationId.value
          : this.allocationId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestFingerprint: data.requestFingerprint.present
          ? data.requestFingerprint.value
          : this.requestFingerprint,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllocationReversal(')
          ..write('id: $id, ')
          ..write('allocationId: $allocationId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    allocationId,
    amountMinor,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllocationReversal &&
          other.id == this.id &&
          other.allocationId == this.allocationId &&
          other.amountMinor == this.amountMinor &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestFingerprint == this.requestFingerprint &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class AllocationReversalsCompanion extends UpdateCompanion<AllocationReversal> {
  final Value<String> id;
  final Value<String> allocationId;
  final Value<int> amountMinor;
  final Value<String> idempotencyKey;
  final Value<String> requestFingerprint;
  final Value<String?> actorId;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AllocationReversalsCompanion({
    this.id = const Value.absent(),
    this.allocationId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestFingerprint = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllocationReversalsCompanion.insert({
    required String id,
    required String allocationId,
    required int amountMinor,
    required String idempotencyKey,
    required String requestFingerprint,
    this.actorId = const Value.absent(),
    required String reason,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       allocationId = Value(allocationId),
       amountMinor = Value(amountMinor),
       idempotencyKey = Value(idempotencyKey),
       requestFingerprint = Value(requestFingerprint),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<AllocationReversal> custom({
    Expression<String>? id,
    Expression<String>? allocationId,
    Expression<int>? amountMinor,
    Expression<String>? idempotencyKey,
    Expression<String>? requestFingerprint,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'allocation_reversal_id': id,
      if (allocationId != null) 'allocation_id': allocationId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestFingerprint != null) 'request_fingerprint': requestFingerprint,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllocationReversalsCompanion copyWith({
    Value<String>? id,
    Value<String>? allocationId,
    Value<int>? amountMinor,
    Value<String>? idempotencyKey,
    Value<String>? requestFingerprint,
    Value<String?>? actorId,
    Value<String>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AllocationReversalsCompanion(
      id: id ?? this.id,
      allocationId: allocationId ?? this.allocationId,
      amountMinor: amountMinor ?? this.amountMinor,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestFingerprint: requestFingerprint ?? this.requestFingerprint,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['allocation_reversal_id'] = Variable<String>(id.value);
    }
    if (allocationId.present) {
      map['allocation_id'] = Variable<String>(allocationId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestFingerprint.present) {
      map['request_fingerprint'] = Variable<String>(requestFingerprint.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
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
    return (StringBuffer('AllocationReversalsCompanion(')
          ..write('id: $id, ')
          ..write('allocationId: $allocationId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllocationStatusHistoryTable extends AllocationStatusHistory
    with TableInfo<$AllocationStatusHistoryTable, AllocationStatusHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllocationStatusHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'status_version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allocationIdMeta = const VerificationMeta(
    'allocationId',
  );
  @override
  late final GeneratedColumn<String> allocationId = GeneratedColumn<String>(
    'allocation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousVersionIdMeta = const VerificationMeta(
    'previousVersionId',
  );
  @override
  late final GeneratedColumn<String> previousVersionId =
      GeneratedColumn<String>(
        'previous_version_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestFingerprintMeta =
      const VerificationMeta('requestFingerprint');
  @override
  late final GeneratedColumn<String> requestFingerprint =
      GeneratedColumn<String>(
        'request_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    allocationId,
    sequence,
    status,
    previousVersionId,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allocation_status_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<AllocationStatusHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('status_version_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['status_version_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('allocation_id')) {
      context.handle(
        _allocationIdMeta,
        allocationId.isAcceptableOrUnknown(
          data['allocation_id']!,
          _allocationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocationIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('previous_version_id')) {
      context.handle(
        _previousVersionIdMeta,
        previousVersionId.isAcceptableOrUnknown(
          data['previous_version_id']!,
          _previousVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_fingerprint')) {
      context.handle(
        _requestFingerprintMeta,
        requestFingerprint.isAcceptableOrUnknown(
          data['request_fingerprint']!,
          _requestFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestFingerprintMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {allocationId, sequence},
    {id, allocationId},
    {idempotencyKey},
  ];
  @override
  AllocationStatusHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllocationStatusHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_version_id'],
      )!,
      allocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      previousVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_version_id'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_fingerprint'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $AllocationStatusHistoryTable createAlias(String alias) {
    return $AllocationStatusHistoryTable(attachedDatabase, alias);
  }
}

class AllocationStatusHistoryData extends DataClass
    implements Insertable<AllocationStatusHistoryData> {
  final String id;
  final String allocationId;
  final int sequence;
  final String status;
  final String? previousVersionId;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String? reason;
  final DateTime recordedAt;
  const AllocationStatusHistoryData({
    required this.id,
    required this.allocationId,
    required this.sequence,
    required this.status,
    this.previousVersionId,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.actorId,
    this.reason,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['status_version_id'] = Variable<String>(id);
    map['allocation_id'] = Variable<String>(allocationId);
    map['sequence'] = Variable<int>(sequence);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || previousVersionId != null) {
      map['previous_version_id'] = Variable<String>(previousVersionId);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_fingerprint'] = Variable<String>(requestFingerprint);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  AllocationStatusHistoryCompanion toCompanion(bool nullToAbsent) {
    return AllocationStatusHistoryCompanion(
      id: Value(id),
      allocationId: Value(allocationId),
      sequence: Value(sequence),
      status: Value(status),
      previousVersionId: previousVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousVersionId),
      idempotencyKey: Value(idempotencyKey),
      requestFingerprint: Value(requestFingerprint),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      recordedAt: Value(recordedAt),
    );
  }

  factory AllocationStatusHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllocationStatusHistoryData(
      id: serializer.fromJson<String>(json['id']),
      allocationId: serializer.fromJson<String>(json['allocationId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      status: serializer.fromJson<String>(json['status']),
      previousVersionId: serializer.fromJson<String?>(
        json['previousVersionId'],
      ),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestFingerprint: serializer.fromJson<String>(
        json['requestFingerprint'],
      ),
      actorId: serializer.fromJson<String?>(json['actorId']),
      reason: serializer.fromJson<String?>(json['reason']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'allocationId': serializer.toJson<String>(allocationId),
      'sequence': serializer.toJson<int>(sequence),
      'status': serializer.toJson<String>(status),
      'previousVersionId': serializer.toJson<String?>(previousVersionId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestFingerprint': serializer.toJson<String>(requestFingerprint),
      'actorId': serializer.toJson<String?>(actorId),
      'reason': serializer.toJson<String?>(reason),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  AllocationStatusHistoryData copyWith({
    String? id,
    String? allocationId,
    int? sequence,
    String? status,
    Value<String?> previousVersionId = const Value.absent(),
    String? idempotencyKey,
    String? requestFingerprint,
    Value<String?> actorId = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    DateTime? recordedAt,
  }) => AllocationStatusHistoryData(
    id: id ?? this.id,
    allocationId: allocationId ?? this.allocationId,
    sequence: sequence ?? this.sequence,
    status: status ?? this.status,
    previousVersionId: previousVersionId.present
        ? previousVersionId.value
        : this.previousVersionId,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestFingerprint: requestFingerprint ?? this.requestFingerprint,
    actorId: actorId.present ? actorId.value : this.actorId,
    reason: reason.present ? reason.value : this.reason,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  AllocationStatusHistoryData copyWithCompanion(
    AllocationStatusHistoryCompanion data,
  ) {
    return AllocationStatusHistoryData(
      id: data.id.present ? data.id.value : this.id,
      allocationId: data.allocationId.present
          ? data.allocationId.value
          : this.allocationId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      status: data.status.present ? data.status.value : this.status,
      previousVersionId: data.previousVersionId.present
          ? data.previousVersionId.value
          : this.previousVersionId,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestFingerprint: data.requestFingerprint.present
          ? data.requestFingerprint.value
          : this.requestFingerprint,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllocationStatusHistoryData(')
          ..write('id: $id, ')
          ..write('allocationId: $allocationId, ')
          ..write('sequence: $sequence, ')
          ..write('status: $status, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    allocationId,
    sequence,
    status,
    previousVersionId,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllocationStatusHistoryData &&
          other.id == this.id &&
          other.allocationId == this.allocationId &&
          other.sequence == this.sequence &&
          other.status == this.status &&
          other.previousVersionId == this.previousVersionId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestFingerprint == this.requestFingerprint &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.recordedAt == this.recordedAt);
}

class AllocationStatusHistoryCompanion
    extends UpdateCompanion<AllocationStatusHistoryData> {
  final Value<String> id;
  final Value<String> allocationId;
  final Value<int> sequence;
  final Value<String> status;
  final Value<String?> previousVersionId;
  final Value<String> idempotencyKey;
  final Value<String> requestFingerprint;
  final Value<String?> actorId;
  final Value<String?> reason;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const AllocationStatusHistoryCompanion({
    this.id = const Value.absent(),
    this.allocationId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.status = const Value.absent(),
    this.previousVersionId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestFingerprint = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllocationStatusHistoryCompanion.insert({
    required String id,
    required String allocationId,
    required int sequence,
    required String status,
    this.previousVersionId = const Value.absent(),
    required String idempotencyKey,
    required String requestFingerprint,
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       allocationId = Value(allocationId),
       sequence = Value(sequence),
       status = Value(status),
       idempotencyKey = Value(idempotencyKey),
       requestFingerprint = Value(requestFingerprint),
       recordedAt = Value(recordedAt);
  static Insertable<AllocationStatusHistoryData> custom({
    Expression<String>? id,
    Expression<String>? allocationId,
    Expression<int>? sequence,
    Expression<String>? status,
    Expression<String>? previousVersionId,
    Expression<String>? idempotencyKey,
    Expression<String>? requestFingerprint,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'status_version_id': id,
      if (allocationId != null) 'allocation_id': allocationId,
      if (sequence != null) 'sequence': sequence,
      if (status != null) 'status': status,
      if (previousVersionId != null) 'previous_version_id': previousVersionId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestFingerprint != null) 'request_fingerprint': requestFingerprint,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllocationStatusHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? allocationId,
    Value<int>? sequence,
    Value<String>? status,
    Value<String?>? previousVersionId,
    Value<String>? idempotencyKey,
    Value<String>? requestFingerprint,
    Value<String?>? actorId,
    Value<String?>? reason,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return AllocationStatusHistoryCompanion(
      id: id ?? this.id,
      allocationId: allocationId ?? this.allocationId,
      sequence: sequence ?? this.sequence,
      status: status ?? this.status,
      previousVersionId: previousVersionId ?? this.previousVersionId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestFingerprint: requestFingerprint ?? this.requestFingerprint,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['status_version_id'] = Variable<String>(id.value);
    }
    if (allocationId.present) {
      map['allocation_id'] = Variable<String>(allocationId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (previousVersionId.present) {
      map['previous_version_id'] = Variable<String>(previousVersionId.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestFingerprint.present) {
      map['request_fingerprint'] = Variable<String>(requestFingerprint.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllocationStatusHistoryCompanion(')
          ..write('id: $id, ')
          ..write('allocationId: $allocationId, ')
          ..write('sequence: $sequence, ')
          ..write('status: $status, ')
          ..write('previousVersionId: $previousVersionId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefundsTable extends Refunds with TableInfo<$RefundsTable, Refund> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'refund_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalPaymentIdMeta = const VerificationMeta(
    'originalPaymentId',
  );
  @override
  late final GeneratedColumn<String> originalPaymentId =
      GeneratedColumn<String>(
        'original_payment_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _originalCashEventIdMeta =
      const VerificationMeta('originalCashEventId');
  @override
  late final GeneratedColumn<String> originalCashEventId =
      GeneratedColumn<String>(
        'original_cash_event_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _refundPaymentIdMeta = const VerificationMeta(
    'refundPaymentId',
  );
  @override
  late final GeneratedColumn<String> refundPaymentId = GeneratedColumn<String>(
    'refund_payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundCashEventIdMeta = const VerificationMeta(
    'refundCashEventId',
  );
  @override
  late final GeneratedColumn<String> refundCashEventId =
      GeneratedColumn<String>(
        'refund_cash_event_id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalFinancialAccountIdMeta =
      const VerificationMeta('originalFinancialAccountId');
  @override
  late final GeneratedColumn<String> originalFinancialAccountId =
      GeneratedColumn<String>(
        'original_financial_account_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _refundFinancialAccountIdMeta =
      const VerificationMeta('refundFinancialAccountId');
  @override
  late final GeneratedColumn<String> refundFinancialAccountId =
      GeneratedColumn<String>(
        'refund_financial_account_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _invoiceFinancialAccountIdMeta =
      const VerificationMeta('invoiceFinancialAccountId');
  @override
  late final GeneratedColumn<String> invoiceFinancialAccountId =
      GeneratedColumn<String>(
        'invoice_financial_account_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyRoleMeta = const VerificationMeta(
    'partyRole',
  );
  @override
  late final GeneratedColumn<String> partyRole = GeneratedColumn<String>(
    'party_role',
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestFingerprintMeta =
      const VerificationMeta('requestFingerprint');
  @override
  late final GeneratedColumn<String> requestFingerprint =
      GeneratedColumn<String>(
        'request_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
    originalPaymentId,
    originalCashEventId,
    refundPaymentId,
    refundCashEventId,
    invoiceId,
    originalFinancialAccountId,
    refundFinancialAccountId,
    invoiceFinancialAccountId,
    partyId,
    partyRole,
    currencyCode,
    amountMinor,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_refunds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Refund> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('refund_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['refund_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('original_payment_id')) {
      context.handle(
        _originalPaymentIdMeta,
        originalPaymentId.isAcceptableOrUnknown(
          data['original_payment_id']!,
          _originalPaymentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalPaymentIdMeta);
    }
    if (data.containsKey('original_cash_event_id')) {
      context.handle(
        _originalCashEventIdMeta,
        originalCashEventId.isAcceptableOrUnknown(
          data['original_cash_event_id']!,
          _originalCashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalCashEventIdMeta);
    }
    if (data.containsKey('refund_payment_id')) {
      context.handle(
        _refundPaymentIdMeta,
        refundPaymentId.isAcceptableOrUnknown(
          data['refund_payment_id']!,
          _refundPaymentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundPaymentIdMeta);
    }
    if (data.containsKey('refund_cash_event_id')) {
      context.handle(
        _refundCashEventIdMeta,
        refundCashEventId.isAcceptableOrUnknown(
          data['refund_cash_event_id']!,
          _refundCashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundCashEventIdMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    }
    if (data.containsKey('original_financial_account_id')) {
      context.handle(
        _originalFinancialAccountIdMeta,
        originalFinancialAccountId.isAcceptableOrUnknown(
          data['original_financial_account_id']!,
          _originalFinancialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalFinancialAccountIdMeta);
    }
    if (data.containsKey('refund_financial_account_id')) {
      context.handle(
        _refundFinancialAccountIdMeta,
        refundFinancialAccountId.isAcceptableOrUnknown(
          data['refund_financial_account_id']!,
          _refundFinancialAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundFinancialAccountIdMeta);
    }
    if (data.containsKey('invoice_financial_account_id')) {
      context.handle(
        _invoiceFinancialAccountIdMeta,
        invoiceFinancialAccountId.isAcceptableOrUnknown(
          data['invoice_financial_account_id']!,
          _invoiceFinancialAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('party_role')) {
      context.handle(
        _partyRoleMeta,
        partyRole.isAcceptableOrUnknown(data['party_role']!, _partyRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_partyRoleMeta);
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
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_fingerprint')) {
      context.handle(
        _requestFingerprintMeta,
        requestFingerprint.isAcceptableOrUnknown(
          data['request_fingerprint']!,
          _requestFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestFingerprintMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
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
    {id, originalPaymentId, invoiceId},
    {id, originalPaymentId, refundPaymentId},
    {id, refundPaymentId, refundCashEventId},
    {refundPaymentId},
    {idempotencyKey},
  ];
  @override
  Refund map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Refund(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_id'],
      )!,
      originalPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_payment_id'],
      )!,
      originalCashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_cash_event_id'],
      )!,
      refundPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_payment_id'],
      )!,
      refundCashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_cash_event_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      ),
      originalFinancialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_financial_account_id'],
      )!,
      refundFinancialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_financial_account_id'],
      )!,
      invoiceFinancialAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_financial_account_id'],
      ),
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      partyRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_role'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_fingerprint'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RefundsTable createAlias(String alias) {
    return $RefundsTable(attachedDatabase, alias);
  }
}

class Refund extends DataClass implements Insertable<Refund> {
  final String id;
  final String originalPaymentId;
  final String originalCashEventId;
  final String refundPaymentId;
  final String refundCashEventId;
  final String? invoiceId;
  final String originalFinancialAccountId;
  final String refundFinancialAccountId;
  final String? invoiceFinancialAccountId;
  final String partyId;
  final String partyRole;
  final String currencyCode;
  final int amountMinor;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String reason;
  final DateTime createdAt;
  const Refund({
    required this.id,
    required this.originalPaymentId,
    required this.originalCashEventId,
    required this.refundPaymentId,
    required this.refundCashEventId,
    this.invoiceId,
    required this.originalFinancialAccountId,
    required this.refundFinancialAccountId,
    this.invoiceFinancialAccountId,
    required this.partyId,
    required this.partyRole,
    required this.currencyCode,
    required this.amountMinor,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.actorId,
    required this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['refund_id'] = Variable<String>(id);
    map['original_payment_id'] = Variable<String>(originalPaymentId);
    map['original_cash_event_id'] = Variable<String>(originalCashEventId);
    map['refund_payment_id'] = Variable<String>(refundPaymentId);
    map['refund_cash_event_id'] = Variable<String>(refundCashEventId);
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<String>(invoiceId);
    }
    map['original_financial_account_id'] = Variable<String>(
      originalFinancialAccountId,
    );
    map['refund_financial_account_id'] = Variable<String>(
      refundFinancialAccountId,
    );
    if (!nullToAbsent || invoiceFinancialAccountId != null) {
      map['invoice_financial_account_id'] = Variable<String>(
        invoiceFinancialAccountId,
      );
    }
    map['party_id'] = Variable<String>(partyId);
    map['party_role'] = Variable<String>(partyRole);
    map['currency_code'] = Variable<String>(currencyCode);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_fingerprint'] = Variable<String>(requestFingerprint);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RefundsCompanion toCompanion(bool nullToAbsent) {
    return RefundsCompanion(
      id: Value(id),
      originalPaymentId: Value(originalPaymentId),
      originalCashEventId: Value(originalCashEventId),
      refundPaymentId: Value(refundPaymentId),
      refundCashEventId: Value(refundCashEventId),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
      originalFinancialAccountId: Value(originalFinancialAccountId),
      refundFinancialAccountId: Value(refundFinancialAccountId),
      invoiceFinancialAccountId:
          invoiceFinancialAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceFinancialAccountId),
      partyId: Value(partyId),
      partyRole: Value(partyRole),
      currencyCode: Value(currencyCode),
      amountMinor: Value(amountMinor),
      idempotencyKey: Value(idempotencyKey),
      requestFingerprint: Value(requestFingerprint),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory Refund.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Refund(
      id: serializer.fromJson<String>(json['id']),
      originalPaymentId: serializer.fromJson<String>(json['originalPaymentId']),
      originalCashEventId: serializer.fromJson<String>(
        json['originalCashEventId'],
      ),
      refundPaymentId: serializer.fromJson<String>(json['refundPaymentId']),
      refundCashEventId: serializer.fromJson<String>(json['refundCashEventId']),
      invoiceId: serializer.fromJson<String?>(json['invoiceId']),
      originalFinancialAccountId: serializer.fromJson<String>(
        json['originalFinancialAccountId'],
      ),
      refundFinancialAccountId: serializer.fromJson<String>(
        json['refundFinancialAccountId'],
      ),
      invoiceFinancialAccountId: serializer.fromJson<String?>(
        json['invoiceFinancialAccountId'],
      ),
      partyId: serializer.fromJson<String>(json['partyId']),
      partyRole: serializer.fromJson<String>(json['partyRole']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestFingerprint: serializer.fromJson<String>(
        json['requestFingerprint'],
      ),
      actorId: serializer.fromJson<String?>(json['actorId']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'originalPaymentId': serializer.toJson<String>(originalPaymentId),
      'originalCashEventId': serializer.toJson<String>(originalCashEventId),
      'refundPaymentId': serializer.toJson<String>(refundPaymentId),
      'refundCashEventId': serializer.toJson<String>(refundCashEventId),
      'invoiceId': serializer.toJson<String?>(invoiceId),
      'originalFinancialAccountId': serializer.toJson<String>(
        originalFinancialAccountId,
      ),
      'refundFinancialAccountId': serializer.toJson<String>(
        refundFinancialAccountId,
      ),
      'invoiceFinancialAccountId': serializer.toJson<String?>(
        invoiceFinancialAccountId,
      ),
      'partyId': serializer.toJson<String>(partyId),
      'partyRole': serializer.toJson<String>(partyRole),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestFingerprint': serializer.toJson<String>(requestFingerprint),
      'actorId': serializer.toJson<String?>(actorId),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Refund copyWith({
    String? id,
    String? originalPaymentId,
    String? originalCashEventId,
    String? refundPaymentId,
    String? refundCashEventId,
    Value<String?> invoiceId = const Value.absent(),
    String? originalFinancialAccountId,
    String? refundFinancialAccountId,
    Value<String?> invoiceFinancialAccountId = const Value.absent(),
    String? partyId,
    String? partyRole,
    String? currencyCode,
    int? amountMinor,
    String? idempotencyKey,
    String? requestFingerprint,
    Value<String?> actorId = const Value.absent(),
    String? reason,
    DateTime? createdAt,
  }) => Refund(
    id: id ?? this.id,
    originalPaymentId: originalPaymentId ?? this.originalPaymentId,
    originalCashEventId: originalCashEventId ?? this.originalCashEventId,
    refundPaymentId: refundPaymentId ?? this.refundPaymentId,
    refundCashEventId: refundCashEventId ?? this.refundCashEventId,
    invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
    originalFinancialAccountId:
        originalFinancialAccountId ?? this.originalFinancialAccountId,
    refundFinancialAccountId:
        refundFinancialAccountId ?? this.refundFinancialAccountId,
    invoiceFinancialAccountId: invoiceFinancialAccountId.present
        ? invoiceFinancialAccountId.value
        : this.invoiceFinancialAccountId,
    partyId: partyId ?? this.partyId,
    partyRole: partyRole ?? this.partyRole,
    currencyCode: currencyCode ?? this.currencyCode,
    amountMinor: amountMinor ?? this.amountMinor,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestFingerprint: requestFingerprint ?? this.requestFingerprint,
    actorId: actorId.present ? actorId.value : this.actorId,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  Refund copyWithCompanion(RefundsCompanion data) {
    return Refund(
      id: data.id.present ? data.id.value : this.id,
      originalPaymentId: data.originalPaymentId.present
          ? data.originalPaymentId.value
          : this.originalPaymentId,
      originalCashEventId: data.originalCashEventId.present
          ? data.originalCashEventId.value
          : this.originalCashEventId,
      refundPaymentId: data.refundPaymentId.present
          ? data.refundPaymentId.value
          : this.refundPaymentId,
      refundCashEventId: data.refundCashEventId.present
          ? data.refundCashEventId.value
          : this.refundCashEventId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      originalFinancialAccountId: data.originalFinancialAccountId.present
          ? data.originalFinancialAccountId.value
          : this.originalFinancialAccountId,
      refundFinancialAccountId: data.refundFinancialAccountId.present
          ? data.refundFinancialAccountId.value
          : this.refundFinancialAccountId,
      invoiceFinancialAccountId: data.invoiceFinancialAccountId.present
          ? data.invoiceFinancialAccountId.value
          : this.invoiceFinancialAccountId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      partyRole: data.partyRole.present ? data.partyRole.value : this.partyRole,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestFingerprint: data.requestFingerprint.present
          ? data.requestFingerprint.value
          : this.requestFingerprint,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Refund(')
          ..write('id: $id, ')
          ..write('originalPaymentId: $originalPaymentId, ')
          ..write('originalCashEventId: $originalCashEventId, ')
          ..write('refundPaymentId: $refundPaymentId, ')
          ..write('refundCashEventId: $refundCashEventId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('originalFinancialAccountId: $originalFinancialAccountId, ')
          ..write('refundFinancialAccountId: $refundFinancialAccountId, ')
          ..write('invoiceFinancialAccountId: $invoiceFinancialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    originalPaymentId,
    originalCashEventId,
    refundPaymentId,
    refundCashEventId,
    invoiceId,
    originalFinancialAccountId,
    refundFinancialAccountId,
    invoiceFinancialAccountId,
    partyId,
    partyRole,
    currencyCode,
    amountMinor,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Refund &&
          other.id == this.id &&
          other.originalPaymentId == this.originalPaymentId &&
          other.originalCashEventId == this.originalCashEventId &&
          other.refundPaymentId == this.refundPaymentId &&
          other.refundCashEventId == this.refundCashEventId &&
          other.invoiceId == this.invoiceId &&
          other.originalFinancialAccountId == this.originalFinancialAccountId &&
          other.refundFinancialAccountId == this.refundFinancialAccountId &&
          other.invoiceFinancialAccountId == this.invoiceFinancialAccountId &&
          other.partyId == this.partyId &&
          other.partyRole == this.partyRole &&
          other.currencyCode == this.currencyCode &&
          other.amountMinor == this.amountMinor &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestFingerprint == this.requestFingerprint &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class RefundsCompanion extends UpdateCompanion<Refund> {
  final Value<String> id;
  final Value<String> originalPaymentId;
  final Value<String> originalCashEventId;
  final Value<String> refundPaymentId;
  final Value<String> refundCashEventId;
  final Value<String?> invoiceId;
  final Value<String> originalFinancialAccountId;
  final Value<String> refundFinancialAccountId;
  final Value<String?> invoiceFinancialAccountId;
  final Value<String> partyId;
  final Value<String> partyRole;
  final Value<String> currencyCode;
  final Value<int> amountMinor;
  final Value<String> idempotencyKey;
  final Value<String> requestFingerprint;
  final Value<String?> actorId;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RefundsCompanion({
    this.id = const Value.absent(),
    this.originalPaymentId = const Value.absent(),
    this.originalCashEventId = const Value.absent(),
    this.refundPaymentId = const Value.absent(),
    this.refundCashEventId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.originalFinancialAccountId = const Value.absent(),
    this.refundFinancialAccountId = const Value.absent(),
    this.invoiceFinancialAccountId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.partyRole = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestFingerprint = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefundsCompanion.insert({
    required String id,
    required String originalPaymentId,
    required String originalCashEventId,
    required String refundPaymentId,
    required String refundCashEventId,
    this.invoiceId = const Value.absent(),
    required String originalFinancialAccountId,
    required String refundFinancialAccountId,
    this.invoiceFinancialAccountId = const Value.absent(),
    required String partyId,
    required String partyRole,
    required String currencyCode,
    required int amountMinor,
    required String idempotencyKey,
    required String requestFingerprint,
    this.actorId = const Value.absent(),
    required String reason,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       originalPaymentId = Value(originalPaymentId),
       originalCashEventId = Value(originalCashEventId),
       refundPaymentId = Value(refundPaymentId),
       refundCashEventId = Value(refundCashEventId),
       originalFinancialAccountId = Value(originalFinancialAccountId),
       refundFinancialAccountId = Value(refundFinancialAccountId),
       partyId = Value(partyId),
       partyRole = Value(partyRole),
       currencyCode = Value(currencyCode),
       amountMinor = Value(amountMinor),
       idempotencyKey = Value(idempotencyKey),
       requestFingerprint = Value(requestFingerprint),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<Refund> custom({
    Expression<String>? id,
    Expression<String>? originalPaymentId,
    Expression<String>? originalCashEventId,
    Expression<String>? refundPaymentId,
    Expression<String>? refundCashEventId,
    Expression<String>? invoiceId,
    Expression<String>? originalFinancialAccountId,
    Expression<String>? refundFinancialAccountId,
    Expression<String>? invoiceFinancialAccountId,
    Expression<String>? partyId,
    Expression<String>? partyRole,
    Expression<String>? currencyCode,
    Expression<int>? amountMinor,
    Expression<String>? idempotencyKey,
    Expression<String>? requestFingerprint,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'refund_id': id,
      if (originalPaymentId != null) 'original_payment_id': originalPaymentId,
      if (originalCashEventId != null)
        'original_cash_event_id': originalCashEventId,
      if (refundPaymentId != null) 'refund_payment_id': refundPaymentId,
      if (refundCashEventId != null) 'refund_cash_event_id': refundCashEventId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (originalFinancialAccountId != null)
        'original_financial_account_id': originalFinancialAccountId,
      if (refundFinancialAccountId != null)
        'refund_financial_account_id': refundFinancialAccountId,
      if (invoiceFinancialAccountId != null)
        'invoice_financial_account_id': invoiceFinancialAccountId,
      if (partyId != null) 'party_id': partyId,
      if (partyRole != null) 'party_role': partyRole,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestFingerprint != null) 'request_fingerprint': requestFingerprint,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefundsCompanion copyWith({
    Value<String>? id,
    Value<String>? originalPaymentId,
    Value<String>? originalCashEventId,
    Value<String>? refundPaymentId,
    Value<String>? refundCashEventId,
    Value<String?>? invoiceId,
    Value<String>? originalFinancialAccountId,
    Value<String>? refundFinancialAccountId,
    Value<String?>? invoiceFinancialAccountId,
    Value<String>? partyId,
    Value<String>? partyRole,
    Value<String>? currencyCode,
    Value<int>? amountMinor,
    Value<String>? idempotencyKey,
    Value<String>? requestFingerprint,
    Value<String?>? actorId,
    Value<String>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RefundsCompanion(
      id: id ?? this.id,
      originalPaymentId: originalPaymentId ?? this.originalPaymentId,
      originalCashEventId: originalCashEventId ?? this.originalCashEventId,
      refundPaymentId: refundPaymentId ?? this.refundPaymentId,
      refundCashEventId: refundCashEventId ?? this.refundCashEventId,
      invoiceId: invoiceId ?? this.invoiceId,
      originalFinancialAccountId:
          originalFinancialAccountId ?? this.originalFinancialAccountId,
      refundFinancialAccountId:
          refundFinancialAccountId ?? this.refundFinancialAccountId,
      invoiceFinancialAccountId:
          invoiceFinancialAccountId ?? this.invoiceFinancialAccountId,
      partyId: partyId ?? this.partyId,
      partyRole: partyRole ?? this.partyRole,
      currencyCode: currencyCode ?? this.currencyCode,
      amountMinor: amountMinor ?? this.amountMinor,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestFingerprint: requestFingerprint ?? this.requestFingerprint,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['refund_id'] = Variable<String>(id.value);
    }
    if (originalPaymentId.present) {
      map['original_payment_id'] = Variable<String>(originalPaymentId.value);
    }
    if (originalCashEventId.present) {
      map['original_cash_event_id'] = Variable<String>(
        originalCashEventId.value,
      );
    }
    if (refundPaymentId.present) {
      map['refund_payment_id'] = Variable<String>(refundPaymentId.value);
    }
    if (refundCashEventId.present) {
      map['refund_cash_event_id'] = Variable<String>(refundCashEventId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (originalFinancialAccountId.present) {
      map['original_financial_account_id'] = Variable<String>(
        originalFinancialAccountId.value,
      );
    }
    if (refundFinancialAccountId.present) {
      map['refund_financial_account_id'] = Variable<String>(
        refundFinancialAccountId.value,
      );
    }
    if (invoiceFinancialAccountId.present) {
      map['invoice_financial_account_id'] = Variable<String>(
        invoiceFinancialAccountId.value,
      );
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (partyRole.present) {
      map['party_role'] = Variable<String>(partyRole.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestFingerprint.present) {
      map['request_fingerprint'] = Variable<String>(requestFingerprint.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
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
    return (StringBuffer('RefundsCompanion(')
          ..write('id: $id, ')
          ..write('originalPaymentId: $originalPaymentId, ')
          ..write('originalCashEventId: $originalCashEventId, ')
          ..write('refundPaymentId: $refundPaymentId, ')
          ..write('refundCashEventId: $refundCashEventId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('originalFinancialAccountId: $originalFinancialAccountId, ')
          ..write('refundFinancialAccountId: $refundFinancialAccountId, ')
          ..write('invoiceFinancialAccountId: $invoiceFinancialAccountId, ')
          ..write('partyId: $partyId, ')
          ..write('partyRole: $partyRole, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefundFinancialTransactionsTable extends RefundFinancialTransactions
    with
        TableInfo<
          $RefundFinancialTransactionsTable,
          RefundFinancialTransaction
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefundFinancialTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _refundIdMeta = const VerificationMeta(
    'refundId',
  );
  @override
  late final GeneratedColumn<String> refundId = GeneratedColumn<String>(
    'refund_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashEventIdMeta = const VerificationMeta(
    'cashEventId',
  );
  @override
  late final GeneratedColumn<String> cashEventId = GeneratedColumn<String>(
    'cash_event_id',
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
  );
  @override
  List<GeneratedColumn> get $columns => [
    refundId,
    transactionId,
    cashEventId,
    paymentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refund_financial_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefundFinancialTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('refund_id')) {
      context.handle(
        _refundIdMeta,
        refundId.isAcceptableOrUnknown(data['refund_id']!, _refundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refundIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('cash_event_id')) {
      context.handle(
        _cashEventIdMeta,
        cashEventId.isAcceptableOrUnknown(
          data['cash_event_id']!,
          _cashEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashEventIdMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {refundId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {transactionId},
  ];
  @override
  RefundFinancialTransaction map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefundFinancialTransaction(
      refundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      cashEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_event_id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
    );
  }

  @override
  $RefundFinancialTransactionsTable createAlias(String alias) {
    return $RefundFinancialTransactionsTable(attachedDatabase, alias);
  }
}

class RefundFinancialTransaction extends DataClass
    implements Insertable<RefundFinancialTransaction> {
  final String refundId;
  final String transactionId;
  final String cashEventId;
  final String paymentId;
  const RefundFinancialTransaction({
    required this.refundId,
    required this.transactionId,
    required this.cashEventId,
    required this.paymentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['refund_id'] = Variable<String>(refundId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['cash_event_id'] = Variable<String>(cashEventId);
    map['payment_id'] = Variable<String>(paymentId);
    return map;
  }

  RefundFinancialTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RefundFinancialTransactionsCompanion(
      refundId: Value(refundId),
      transactionId: Value(transactionId),
      cashEventId: Value(cashEventId),
      paymentId: Value(paymentId),
    );
  }

  factory RefundFinancialTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefundFinancialTransaction(
      refundId: serializer.fromJson<String>(json['refundId']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      cashEventId: serializer.fromJson<String>(json['cashEventId']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'refundId': serializer.toJson<String>(refundId),
      'transactionId': serializer.toJson<String>(transactionId),
      'cashEventId': serializer.toJson<String>(cashEventId),
      'paymentId': serializer.toJson<String>(paymentId),
    };
  }

  RefundFinancialTransaction copyWith({
    String? refundId,
    String? transactionId,
    String? cashEventId,
    String? paymentId,
  }) => RefundFinancialTransaction(
    refundId: refundId ?? this.refundId,
    transactionId: transactionId ?? this.transactionId,
    cashEventId: cashEventId ?? this.cashEventId,
    paymentId: paymentId ?? this.paymentId,
  );
  RefundFinancialTransaction copyWithCompanion(
    RefundFinancialTransactionsCompanion data,
  ) {
    return RefundFinancialTransaction(
      refundId: data.refundId.present ? data.refundId.value : this.refundId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      cashEventId: data.cashEventId.present
          ? data.cashEventId.value
          : this.cashEventId,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefundFinancialTransaction(')
          ..write('refundId: $refundId, ')
          ..write('transactionId: $transactionId, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(refundId, transactionId, cashEventId, paymentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefundFinancialTransaction &&
          other.refundId == this.refundId &&
          other.transactionId == this.transactionId &&
          other.cashEventId == this.cashEventId &&
          other.paymentId == this.paymentId);
}

class RefundFinancialTransactionsCompanion
    extends UpdateCompanion<RefundFinancialTransaction> {
  final Value<String> refundId;
  final Value<String> transactionId;
  final Value<String> cashEventId;
  final Value<String> paymentId;
  final Value<int> rowid;
  const RefundFinancialTransactionsCompanion({
    this.refundId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.cashEventId = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefundFinancialTransactionsCompanion.insert({
    required String refundId,
    required String transactionId,
    required String cashEventId,
    required String paymentId,
    this.rowid = const Value.absent(),
  }) : refundId = Value(refundId),
       transactionId = Value(transactionId),
       cashEventId = Value(cashEventId),
       paymentId = Value(paymentId);
  static Insertable<RefundFinancialTransaction> custom({
    Expression<String>? refundId,
    Expression<String>? transactionId,
    Expression<String>? cashEventId,
    Expression<String>? paymentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (refundId != null) 'refund_id': refundId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (cashEventId != null) 'cash_event_id': cashEventId,
      if (paymentId != null) 'payment_id': paymentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefundFinancialTransactionsCompanion copyWith({
    Value<String>? refundId,
    Value<String>? transactionId,
    Value<String>? cashEventId,
    Value<String>? paymentId,
    Value<int>? rowid,
  }) {
    return RefundFinancialTransactionsCompanion(
      refundId: refundId ?? this.refundId,
      transactionId: transactionId ?? this.transactionId,
      cashEventId: cashEventId ?? this.cashEventId,
      paymentId: paymentId ?? this.paymentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (refundId.present) {
      map['refund_id'] = Variable<String>(refundId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (cashEventId.present) {
      map['cash_event_id'] = Variable<String>(cashEventId.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefundFinancialTransactionsCompanion(')
          ..write('refundId: $refundId, ')
          ..write('transactionId: $transactionId, ')
          ..write('cashEventId: $cashEventId, ')
          ..write('paymentId: $paymentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefundAllocationReversalsTable extends RefundAllocationReversals
    with TableInfo<$RefundAllocationReversalsTable, RefundAllocationReversal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefundAllocationReversalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'refund_allocation_reversal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundIdMeta = const VerificationMeta(
    'refundId',
  );
  @override
  late final GeneratedColumn<String> refundId = GeneratedColumn<String>(
    'refund_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalPaymentIdMeta = const VerificationMeta(
    'originalPaymentId',
  );
  @override
  late final GeneratedColumn<String> originalPaymentId =
      GeneratedColumn<String>(
        'original_payment_id',
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
  static const VerificationMeta _allocationIdMeta = const VerificationMeta(
    'allocationId',
  );
  @override
  late final GeneratedColumn<String> allocationId = GeneratedColumn<String>(
    'allocation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allocationReversalIdMeta =
      const VerificationMeta('allocationReversalId');
  @override
  late final GeneratedColumn<String> allocationReversalId =
      GeneratedColumn<String>(
        'allocation_reversal_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestFingerprintMeta =
      const VerificationMeta('requestFingerprint');
  @override
  late final GeneratedColumn<String> requestFingerprint =
      GeneratedColumn<String>(
        'request_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    refundId,
    originalPaymentId,
    invoiceId,
    allocationId,
    allocationReversalId,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refund_allocation_reversals';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefundAllocationReversal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('refund_allocation_reversal_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(
          data['refund_allocation_reversal_id']!,
          _idMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('refund_id')) {
      context.handle(
        _refundIdMeta,
        refundId.isAcceptableOrUnknown(data['refund_id']!, _refundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refundIdMeta);
    }
    if (data.containsKey('original_payment_id')) {
      context.handle(
        _originalPaymentIdMeta,
        originalPaymentId.isAcceptableOrUnknown(
          data['original_payment_id']!,
          _originalPaymentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalPaymentIdMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('allocation_id')) {
      context.handle(
        _allocationIdMeta,
        allocationId.isAcceptableOrUnknown(
          data['allocation_id']!,
          _allocationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocationIdMeta);
    }
    if (data.containsKey('allocation_reversal_id')) {
      context.handle(
        _allocationReversalIdMeta,
        allocationReversalId.isAcceptableOrUnknown(
          data['allocation_reversal_id']!,
          _allocationReversalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocationReversalIdMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_fingerprint')) {
      context.handle(
        _requestFingerprintMeta,
        requestFingerprint.isAcceptableOrUnknown(
          data['request_fingerprint']!,
          _requestFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestFingerprintMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, refundId},
    {allocationReversalId},
    {idempotencyKey},
  ];
  @override
  RefundAllocationReversal map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefundAllocationReversal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_allocation_reversal_id'],
      )!,
      refundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_id'],
      )!,
      originalPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_payment_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      allocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_id'],
      )!,
      allocationReversalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_reversal_id'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_fingerprint'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RefundAllocationReversalsTable createAlias(String alias) {
    return $RefundAllocationReversalsTable(attachedDatabase, alias);
  }
}

class RefundAllocationReversal extends DataClass
    implements Insertable<RefundAllocationReversal> {
  final String id;
  final String refundId;
  final String originalPaymentId;
  final String invoiceId;
  final String allocationId;
  final String allocationReversalId;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String? reason;
  final DateTime createdAt;
  const RefundAllocationReversal({
    required this.id,
    required this.refundId,
    required this.originalPaymentId,
    required this.invoiceId,
    required this.allocationId,
    required this.allocationReversalId,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.actorId,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['refund_allocation_reversal_id'] = Variable<String>(id);
    map['refund_id'] = Variable<String>(refundId);
    map['original_payment_id'] = Variable<String>(originalPaymentId);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['allocation_id'] = Variable<String>(allocationId);
    map['allocation_reversal_id'] = Variable<String>(allocationReversalId);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_fingerprint'] = Variable<String>(requestFingerprint);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RefundAllocationReversalsCompanion toCompanion(bool nullToAbsent) {
    return RefundAllocationReversalsCompanion(
      id: Value(id),
      refundId: Value(refundId),
      originalPaymentId: Value(originalPaymentId),
      invoiceId: Value(invoiceId),
      allocationId: Value(allocationId),
      allocationReversalId: Value(allocationReversalId),
      idempotencyKey: Value(idempotencyKey),
      requestFingerprint: Value(requestFingerprint),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory RefundAllocationReversal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefundAllocationReversal(
      id: serializer.fromJson<String>(json['id']),
      refundId: serializer.fromJson<String>(json['refundId']),
      originalPaymentId: serializer.fromJson<String>(json['originalPaymentId']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      allocationId: serializer.fromJson<String>(json['allocationId']),
      allocationReversalId: serializer.fromJson<String>(
        json['allocationReversalId'],
      ),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestFingerprint: serializer.fromJson<String>(
        json['requestFingerprint'],
      ),
      actorId: serializer.fromJson<String?>(json['actorId']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'refundId': serializer.toJson<String>(refundId),
      'originalPaymentId': serializer.toJson<String>(originalPaymentId),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'allocationId': serializer.toJson<String>(allocationId),
      'allocationReversalId': serializer.toJson<String>(allocationReversalId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestFingerprint': serializer.toJson<String>(requestFingerprint),
      'actorId': serializer.toJson<String?>(actorId),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RefundAllocationReversal copyWith({
    String? id,
    String? refundId,
    String? originalPaymentId,
    String? invoiceId,
    String? allocationId,
    String? allocationReversalId,
    String? idempotencyKey,
    String? requestFingerprint,
    Value<String?> actorId = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => RefundAllocationReversal(
    id: id ?? this.id,
    refundId: refundId ?? this.refundId,
    originalPaymentId: originalPaymentId ?? this.originalPaymentId,
    invoiceId: invoiceId ?? this.invoiceId,
    allocationId: allocationId ?? this.allocationId,
    allocationReversalId: allocationReversalId ?? this.allocationReversalId,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestFingerprint: requestFingerprint ?? this.requestFingerprint,
    actorId: actorId.present ? actorId.value : this.actorId,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  RefundAllocationReversal copyWithCompanion(
    RefundAllocationReversalsCompanion data,
  ) {
    return RefundAllocationReversal(
      id: data.id.present ? data.id.value : this.id,
      refundId: data.refundId.present ? data.refundId.value : this.refundId,
      originalPaymentId: data.originalPaymentId.present
          ? data.originalPaymentId.value
          : this.originalPaymentId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      allocationId: data.allocationId.present
          ? data.allocationId.value
          : this.allocationId,
      allocationReversalId: data.allocationReversalId.present
          ? data.allocationReversalId.value
          : this.allocationReversalId,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestFingerprint: data.requestFingerprint.present
          ? data.requestFingerprint.value
          : this.requestFingerprint,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefundAllocationReversal(')
          ..write('id: $id, ')
          ..write('refundId: $refundId, ')
          ..write('originalPaymentId: $originalPaymentId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('allocationId: $allocationId, ')
          ..write('allocationReversalId: $allocationReversalId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    refundId,
    originalPaymentId,
    invoiceId,
    allocationId,
    allocationReversalId,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefundAllocationReversal &&
          other.id == this.id &&
          other.refundId == this.refundId &&
          other.originalPaymentId == this.originalPaymentId &&
          other.invoiceId == this.invoiceId &&
          other.allocationId == this.allocationId &&
          other.allocationReversalId == this.allocationReversalId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestFingerprint == this.requestFingerprint &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class RefundAllocationReversalsCompanion
    extends UpdateCompanion<RefundAllocationReversal> {
  final Value<String> id;
  final Value<String> refundId;
  final Value<String> originalPaymentId;
  final Value<String> invoiceId;
  final Value<String> allocationId;
  final Value<String> allocationReversalId;
  final Value<String> idempotencyKey;
  final Value<String> requestFingerprint;
  final Value<String?> actorId;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RefundAllocationReversalsCompanion({
    this.id = const Value.absent(),
    this.refundId = const Value.absent(),
    this.originalPaymentId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.allocationId = const Value.absent(),
    this.allocationReversalId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestFingerprint = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefundAllocationReversalsCompanion.insert({
    required String id,
    required String refundId,
    required String originalPaymentId,
    required String invoiceId,
    required String allocationId,
    required String allocationReversalId,
    required String idempotencyKey,
    required String requestFingerprint,
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       refundId = Value(refundId),
       originalPaymentId = Value(originalPaymentId),
       invoiceId = Value(invoiceId),
       allocationId = Value(allocationId),
       allocationReversalId = Value(allocationReversalId),
       idempotencyKey = Value(idempotencyKey),
       requestFingerprint = Value(requestFingerprint),
       createdAt = Value(createdAt);
  static Insertable<RefundAllocationReversal> custom({
    Expression<String>? id,
    Expression<String>? refundId,
    Expression<String>? originalPaymentId,
    Expression<String>? invoiceId,
    Expression<String>? allocationId,
    Expression<String>? allocationReversalId,
    Expression<String>? idempotencyKey,
    Expression<String>? requestFingerprint,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'refund_allocation_reversal_id': id,
      if (refundId != null) 'refund_id': refundId,
      if (originalPaymentId != null) 'original_payment_id': originalPaymentId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (allocationId != null) 'allocation_id': allocationId,
      if (allocationReversalId != null)
        'allocation_reversal_id': allocationReversalId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestFingerprint != null) 'request_fingerprint': requestFingerprint,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefundAllocationReversalsCompanion copyWith({
    Value<String>? id,
    Value<String>? refundId,
    Value<String>? originalPaymentId,
    Value<String>? invoiceId,
    Value<String>? allocationId,
    Value<String>? allocationReversalId,
    Value<String>? idempotencyKey,
    Value<String>? requestFingerprint,
    Value<String?>? actorId,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RefundAllocationReversalsCompanion(
      id: id ?? this.id,
      refundId: refundId ?? this.refundId,
      originalPaymentId: originalPaymentId ?? this.originalPaymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      allocationId: allocationId ?? this.allocationId,
      allocationReversalId: allocationReversalId ?? this.allocationReversalId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestFingerprint: requestFingerprint ?? this.requestFingerprint,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['refund_allocation_reversal_id'] = Variable<String>(id.value);
    }
    if (refundId.present) {
      map['refund_id'] = Variable<String>(refundId.value);
    }
    if (originalPaymentId.present) {
      map['original_payment_id'] = Variable<String>(originalPaymentId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (allocationId.present) {
      map['allocation_id'] = Variable<String>(allocationId.value);
    }
    if (allocationReversalId.present) {
      map['allocation_reversal_id'] = Variable<String>(
        allocationReversalId.value,
      );
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestFingerprint.present) {
      map['request_fingerprint'] = Variable<String>(requestFingerprint.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
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
    return (StringBuffer('RefundAllocationReversalsCompanion(')
          ..write('id: $id, ')
          ..write('refundId: $refundId, ')
          ..write('originalPaymentId: $originalPaymentId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('allocationId: $allocationId, ')
          ..write('allocationReversalId: $allocationReversalId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceLifecycleEventsTable extends InvoiceLifecycleEvents
    with TableInfo<$InvoiceLifecycleEventsTable, InvoiceLifecycleEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceLifecycleEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'lifecycle_event_id',
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
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousEventIdMeta = const VerificationMeta(
    'previousEventId',
  );
  @override
  late final GeneratedColumn<String> previousEventId = GeneratedColumn<String>(
    'previous_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestFingerprintMeta =
      const VerificationMeta('requestFingerprint');
  @override
  late final GeneratedColumn<String> requestFingerprint =
      GeneratedColumn<String>(
        'request_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    sequence,
    state,
    previousEventId,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_lifecycle_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceLifecycleEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lifecycle_event_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['lifecycle_event_id']!, _idMeta),
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
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('previous_event_id')) {
      context.handle(
        _previousEventIdMeta,
        previousEventId.isAcceptableOrUnknown(
          data['previous_event_id']!,
          _previousEventIdMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('request_fingerprint')) {
      context.handle(
        _requestFingerprintMeta,
        requestFingerprint.isAcceptableOrUnknown(
          data['request_fingerprint']!,
          _requestFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestFingerprintMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {invoiceId, sequence},
    {id, invoiceId},
    {idempotencyKey},
  ];
  @override
  InvoiceLifecycleEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceLifecycleEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle_event_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      previousEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_event_id'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      requestFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_fingerprint'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $InvoiceLifecycleEventsTable createAlias(String alias) {
    return $InvoiceLifecycleEventsTable(attachedDatabase, alias);
  }
}

class InvoiceLifecycleEvent extends DataClass
    implements Insertable<InvoiceLifecycleEvent> {
  final String id;
  final String invoiceId;
  final int sequence;
  final String state;
  final String? previousEventId;
  final String idempotencyKey;
  final String requestFingerprint;
  final String? actorId;
  final String? reason;
  final DateTime recordedAt;
  const InvoiceLifecycleEvent({
    required this.id,
    required this.invoiceId,
    required this.sequence,
    required this.state,
    this.previousEventId,
    required this.idempotencyKey,
    required this.requestFingerprint,
    this.actorId,
    this.reason,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lifecycle_event_id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['sequence'] = Variable<int>(sequence);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || previousEventId != null) {
      map['previous_event_id'] = Variable<String>(previousEventId);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['request_fingerprint'] = Variable<String>(requestFingerprint);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  InvoiceLifecycleEventsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceLifecycleEventsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      sequence: Value(sequence),
      state: Value(state),
      previousEventId: previousEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousEventId),
      idempotencyKey: Value(idempotencyKey),
      requestFingerprint: Value(requestFingerprint),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      recordedAt: Value(recordedAt),
    );
  }

  factory InvoiceLifecycleEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceLifecycleEvent(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      state: serializer.fromJson<String>(json['state']),
      previousEventId: serializer.fromJson<String?>(json['previousEventId']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      requestFingerprint: serializer.fromJson<String>(
        json['requestFingerprint'],
      ),
      actorId: serializer.fromJson<String?>(json['actorId']),
      reason: serializer.fromJson<String?>(json['reason']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'sequence': serializer.toJson<int>(sequence),
      'state': serializer.toJson<String>(state),
      'previousEventId': serializer.toJson<String?>(previousEventId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'requestFingerprint': serializer.toJson<String>(requestFingerprint),
      'actorId': serializer.toJson<String?>(actorId),
      'reason': serializer.toJson<String?>(reason),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  InvoiceLifecycleEvent copyWith({
    String? id,
    String? invoiceId,
    int? sequence,
    String? state,
    Value<String?> previousEventId = const Value.absent(),
    String? idempotencyKey,
    String? requestFingerprint,
    Value<String?> actorId = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    DateTime? recordedAt,
  }) => InvoiceLifecycleEvent(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    sequence: sequence ?? this.sequence,
    state: state ?? this.state,
    previousEventId: previousEventId.present
        ? previousEventId.value
        : this.previousEventId,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    requestFingerprint: requestFingerprint ?? this.requestFingerprint,
    actorId: actorId.present ? actorId.value : this.actorId,
    reason: reason.present ? reason.value : this.reason,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  InvoiceLifecycleEvent copyWithCompanion(
    InvoiceLifecycleEventsCompanion data,
  ) {
    return InvoiceLifecycleEvent(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      state: data.state.present ? data.state.value : this.state,
      previousEventId: data.previousEventId.present
          ? data.previousEventId.value
          : this.previousEventId,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      requestFingerprint: data.requestFingerprint.present
          ? data.requestFingerprint.value
          : this.requestFingerprint,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLifecycleEvent(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('sequence: $sequence, ')
          ..write('state: $state, ')
          ..write('previousEventId: $previousEventId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    sequence,
    state,
    previousEventId,
    idempotencyKey,
    requestFingerprint,
    actorId,
    reason,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceLifecycleEvent &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.sequence == this.sequence &&
          other.state == this.state &&
          other.previousEventId == this.previousEventId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.requestFingerprint == this.requestFingerprint &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.recordedAt == this.recordedAt);
}

class InvoiceLifecycleEventsCompanion
    extends UpdateCompanion<InvoiceLifecycleEvent> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<int> sequence;
  final Value<String> state;
  final Value<String?> previousEventId;
  final Value<String> idempotencyKey;
  final Value<String> requestFingerprint;
  final Value<String?> actorId;
  final Value<String?> reason;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const InvoiceLifecycleEventsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.state = const Value.absent(),
    this.previousEventId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.requestFingerprint = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceLifecycleEventsCompanion.insert({
    required String id,
    required String invoiceId,
    required int sequence,
    required String state,
    this.previousEventId = const Value.absent(),
    required String idempotencyKey,
    required String requestFingerprint,
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       sequence = Value(sequence),
       state = Value(state),
       idempotencyKey = Value(idempotencyKey),
       requestFingerprint = Value(requestFingerprint),
       recordedAt = Value(recordedAt);
  static Insertable<InvoiceLifecycleEvent> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<int>? sequence,
    Expression<String>? state,
    Expression<String>? previousEventId,
    Expression<String>? idempotencyKey,
    Expression<String>? requestFingerprint,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'lifecycle_event_id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (sequence != null) 'sequence': sequence,
      if (state != null) 'state': state,
      if (previousEventId != null) 'previous_event_id': previousEventId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (requestFingerprint != null) 'request_fingerprint': requestFingerprint,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceLifecycleEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<int>? sequence,
    Value<String>? state,
    Value<String?>? previousEventId,
    Value<String>? idempotencyKey,
    Value<String>? requestFingerprint,
    Value<String?>? actorId,
    Value<String?>? reason,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return InvoiceLifecycleEventsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      sequence: sequence ?? this.sequence,
      state: state ?? this.state,
      previousEventId: previousEventId ?? this.previousEventId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      requestFingerprint: requestFingerprint ?? this.requestFingerprint,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['lifecycle_event_id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (previousEventId.present) {
      map['previous_event_id'] = Variable<String>(previousEventId.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (requestFingerprint.present) {
      map['request_fingerprint'] = Variable<String>(requestFingerprint.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLifecycleEventsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('sequence: $sequence, ')
          ..write('state: $state, ')
          ..write('previousEventId: $previousEventId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('requestFingerprint: $requestFingerprint, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $PartyRolesTable partyRoles = $PartyRolesTable(this);
  late final $FinancialAccountsTable financialAccounts =
      $FinancialAccountsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceLinesTable invoiceLines = $InvoiceLinesTable(this);
  late final $PaymentIdentitiesTable paymentIdentities =
      $PaymentIdentitiesTable(this);
  late final $CashEventsTable cashEvents = $CashEventsTable(this);
  late final $FinancialTransactionsTable financialTransactions =
      $FinancialTransactionsTable(this);
  late final $CashEventVersionsTable cashEventVersions =
      $CashEventVersionsTable(this);
  late final $CashEventHeadsTable cashEventHeads = $CashEventHeadsTable(this);
  late final $ReconciliationCasesTable reconciliationCases =
      $ReconciliationCasesTable(this);
  late final $SuspenseResolutionsTable suspenseResolutions =
      $SuspenseResolutionsTable(this);
  late final $SuspenseEntriesTable suspenseEntries = $SuspenseEntriesTable(
    this,
  );
  late final $InvoiceAllocationsTable invoiceAllocations =
      $InvoiceAllocationsTable(this);
  late final $AllocationReversalsTable allocationReversals =
      $AllocationReversalsTable(this);
  late final $AllocationStatusHistoryTable allocationStatusHistory =
      $AllocationStatusHistoryTable(this);
  late final $RefundsTable refunds = $RefundsTable(this);
  late final $RefundFinancialTransactionsTable refundFinancialTransactions =
      $RefundFinancialTransactionsTable(this);
  late final $RefundAllocationReversalsTable refundAllocationReversals =
      $RefundAllocationReversalsTable(this);
  late final $InvoiceLifecycleEventsTable invoiceLifecycleEvents =
      $InvoiceLifecycleEventsTable(this);
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
    paymentIdentities,
    cashEvents,
    financialTransactions,
    cashEventVersions,
    cashEventHeads,
    reconciliationCases,
    suspenseResolutions,
    suspenseEntries,
    invoiceAllocations,
    allocationReversals,
    allocationStatusHistory,
    refunds,
    refundFinancialTransactions,
    refundAllocationReversals,
    invoiceLifecycleEvents,
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
    extends Composer<_$AppDatabase, $CurrenciesTable> {
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
    extends Composer<_$AppDatabase, $CurrenciesTable> {
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
    extends Composer<_$AppDatabase, $CurrenciesTable> {
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
          _$AppDatabase,
          $CurrenciesTable,
          Currency,
          $$CurrenciesTableFilterComposer,
          $$CurrenciesTableOrderingComposer,
          $$CurrenciesTableAnnotationComposer,
          $$CurrenciesTableCreateCompanionBuilder,
          $$CurrenciesTableUpdateCompanionBuilder,
          (Currency, BaseReferences<_$AppDatabase, $CurrenciesTable, Currency>),
          Currency,
          PrefetchHooks Function()
        > {
  $$CurrenciesTableTableManager(_$AppDatabase db, $CurrenciesTable table)
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
                  BaseReferences<_$AppDatabase, $CurrenciesTable, Currency>(
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
      _$AppDatabase,
      $CurrenciesTable,
      Currency,
      $$CurrenciesTableFilterComposer,
      $$CurrenciesTableOrderingComposer,
      $$CurrenciesTableAnnotationComposer,
      $$CurrenciesTableCreateCompanionBuilder,
      $$CurrenciesTableUpdateCompanionBuilder,
      (Currency, BaseReferences<_$AppDatabase, $CurrenciesTable, Currency>),
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
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
          Party,
          PrefetchHooks Function()
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
                  BaseReferences<_$AppDatabase, $PartiesTable, Party>(
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
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
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
    extends Composer<_$AppDatabase, $PartyRolesTable> {
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
    extends Composer<_$AppDatabase, $PartyRolesTable> {
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
    extends Composer<_$AppDatabase, $PartyRolesTable> {
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
          _$AppDatabase,
          $PartyRolesTable,
          PartyRole,
          $$PartyRolesTableFilterComposer,
          $$PartyRolesTableOrderingComposer,
          $$PartyRolesTableAnnotationComposer,
          $$PartyRolesTableCreateCompanionBuilder,
          $$PartyRolesTableUpdateCompanionBuilder,
          (
            PartyRole,
            BaseReferences<_$AppDatabase, $PartyRolesTable, PartyRole>,
          ),
          PartyRole,
          PrefetchHooks Function()
        > {
  $$PartyRolesTableTableManager(_$AppDatabase db, $PartyRolesTable table)
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
                  BaseReferences<_$AppDatabase, $PartyRolesTable, PartyRole>(
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
      _$AppDatabase,
      $PartyRolesTable,
      PartyRole,
      $$PartyRolesTableFilterComposer,
      $$PartyRolesTableOrderingComposer,
      $$PartyRolesTableAnnotationComposer,
      $$PartyRolesTableCreateCompanionBuilder,
      $$PartyRolesTableUpdateCompanionBuilder,
      (PartyRole, BaseReferences<_$AppDatabase, $PartyRolesTable, PartyRole>),
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
    extends Composer<_$AppDatabase, $FinancialAccountsTable> {
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
    extends Composer<_$AppDatabase, $FinancialAccountsTable> {
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
    extends Composer<_$AppDatabase, $FinancialAccountsTable> {
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
          _$AppDatabase,
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
              _$AppDatabase,
              $FinancialAccountsTable,
              FinancialAccount
            >,
          ),
          FinancialAccount,
          PrefetchHooks Function()
        > {
  $$FinancialAccountsTableTableManager(
    _$AppDatabase db,
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
                    _$AppDatabase,
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
      _$AppDatabase,
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
          _$AppDatabase,
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
    extends Composer<_$AppDatabase, $InvoicesTable> {
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
    extends Composer<_$AppDatabase, $InvoicesTable> {
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
    extends Composer<_$AppDatabase, $InvoicesTable> {
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
          _$AppDatabase,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
          Invoice,
          PrefetchHooks Function()
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
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
                  BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>(
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
      _$AppDatabase,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
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
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
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
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
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
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
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
          _$AppDatabase,
          $InvoiceLinesTable,
          InvoiceLine,
          $$InvoiceLinesTableFilterComposer,
          $$InvoiceLinesTableOrderingComposer,
          $$InvoiceLinesTableAnnotationComposer,
          $$InvoiceLinesTableCreateCompanionBuilder,
          $$InvoiceLinesTableUpdateCompanionBuilder,
          (
            InvoiceLine,
            BaseReferences<_$AppDatabase, $InvoiceLinesTable, InvoiceLine>,
          ),
          InvoiceLine,
          PrefetchHooks Function()
        > {
  $$InvoiceLinesTableTableManager(_$AppDatabase db, $InvoiceLinesTable table)
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
                    _$AppDatabase,
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
      _$AppDatabase,
      $InvoiceLinesTable,
      InvoiceLine,
      $$InvoiceLinesTableFilterComposer,
      $$InvoiceLinesTableOrderingComposer,
      $$InvoiceLinesTableAnnotationComposer,
      $$InvoiceLinesTableCreateCompanionBuilder,
      $$InvoiceLinesTableUpdateCompanionBuilder,
      (
        InvoiceLine,
        BaseReferences<_$AppDatabase, $InvoiceLinesTable, InvoiceLine>,
      ),
      InvoiceLine,
      PrefetchHooks Function()
    >;
typedef $$PaymentIdentitiesTableCreateCompanionBuilder =
    PaymentIdentitiesCompanion Function({
      required String id,
      required String financialAccountId,
      required String partyId,
      required String partyRole,
      required String currencyCode,
      required String financialDirection,
      required String createdByActorId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PaymentIdentitiesTableUpdateCompanionBuilder =
    PaymentIdentitiesCompanion Function({
      Value<String> id,
      Value<String> financialAccountId,
      Value<String> partyId,
      Value<String> partyRole,
      Value<String> currencyCode,
      Value<String> financialDirection,
      Value<String> createdByActorId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PaymentIdentitiesTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentIdentitiesTable> {
  $$PaymentIdentitiesTableFilterComposer({
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

  ColumnFilters<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialDirection => $composableBuilder(
    column: $table.financialDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentIdentitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentIdentitiesTable> {
  $$PaymentIdentitiesTableOrderingComposer({
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

  ColumnOrderings<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialDirection => $composableBuilder(
    column: $table.financialDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentIdentitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentIdentitiesTable> {
  $$PaymentIdentitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get financialDirection => $composableBuilder(
    column: $table.financialDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentIdentitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentIdentitiesTable,
          PaymentIdentity,
          $$PaymentIdentitiesTableFilterComposer,
          $$PaymentIdentitiesTableOrderingComposer,
          $$PaymentIdentitiesTableAnnotationComposer,
          $$PaymentIdentitiesTableCreateCompanionBuilder,
          $$PaymentIdentitiesTableUpdateCompanionBuilder,
          (
            PaymentIdentity,
            BaseReferences<
              _$AppDatabase,
              $PaymentIdentitiesTable,
              PaymentIdentity
            >,
          ),
          PaymentIdentity,
          PrefetchHooks Function()
        > {
  $$PaymentIdentitiesTableTableManager(
    _$AppDatabase db,
    $PaymentIdentitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentIdentitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentIdentitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentIdentitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> financialAccountId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> partyRole = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> financialDirection = const Value.absent(),
                Value<String> createdByActorId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentIdentitiesCompanion(
                id: id,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                financialDirection: financialDirection,
                createdByActorId: createdByActorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String financialAccountId,
                required String partyId,
                required String partyRole,
                required String currencyCode,
                required String financialDirection,
                required String createdByActorId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentIdentitiesCompanion.insert(
                id: id,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                financialDirection: financialDirection,
                createdByActorId: createdByActorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentIdentitiesTable, PaymentIdentity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PaymentIdentitiesTable,
                    PaymentIdentity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentIdentitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentIdentitiesTable,
      PaymentIdentity,
      $$PaymentIdentitiesTableFilterComposer,
      $$PaymentIdentitiesTableOrderingComposer,
      $$PaymentIdentitiesTableAnnotationComposer,
      $$PaymentIdentitiesTableCreateCompanionBuilder,
      $$PaymentIdentitiesTableUpdateCompanionBuilder,
      (
        PaymentIdentity,
        BaseReferences<_$AppDatabase, $PaymentIdentitiesTable, PaymentIdentity>,
      ),
      PaymentIdentity,
      PrefetchHooks Function()
    >;
typedef $$CashEventsTableCreateCompanionBuilder =
    CashEventsCompanion Function({
      required String id,
      required String paymentId,
      required String createdByActorId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CashEventsTableUpdateCompanionBuilder =
    CashEventsCompanion Function({
      Value<String> id,
      Value<String> paymentId,
      Value<String> createdByActorId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CashEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CashEventsTable> {
  $$CashEventsTableFilterComposer({
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

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashEventsTable> {
  $$CashEventsTableOrderingComposer({
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

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashEventsTable> {
  $$CashEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CashEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashEventsTable,
          CashEvent,
          $$CashEventsTableFilterComposer,
          $$CashEventsTableOrderingComposer,
          $$CashEventsTableAnnotationComposer,
          $$CashEventsTableCreateCompanionBuilder,
          $$CashEventsTableUpdateCompanionBuilder,
          (
            CashEvent,
            BaseReferences<_$AppDatabase, $CashEventsTable, CashEvent>,
          ),
          CashEvent,
          PrefetchHooks Function()
        > {
  $$CashEventsTableTableManager(_$AppDatabase db, $CashEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> createdByActorId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashEventsCompanion(
                id: id,
                paymentId: paymentId,
                createdByActorId: createdByActorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String paymentId,
                required String createdByActorId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CashEventsCompanion.insert(
                id: id,
                paymentId: paymentId,
                createdByActorId: createdByActorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashEventsTable, CashEvent>(table),
                  BaseReferences<_$AppDatabase, $CashEventsTable, CashEvent>(
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

typedef $$CashEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashEventsTable,
      CashEvent,
      $$CashEventsTableFilterComposer,
      $$CashEventsTableOrderingComposer,
      $$CashEventsTableAnnotationComposer,
      $$CashEventsTableCreateCompanionBuilder,
      $$CashEventsTableUpdateCompanionBuilder,
      (CashEvent, BaseReferences<_$AppDatabase, $CashEventsTable, CashEvent>),
      CashEvent,
      PrefetchHooks Function()
    >;
typedef $$FinancialTransactionsTableCreateCompanionBuilder =
    FinancialTransactionsCompanion Function({
      required String id,
      required String cashEventId,
      required String paymentId,
      required String financialAccountId,
      required String partyId,
      required String partyRole,
      required String currencyCode,
      required String transactionType,
      required String direction,
      required int amountMinor,
      Value<String?> relatedTransactionId,
      required String actorId,
      required String reason,
      Value<String?> idempotencyKey,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$FinancialTransactionsTableUpdateCompanionBuilder =
    FinancialTransactionsCompanion Function({
      Value<String> id,
      Value<String> cashEventId,
      Value<String> paymentId,
      Value<String> financialAccountId,
      Value<String> partyId,
      Value<String> partyRole,
      Value<String> currencyCode,
      Value<String> transactionType,
      Value<String> direction,
      Value<int> amountMinor,
      Value<String?> relatedTransactionId,
      Value<String> actorId,
      Value<String> reason,
      Value<String?> idempotencyKey,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

class $$FinancialTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialTransactionsTable> {
  $$FinancialTransactionsTableFilterComposer({
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

  ColumnFilters<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedTransactionId => $composableBuilder(
    column: $table.relatedTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinancialTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialTransactionsTable> {
  $$FinancialTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedTransactionId => $composableBuilder(
    column: $table.relatedTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinancialTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialTransactionsTable> {
  $$FinancialTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedTransactionId => $composableBuilder(
    column: $table.relatedTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$FinancialTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinancialTransactionsTable,
          FinancialTransaction,
          $$FinancialTransactionsTableFilterComposer,
          $$FinancialTransactionsTableOrderingComposer,
          $$FinancialTransactionsTableAnnotationComposer,
          $$FinancialTransactionsTableCreateCompanionBuilder,
          $$FinancialTransactionsTableUpdateCompanionBuilder,
          (
            FinancialTransaction,
            BaseReferences<
              _$AppDatabase,
              $FinancialTransactionsTable,
              FinancialTransaction
            >,
          ),
          FinancialTransaction,
          PrefetchHooks Function()
        > {
  $$FinancialTransactionsTableTableManager(
    _$AppDatabase db,
    $FinancialTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FinancialTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FinancialTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cashEventId = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> financialAccountId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> partyRole = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String?> relatedTransactionId = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialTransactionsCompanion(
                id: id,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                transactionType: transactionType,
                direction: direction,
                amountMinor: amountMinor,
                relatedTransactionId: relatedTransactionId,
                actorId: actorId,
                reason: reason,
                idempotencyKey: idempotencyKey,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cashEventId,
                required String paymentId,
                required String financialAccountId,
                required String partyId,
                required String partyRole,
                required String currencyCode,
                required String transactionType,
                required String direction,
                required int amountMinor,
                Value<String?> relatedTransactionId = const Value.absent(),
                required String actorId,
                required String reason,
                Value<String?> idempotencyKey = const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => FinancialTransactionsCompanion.insert(
                id: id,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                transactionType: transactionType,
                direction: direction,
                amountMinor: amountMinor,
                relatedTransactionId: relatedTransactionId,
                actorId: actorId,
                reason: reason,
                idempotencyKey: idempotencyKey,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $FinancialTransactionsTable,
                    FinancialTransaction
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FinancialTransactionsTable,
                    FinancialTransaction
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinancialTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinancialTransactionsTable,
      FinancialTransaction,
      $$FinancialTransactionsTableFilterComposer,
      $$FinancialTransactionsTableOrderingComposer,
      $$FinancialTransactionsTableAnnotationComposer,
      $$FinancialTransactionsTableCreateCompanionBuilder,
      $$FinancialTransactionsTableUpdateCompanionBuilder,
      (
        FinancialTransaction,
        BaseReferences<
          _$AppDatabase,
          $FinancialTransactionsTable,
          FinancialTransaction
        >,
      ),
      FinancialTransaction,
      PrefetchHooks Function()
    >;
typedef $$CashEventVersionsTableCreateCompanionBuilder =
    CashEventVersionsCompanion Function({
      required String id,
      required String cashEventId,
      required String paymentId,
      required int sequence,
      required String operation,
      required String occurred,
      required String cashDirection,
      required int physicalAmountMinor,
      required int effectiveRecognizedMinor,
      Value<String?> transactionId,
      Value<String?> previousVersionId,
      required String idempotencyKey,
      required String requestPayload,
      required String actorId,
      required String reason,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$CashEventVersionsTableUpdateCompanionBuilder =
    CashEventVersionsCompanion Function({
      Value<String> id,
      Value<String> cashEventId,
      Value<String> paymentId,
      Value<int> sequence,
      Value<String> operation,
      Value<String> occurred,
      Value<String> cashDirection,
      Value<int> physicalAmountMinor,
      Value<int> effectiveRecognizedMinor,
      Value<String?> transactionId,
      Value<String?> previousVersionId,
      Value<String> idempotencyKey,
      Value<String> requestPayload,
      Value<String> actorId,
      Value<String> reason,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$CashEventVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $CashEventVersionsTable> {
  $$CashEventVersionsTableFilterComposer({
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

  ColumnFilters<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurred => $composableBuilder(
    column: $table.occurred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashDirection => $composableBuilder(
    column: $table.cashDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get physicalAmountMinor => $composableBuilder(
    column: $table.physicalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveRecognizedMinor => $composableBuilder(
    column: $table.effectiveRecognizedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashEventVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashEventVersionsTable> {
  $$CashEventVersionsTableOrderingComposer({
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

  ColumnOrderings<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurred => $composableBuilder(
    column: $table.occurred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashDirection => $composableBuilder(
    column: $table.cashDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get physicalAmountMinor => $composableBuilder(
    column: $table.physicalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveRecognizedMinor => $composableBuilder(
    column: $table.effectiveRecognizedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashEventVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashEventVersionsTable> {
  $$CashEventVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get occurred =>
      $composableBuilder(column: $table.occurred, builder: (column) => column);

  GeneratedColumn<String> get cashDirection => $composableBuilder(
    column: $table.cashDirection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get physicalAmountMinor => $composableBuilder(
    column: $table.physicalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveRecognizedMinor => $composableBuilder(
    column: $table.effectiveRecognizedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$CashEventVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashEventVersionsTable,
          CashEventVersion,
          $$CashEventVersionsTableFilterComposer,
          $$CashEventVersionsTableOrderingComposer,
          $$CashEventVersionsTableAnnotationComposer,
          $$CashEventVersionsTableCreateCompanionBuilder,
          $$CashEventVersionsTableUpdateCompanionBuilder,
          (
            CashEventVersion,
            BaseReferences<
              _$AppDatabase,
              $CashEventVersionsTable,
              CashEventVersion
            >,
          ),
          CashEventVersion,
          PrefetchHooks Function()
        > {
  $$CashEventVersionsTableTableManager(
    _$AppDatabase db,
    $CashEventVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashEventVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashEventVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashEventVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cashEventId = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> occurred = const Value.absent(),
                Value<String> cashDirection = const Value.absent(),
                Value<int> physicalAmountMinor = const Value.absent(),
                Value<int> effectiveRecognizedMinor = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<String?> previousVersionId = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestPayload = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashEventVersionsCompanion(
                id: id,
                cashEventId: cashEventId,
                paymentId: paymentId,
                sequence: sequence,
                operation: operation,
                occurred: occurred,
                cashDirection: cashDirection,
                physicalAmountMinor: physicalAmountMinor,
                effectiveRecognizedMinor: effectiveRecognizedMinor,
                transactionId: transactionId,
                previousVersionId: previousVersionId,
                idempotencyKey: idempotencyKey,
                requestPayload: requestPayload,
                actorId: actorId,
                reason: reason,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cashEventId,
                required String paymentId,
                required int sequence,
                required String operation,
                required String occurred,
                required String cashDirection,
                required int physicalAmountMinor,
                required int effectiveRecognizedMinor,
                Value<String?> transactionId = const Value.absent(),
                Value<String?> previousVersionId = const Value.absent(),
                required String idempotencyKey,
                required String requestPayload,
                required String actorId,
                required String reason,
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => CashEventVersionsCompanion.insert(
                id: id,
                cashEventId: cashEventId,
                paymentId: paymentId,
                sequence: sequence,
                operation: operation,
                occurred: occurred,
                cashDirection: cashDirection,
                physicalAmountMinor: physicalAmountMinor,
                effectiveRecognizedMinor: effectiveRecognizedMinor,
                transactionId: transactionId,
                previousVersionId: previousVersionId,
                idempotencyKey: idempotencyKey,
                requestPayload: requestPayload,
                actorId: actorId,
                reason: reason,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashEventVersionsTable, CashEventVersion>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashEventVersionsTable,
                    CashEventVersion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashEventVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashEventVersionsTable,
      CashEventVersion,
      $$CashEventVersionsTableFilterComposer,
      $$CashEventVersionsTableOrderingComposer,
      $$CashEventVersionsTableAnnotationComposer,
      $$CashEventVersionsTableCreateCompanionBuilder,
      $$CashEventVersionsTableUpdateCompanionBuilder,
      (
        CashEventVersion,
        BaseReferences<
          _$AppDatabase,
          $CashEventVersionsTable,
          CashEventVersion
        >,
      ),
      CashEventVersion,
      PrefetchHooks Function()
    >;
typedef $$CashEventHeadsTableCreateCompanionBuilder =
    CashEventHeadsCompanion Function({
      required String cashEventId,
      required String paymentId,
      required String versionId,
      required int revision,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CashEventHeadsTableUpdateCompanionBuilder =
    CashEventHeadsCompanion Function({
      Value<String> cashEventId,
      Value<String> paymentId,
      Value<String> versionId,
      Value<int> revision,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CashEventHeadsTableFilterComposer
    extends Composer<_$AppDatabase, $CashEventHeadsTable> {
  $$CashEventHeadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashEventHeadsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashEventHeadsTable> {
  $$CashEventHeadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashEventHeadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashEventHeadsTable> {
  $$CashEventHeadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CashEventHeadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashEventHeadsTable,
          CashEventHead,
          $$CashEventHeadsTableFilterComposer,
          $$CashEventHeadsTableOrderingComposer,
          $$CashEventHeadsTableAnnotationComposer,
          $$CashEventHeadsTableCreateCompanionBuilder,
          $$CashEventHeadsTableUpdateCompanionBuilder,
          (
            CashEventHead,
            BaseReferences<_$AppDatabase, $CashEventHeadsTable, CashEventHead>,
          ),
          CashEventHead,
          PrefetchHooks Function()
        > {
  $$CashEventHeadsTableTableManager(
    _$AppDatabase db,
    $CashEventHeadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashEventHeadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashEventHeadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashEventHeadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cashEventId = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashEventHeadsCompanion(
                cashEventId: cashEventId,
                paymentId: paymentId,
                versionId: versionId,
                revision: revision,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cashEventId,
                required String paymentId,
                required String versionId,
                required int revision,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CashEventHeadsCompanion.insert(
                cashEventId: cashEventId,
                paymentId: paymentId,
                versionId: versionId,
                revision: revision,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashEventHeadsTable, CashEventHead>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashEventHeadsTable,
                    CashEventHead
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashEventHeadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashEventHeadsTable,
      CashEventHead,
      $$CashEventHeadsTableFilterComposer,
      $$CashEventHeadsTableOrderingComposer,
      $$CashEventHeadsTableAnnotationComposer,
      $$CashEventHeadsTableCreateCompanionBuilder,
      $$CashEventHeadsTableUpdateCompanionBuilder,
      (
        CashEventHead,
        BaseReferences<_$AppDatabase, $CashEventHeadsTable, CashEventHead>,
      ),
      CashEventHead,
      PrefetchHooks Function()
    >;
typedef $$ReconciliationCasesTableCreateCompanionBuilder =
    ReconciliationCasesCompanion Function({
      required String id,
      required String cashEventId,
      required String paymentId,
      required String financialAccountId,
      required String partyId,
      required String partyRole,
      required String currencyCode,
      required String reason,
      required String createdByActorId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReconciliationCasesTableUpdateCompanionBuilder =
    ReconciliationCasesCompanion Function({
      Value<String> id,
      Value<String> cashEventId,
      Value<String> paymentId,
      Value<String> financialAccountId,
      Value<String> partyId,
      Value<String> partyRole,
      Value<String> currencyCode,
      Value<String> reason,
      Value<String> createdByActorId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ReconciliationCasesTableFilterComposer
    extends Composer<_$AppDatabase, $ReconciliationCasesTable> {
  $$ReconciliationCasesTableFilterComposer({
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

  ColumnFilters<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReconciliationCasesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReconciliationCasesTable> {
  $$ReconciliationCasesTableOrderingComposer({
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

  ColumnOrderings<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReconciliationCasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReconciliationCasesTable> {
  $$ReconciliationCasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get createdByActorId => $composableBuilder(
    column: $table.createdByActorId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReconciliationCasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReconciliationCasesTable,
          ReconciliationCase,
          $$ReconciliationCasesTableFilterComposer,
          $$ReconciliationCasesTableOrderingComposer,
          $$ReconciliationCasesTableAnnotationComposer,
          $$ReconciliationCasesTableCreateCompanionBuilder,
          $$ReconciliationCasesTableUpdateCompanionBuilder,
          (
            ReconciliationCase,
            BaseReferences<
              _$AppDatabase,
              $ReconciliationCasesTable,
              ReconciliationCase
            >,
          ),
          ReconciliationCase,
          PrefetchHooks Function()
        > {
  $$ReconciliationCasesTableTableManager(
    _$AppDatabase db,
    $ReconciliationCasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReconciliationCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReconciliationCasesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReconciliationCasesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cashEventId = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> financialAccountId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> partyRole = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> createdByActorId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReconciliationCasesCompanion(
                id: id,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                reason: reason,
                createdByActorId: createdByActorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cashEventId,
                required String paymentId,
                required String financialAccountId,
                required String partyId,
                required String partyRole,
                required String currencyCode,
                required String reason,
                required String createdByActorId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReconciliationCasesCompanion.insert(
                id: id,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                reason: reason,
                createdByActorId: createdByActorId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReconciliationCasesTable, ReconciliationCase>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ReconciliationCasesTable,
                    ReconciliationCase
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReconciliationCasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReconciliationCasesTable,
      ReconciliationCase,
      $$ReconciliationCasesTableFilterComposer,
      $$ReconciliationCasesTableOrderingComposer,
      $$ReconciliationCasesTableAnnotationComposer,
      $$ReconciliationCasesTableCreateCompanionBuilder,
      $$ReconciliationCasesTableUpdateCompanionBuilder,
      (
        ReconciliationCase,
        BaseReferences<
          _$AppDatabase,
          $ReconciliationCasesTable,
          ReconciliationCase
        >,
      ),
      ReconciliationCase,
      PrefetchHooks Function()
    >;
typedef $$SuspenseResolutionsTableCreateCompanionBuilder =
    SuspenseResolutionsCompanion Function({
      required String id,
      required String caseId,
      required String cashEventId,
      required String paymentId,
      required String financialAccountId,
      required String partyId,
      required String partyRole,
      required String currencyCode,
      required int amountMinor,
      required String actorId,
      required String authorizedByActorId,
      required String authorizationReference,
      required String reason,
      required String idempotencyKey,
      required String requestPayload,
      required DateTime resolvedAt,
      Value<int> rowid,
    });
typedef $$SuspenseResolutionsTableUpdateCompanionBuilder =
    SuspenseResolutionsCompanion Function({
      Value<String> id,
      Value<String> caseId,
      Value<String> cashEventId,
      Value<String> paymentId,
      Value<String> financialAccountId,
      Value<String> partyId,
      Value<String> partyRole,
      Value<String> currencyCode,
      Value<int> amountMinor,
      Value<String> actorId,
      Value<String> authorizedByActorId,
      Value<String> authorizationReference,
      Value<String> reason,
      Value<String> idempotencyKey,
      Value<String> requestPayload,
      Value<DateTime> resolvedAt,
      Value<int> rowid,
    });

class $$SuspenseResolutionsTableFilterComposer
    extends Composer<_$AppDatabase, $SuspenseResolutionsTable> {
  $$SuspenseResolutionsTableFilterComposer({
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

  ColumnFilters<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorizedByActorId => $composableBuilder(
    column: $table.authorizedByActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorizationReference => $composableBuilder(
    column: $table.authorizationReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuspenseResolutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuspenseResolutionsTable> {
  $$SuspenseResolutionsTableOrderingComposer({
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

  ColumnOrderings<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorizedByActorId => $composableBuilder(
    column: $table.authorizedByActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorizationReference => $composableBuilder(
    column: $table.authorizationReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuspenseResolutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuspenseResolutionsTable> {
  $$SuspenseResolutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get authorizedByActorId => $composableBuilder(
    column: $table.authorizedByActorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorizationReference => $composableBuilder(
    column: $table.authorizationReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SuspenseResolutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuspenseResolutionsTable,
          SuspenseResolution,
          $$SuspenseResolutionsTableFilterComposer,
          $$SuspenseResolutionsTableOrderingComposer,
          $$SuspenseResolutionsTableAnnotationComposer,
          $$SuspenseResolutionsTableCreateCompanionBuilder,
          $$SuspenseResolutionsTableUpdateCompanionBuilder,
          (
            SuspenseResolution,
            BaseReferences<
              _$AppDatabase,
              $SuspenseResolutionsTable,
              SuspenseResolution
            >,
          ),
          SuspenseResolution,
          PrefetchHooks Function()
        > {
  $$SuspenseResolutionsTableTableManager(
    _$AppDatabase db,
    $SuspenseResolutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuspenseResolutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuspenseResolutionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SuspenseResolutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> caseId = const Value.absent(),
                Value<String> cashEventId = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> financialAccountId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> partyRole = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> authorizedByActorId = const Value.absent(),
                Value<String> authorizationReference = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestPayload = const Value.absent(),
                Value<DateTime> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuspenseResolutionsCompanion(
                id: id,
                caseId: caseId,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                actorId: actorId,
                authorizedByActorId: authorizedByActorId,
                authorizationReference: authorizationReference,
                reason: reason,
                idempotencyKey: idempotencyKey,
                requestPayload: requestPayload,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String caseId,
                required String cashEventId,
                required String paymentId,
                required String financialAccountId,
                required String partyId,
                required String partyRole,
                required String currencyCode,
                required int amountMinor,
                required String actorId,
                required String authorizedByActorId,
                required String authorizationReference,
                required String reason,
                required String idempotencyKey,
                required String requestPayload,
                required DateTime resolvedAt,
                Value<int> rowid = const Value.absent(),
              }) => SuspenseResolutionsCompanion.insert(
                id: id,
                caseId: caseId,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                actorId: actorId,
                authorizedByActorId: authorizedByActorId,
                authorizationReference: authorizationReference,
                reason: reason,
                idempotencyKey: idempotencyKey,
                requestPayload: requestPayload,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuspenseResolutionsTable, SuspenseResolution>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SuspenseResolutionsTable,
                    SuspenseResolution
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuspenseResolutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuspenseResolutionsTable,
      SuspenseResolution,
      $$SuspenseResolutionsTableFilterComposer,
      $$SuspenseResolutionsTableOrderingComposer,
      $$SuspenseResolutionsTableAnnotationComposer,
      $$SuspenseResolutionsTableCreateCompanionBuilder,
      $$SuspenseResolutionsTableUpdateCompanionBuilder,
      (
        SuspenseResolution,
        BaseReferences<
          _$AppDatabase,
          $SuspenseResolutionsTable,
          SuspenseResolution
        >,
      ),
      SuspenseResolution,
      PrefetchHooks Function()
    >;
typedef $$SuspenseEntriesTableCreateCompanionBuilder =
    SuspenseEntriesCompanion Function({
      required String id,
      required String caseId,
      required String cashEventId,
      required String paymentId,
      required String financialAccountId,
      required String partyId,
      required String partyRole,
      required String currencyCode,
      required String movementType,
      required int amountMinor,
      Value<String?> resolutionId,
      required String actorId,
      required String reason,
      required String idempotencyKey,
      required String requestPayload,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$SuspenseEntriesTableUpdateCompanionBuilder =
    SuspenseEntriesCompanion Function({
      Value<String> id,
      Value<String> caseId,
      Value<String> cashEventId,
      Value<String> paymentId,
      Value<String> financialAccountId,
      Value<String> partyId,
      Value<String> partyRole,
      Value<String> currencyCode,
      Value<String> movementType,
      Value<int> amountMinor,
      Value<String?> resolutionId,
      Value<String> actorId,
      Value<String> reason,
      Value<String> idempotencyKey,
      Value<String> requestPayload,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$SuspenseEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SuspenseEntriesTable> {
  $$SuspenseEntriesTableFilterComposer({
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

  ColumnFilters<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionId => $composableBuilder(
    column: $table.resolutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuspenseEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SuspenseEntriesTable> {
  $$SuspenseEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionId => $composableBuilder(
    column: $table.resolutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuspenseEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuspenseEntriesTable> {
  $$SuspenseEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get financialAccountId => $composableBuilder(
    column: $table.financialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutionId => $composableBuilder(
    column: $table.resolutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestPayload => $composableBuilder(
    column: $table.requestPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$SuspenseEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuspenseEntriesTable,
          SuspenseEntry,
          $$SuspenseEntriesTableFilterComposer,
          $$SuspenseEntriesTableOrderingComposer,
          $$SuspenseEntriesTableAnnotationComposer,
          $$SuspenseEntriesTableCreateCompanionBuilder,
          $$SuspenseEntriesTableUpdateCompanionBuilder,
          (
            SuspenseEntry,
            BaseReferences<_$AppDatabase, $SuspenseEntriesTable, SuspenseEntry>,
          ),
          SuspenseEntry,
          PrefetchHooks Function()
        > {
  $$SuspenseEntriesTableTableManager(
    _$AppDatabase db,
    $SuspenseEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuspenseEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuspenseEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuspenseEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> caseId = const Value.absent(),
                Value<String> cashEventId = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> financialAccountId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> partyRole = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String?> resolutionId = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestPayload = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuspenseEntriesCompanion(
                id: id,
                caseId: caseId,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                movementType: movementType,
                amountMinor: amountMinor,
                resolutionId: resolutionId,
                actorId: actorId,
                reason: reason,
                idempotencyKey: idempotencyKey,
                requestPayload: requestPayload,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String caseId,
                required String cashEventId,
                required String paymentId,
                required String financialAccountId,
                required String partyId,
                required String partyRole,
                required String currencyCode,
                required String movementType,
                required int amountMinor,
                Value<String?> resolutionId = const Value.absent(),
                required String actorId,
                required String reason,
                required String idempotencyKey,
                required String requestPayload,
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => SuspenseEntriesCompanion.insert(
                id: id,
                caseId: caseId,
                cashEventId: cashEventId,
                paymentId: paymentId,
                financialAccountId: financialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                movementType: movementType,
                amountMinor: amountMinor,
                resolutionId: resolutionId,
                actorId: actorId,
                reason: reason,
                idempotencyKey: idempotencyKey,
                requestPayload: requestPayload,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuspenseEntriesTable, SuspenseEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SuspenseEntriesTable,
                    SuspenseEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuspenseEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuspenseEntriesTable,
      SuspenseEntry,
      $$SuspenseEntriesTableFilterComposer,
      $$SuspenseEntriesTableOrderingComposer,
      $$SuspenseEntriesTableAnnotationComposer,
      $$SuspenseEntriesTableCreateCompanionBuilder,
      $$SuspenseEntriesTableUpdateCompanionBuilder,
      (
        SuspenseEntry,
        BaseReferences<_$AppDatabase, $SuspenseEntriesTable, SuspenseEntry>,
      ),
      SuspenseEntry,
      PrefetchHooks Function()
    >;
typedef $$InvoiceAllocationsTableCreateCompanionBuilder =
    InvoiceAllocationsCompanion Function({
      required String id,
      required String paymentId,
      required String invoiceId,
      required String paymentFinancialAccountId,
      required String invoiceFinancialAccountId,
      required String partyId,
      required String partyRole,
      required String currencyCode,
      required int amountMinor,
      required String idempotencyKey,
      required String requestFingerprint,
      Value<String?> originDeviceId,
      Value<String?> conflictGroupId,
      Value<String?> actorId,
      Value<String?> reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$InvoiceAllocationsTableUpdateCompanionBuilder =
    InvoiceAllocationsCompanion Function({
      Value<String> id,
      Value<String> paymentId,
      Value<String> invoiceId,
      Value<String> paymentFinancialAccountId,
      Value<String> invoiceFinancialAccountId,
      Value<String> partyId,
      Value<String> partyRole,
      Value<String> currencyCode,
      Value<int> amountMinor,
      Value<String> idempotencyKey,
      Value<String> requestFingerprint,
      Value<String?> originDeviceId,
      Value<String?> conflictGroupId,
      Value<String?> actorId,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$InvoiceAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceAllocationsTable> {
  $$InvoiceAllocationsTableFilterComposer({
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

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentFinancialAccountId => $composableBuilder(
    column: $table.paymentFinancialAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceFinancialAccountId => $composableBuilder(
    column: $table.invoiceFinancialAccountId,
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictGroupId => $composableBuilder(
    column: $table.conflictGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoiceAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceAllocationsTable> {
  $$InvoiceAllocationsTableOrderingComposer({
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

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentFinancialAccountId => $composableBuilder(
    column: $table.paymentFinancialAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceFinancialAccountId => $composableBuilder(
    column: $table.invoiceFinancialAccountId,
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictGroupId => $composableBuilder(
    column: $table.conflictGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoiceAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceAllocationsTable> {
  $$InvoiceAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get paymentFinancialAccountId => $composableBuilder(
    column: $table.paymentFinancialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceFinancialAccountId => $composableBuilder(
    column: $table.invoiceFinancialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictGroupId => $composableBuilder(
    column: $table.conflictGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InvoiceAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceAllocationsTable,
          InvoiceAllocation,
          $$InvoiceAllocationsTableFilterComposer,
          $$InvoiceAllocationsTableOrderingComposer,
          $$InvoiceAllocationsTableAnnotationComposer,
          $$InvoiceAllocationsTableCreateCompanionBuilder,
          $$InvoiceAllocationsTableUpdateCompanionBuilder,
          (
            InvoiceAllocation,
            BaseReferences<
              _$AppDatabase,
              $InvoiceAllocationsTable,
              InvoiceAllocation
            >,
          ),
          InvoiceAllocation,
          PrefetchHooks Function()
        > {
  $$InvoiceAllocationsTableTableManager(
    _$AppDatabase db,
    $InvoiceAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> paymentFinancialAccountId = const Value.absent(),
                Value<String> invoiceFinancialAccountId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> partyRole = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestFingerprint = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> conflictGroupId = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceAllocationsCompanion(
                id: id,
                paymentId: paymentId,
                invoiceId: invoiceId,
                paymentFinancialAccountId: paymentFinancialAccountId,
                invoiceFinancialAccountId: invoiceFinancialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                originDeviceId: originDeviceId,
                conflictGroupId: conflictGroupId,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String paymentId,
                required String invoiceId,
                required String paymentFinancialAccountId,
                required String invoiceFinancialAccountId,
                required String partyId,
                required String partyRole,
                required String currencyCode,
                required int amountMinor,
                required String idempotencyKey,
                required String requestFingerprint,
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> conflictGroupId = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InvoiceAllocationsCompanion.insert(
                id: id,
                paymentId: paymentId,
                invoiceId: invoiceId,
                paymentFinancialAccountId: paymentFinancialAccountId,
                invoiceFinancialAccountId: invoiceFinancialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                originDeviceId: originDeviceId,
                conflictGroupId: conflictGroupId,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvoiceAllocationsTable, InvoiceAllocation>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $InvoiceAllocationsTable,
                    InvoiceAllocation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoiceAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceAllocationsTable,
      InvoiceAllocation,
      $$InvoiceAllocationsTableFilterComposer,
      $$InvoiceAllocationsTableOrderingComposer,
      $$InvoiceAllocationsTableAnnotationComposer,
      $$InvoiceAllocationsTableCreateCompanionBuilder,
      $$InvoiceAllocationsTableUpdateCompanionBuilder,
      (
        InvoiceAllocation,
        BaseReferences<
          _$AppDatabase,
          $InvoiceAllocationsTable,
          InvoiceAllocation
        >,
      ),
      InvoiceAllocation,
      PrefetchHooks Function()
    >;
typedef $$AllocationReversalsTableCreateCompanionBuilder =
    AllocationReversalsCompanion Function({
      required String id,
      required String allocationId,
      required int amountMinor,
      required String idempotencyKey,
      required String requestFingerprint,
      Value<String?> actorId,
      required String reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AllocationReversalsTableUpdateCompanionBuilder =
    AllocationReversalsCompanion Function({
      Value<String> id,
      Value<String> allocationId,
      Value<int> amountMinor,
      Value<String> idempotencyKey,
      Value<String> requestFingerprint,
      Value<String?> actorId,
      Value<String> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AllocationReversalsTableFilterComposer
    extends Composer<_$AppDatabase, $AllocationReversalsTable> {
  $$AllocationReversalsTableFilterComposer({
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

  ColumnFilters<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AllocationReversalsTableOrderingComposer
    extends Composer<_$AppDatabase, $AllocationReversalsTable> {
  $$AllocationReversalsTableOrderingComposer({
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

  ColumnOrderings<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AllocationReversalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllocationReversalsTable> {
  $$AllocationReversalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AllocationReversalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllocationReversalsTable,
          AllocationReversal,
          $$AllocationReversalsTableFilterComposer,
          $$AllocationReversalsTableOrderingComposer,
          $$AllocationReversalsTableAnnotationComposer,
          $$AllocationReversalsTableCreateCompanionBuilder,
          $$AllocationReversalsTableUpdateCompanionBuilder,
          (
            AllocationReversal,
            BaseReferences<
              _$AppDatabase,
              $AllocationReversalsTable,
              AllocationReversal
            >,
          ),
          AllocationReversal,
          PrefetchHooks Function()
        > {
  $$AllocationReversalsTableTableManager(
    _$AppDatabase db,
    $AllocationReversalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllocationReversalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllocationReversalsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AllocationReversalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> allocationId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestFingerprint = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllocationReversalsCompanion(
                id: id,
                allocationId: allocationId,
                amountMinor: amountMinor,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String allocationId,
                required int amountMinor,
                required String idempotencyKey,
                required String requestFingerprint,
                Value<String?> actorId = const Value.absent(),
                required String reason,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AllocationReversalsCompanion.insert(
                id: id,
                allocationId: allocationId,
                amountMinor: amountMinor,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AllocationReversalsTable, AllocationReversal>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AllocationReversalsTable,
                    AllocationReversal
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AllocationReversalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllocationReversalsTable,
      AllocationReversal,
      $$AllocationReversalsTableFilterComposer,
      $$AllocationReversalsTableOrderingComposer,
      $$AllocationReversalsTableAnnotationComposer,
      $$AllocationReversalsTableCreateCompanionBuilder,
      $$AllocationReversalsTableUpdateCompanionBuilder,
      (
        AllocationReversal,
        BaseReferences<
          _$AppDatabase,
          $AllocationReversalsTable,
          AllocationReversal
        >,
      ),
      AllocationReversal,
      PrefetchHooks Function()
    >;
typedef $$AllocationStatusHistoryTableCreateCompanionBuilder =
    AllocationStatusHistoryCompanion Function({
      required String id,
      required String allocationId,
      required int sequence,
      required String status,
      Value<String?> previousVersionId,
      required String idempotencyKey,
      required String requestFingerprint,
      Value<String?> actorId,
      Value<String?> reason,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$AllocationStatusHistoryTableUpdateCompanionBuilder =
    AllocationStatusHistoryCompanion Function({
      Value<String> id,
      Value<String> allocationId,
      Value<int> sequence,
      Value<String> status,
      Value<String?> previousVersionId,
      Value<String> idempotencyKey,
      Value<String> requestFingerprint,
      Value<String?> actorId,
      Value<String?> reason,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$AllocationStatusHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $AllocationStatusHistoryTable> {
  $$AllocationStatusHistoryTableFilterComposer({
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

  ColumnFilters<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AllocationStatusHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $AllocationStatusHistoryTable> {
  $$AllocationStatusHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AllocationStatusHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllocationStatusHistoryTable> {
  $$AllocationStatusHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get previousVersionId => $composableBuilder(
    column: $table.previousVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$AllocationStatusHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllocationStatusHistoryTable,
          AllocationStatusHistoryData,
          $$AllocationStatusHistoryTableFilterComposer,
          $$AllocationStatusHistoryTableOrderingComposer,
          $$AllocationStatusHistoryTableAnnotationComposer,
          $$AllocationStatusHistoryTableCreateCompanionBuilder,
          $$AllocationStatusHistoryTableUpdateCompanionBuilder,
          (
            AllocationStatusHistoryData,
            BaseReferences<
              _$AppDatabase,
              $AllocationStatusHistoryTable,
              AllocationStatusHistoryData
            >,
          ),
          AllocationStatusHistoryData,
          PrefetchHooks Function()
        > {
  $$AllocationStatusHistoryTableTableManager(
    _$AppDatabase db,
    $AllocationStatusHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllocationStatusHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AllocationStatusHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AllocationStatusHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> allocationId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> previousVersionId = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestFingerprint = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllocationStatusHistoryCompanion(
                id: id,
                allocationId: allocationId,
                sequence: sequence,
                status: status,
                previousVersionId: previousVersionId,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String allocationId,
                required int sequence,
                required String status,
                Value<String?> previousVersionId = const Value.absent(),
                required String idempotencyKey,
                required String requestFingerprint,
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => AllocationStatusHistoryCompanion.insert(
                id: id,
                allocationId: allocationId,
                sequence: sequence,
                status: status,
                previousVersionId: previousVersionId,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $AllocationStatusHistoryTable,
                    AllocationStatusHistoryData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AllocationStatusHistoryTable,
                    AllocationStatusHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AllocationStatusHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllocationStatusHistoryTable,
      AllocationStatusHistoryData,
      $$AllocationStatusHistoryTableFilterComposer,
      $$AllocationStatusHistoryTableOrderingComposer,
      $$AllocationStatusHistoryTableAnnotationComposer,
      $$AllocationStatusHistoryTableCreateCompanionBuilder,
      $$AllocationStatusHistoryTableUpdateCompanionBuilder,
      (
        AllocationStatusHistoryData,
        BaseReferences<
          _$AppDatabase,
          $AllocationStatusHistoryTable,
          AllocationStatusHistoryData
        >,
      ),
      AllocationStatusHistoryData,
      PrefetchHooks Function()
    >;
typedef $$RefundsTableCreateCompanionBuilder =
    RefundsCompanion Function({
      required String id,
      required String originalPaymentId,
      required String originalCashEventId,
      required String refundPaymentId,
      required String refundCashEventId,
      Value<String?> invoiceId,
      required String originalFinancialAccountId,
      required String refundFinancialAccountId,
      Value<String?> invoiceFinancialAccountId,
      required String partyId,
      required String partyRole,
      required String currencyCode,
      required int amountMinor,
      required String idempotencyKey,
      required String requestFingerprint,
      Value<String?> actorId,
      required String reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RefundsTableUpdateCompanionBuilder =
    RefundsCompanion Function({
      Value<String> id,
      Value<String> originalPaymentId,
      Value<String> originalCashEventId,
      Value<String> refundPaymentId,
      Value<String> refundCashEventId,
      Value<String?> invoiceId,
      Value<String> originalFinancialAccountId,
      Value<String> refundFinancialAccountId,
      Value<String?> invoiceFinancialAccountId,
      Value<String> partyId,
      Value<String> partyRole,
      Value<String> currencyCode,
      Value<int> amountMinor,
      Value<String> idempotencyKey,
      Value<String> requestFingerprint,
      Value<String?> actorId,
      Value<String> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RefundsTableFilterComposer
    extends Composer<_$AppDatabase, $RefundsTable> {
  $$RefundsTableFilterComposer({
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

  ColumnFilters<String> get originalPaymentId => $composableBuilder(
    column: $table.originalPaymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCashEventId => $composableBuilder(
    column: $table.originalCashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundPaymentId => $composableBuilder(
    column: $table.refundPaymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundCashEventId => $composableBuilder(
    column: $table.refundCashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFinancialAccountId => $composableBuilder(
    column: $table.originalFinancialAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundFinancialAccountId => $composableBuilder(
    column: $table.refundFinancialAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceFinancialAccountId => $composableBuilder(
    column: $table.invoiceFinancialAccountId,
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RefundsTableOrderingComposer
    extends Composer<_$AppDatabase, $RefundsTable> {
  $$RefundsTableOrderingComposer({
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

  ColumnOrderings<String> get originalPaymentId => $composableBuilder(
    column: $table.originalPaymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCashEventId => $composableBuilder(
    column: $table.originalCashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundPaymentId => $composableBuilder(
    column: $table.refundPaymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundCashEventId => $composableBuilder(
    column: $table.refundCashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFinancialAccountId => $composableBuilder(
    column: $table.originalFinancialAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundFinancialAccountId => $composableBuilder(
    column: $table.refundFinancialAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceFinancialAccountId => $composableBuilder(
    column: $table.invoiceFinancialAccountId,
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RefundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefundsTable> {
  $$RefundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalPaymentId => $composableBuilder(
    column: $table.originalPaymentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalCashEventId => $composableBuilder(
    column: $table.originalCashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refundPaymentId => $composableBuilder(
    column: $table.refundPaymentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refundCashEventId => $composableBuilder(
    column: $table.refundCashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get originalFinancialAccountId => $composableBuilder(
    column: $table.originalFinancialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refundFinancialAccountId => $composableBuilder(
    column: $table.refundFinancialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceFinancialAccountId => $composableBuilder(
    column: $table.invoiceFinancialAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get partyRole =>
      $composableBuilder(column: $table.partyRole, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RefundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefundsTable,
          Refund,
          $$RefundsTableFilterComposer,
          $$RefundsTableOrderingComposer,
          $$RefundsTableAnnotationComposer,
          $$RefundsTableCreateCompanionBuilder,
          $$RefundsTableUpdateCompanionBuilder,
          (Refund, BaseReferences<_$AppDatabase, $RefundsTable, Refund>),
          Refund,
          PrefetchHooks Function()
        > {
  $$RefundsTableTableManager(_$AppDatabase db, $RefundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> originalPaymentId = const Value.absent(),
                Value<String> originalCashEventId = const Value.absent(),
                Value<String> refundPaymentId = const Value.absent(),
                Value<String> refundCashEventId = const Value.absent(),
                Value<String?> invoiceId = const Value.absent(),
                Value<String> originalFinancialAccountId = const Value.absent(),
                Value<String> refundFinancialAccountId = const Value.absent(),
                Value<String?> invoiceFinancialAccountId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> partyRole = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestFingerprint = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefundsCompanion(
                id: id,
                originalPaymentId: originalPaymentId,
                originalCashEventId: originalCashEventId,
                refundPaymentId: refundPaymentId,
                refundCashEventId: refundCashEventId,
                invoiceId: invoiceId,
                originalFinancialAccountId: originalFinancialAccountId,
                refundFinancialAccountId: refundFinancialAccountId,
                invoiceFinancialAccountId: invoiceFinancialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String originalPaymentId,
                required String originalCashEventId,
                required String refundPaymentId,
                required String refundCashEventId,
                Value<String?> invoiceId = const Value.absent(),
                required String originalFinancialAccountId,
                required String refundFinancialAccountId,
                Value<String?> invoiceFinancialAccountId = const Value.absent(),
                required String partyId,
                required String partyRole,
                required String currencyCode,
                required int amountMinor,
                required String idempotencyKey,
                required String requestFingerprint,
                Value<String?> actorId = const Value.absent(),
                required String reason,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RefundsCompanion.insert(
                id: id,
                originalPaymentId: originalPaymentId,
                originalCashEventId: originalCashEventId,
                refundPaymentId: refundPaymentId,
                refundCashEventId: refundCashEventId,
                invoiceId: invoiceId,
                originalFinancialAccountId: originalFinancialAccountId,
                refundFinancialAccountId: refundFinancialAccountId,
                invoiceFinancialAccountId: invoiceFinancialAccountId,
                partyId: partyId,
                partyRole: partyRole,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RefundsTable, Refund>(table),
                  BaseReferences<_$AppDatabase, $RefundsTable, Refund>(
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

typedef $$RefundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefundsTable,
      Refund,
      $$RefundsTableFilterComposer,
      $$RefundsTableOrderingComposer,
      $$RefundsTableAnnotationComposer,
      $$RefundsTableCreateCompanionBuilder,
      $$RefundsTableUpdateCompanionBuilder,
      (Refund, BaseReferences<_$AppDatabase, $RefundsTable, Refund>),
      Refund,
      PrefetchHooks Function()
    >;
typedef $$RefundFinancialTransactionsTableCreateCompanionBuilder =
    RefundFinancialTransactionsCompanion Function({
      required String refundId,
      required String transactionId,
      required String cashEventId,
      required String paymentId,
      Value<int> rowid,
    });
typedef $$RefundFinancialTransactionsTableUpdateCompanionBuilder =
    RefundFinancialTransactionsCompanion Function({
      Value<String> refundId,
      Value<String> transactionId,
      Value<String> cashEventId,
      Value<String> paymentId,
      Value<int> rowid,
    });

class $$RefundFinancialTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RefundFinancialTransactionsTable> {
  $$RefundFinancialTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get refundId => $composableBuilder(
    column: $table.refundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RefundFinancialTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RefundFinancialTransactionsTable> {
  $$RefundFinancialTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get refundId => $composableBuilder(
    column: $table.refundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RefundFinancialTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefundFinancialTransactionsTable> {
  $$RefundFinancialTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get refundId =>
      $composableBuilder(column: $table.refundId, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cashEventId => $composableBuilder(
    column: $table.cashEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);
}

class $$RefundFinancialTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefundFinancialTransactionsTable,
          RefundFinancialTransaction,
          $$RefundFinancialTransactionsTableFilterComposer,
          $$RefundFinancialTransactionsTableOrderingComposer,
          $$RefundFinancialTransactionsTableAnnotationComposer,
          $$RefundFinancialTransactionsTableCreateCompanionBuilder,
          $$RefundFinancialTransactionsTableUpdateCompanionBuilder,
          (
            RefundFinancialTransaction,
            BaseReferences<
              _$AppDatabase,
              $RefundFinancialTransactionsTable,
              RefundFinancialTransaction
            >,
          ),
          RefundFinancialTransaction,
          PrefetchHooks Function()
        > {
  $$RefundFinancialTransactionsTableTableManager(
    _$AppDatabase db,
    $RefundFinancialTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefundFinancialTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RefundFinancialTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RefundFinancialTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> refundId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> cashEventId = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefundFinancialTransactionsCompanion(
                refundId: refundId,
                transactionId: transactionId,
                cashEventId: cashEventId,
                paymentId: paymentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String refundId,
                required String transactionId,
                required String cashEventId,
                required String paymentId,
                Value<int> rowid = const Value.absent(),
              }) => RefundFinancialTransactionsCompanion.insert(
                refundId: refundId,
                transactionId: transactionId,
                cashEventId: cashEventId,
                paymentId: paymentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RefundFinancialTransactionsTable,
                    RefundFinancialTransaction
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RefundFinancialTransactionsTable,
                    RefundFinancialTransaction
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RefundFinancialTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefundFinancialTransactionsTable,
      RefundFinancialTransaction,
      $$RefundFinancialTransactionsTableFilterComposer,
      $$RefundFinancialTransactionsTableOrderingComposer,
      $$RefundFinancialTransactionsTableAnnotationComposer,
      $$RefundFinancialTransactionsTableCreateCompanionBuilder,
      $$RefundFinancialTransactionsTableUpdateCompanionBuilder,
      (
        RefundFinancialTransaction,
        BaseReferences<
          _$AppDatabase,
          $RefundFinancialTransactionsTable,
          RefundFinancialTransaction
        >,
      ),
      RefundFinancialTransaction,
      PrefetchHooks Function()
    >;
typedef $$RefundAllocationReversalsTableCreateCompanionBuilder =
    RefundAllocationReversalsCompanion Function({
      required String id,
      required String refundId,
      required String originalPaymentId,
      required String invoiceId,
      required String allocationId,
      required String allocationReversalId,
      required String idempotencyKey,
      required String requestFingerprint,
      Value<String?> actorId,
      Value<String?> reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RefundAllocationReversalsTableUpdateCompanionBuilder =
    RefundAllocationReversalsCompanion Function({
      Value<String> id,
      Value<String> refundId,
      Value<String> originalPaymentId,
      Value<String> invoiceId,
      Value<String> allocationId,
      Value<String> allocationReversalId,
      Value<String> idempotencyKey,
      Value<String> requestFingerprint,
      Value<String?> actorId,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RefundAllocationReversalsTableFilterComposer
    extends Composer<_$AppDatabase, $RefundAllocationReversalsTable> {
  $$RefundAllocationReversalsTableFilterComposer({
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

  ColumnFilters<String> get refundId => $composableBuilder(
    column: $table.refundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalPaymentId => $composableBuilder(
    column: $table.originalPaymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allocationReversalId => $composableBuilder(
    column: $table.allocationReversalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RefundAllocationReversalsTableOrderingComposer
    extends Composer<_$AppDatabase, $RefundAllocationReversalsTable> {
  $$RefundAllocationReversalsTableOrderingComposer({
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

  ColumnOrderings<String> get refundId => $composableBuilder(
    column: $table.refundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalPaymentId => $composableBuilder(
    column: $table.originalPaymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allocationReversalId => $composableBuilder(
    column: $table.allocationReversalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RefundAllocationReversalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefundAllocationReversalsTable> {
  $$RefundAllocationReversalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get refundId =>
      $composableBuilder(column: $table.refundId, builder: (column) => column);

  GeneratedColumn<String> get originalPaymentId => $composableBuilder(
    column: $table.originalPaymentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get allocationId => $composableBuilder(
    column: $table.allocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allocationReversalId => $composableBuilder(
    column: $table.allocationReversalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RefundAllocationReversalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefundAllocationReversalsTable,
          RefundAllocationReversal,
          $$RefundAllocationReversalsTableFilterComposer,
          $$RefundAllocationReversalsTableOrderingComposer,
          $$RefundAllocationReversalsTableAnnotationComposer,
          $$RefundAllocationReversalsTableCreateCompanionBuilder,
          $$RefundAllocationReversalsTableUpdateCompanionBuilder,
          (
            RefundAllocationReversal,
            BaseReferences<
              _$AppDatabase,
              $RefundAllocationReversalsTable,
              RefundAllocationReversal
            >,
          ),
          RefundAllocationReversal,
          PrefetchHooks Function()
        > {
  $$RefundAllocationReversalsTableTableManager(
    _$AppDatabase db,
    $RefundAllocationReversalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefundAllocationReversalsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RefundAllocationReversalsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RefundAllocationReversalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> refundId = const Value.absent(),
                Value<String> originalPaymentId = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> allocationId = const Value.absent(),
                Value<String> allocationReversalId = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestFingerprint = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefundAllocationReversalsCompanion(
                id: id,
                refundId: refundId,
                originalPaymentId: originalPaymentId,
                invoiceId: invoiceId,
                allocationId: allocationId,
                allocationReversalId: allocationReversalId,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String refundId,
                required String originalPaymentId,
                required String invoiceId,
                required String allocationId,
                required String allocationReversalId,
                required String idempotencyKey,
                required String requestFingerprint,
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RefundAllocationReversalsCompanion.insert(
                id: id,
                refundId: refundId,
                originalPaymentId: originalPaymentId,
                invoiceId: invoiceId,
                allocationId: allocationId,
                allocationReversalId: allocationReversalId,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RefundAllocationReversalsTable,
                    RefundAllocationReversal
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RefundAllocationReversalsTable,
                    RefundAllocationReversal
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RefundAllocationReversalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefundAllocationReversalsTable,
      RefundAllocationReversal,
      $$RefundAllocationReversalsTableFilterComposer,
      $$RefundAllocationReversalsTableOrderingComposer,
      $$RefundAllocationReversalsTableAnnotationComposer,
      $$RefundAllocationReversalsTableCreateCompanionBuilder,
      $$RefundAllocationReversalsTableUpdateCompanionBuilder,
      (
        RefundAllocationReversal,
        BaseReferences<
          _$AppDatabase,
          $RefundAllocationReversalsTable,
          RefundAllocationReversal
        >,
      ),
      RefundAllocationReversal,
      PrefetchHooks Function()
    >;
typedef $$InvoiceLifecycleEventsTableCreateCompanionBuilder =
    InvoiceLifecycleEventsCompanion Function({
      required String id,
      required String invoiceId,
      required int sequence,
      required String state,
      Value<String?> previousEventId,
      required String idempotencyKey,
      required String requestFingerprint,
      Value<String?> actorId,
      Value<String?> reason,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$InvoiceLifecycleEventsTableUpdateCompanionBuilder =
    InvoiceLifecycleEventsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<int> sequence,
      Value<String> state,
      Value<String?> previousEventId,
      Value<String> idempotencyKey,
      Value<String> requestFingerprint,
      Value<String?> actorId,
      Value<String?> reason,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$InvoiceLifecycleEventsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceLifecycleEventsTable> {
  $$InvoiceLifecycleEventsTableFilterComposer({
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

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousEventId => $composableBuilder(
    column: $table.previousEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoiceLifecycleEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceLifecycleEventsTable> {
  $$InvoiceLifecycleEventsTableOrderingComposer({
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

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousEventId => $composableBuilder(
    column: $table.previousEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoiceLifecycleEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceLifecycleEventsTable> {
  $$InvoiceLifecycleEventsTableAnnotationComposer({
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

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get previousEventId => $composableBuilder(
    column: $table.previousEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestFingerprint => $composableBuilder(
    column: $table.requestFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$InvoiceLifecycleEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceLifecycleEventsTable,
          InvoiceLifecycleEvent,
          $$InvoiceLifecycleEventsTableFilterComposer,
          $$InvoiceLifecycleEventsTableOrderingComposer,
          $$InvoiceLifecycleEventsTableAnnotationComposer,
          $$InvoiceLifecycleEventsTableCreateCompanionBuilder,
          $$InvoiceLifecycleEventsTableUpdateCompanionBuilder,
          (
            InvoiceLifecycleEvent,
            BaseReferences<
              _$AppDatabase,
              $InvoiceLifecycleEventsTable,
              InvoiceLifecycleEvent
            >,
          ),
          InvoiceLifecycleEvent,
          PrefetchHooks Function()
        > {
  $$InvoiceLifecycleEventsTableTableManager(
    _$AppDatabase db,
    $InvoiceLifecycleEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceLifecycleEventsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InvoiceLifecycleEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InvoiceLifecycleEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> previousEventId = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> requestFingerprint = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceLifecycleEventsCompanion(
                id: id,
                invoiceId: invoiceId,
                sequence: sequence,
                state: state,
                previousEventId: previousEventId,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                required int sequence,
                required String state,
                Value<String?> previousEventId = const Value.absent(),
                required String idempotencyKey,
                required String requestFingerprint,
                Value<String?> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => InvoiceLifecycleEventsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                sequence: sequence,
                state: state,
                previousEventId: previousEventId,
                idempotencyKey: idempotencyKey,
                requestFingerprint: requestFingerprint,
                actorId: actorId,
                reason: reason,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $InvoiceLifecycleEventsTable,
                    InvoiceLifecycleEvent
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InvoiceLifecycleEventsTable,
                    InvoiceLifecycleEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoiceLifecycleEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceLifecycleEventsTable,
      InvoiceLifecycleEvent,
      $$InvoiceLifecycleEventsTableFilterComposer,
      $$InvoiceLifecycleEventsTableOrderingComposer,
      $$InvoiceLifecycleEventsTableAnnotationComposer,
      $$InvoiceLifecycleEventsTableCreateCompanionBuilder,
      $$InvoiceLifecycleEventsTableUpdateCompanionBuilder,
      (
        InvoiceLifecycleEvent,
        BaseReferences<
          _$AppDatabase,
          $InvoiceLifecycleEventsTable,
          InvoiceLifecycleEvent
        >,
      ),
      InvoiceLifecycleEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
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
  $$PaymentIdentitiesTableTableManager get paymentIdentities =>
      $$PaymentIdentitiesTableTableManager(_db, _db.paymentIdentities);
  $$CashEventsTableTableManager get cashEvents =>
      $$CashEventsTableTableManager(_db, _db.cashEvents);
  $$FinancialTransactionsTableTableManager get financialTransactions =>
      $$FinancialTransactionsTableTableManager(_db, _db.financialTransactions);
  $$CashEventVersionsTableTableManager get cashEventVersions =>
      $$CashEventVersionsTableTableManager(_db, _db.cashEventVersions);
  $$CashEventHeadsTableTableManager get cashEventHeads =>
      $$CashEventHeadsTableTableManager(_db, _db.cashEventHeads);
  $$ReconciliationCasesTableTableManager get reconciliationCases =>
      $$ReconciliationCasesTableTableManager(_db, _db.reconciliationCases);
  $$SuspenseResolutionsTableTableManager get suspenseResolutions =>
      $$SuspenseResolutionsTableTableManager(_db, _db.suspenseResolutions);
  $$SuspenseEntriesTableTableManager get suspenseEntries =>
      $$SuspenseEntriesTableTableManager(_db, _db.suspenseEntries);
  $$InvoiceAllocationsTableTableManager get invoiceAllocations =>
      $$InvoiceAllocationsTableTableManager(_db, _db.invoiceAllocations);
  $$AllocationReversalsTableTableManager get allocationReversals =>
      $$AllocationReversalsTableTableManager(_db, _db.allocationReversals);
  $$AllocationStatusHistoryTableTableManager get allocationStatusHistory =>
      $$AllocationStatusHistoryTableTableManager(
        _db,
        _db.allocationStatusHistory,
      );
  $$RefundsTableTableManager get refunds =>
      $$RefundsTableTableManager(_db, _db.refunds);
  $$RefundFinancialTransactionsTableTableManager
  get refundFinancialTransactions =>
      $$RefundFinancialTransactionsTableTableManager(
        _db,
        _db.refundFinancialTransactions,
      );
  $$RefundAllocationReversalsTableTableManager get refundAllocationReversals =>
      $$RefundAllocationReversalsTableTableManager(
        _db,
        _db.refundAllocationReversals,
      );
  $$InvoiceLifecycleEventsTableTableManager get invoiceLifecycleEvents =>
      $$InvoiceLifecycleEventsTableTableManager(
        _db,
        _db.invoiceLifecycleEvents,
      );
}
