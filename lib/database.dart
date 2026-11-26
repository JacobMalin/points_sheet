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
  int get schemaVersion => 11;

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
    await batch((batch) {
      batch.insertAll(rewardTable, [
        RewardTableCompanion.insert(name: 'Mocktail', pointsRequired: 250),
        RewardTableCompanion.insert(name: 'Hot Food', pointsRequired: 500),
        RewardTableCompanion.insert(
          name: 'Any Concessions',
          pointsRequired: 1000,
        ),
      ]);
      batch.insertAll(writeupTable, [
        WriteupTableCompanion.insert(title: 'Behavior', points: 100),
        WriteupTableCompanion.insert(title: 'Attendance', points: 500),
        WriteupTableCompanion.insert(title: 'Till', points: 50),
      ]);
    });
  }

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
  }) => into(historyTable).insert(
    HistoryTableCompanion.insert(
      actionType: actionType,
      description: Value(description),
      actor: Value(actor),
      employee: Value(employee),
      points: Value(points),
    ),
  );
}
