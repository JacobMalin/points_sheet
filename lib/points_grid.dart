import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:provider/provider.dart';

class Reward {
  const Reward(this.name, this.pointsRequired);

  final String name;
  final int pointsRequired;
}

class PointsGrid extends StatelessWidget {
  const new({super.key, required this.rewards});

  final List<Reward> rewards;

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
                    return PointCard(
                      employee: employees[index],
                      rewards: rewards,
                    );
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
  const new({super.key, required this.employee, required this.rewards});

  final Employee employee;
  final List<Reward> rewards;

  Future<void> _redeemReward(
    BuildContext context,
    Employee currentEmployee,
    Reward reward,
    ValueChanged<int> updatePoints,
  ) async {
    final remainingPoints = currentEmployee.data.points - reward.pointsRequired;

    if (remainingPoints < 0) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Not enough points'),
          content: Text(
            'Redeeming ${reward.name} will leave ${currentEmployee.name} with '
            '${NumberFormat().format(remainingPoints)} points. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Redeem anyway'),
            ),
          ],
        ),
      );

      if (shouldContinue != true || !context.mounted) return;
    }

    try {
      final database = context.read<AppDatabase>();
      await database.transaction(() async {
        final updated = await EmployeeDao(database).updateEmployee(
          currentEmployee.data.copyWith(points: remainingPoints),
        );
        if (!updated) throw StateError('Employee was not found.');

        final employeeName =
            '${currentEmployee.data.firstName} '
                    '${currentEmployee.data.lastName}'
                .trim();
        await HistoryDao(database).addEntry(
          actionType: 'Reward redeemed',
          description: reward.name,
          actor: '',
          employee: employeeName,
          points: (-reward.pointsRequired).toString(),
        );
      });

      if (context.mounted) updatePoints(remainingPoints);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not redeem reward: $error')),
      );
    }
  }

  Future<void> _showEmployeeDialog(BuildContext context) async {
    var currentEmployee = employee;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(48, 24, 48, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentEmployee.name, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          currentEmployee.formattedPoints,
                          style: Theme.of(dialogContext)
                              .textTheme
                              .headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: 420,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reward in rewards)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          currentEmployee.data.points >= reward.pointsRequired
                          ? Theme.of(dialogContext)
                                .colorScheme
                                .secondaryContainer
                          : Theme.of(dialogContext)
                                .colorScheme
                                .surfaceContainerHighest,
                      foregroundColor:
                          currentEmployee.data.points >= reward.pointsRequired
                          ? Theme.of(dialogContext)
                                .colorScheme
                                .onSecondaryContainer
                          : Theme.of(dialogContext)
                                .colorScheme
                                .onSurfaceVariant,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _redeemReward(
                      dialogContext,
                      currentEmployee,
                      reward,
                      (points) => setDialogState(
                        () => currentEmployee = Employee(
                          currentEmployee.data.copyWith(points: points),
                        ),
                      ),
                    ),
                    child: Text(
                      '${reward.name}\n'
                      '${NumberFormat().format(reward.pointsRequired)} points',
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
