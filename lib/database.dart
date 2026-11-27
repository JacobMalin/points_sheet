import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:intl/intl.dart';

part 'database.g.dart';

class Employee {
  const Employee(this.data);

  final EmployeeTableData data;

  String get name => '${data.firstName} ${data.lastName}'.trim();

  String get formattedPoints {
    final NumberFormat f = NumberFormat();

    return f.format(data.points);
  }

  set points(int newPoints) {
    EmployeeDao? dao = EmployeeDao(AppDatabase());
    dao.updateEmployee(data.copyWith(points: newPoints));
    dao.close();
  }
}

class EmployeeTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  IntColumn get points => integer().withDefault(const Constant(0))();
}

class HistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get actor => text().withDefault(const Constant(''))();
  TextColumn get employee => text().nullable()();
  TextColumn get points => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get undoData => text().nullable()();
  BoolColumn get isUndone => boolean().withDefault(const Constant(false))();
}

class RewardTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get pointsRequired => integer()();
  IntColumn get sortOrder => integer().nullable()();
}

class WriteupTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get points => integer()();
  IntColumn get sortOrder => integer().nullable()();
}

class WindowPositionTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  RealColumn get x => real()();
  RealColumn get y => real()();
  RealColumn get width => real().nullable()();
  RealColumn get height => real().nullable()();
  BoolColumn get isMaximized => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    EmployeeTable,
    HistoryTable,
    RewardTable,
    WriteupTable,
    WindowPositionTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedRewardsAndWriteups();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(historyTable);
      } else {
        if (from < 3) {
          await m.addColumn(historyTable, historyTable.description);
        }
        if (from < 4) {
          await m.addColumn(historyTable, historyTable.employee);
          await m.addColumn(historyTable, historyTable.points);
        }
      }
      if (from < 5) {
        await m.alterTable(TableMigration(historyTable));
      }
      if (from < 6) {
        await m.createTable(rewardTable);
        await m.createTable(writeupTable);
        await _seedRewardsAndWriteups();
      } else if (from >= 6 && from < 7) {
        await m.addColumn(rewardTable, rewardTable.sortOrder);
        await m.addColumn(writeupTable, writeupTable.sortOrder);
      }
      if (from < 8) {
        await m.createTable(windowPositionTable);
      } else if (from >= 8 && from < 10) {
        await m.addColumn(windowPositionTable, windowPositionTable.width);
        await m.addColumn(windowPositionTable, windowPositionTable.height);
      }
      if (from >= 8 && from < 11) {
        await m.addColumn(windowPositionTable, windowPositionTable.isMaximized);
      }
      if (from >= 5 && from < 12) {
        final columns = await customSelect(
          'PRAGMA table_info(history_table)',
        ).get();
        final names = columns.map((column) => column.read<String>('name')).toSet();
        if (!names.contains('undo_data')) {
          await m.addColumn(historyTable, historyTable.undoData);
        }
        if (!names.contains('is_undone')) {
          await m.addColumn(historyTable, historyTable.isUndone);
        }
      }
      if (from < 9) {
        await transaction(() async {
          final latest =
              await (select(windowPositionTable)
                    ..orderBy([(position) => OrderingTerm.desc(position.id)])
                    ..limit(1))
                  .getSingleOrNull();
          if (latest != null) {
            await saveWindowPosition(latest.x, latest.y);
            await (delete(
              windowPositionTable,
            )..where((position) => position.id.isNotValue(1))).go();
          }
        });
      }
    },
  );

  Future<void> _seedRewardsAndWriteups() async {
    final rewards = await select(rewardTable).get();
    final writeups = await select(writeupTable).get();

    await batch((batch) {
      if (rewards.isEmpty) {
        batch.insertAll(rewardTable, [
          RewardTableCompanion.insert(name: 'Mocktail', pointsRequired: 250),
          RewardTableCompanion.insert(name: 'Hot Food', pointsRequired: 500),
          RewardTableCompanion.insert(
            name: 'Any Concessions',
            pointsRequired: 1000,
          ),
        ]);
      }
      if (writeups.isEmpty) {
        batch.insertAll(writeupTable, [
          WriteupTableCompanion.insert(title: 'Behavior', points: 100),
          WriteupTableCompanion.insert(title: 'Attendance', points: 500),
          WriteupTableCompanion.insert(title: 'Till', points: 50),
        ]);
      }
    });
  }

  Future<void> undoHistoryEntry(int id) => transaction(() async {
    final entry = await (select(
      historyTable,
    )..where((history) => history.id.equals(id))).getSingleOrNull();
    if (entry == null) throw StateError('History entry was not found.');
    if (entry.isUndone || entry.actionType == 'Action undone') {
      throw StateError('This action has already been undone.');
    }

    final undoData = entry.undoData == null
        ? await _legacyUndoData(entry)
        : _decodeUndoData(entry.undoData!);
    switch (undoData['kind']) {
      case 'points':
        await _undoPoints(undoData);
        break;
      case 'employeesAdded':
        await _undoEmployeesAdded(undoData);
        break;
      case 'employeesDeleted':
        await _undoEmployeesDeleted(undoData);
        break;
      default:
        throw StateError('This history entry cannot be undone.');
    }

    await (delete(
      historyTable,
    )..where((history) => history.id.equals(id))).go();
  });

  Map<String, dynamic> _decodeUndoData(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid undo data.');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> _legacyUndoData(HistoryTableData entry) async {
    if (entry.actionType == 'Employees deleted') {
      throw StateError(
        "This older deletion cannot be undone because it did not save "
        "the employees' complete details.",
      );
    }

    if (entry.actionType == 'Employee added' ||
        entry.actionType == 'Employees added') {
      final names = _historyNames(entry);
      final employees = await select(employeeTable).get();
      final ids = <int>[];
      for (final name in names) {
        final matches = employees
            .where(
              (employee) =>
                  _employeeNameKey(employee.firstName, employee.lastName) ==
                  _normalizeEmployeeName(name),
            )
            .toList();
        if (matches.length != 1) {
          throw StateError('Could not uniquely find employee "$name".');
        }
        ids.add(matches.single.id);
      }
      return {'kind': 'employeesAdded', 'employeeIds': ids};
    }

    const pointActions = {
      'Mass add points',
      'Points added',
      'Points removed',
      'Points adjusted',
      'Reward redeemed',
      'Writeup',
    };
    if (!pointActions.contains(entry.actionType)) {
      throw StateError('This history entry cannot be undone.');
    }

    final names = _historyNames(entry);
    final points = (entry.points ?? '')
        .split('\n')
        .map(_parseHistoryPoints)
        .toList();
    if (points.length != names.length || points.any((value) => value == null)) {
      throw StateError('This history entry does not contain valid point data.');
    }

    final employees = await select(employeeTable).get();
    final changes = <Map<String, int>>[];
    for (var index = 0; index < names.length; index++) {
      final matches = employees
          .where(
            (employee) =>
                _employeeNameKey(employee.firstName, employee.lastName) ==
                _normalizeEmployeeName(names[index]),
          )
          .toList();
      if (matches.length != 1) {
        throw StateError('Could not uniquely find employee "${names[index]}".');
      }
      changes.add({'employeeId': matches.single.id, 'delta': points[index]!});
    }
    return {'kind': 'points', 'changes': changes};
  }

  List<String> _historyNames(HistoryTableData entry) {
    final names = (entry.employee ?? '')
        .split('\n')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isEmpty) throw StateError('Employee information is missing.');
    return names;
  }

  int? _parseHistoryPoints(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9+-]'), '');
    return int.tryParse(normalized);
  }

  Future<void> _undoPoints(Map<String, dynamic> data) async {
    final changes = data['changes'];
    if (changes is! List || changes.isEmpty) {
      throw const FormatException('Undo data has no point changes.');
    }

    final parsed = <(int, int)>[];
    for (final change in changes) {
      if (change is! Map) {
        throw const FormatException('Invalid point undo data.');
      }
      final employeeId = change['employeeId'];
      final delta = change['delta'];
      if (employeeId is! int || delta is! int) {
        throw const FormatException('Invalid point undo data.');
      }
      parsed.add((employeeId, delta));
    }
    if (parsed.map((change) => change.$1).toSet().length != parsed.length) {
      throw const FormatException('Undo data contains duplicate employees.');
    }

    final updates = <EmployeeTableData>[];
    for (final (employeeId, delta) in parsed) {
      final current = await (select(
        employeeTable,
      )..where((employee) => employee.id.equals(employeeId))).getSingleOrNull();
      if (current == null) {
        throw StateError('An affected employee no longer exists.');
      }
      final points = BigInt.from(current.points) - BigInt.from(delta);
      final minPoints = -(BigInt.one << 63);
      final maxPoints = (BigInt.one << 63) - BigInt.one;
      if (points < minPoints || points > maxPoints) {
        throw StateError('Undo would put an employee balance out of range.');
      }
      updates.add(current.copyWith(points: points.toInt()));
    }
    for (final employee in updates) {
      if (!await update(employeeTable).replace(employee)) {
        throw StateError('An affected employee could not be updated.');
      }
    }
  }

  Future<void> _undoEmployeesAdded(Map<String, dynamic> data) async {
    final ids = data['employeeIds'];
    if (ids is! List || ids.isEmpty || ids.any((id) => id is! int)) {
      throw const FormatException('Invalid employee undo data.');
    }

    final employees = <EmployeeTableData>[];
    for (final id in ids.cast<int>()) {
      final employee = await (select(
        employeeTable,
      )..where((row) => row.id.equals(id))).getSingleOrNull();
      if (employee == null) {
        throw StateError('An added employee no longer exists.');
      }
      if (employee.points != 0) {
        throw StateError(
          'Undo later actions affecting these employees before undoing '
          'their addition.',
        );
      }
      employees.add(employee);
    }
    for (final employee in employees) {
      await (delete(
        employeeTable,
      )..where((row) => row.id.equals(employee.id))).go();
    }
  }

  Future<void> _undoEmployeesDeleted(Map<String, dynamic> data) async {
    final snapshots = data['employees'];
    if (snapshots is! List || snapshots.isEmpty) {
      throw const FormatException('Invalid employee undo data.');
    }
    final currentEmployees = await select(employeeTable).get();
    final restored = <EmployeeTableData>[];
    for (final snapshot in snapshots) {
      if (snapshot is! Map) {
        throw const FormatException('Invalid employee undo data.');
      }
      final id = snapshot['id'];
      final firstName = snapshot['firstName'];
      final lastName = snapshot['lastName'];
      final points = snapshot['points'];
      if (id is! int ||
          firstName is! String ||
          lastName is! String ||
          points is! int) {
        throw const FormatException('Invalid employee undo data.');
      }
      if (currentEmployees.any((employee) => employee.id == id)) {
        throw StateError('An employee ID needed for undo is already in use.');
      }
      if (currentEmployees.any(
        (employee) =>
            _employeeNameKey(employee.firstName, employee.lastName) ==
            _employeeNameKey(firstName, lastName),
      )) {
        throw StateError(
          'An employee with the name "$firstName $lastName" already exists.',
        );
      }
      restored.add(
        EmployeeTableData(
          id: id,
          firstName: firstName,
          lastName: lastName,
          points: points,
        ),
      );
    }
    for (final employee in restored) {
      await into(employeeTable).insert(
        EmployeeTableCompanion.insert(
          id: Value(employee.id),
          firstName: employee.firstName,
          lastName: Value(employee.lastName),
          points: Value(employee.points),
        ),
      );
    }
  }

  String _employeeNameKey(String firstName, String lastName) =>
      _normalizeEmployeeName('$firstName $lastName');

  String _normalizeEmployeeName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Stream<List<RewardTableData>> watchRewards() =>
      (select(rewardTable)..orderBy([
            (reward) => OrderingTerm(
              expression: reward.sortOrder,
              nulls: NullsOrder.last,
            ),
            (reward) => OrderingTerm.asc(reward.id),
          ]))
          .watch();

  Stream<List<WriteupTableData>> watchWriteups() =>
      (select(writeupTable)..orderBy([
            (writeup) => OrderingTerm(
              expression: writeup.sortOrder,
              nulls: NullsOrder.last,
            ),
            (writeup) => OrderingTerm.asc(writeup.id),
          ]))
          .watch();

  Future<void> reorderRewards(List<int> ids) => transaction(() async {
    final existing = await select(rewardTable).get();
    if (ids.length != existing.length ||
        ids.toSet().length != existing.length ||
        !ids.toSet().containsAll(existing.map((reward) => reward.id))) {
      throw StateError('The rewards changed. Please try reordering again.');
    }
    await batch((batch) {
      for (var index = 0; index < ids.length; index++) {
        final id = ids[index];
        batch.update(
          rewardTable,
          RewardTableCompanion(sortOrder: Value(index)),
          where: (reward) => reward.id.equals(id),
        );
      }
    });
  });

  Future<void> reorderWriteups(List<int> ids) => transaction(() async {
    final existing = await select(writeupTable).get();
    if (ids.length != existing.length ||
        ids.toSet().length != existing.length ||
        !ids.toSet().containsAll(existing.map((writeup) => writeup.id))) {
      throw StateError('The writeups changed. Please try reordering again.');
    }
    await batch((batch) {
      for (var index = 0; index < ids.length; index++) {
        final id = ids[index];
        batch.update(
          writeupTable,
          WriteupTableCompanion(sortOrder: Value(index)),
          where: (writeup) => writeup.id.equals(id),
        );
      }
    });
  });

  Future<WindowPositionTableData?> getWindowPosition() => (select(
    windowPositionTable,
  )..where((position) => position.id.equals(1))).getSingleOrNull();

  Future<void> saveWindowPosition(
    double x,
    double y, {
    double? width,
    double? height,
    bool? isMaximized,
  }) async {
    await into(windowPositionTable).insertOnConflictUpdate(
      WindowPositionTableCompanion.insert(
        id: const Value(1),
        x: x,
        y: y,
        width: width == null ? const Value.absent() : Value(width),
        height: height == null ? const Value.absent() : Value(height),
        isMaximized: isMaximized == null
            ? const Value.absent()
            : Value(isMaximized),
      ),
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'points_database',
      native: const DriftNativeOptions(),
    );
  }
}

@DriftAccessor(tables: [EmployeeTable])
class EmployeeDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeeDaoMixin {
  EmployeeDao(super.attachedDatabase);

  Future<List<Employee>> getAllEmployees() =>
      select(employeeTable)
          .get()
          .then((data) => data.map((d) => Employee(d)).toList());

  Future<EmployeeTableData?> getEmployee(int id) => (select(
    employeeTable,
  )..where((employee) => employee.id.equals(id))).getSingleOrNull();

  Stream<List<Employee>> watchAllEmployees() =>
      select(employeeTable)
          .watch()
          .map((data) => data.map((d) => Employee(d)).toList());

  Future<int> insertEmployee(EmployeeTableCompanion employee) =>
      into(employeeTable).insert(employee);

  Future<int> addEmployee({required String firstName, String lastName = ''}) =>
      insertEmployee(
        EmployeeTableCompanion.insert(
          firstName: firstName,
          lastName: Value(lastName),
        ),
      );

  Future<bool> updateEmployee(EmployeeTableData data) =>
      update(employeeTable).replace(data);

  Future<int> deleteEmployee(Employee employee) => (delete(
    employeeTable,
  )..where((tbl) => tbl.id.equals(employee.data.id))).go();
}

@DriftAccessor(tables: [HistoryTable])
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.attachedDatabase);

  Stream<List<HistoryTableData>> watchAllEntries() => (select(
    historyTable,
  )..orderBy([(entry) => OrderingTerm.desc(entry.id)])).watch();

  Future<int> addEntry({
    required String actionType,
    required String description,
    required String actor,
    String? employee,
    String? points,
    String? undoData,
  }) => into(historyTable).insert(
    HistoryTableCompanion.insert(
      actionType: actionType,
      description: Value(description),
      actor: Value(actor),
      employee: Value(employee),
      points: Value(points),
      undoData: Value(undoData),
    ),
  );

  static String pointsUndoData(Map<int, int> changes) => jsonEncode({
    'kind': 'points',
    'changes': [
      for (final change in changes.entries)
        {'employeeId': change.key, 'delta': change.value},
    ],
  });

  static String employeesAddedUndoData(List<int> employeeIds) =>
      jsonEncode({'kind': 'employeesAdded', 'employeeIds': employeeIds});

  static String employeesDeletedUndoData(List<EmployeeTableData> employees) =>
      jsonEncode({
        'kind': 'employeesDeleted',
        'employees': [
          for (final employee in employees)
            {
              'id': employee.id,
              'firstName': employee.firstName,
              'lastName': employee.lastName,
              'points': employee.points,
            },
        ],
      });
}
