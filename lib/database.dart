import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:intl/intl.dart';

part 'database.g.dart';

class Employee {
  const Employee(this.data);

  final EmployeeTableData data;

  String get name =>
      '${data.firstName} ${data.lastName.isEmpty ? '' : data.lastName.substring(0, 1)}';

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

@DriftDatabase(tables: [EmployeeTable, HistoryTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
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
    },
  );

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
