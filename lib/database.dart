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

@DriftDatabase(tables: [EmployeeTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

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
