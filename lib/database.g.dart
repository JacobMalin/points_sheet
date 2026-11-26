// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EmployeeTableTable extends EmployeeTable
    with TableInfo<$EmployeeTableTable, EmployeeTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeeTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, firstName, lastName, points];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employee_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmployeeTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmployeeTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  $EmployeeTableTable createAlias(String alias) {
    return $EmployeeTableTable(attachedDatabase, alias);
  }
}

class EmployeeTableData extends DataClass
    implements Insertable<EmployeeTableData> {
  final int id;
  final String firstName;
  final String lastName;
  final int points;
  const EmployeeTableData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['points'] = Variable<int>(points);
    return map;
  }

  EmployeeTableCompanion toCompanion(bool nullToAbsent) {
    return EmployeeTableCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      points: Value(points),
    );
  }

  factory EmployeeTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeTableData(
      id: serializer.fromJson<int>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'points': serializer.toJson<int>(points),
    };
  }

  EmployeeTableData copyWith({
    int? id,
    String? firstName,
    String? lastName,
    int? points,
  }) => EmployeeTableData(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    points: points ?? this.points,
  );
  EmployeeTableData copyWithCompanion(EmployeeTableCompanion data) {
    return EmployeeTableData(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeTableData(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, firstName, lastName, points);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeTableData &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.points == this.points);
}

class EmployeeTableCompanion extends UpdateCompanion<EmployeeTableData> {
  final Value<int> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<int> points;
  const EmployeeTableCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.points = const Value.absent(),
  });
  EmployeeTableCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    this.lastName = const Value.absent(),
    this.points = const Value.absent(),
  }) : firstName = Value(firstName);
  static Insertable<EmployeeTableData> custom({
    Expression<int>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<int>? points,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (points != null) 'points': points,
    });
  }

  EmployeeTableCompanion copyWith({
    Value<int>? id,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<int>? points,
  }) {
    return EmployeeTableCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      points: points ?? this.points,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeTableCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }
}

class $HistoryTableTable extends HistoryTable
    with TableInfo<$HistoryTableTable, HistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _actorMeta = const VerificationMeta('actor');
  @override
  late final GeneratedColumn<String> actor = GeneratedColumn<String>(
    'actor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _employeeMeta = const VerificationMeta(
    'employee',
  );
  @override
  late final GeneratedColumn<String> employee = GeneratedColumn<String>(
    'employee',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<String> points = GeneratedColumn<String>(
    'points',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    description,
    actor,
    employee,
    points,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('actor')) {
      context.handle(
        _actorMeta,
        actor.isAcceptableOrUnknown(data['actor']!, _actorMeta),
      );
    }
    if (data.containsKey('employee')) {
      context.handle(
        _employeeMeta,
        employee.isAcceptableOrUnknown(data['employee']!, _employeeMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      actor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor'],
      )!,
      employee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee'],
      ),
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}points'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HistoryTableTable createAlias(String alias) {
    return $HistoryTableTable(attachedDatabase, alias);
  }
}

class HistoryTableData extends DataClass
    implements Insertable<HistoryTableData> {
  final int id;
  final String actionType;
  final String description;
  final String actor;
  final String? employee;
  final String? points;
  final DateTime createdAt;
  const HistoryTableData({
    required this.id,
    required this.actionType,
    required this.description,
    required this.actor,
    this.employee,
    this.points,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['description'] = Variable<String>(description);
    map['actor'] = Variable<String>(actor);
    if (!nullToAbsent || employee != null) {
      map['employee'] = Variable<String>(employee);
    }
    if (!nullToAbsent || points != null) {
      map['points'] = Variable<String>(points);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HistoryTableCompanion toCompanion(bool nullToAbsent) {
    return HistoryTableCompanion(
      id: Value(id),
      actionType: Value(actionType),
      description: Value(description),
      actor: Value(actor),
      employee: employee == null && nullToAbsent
          ? const Value.absent()
          : Value(employee),
      points: points == null && nullToAbsent
          ? const Value.absent()
          : Value(points),
      createdAt: Value(createdAt),
    );
  }

  factory HistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      description: serializer.fromJson<String>(json['description']),
      actor: serializer.fromJson<String>(json['actor']),
      employee: serializer.fromJson<String?>(json['employee']),
      points: serializer.fromJson<String?>(json['points']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'description': serializer.toJson<String>(description),
      'actor': serializer.toJson<String>(actor),
      'employee': serializer.toJson<String?>(employee),
      'points': serializer.toJson<String?>(points),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HistoryTableData copyWith({
    int? id,
    String? actionType,
    String? description,
    String? actor,
    Value<String?> employee = const Value.absent(),
    Value<String?> points = const Value.absent(),
    DateTime? createdAt,
  }) => HistoryTableData(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    description: description ?? this.description,
    actor: actor ?? this.actor,
    employee: employee.present ? employee.value : this.employee,
    points: points.present ? points.value : this.points,
    createdAt: createdAt ?? this.createdAt,
  );
  HistoryTableData copyWithCompanion(HistoryTableCompanion data) {
    return HistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      description: data.description.present
          ? data.description.value
          : this.description,
      actor: data.actor.present ? data.actor.value : this.actor,
      employee: data.employee.present ? data.employee.value : this.employee,
      points: data.points.present ? data.points.value : this.points,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableData(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('description: $description, ')
          ..write('actor: $actor, ')
          ..write('employee: $employee, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionType,
    description,
    actor,
    employee,
    points,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryTableData &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.description == this.description &&
          other.actor == this.actor &&
          other.employee == this.employee &&
          other.points == this.points &&
          other.createdAt == this.createdAt);
}

class HistoryTableCompanion extends UpdateCompanion<HistoryTableData> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> description;
  final Value<String> actor;
  final Value<String?> employee;
  final Value<String?> points;
  final Value<DateTime> createdAt;
  const HistoryTableCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.description = const Value.absent(),
    this.actor = const Value.absent(),
    this.employee = const Value.absent(),
    this.points = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    this.description = const Value.absent(),
    this.actor = const Value.absent(),
    this.employee = const Value.absent(),
    this.points = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : actionType = Value(actionType);
  static Insertable<HistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? description,
    Expression<String>? actor,
    Expression<String>? employee,
    Expression<String>? points,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (description != null) 'description': description,
      if (actor != null) 'actor': actor,
      if (employee != null) 'employee': employee,
      if (points != null) 'points': points,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<String>? description,
    Value<String>? actor,
    Value<String?>? employee,
    Value<String?>? points,
    Value<DateTime>? createdAt,
  }) {
    return HistoryTableCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      description: description ?? this.description,
      actor: actor ?? this.actor,
      employee: employee ?? this.employee,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (actor.present) {
      map['actor'] = Variable<String>(actor.value);
    }
    if (employee.present) {
      map['employee'] = Variable<String>(employee.value);
    }
    if (points.present) {
      map['points'] = Variable<String>(points.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('description: $description, ')
          ..write('actor: $actor, ')
          ..write('employee: $employee, ')
          ..write('points: $points, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RewardTableTable extends RewardTable
    with TableInfo<$RewardTableTable, RewardTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
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
  static const VerificationMeta _pointsRequiredMeta = const VerificationMeta(
    'pointsRequired',
  );
  @override
  late final GeneratedColumn<int> pointsRequired = GeneratedColumn<int>(
    'points_required',
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, pointsRequired, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reward_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RewardTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('points_required')) {
      context.handle(
        _pointsRequiredMeta,
        pointsRequired.isAcceptableOrUnknown(
          data['points_required']!,
          _pointsRequiredMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsRequiredMeta);
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
  RewardTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pointsRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_required'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $RewardTableTable createAlias(String alias) {
    return $RewardTableTable(attachedDatabase, alias);
  }
}

class RewardTableData extends DataClass implements Insertable<RewardTableData> {
  final int id;
  final String name;
  final int pointsRequired;
  final int? sortOrder;
  const RewardTableData({
    required this.id,
    required this.name,
    required this.pointsRequired,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['points_required'] = Variable<int>(pointsRequired);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  RewardTableCompanion toCompanion(bool nullToAbsent) {
    return RewardTableCompanion(
      id: Value(id),
      name: Value(name),
      pointsRequired: Value(pointsRequired),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory RewardTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      pointsRequired: serializer.fromJson<int>(json['pointsRequired']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'pointsRequired': serializer.toJson<int>(pointsRequired),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  RewardTableData copyWith({
    int? id,
    String? name,
    int? pointsRequired,
    Value<int?> sortOrder = const Value.absent(),
  }) => RewardTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    pointsRequired: pointsRequired ?? this.pointsRequired,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  RewardTableData copyWithCompanion(RewardTableCompanion data) {
    return RewardTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      pointsRequired: data.pointsRequired.present
          ? data.pointsRequired.value
          : this.pointsRequired,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pointsRequired: $pointsRequired, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, pointsRequired, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.pointsRequired == this.pointsRequired &&
          other.sortOrder == this.sortOrder);
}

class RewardTableCompanion extends UpdateCompanion<RewardTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> pointsRequired;
  final Value<int?> sortOrder;
  const RewardTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.pointsRequired = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  RewardTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int pointsRequired,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       pointsRequired = Value(pointsRequired);
  static Insertable<RewardTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? pointsRequired,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (pointsRequired != null) 'points_required': pointsRequired,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  RewardTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? pointsRequired,
    Value<int?>? sortOrder,
  }) {
    return RewardTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pointsRequired.present) {
      map['points_required'] = Variable<int>(pointsRequired.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pointsRequired: $pointsRequired, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $WriteupTableTable extends WriteupTable
    with TableInfo<$WriteupTableTable, WriteupTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WriteupTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, points, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'writeup_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WriteupTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
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
  WriteupTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WriteupTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $WriteupTableTable createAlias(String alias) {
    return $WriteupTableTable(attachedDatabase, alias);
  }
}

class WriteupTableData extends DataClass
    implements Insertable<WriteupTableData> {
  final int id;
  final String title;
  final int points;
  final int? sortOrder;
  const WriteupTableData({
    required this.id,
    required this.title,
    required this.points,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['points'] = Variable<int>(points);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  WriteupTableCompanion toCompanion(bool nullToAbsent) {
    return WriteupTableCompanion(
      id: Value(id),
      title: Value(title),
      points: Value(points),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory WriteupTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WriteupTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      points: serializer.fromJson<int>(json['points']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'points': serializer.toJson<int>(points),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  WriteupTableData copyWith({
    int? id,
    String? title,
    int? points,
    Value<int?> sortOrder = const Value.absent(),
  }) => WriteupTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    points: points ?? this.points,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  WriteupTableData copyWithCompanion(WriteupTableCompanion data) {
    return WriteupTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      points: data.points.present ? data.points.value : this.points,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WriteupTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('points: $points, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, points, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WriteupTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.points == this.points &&
          other.sortOrder == this.sortOrder);
}

class WriteupTableCompanion extends UpdateCompanion<WriteupTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> points;
  final Value<int?> sortOrder;
  const WriteupTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.points = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WriteupTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int points,
    this.sortOrder = const Value.absent(),
  }) : title = Value(title),
       points = Value(points);
  static Insertable<WriteupTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? points,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (points != null) 'points': points,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WriteupTableCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? points,
    Value<int?>? sortOrder,
  }) {
    return WriteupTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      points: points ?? this.points,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WriteupTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('points: $points, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $WindowPositionTableTable extends WindowPositionTable
    with TableInfo<$WindowPositionTableTable, WindowPositionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WindowPositionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMaximizedMeta = const VerificationMeta(
    'isMaximized',
  );
  @override
  late final GeneratedColumn<bool> isMaximized = GeneratedColumn<bool>(
    'is_maximized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_maximized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, x, y, width, height, isMaximized];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'window_position_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WindowPositionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('is_maximized')) {
      context.handle(
        _isMaximizedMeta,
        isMaximized.isAcceptableOrUnknown(
          data['is_maximized']!,
          _isMaximizedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WindowPositionTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WindowPositionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      ),
      isMaximized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_maximized'],
      )!,
    );
  }

  @override
  $WindowPositionTableTable createAlias(String alias) {
    return $WindowPositionTableTable(attachedDatabase, alias);
  }
}

class WindowPositionTableData extends DataClass
    implements Insertable<WindowPositionTableData> {
  final int id;
  final double x;
  final double y;
  final double? width;
  final double? height;
  final bool isMaximized;
  const WindowPositionTableData({
    required this.id,
    required this.x,
    required this.y,
    this.width,
    this.height,
    required this.isMaximized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<double>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    map['is_maximized'] = Variable<bool>(isMaximized);
    return map;
  }

  WindowPositionTableCompanion toCompanion(bool nullToAbsent) {
    return WindowPositionTableCompanion(
      id: Value(id),
      x: Value(x),
      y: Value(y),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      isMaximized: Value(isMaximized),
    );
  }

  factory WindowPositionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WindowPositionTableData(
      id: serializer.fromJson<int>(json['id']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      width: serializer.fromJson<double?>(json['width']),
      height: serializer.fromJson<double?>(json['height']),
      isMaximized: serializer.fromJson<bool>(json['isMaximized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'width': serializer.toJson<double?>(width),
      'height': serializer.toJson<double?>(height),
      'isMaximized': serializer.toJson<bool>(isMaximized),
    };
  }

  WindowPositionTableData copyWith({
    int? id,
    double? x,
    double? y,
    Value<double?> width = const Value.absent(),
    Value<double?> height = const Value.absent(),
    bool? isMaximized,
  }) => WindowPositionTableData(
    id: id ?? this.id,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    isMaximized: isMaximized ?? this.isMaximized,
  );
  WindowPositionTableData copyWithCompanion(WindowPositionTableCompanion data) {
    return WindowPositionTableData(
      id: data.id.present ? data.id.value : this.id,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      isMaximized: data.isMaximized.present
          ? data.isMaximized.value
          : this.isMaximized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WindowPositionTableData(')
          ..write('id: $id, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('isMaximized: $isMaximized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, x, y, width, height, isMaximized);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WindowPositionTableData &&
          other.id == this.id &&
          other.x == this.x &&
          other.y == this.y &&
          other.width == this.width &&
          other.height == this.height &&
          other.isMaximized == this.isMaximized);
}

class WindowPositionTableCompanion
    extends UpdateCompanion<WindowPositionTableData> {
  final Value<int> id;
  final Value<double> x;
  final Value<double> y;
  final Value<double?> width;
  final Value<double?> height;
  final Value<bool> isMaximized;
  const WindowPositionTableCompanion({
    this.id = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.isMaximized = const Value.absent(),
  });
  WindowPositionTableCompanion.insert({
    this.id = const Value.absent(),
    required double x,
    required double y,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.isMaximized = const Value.absent(),
  }) : x = Value(x),
       y = Value(y);
  static Insertable<WindowPositionTableData> custom({
    Expression<int>? id,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? width,
    Expression<double>? height,
    Expression<bool>? isMaximized,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (isMaximized != null) 'is_maximized': isMaximized,
    });
  }

  WindowPositionTableCompanion copyWith({
    Value<int>? id,
    Value<double>? x,
    Value<double>? y,
    Value<double?>? width,
    Value<double?>? height,
    Value<bool>? isMaximized,
  }) {
    return WindowPositionTableCompanion(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      isMaximized: isMaximized ?? this.isMaximized,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (isMaximized.present) {
      map['is_maximized'] = Variable<bool>(isMaximized.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WindowPositionTableCompanion(')
          ..write('id: $id, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('isMaximized: $isMaximized')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EmployeeTableTable employeeTable = $EmployeeTableTable(this);
  late final $HistoryTableTable historyTable = $HistoryTableTable(this);
  late final $RewardTableTable rewardTable = $RewardTableTable(this);
  late final $WriteupTableTable writeupTable = $WriteupTableTable(this);
  late final $WindowPositionTableTable windowPositionTable =
      $WindowPositionTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    employeeTable,
    historyTable,
    rewardTable,
    writeupTable,
    windowPositionTable,
  ];
}

typedef $$EmployeeTableTableCreateCompanionBuilder =
    EmployeeTableCompanion Function({
      Value<int> id,
      required String firstName,
      Value<String> lastName,
      Value<int> points,
    });
typedef $$EmployeeTableTableUpdateCompanionBuilder =
    EmployeeTableCompanion Function({
      Value<int> id,
      Value<String> firstName,
      Value<String> lastName,
      Value<int> points,
    });

class $$EmployeeTableTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeeTableTable> {
  $$EmployeeTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmployeeTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeeTableTable> {
  $$EmployeeTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmployeeTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeeTableTable> {
  $$EmployeeTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);
}

class $$EmployeeTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeeTableTable,
          EmployeeTableData,
          $$EmployeeTableTableFilterComposer,
          $$EmployeeTableTableOrderingComposer,
          $$EmployeeTableTableAnnotationComposer,
          $$EmployeeTableTableCreateCompanionBuilder,
          $$EmployeeTableTableUpdateCompanionBuilder,
          (
            EmployeeTableData,
            BaseReferences<
              _$AppDatabase,
              $EmployeeTableTable,
              EmployeeTableData
            >,
          ),
          EmployeeTableData,
          PrefetchHooks Function()
        > {
  $$EmployeeTableTableTableManager(_$AppDatabase db, $EmployeeTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeeTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeeTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeeTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<int> points = const Value.absent(),
              }) => EmployeeTableCompanion(
                id: id,
                firstName: firstName,
                lastName: lastName,
                points: points,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String firstName,
                Value<String> lastName = const Value.absent(),
                Value<int> points = const Value.absent(),
              }) => EmployeeTableCompanion.insert(
                id: id,
                firstName: firstName,
                lastName: lastName,
                points: points,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmployeeTableTable, EmployeeTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EmployeeTableTable,
                    EmployeeTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmployeeTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeeTableTable,
      EmployeeTableData,
      $$EmployeeTableTableFilterComposer,
      $$EmployeeTableTableOrderingComposer,
      $$EmployeeTableTableAnnotationComposer,
      $$EmployeeTableTableCreateCompanionBuilder,
      $$EmployeeTableTableUpdateCompanionBuilder,
      (
        EmployeeTableData,
        BaseReferences<_$AppDatabase, $EmployeeTableTable, EmployeeTableData>,
      ),
      EmployeeTableData,
      PrefetchHooks Function()
    >;
typedef $$HistoryTableTableCreateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<int> id,
      required String actionType,
      Value<String> description,
      Value<String> actor,
      Value<String?> employee,
      Value<String?> points,
      Value<DateTime> createdAt,
    });
typedef $$HistoryTableTableUpdateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<String> description,
      Value<String> actor,
      Value<String?> employee,
      Value<String?> points,
      Value<DateTime> createdAt,
    });

class $$HistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employee => $composableBuilder(
    column: $table.employee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employee => $composableBuilder(
    column: $table.employee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actor =>
      $composableBuilder(column: $table.actor, builder: (column) => column);

  GeneratedColumn<String> get employee =>
      $composableBuilder(column: $table.employee, builder: (column) => column);

  GeneratedColumn<String> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryTableTable,
          HistoryTableData,
          $$HistoryTableTableFilterComposer,
          $$HistoryTableTableOrderingComposer,
          $$HistoryTableTableAnnotationComposer,
          $$HistoryTableTableCreateCompanionBuilder,
          $$HistoryTableTableUpdateCompanionBuilder,
          (
            HistoryTableData,
            BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>,
          ),
          HistoryTableData,
          PrefetchHooks Function()
        > {
  $$HistoryTableTableTableManager(_$AppDatabase db, $HistoryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> actor = const Value.absent(),
                Value<String?> employee = const Value.absent(),
                Value<String?> points = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HistoryTableCompanion(
                id: id,
                actionType: actionType,
                description: description,
                actor: actor,
                employee: employee,
                points: points,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                Value<String> description = const Value.absent(),
                Value<String> actor = const Value.absent(),
                Value<String?> employee = const Value.absent(),
                Value<String?> points = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HistoryTableCompanion.insert(
                id: id,
                actionType: actionType,
                description: description,
                actor: actor,
                employee: employee,
                points: points,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistoryTableTable, HistoryTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HistoryTableTable,
                    HistoryTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryTableTable,
      HistoryTableData,
      $$HistoryTableTableFilterComposer,
      $$HistoryTableTableOrderingComposer,
      $$HistoryTableTableAnnotationComposer,
      $$HistoryTableTableCreateCompanionBuilder,
      $$HistoryTableTableUpdateCompanionBuilder,
      (
        HistoryTableData,
        BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>,
      ),
      HistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$RewardTableTableCreateCompanionBuilder =
    RewardTableCompanion Function({
      Value<int> id,
      required String name,
      required int pointsRequired,
      Value<int?> sortOrder,
    });
typedef $$RewardTableTableUpdateCompanionBuilder =
    RewardTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> pointsRequired,
      Value<int?> sortOrder,
    });

class $$RewardTableTableFilterComposer
    extends Composer<_$AppDatabase, $RewardTableTable> {
  $$RewardTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsRequired => $composableBuilder(
    column: $table.pointsRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RewardTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RewardTableTable> {
  $$RewardTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsRequired => $composableBuilder(
    column: $table.pointsRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RewardTableTable> {
  $$RewardTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get pointsRequired => $composableBuilder(
    column: $table.pointsRequired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$RewardTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RewardTableTable,
          RewardTableData,
          $$RewardTableTableFilterComposer,
          $$RewardTableTableOrderingComposer,
          $$RewardTableTableAnnotationComposer,
          $$RewardTableTableCreateCompanionBuilder,
          $$RewardTableTableUpdateCompanionBuilder,
          (
            RewardTableData,
            BaseReferences<_$AppDatabase, $RewardTableTable, RewardTableData>,
          ),
          RewardTableData,
          PrefetchHooks Function()
        > {
  $$RewardTableTableTableManager(_$AppDatabase db, $RewardTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> pointsRequired = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
              }) => RewardTableCompanion(
                id: id,
                name: name,
                pointsRequired: pointsRequired,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int pointsRequired,
                Value<int?> sortOrder = const Value.absent(),
              }) => RewardTableCompanion.insert(
                id: id,
                name: name,
                pointsRequired: pointsRequired,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RewardTableTable, RewardTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RewardTableTable,
                    RewardTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RewardTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RewardTableTable,
      RewardTableData,
      $$RewardTableTableFilterComposer,
      $$RewardTableTableOrderingComposer,
      $$RewardTableTableAnnotationComposer,
      $$RewardTableTableCreateCompanionBuilder,
      $$RewardTableTableUpdateCompanionBuilder,
      (
        RewardTableData,
        BaseReferences<_$AppDatabase, $RewardTableTable, RewardTableData>,
      ),
      RewardTableData,
      PrefetchHooks Function()
    >;
typedef $$WriteupTableTableCreateCompanionBuilder =
    WriteupTableCompanion Function({
      Value<int> id,
      required String title,
      required int points,
      Value<int?> sortOrder,
    });
typedef $$WriteupTableTableUpdateCompanionBuilder =
    WriteupTableCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> points,
      Value<int?> sortOrder,
    });

class $$WriteupTableTableFilterComposer
    extends Composer<_$AppDatabase, $WriteupTableTable> {
  $$WriteupTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WriteupTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WriteupTableTable> {
  $$WriteupTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WriteupTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WriteupTableTable> {
  $$WriteupTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$WriteupTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WriteupTableTable,
          WriteupTableData,
          $$WriteupTableTableFilterComposer,
          $$WriteupTableTableOrderingComposer,
          $$WriteupTableTableAnnotationComposer,
          $$WriteupTableTableCreateCompanionBuilder,
          $$WriteupTableTableUpdateCompanionBuilder,
          (
            WriteupTableData,
            BaseReferences<_$AppDatabase, $WriteupTableTable, WriteupTableData>,
          ),
          WriteupTableData,
          PrefetchHooks Function()
        > {
  $$WriteupTableTableTableManager(_$AppDatabase db, $WriteupTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WriteupTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WriteupTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WriteupTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
              }) => WriteupTableCompanion(
                id: id,
                title: title,
                points: points,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int points,
                Value<int?> sortOrder = const Value.absent(),
              }) => WriteupTableCompanion.insert(
                id: id,
                title: title,
                points: points,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WriteupTableTable, WriteupTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WriteupTableTable,
                    WriteupTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WriteupTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WriteupTableTable,
      WriteupTableData,
      $$WriteupTableTableFilterComposer,
      $$WriteupTableTableOrderingComposer,
      $$WriteupTableTableAnnotationComposer,
      $$WriteupTableTableCreateCompanionBuilder,
      $$WriteupTableTableUpdateCompanionBuilder,
      (
        WriteupTableData,
        BaseReferences<_$AppDatabase, $WriteupTableTable, WriteupTableData>,
      ),
      WriteupTableData,
      PrefetchHooks Function()
    >;
typedef $$WindowPositionTableTableCreateCompanionBuilder =
    WindowPositionTableCompanion Function({
      Value<int> id,
      required double x,
      required double y,
      Value<double?> width,
      Value<double?> height,
      Value<bool> isMaximized,
    });
typedef $$WindowPositionTableTableUpdateCompanionBuilder =
    WindowPositionTableCompanion Function({
      Value<int> id,
      Value<double> x,
      Value<double> y,
      Value<double?> width,
      Value<double?> height,
      Value<bool> isMaximized,
    });

class $$WindowPositionTableTableFilterComposer
    extends Composer<_$AppDatabase, $WindowPositionTableTable> {
  $$WindowPositionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMaximized => $composableBuilder(
    column: $table.isMaximized,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WindowPositionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WindowPositionTableTable> {
  $$WindowPositionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMaximized => $composableBuilder(
    column: $table.isMaximized,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WindowPositionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WindowPositionTableTable> {
  $$WindowPositionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<bool> get isMaximized => $composableBuilder(
    column: $table.isMaximized,
    builder: (column) => column,
  );
}

class $$WindowPositionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WindowPositionTableTable,
          WindowPositionTableData,
          $$WindowPositionTableTableFilterComposer,
          $$WindowPositionTableTableOrderingComposer,
          $$WindowPositionTableTableAnnotationComposer,
          $$WindowPositionTableTableCreateCompanionBuilder,
          $$WindowPositionTableTableUpdateCompanionBuilder,
          (
            WindowPositionTableData,
            BaseReferences<
              _$AppDatabase,
              $WindowPositionTableTable,
              WindowPositionTableData
            >,
          ),
          WindowPositionTableData,
          PrefetchHooks Function()
        > {
  $$WindowPositionTableTableTableManager(
    _$AppDatabase db,
    $WindowPositionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WindowPositionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WindowPositionTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WindowPositionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double?> width = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<bool> isMaximized = const Value.absent(),
              }) => WindowPositionTableCompanion(
                id: id,
                x: x,
                y: y,
                width: width,
                height: height,
                isMaximized: isMaximized,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double x,
                required double y,
                Value<double?> width = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<bool> isMaximized = const Value.absent(),
              }) => WindowPositionTableCompanion.insert(
                id: id,
                x: x,
                y: y,
                width: width,
                height: height,
                isMaximized: isMaximized,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $WindowPositionTableTable,
                    WindowPositionTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WindowPositionTableTable,
                    WindowPositionTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WindowPositionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WindowPositionTableTable,
      WindowPositionTableData,
      $$WindowPositionTableTableFilterComposer,
      $$WindowPositionTableTableOrderingComposer,
      $$WindowPositionTableTableAnnotationComposer,
      $$WindowPositionTableTableCreateCompanionBuilder,
      $$WindowPositionTableTableUpdateCompanionBuilder,
      (
        WindowPositionTableData,
        BaseReferences<
          _$AppDatabase,
          $WindowPositionTableTable,
          WindowPositionTableData
        >,
      ),
      WindowPositionTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmployeeTableTableTableManager get employeeTable =>
      $$EmployeeTableTableTableManager(_db, _db.employeeTable);
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db, _db.historyTable);
  $$RewardTableTableTableManager get rewardTable =>
      $$RewardTableTableTableManager(_db, _db.rewardTable);
  $$WriteupTableTableTableManager get writeupTable =>
      $$WriteupTableTableTableManager(_db, _db.writeupTable);
  $$WindowPositionTableTableTableManager get windowPositionTable =>
      $$WindowPositionTableTableTableManager(_db, _db.windowPositionTable);
}

mixin _$EmployeeDaoMixin on DatabaseAccessor<AppDatabase> {
  $EmployeeTableTable get employeeTable => attachedDatabase.employeeTable;
  EmployeeDaoManager get managers => EmployeeDaoManager(this);
}

class EmployeeDaoManager {
  final _$EmployeeDaoMixin _db;
  EmployeeDaoManager(this._db);
  $$EmployeeTableTableTableManager get employeeTable =>
      $$EmployeeTableTableTableManager(_db.attachedDatabase, _db.employeeTable);
}

mixin _$HistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $HistoryTableTable get historyTable => attachedDatabase.historyTable;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db.attachedDatabase, _db.historyTable);
}
