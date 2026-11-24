import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:provider/provider.dart';

class PointsGrid extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var crossAxisCount = constraints.maxWidth ~/ 180;
        crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

        return Consumer<AppDatabase>(
          builder: (BuildContext context, AppDatabase database, Widget? child) {
            return StreamBuilder(
              stream: EmployeeDao(database).watchAllEmployees(),
              builder: (context, asyncSnapshot) {
                final employees = [...?asyncSnapshot.data]
                  ..sort((a, b) {
                    final firstNameComparison = a.data.firstName
                        .toLowerCase()
                        .compareTo(b.data.firstName.toLowerCase());
                    if (firstNameComparison != 0) return firstNameComparison;

                    return a.data.lastName.toLowerCase().compareTo(
                      b.data.lastName.toLowerCase(),
                    );
                  });

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    return PointCard(employee: employees[index]);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class PointCard extends StatelessWidget {
  const new({super.key, required this.employee});

  final Employee employee;

  Future<void> _showEmployeeDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(employee.name),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete employee'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await EmployeeDao(context.read<AppDatabase>()).deleteEmployee(employee);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete employee: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showEmployeeDialog(context),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      employee.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    employee.formattedPoints,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
