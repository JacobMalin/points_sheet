import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:points_sheet/history_menu.dart';
import 'package:provider/provider.dart';

class Reward {
  const Reward(this.name, this.pointsRequired);

  final String name;
  final int pointsRequired;
}

class Writeup {
  const Writeup(this.title, this.points);

  final String title;
  final int points;
}

class PointsGrid extends StatefulWidget {
  const PointsGrid({
    super.key,
    required this.rewards,
    required this.writeups,
    required this.useDetailsPanel,
  });

  final List<Reward> rewards;
  final List<Writeup> writeups;
  final bool useDetailsPanel;

  @override
  State<PointsGrid> createState() => _PointsGridState();
}

class _PointsGridState extends State<PointsGrid> {
  static const _detailsPanelWidth = 360.0;
  int? _selectedEmployeeId;
  int? _dialogEmployeeId;
  Employee? _drawerEmployee;
  bool _skipDrawerAnimation = false;
  bool _restoreDrawerAnimationScheduled = false;

  Future<void> _showEmployeeDialog(
    BuildContext context,
    Employee employee,
  ) async {
    var currentEmployee = employee;
    _dialogEmployeeId = employee.data.id;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentEmployee.name,
                            textAlign: TextAlign.center,
                          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EmployeeRewards(
                    employee: currentEmployee,
                    rewards: widget.rewards,
                    onRedeemed: (employee) =>
                        setDialogState(() => currentEmployee = employee),
                  ),
                  const SizedBox(height: 16),
                  _EmployeeWriteups(
                    employee: currentEmployee,
                    writeups: widget.writeups,
                    onWritten: (employee) =>
                        setDialogState(() => currentEmployee = employee),
                  ),
                  if (MediaQuery.sizeOf(dialogContext).height >= 488)
                    Expanded(
                      child: PointCard.buildEmployeeHistory(
                        dialogContext,
                        currentEmployee,
                        expand: true,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (mounted) _dialogEmployeeId = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final useDetailsPanel = widget.useDetailsPanel;
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

                if (useDetailsPanel && _dialogEmployeeId != null) {
                  final dialogEmployeeId = _dialogEmployeeId;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _dialogEmployeeId = null;
                      _selectedEmployeeId = dialogEmployeeId;
                      for (final employee in employees) {
                        if (employee.data.id == dialogEmployeeId) {
                          _drawerEmployee = employee;
                          break;
                        }
                      }
                      _skipDrawerAnimation = true;
                    });
                    Navigator.of(context).pop();
                  });
                }

                if (!useDetailsPanel && _selectedEmployeeId != null) {
                  final selectedEmployeeId = _selectedEmployeeId;
                  Employee? selectedEmployee;
                  for (final employee in employees) {
                    if (employee.data.id == selectedEmployeeId) {
                      selectedEmployee = employee;
                      break;
                    }
                  }
                  if (selectedEmployee != null) {
                    final employeeToOpen = selectedEmployee;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _selectedEmployeeId = null;
                        _drawerEmployee = null;
                      });
                      _showEmployeeDialog(context, employeeToOpen);
                    });
                  }
                }

                if (_selectedEmployeeId != null &&
                    !employees.any(
                      (employee) => employee.data.id == _selectedEmployeeId,
                    )) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedEmployeeId = null);
                  });
                }

                Employee? selectedEmployee;
                if (_selectedEmployeeId != null) {
                  for (final employee in employees) {
                    if (employee.data.id == _selectedEmployeeId) {
                      selectedEmployee = employee;
                      break;
                    }
                  }
                }

                Widget grid = LayoutBuilder(
                  builder: (context, gridConstraints) {
                    var crossAxisCount = gridConstraints.maxWidth ~/ 180;
                    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;
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
                        final employee = employees[index];
                        return PointCard(
                          employee: employee,
                          rewards: widget.rewards,
                          isSelected:
                              useDetailsPanel &&
                              employee.data.id == _selectedEmployeeId,
                          onTap: useDetailsPanel
                              ? () => setState(() {
                                  if (_selectedEmployeeId == employee.data.id) {
                                    _selectedEmployeeId = null;
                                  } else {
                                    _selectedEmployeeId = employee.data.id;
                                    _drawerEmployee = employee;
                                  }
                                })
                              : () => _showEmployeeDialog(context, employee),
                        );
                      },
                    );
                  },
                );

                if (!useDetailsPanel) {
                  return grid;
                }

                if (_skipDrawerAnimation && !_restoreDrawerAnimationScheduled) {
                  _restoreDrawerAnimationScheduled = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _skipDrawerAnimation = false;
                      _restoreDrawerAnimationScheduled = false;
                    });
                  });
                }
                final drawerDuration = _skipDrawerAnimation
                    ? Duration.zero
                    : const Duration(milliseconds: 280);
                final drawerEmployee = selectedEmployee ?? _drawerEmployee;

                return Row(
                  children: [
                    Expanded(child: grid),
                    SizedBox(
                      width: _detailsPanelWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLow,
                          border: Border(
                            left: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const HistoryMenu(),
                            AnimatedPositioned(
                              duration: drawerDuration,
                              curve: Curves.easeOutCubic,
                              top: 0,
                              bottom: 0,
                              right: selectedEmployee == null
                                  ? -_detailsPanelWidth
                                  : 0,
                              width: _detailsPanelWidth,
                              onEnd: () {
                                if (selectedEmployee == null &&
                                    _drawerEmployee != null) {
                                  setState(() => _drawerEmployee = null);
                                }
                              },
                              child: drawerEmployee == null
                                  ? const SizedBox.shrink()
                                  : Material(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLow,
                                      elevation: 8,
                                      child: _EmployeeDetailsPanel(
                                        employee: drawerEmployee,
                                        rewards: widget.rewards,
                                        writeups: widget.writeups,
                                        onClose: () => setState(
                                          () => _selectedEmployeeId = null,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget _twoRowChips(List<Widget> chips) => _TwoRowChips(chips: chips);

class _TwoRowChips extends StatefulWidget {
  const _TwoRowChips({required this.chips});

  final List<Widget> chips;

  @override
  State<_TwoRowChips> createState() => _TwoRowChipsState();
}

class _TwoRowChipsState extends State<_TwoRowChips> {
  final _controller = ScrollController();
  bool _overflows = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstRow = <Widget>[];
    final secondRow = <Widget>[];
    for (var index = 0; index < widget.chips.length; index++) {
      (index.isEven ? firstRow : secondRow).add(widget.chips[index]);
    }

    Widget row(List<Widget> rowChips) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < rowChips.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          rowChips[index],
        ],
      ],
    );

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        final overflows = notification.metrics.maxScrollExtent > 0;
        if (overflows != _overflows) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _overflows = overflows);
          });
        }
        return false;
      },
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.only(bottom: _overflows ? 12 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                row(firstRow),
                if (secondRow.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  row(secondRow),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DelayedProgressIndicator extends StatefulWidget {
  const _DelayedProgressIndicator();

  @override
  State<_DelayedProgressIndicator> createState() =>
      _DelayedProgressIndicatorState();
}

class _DelayedProgressIndicatorState extends State<_DelayedProgressIndicator> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _visible ? const CircularProgressIndicator() : const SizedBox.shrink();
}

class _EmployeeRewards extends StatelessWidget {
  const _EmployeeRewards({
    required this.employee,
    required this.rewards,
    required this.onRedeemed,
  });

  final Employee employee;
  final List<Reward> rewards;
  final ValueChanged<Employee> onRedeemed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Rewards', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _twoRowChips([
          for (final reward in rewards)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: employee.data.points >= reward.pointsRequired
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: employee.data.points >= reward.pointsRequired
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => PointCard.redeemReward(
                context,
                employee,
                reward,
                (points) => onRedeemed(
                  Employee(employee.data.copyWith(points: points)),
                ),
              ),
              child: Text(
                '${reward.name}\n'
                '${NumberFormat().format(reward.pointsRequired)} points',
                textAlign: TextAlign.center,
              ),
            ),
        ]),
      ],
    );
  }
}

class _EmployeeWriteups extends StatelessWidget {
  const _EmployeeWriteups({
    required this.employee,
    required this.writeups,
    required this.onWritten,
  });

  final Employee employee;
  final List<Writeup> writeups;
  final ValueChanged<Employee> onWritten;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Writeups', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _twoRowChips([
          for (final writeup in writeups)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color.lerp(
                  Colors.grey.shade900,
                  Colors.red.shade900,
                  0.3,
                ),
                foregroundColor: Colors.grey.shade300,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: employee.data.points <= 0
                  ? null
                  : () => PointCard.applyWriteup(
                      context,
                      employee,
                      writeup,
                      onWritten,
                    ),
              child: Text(
                '${writeup.title}\n'
                '${NumberFormat().format(writeup.points)} points',
                textAlign: TextAlign.center,
              ),
            ),
        ]),
      ],
    );
  }
}

class _EmployeeDetailsPanel extends StatefulWidget {
  const _EmployeeDetailsPanel({
    required this.employee,
    required this.rewards,
    required this.writeups,
    required this.onClose,
  });

  final Employee employee;
  final List<Reward> rewards;
  final List<Writeup> writeups;
  final VoidCallback onClose;

  @override
  State<_EmployeeDetailsPanel> createState() => _EmployeeDetailsPanelState();
}

class _EmployeeDetailsPanelState extends State<_EmployeeDetailsPanel> {
  late Employee _employee;

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
  }

  @override
  void didUpdateWidget(covariant _EmployeeDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employee.data.id == widget.employee.data.id &&
        oldWidget.employee.data.points != widget.employee.data.points) {
      _employee = widget.employee;
    } else if (oldWidget.employee.data.id != widget.employee.data.id) {
      _employee = widget.employee;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
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
                  onPressed: widget.onClose,
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
                      Text(
                        _employee.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _employee.formattedPoints,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    _EmployeeRewards(
                      employee: _employee,
                      rewards: widget.rewards,
                      onRedeemed: (employee) =>
                          setState(() => _employee = employee),
                    ),
                    const SizedBox(height: 16),
                    _EmployeeWriteups(
                      employee: _employee,
                      writeups: widget.writeups,
                      onWritten: (employee) =>
                          setState(() => _employee = employee),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        constraints.maxHeight < 44
                        ? const SizedBox.shrink()
                        : PointCard.buildEmployeeHistory(
                            context,
                            _employee,
                            expand: true,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PointCard extends StatelessWidget {
  const PointCard({
    super.key,
    required this.employee,
    required this.rewards,
    this.onTap,
    this.isSelected = false,
  });

  final Employee employee;
  final List<Reward> rewards;
  final VoidCallback? onTap;
  final bool isSelected;

  static bool _isPointsHistoryEntry(HistoryTableData entry) =>
      entry.actionType == 'Mass add points' ||
      entry.actionType == 'Reward redeemed' ||
      entry.actionType == 'Writeup';

  static String? _pointsForEmployee(HistoryTableData entry, Employee employee) {
    String normalizeName(String name) =>
        name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    final employeeNames =
        entry.employee?.split('\n').map(normalizeName).toList() ?? [];
    final fullName = normalizeName(
      '${employee.data.firstName} ${employee.data.lastName}'.trim(),
    );
    final displayName = normalizeName(employee.name);
    var employeeIndex = employeeNames.indexWhere(
      (name) => name == fullName || name == displayName,
    );
    if (employeeIndex < 0) return null;

    final pointValues =
        entry.points?.split('\n').map((points) => points.trim()).toList() ?? [];
    if (pointValues.isEmpty) return null;
    if (pointValues.length == 1) return pointValues.first;
    if (employeeIndex >= pointValues.length) return null;
    return pointValues[employeeIndex];
  }

  static Widget buildEmployeeHistory(
    BuildContext context,
    Employee employee, {
    bool expand = false,
  }) {
    final database = context.read<AppDatabase>();

    return StreamBuilder<List<HistoryTableData>>(
      stream: HistoryDao(database).watchAllEntries(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Could not load history: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: _DelayedProgressIndicator()),
          );
        }

        final entries = snapshot.data!
            .where(_isPointsHistoryEntry)
            .map(
              (entry) =>
                  (entry: entry, points: _pointsForEmployee(entry, employee)),
            )
            .where((item) => item.points != null)
            .toList();

        Widget historyList({required bool shrinkWrap}) => ListView.separated(
          shrinkWrap: shrinkWrap,
          itemCount: entries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = entries[index];
            final entry = item.entry;
            final received = entry.actionType == 'Mass add points';
            final description = entry.description.trim();
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                received ? 'Points received' : 'Points removed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (entry.actor.trim().isNotEmpty) ...[
                              const SizedBox(width: 8),
                              ManagerBadge(manager: entry.actor.trim()),
                            ],
                          ],
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(
                            entry.createdAt.toLocal(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.points!,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: received
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              subtitle: description.isEmpty
                  ? null
                  : Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            );
          },
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            const Divider(),
            Text(
              'Points history',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Text('No points received or removed yet.')
            else if (expand)
              Expanded(child: historyList(shrinkWrap: false))
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: historyList(shrinkWrap: true),
              ),
          ],
        );
      },
    );
  }

  static Future<void> applyWriteup(
    BuildContext context,
    Employee currentEmployee,
    Writeup writeup,
    ValueChanged<Employee> updateEmployee,
  ) async {
    final pointsRemoved = writeup.points < currentEmployee.data.points
        ? writeup.points
        : currentEmployee.data.points;
    if (pointsRemoved <= 0) return;

    final remainingPoints = currentEmployee.data.points - pointsRemoved;
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
          actionType: 'Writeup',
          description: writeup.title,
          actor: '',
          employee: employeeName,
          points: '-${NumberFormat().format(pointsRemoved)}',
        );
      });

      if (context.mounted) {
        updateEmployee(
          Employee(currentEmployee.data.copyWith(points: remainingPoints)),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not apply write-up: $error')),
      );
    }
  }

  static Future<void> redeemReward(
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
          points: "-${NumberFormat().format(reward.pointsRequired)}",
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final reward in rewards)
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              currentEmployee.data.points >=
                                  reward.pointsRequired
                              ? Theme.of(dialogContext)
                                    .colorScheme
                                    .secondaryContainer
                              : Theme.of(dialogContext)
                                    .colorScheme
                                    .surfaceContainerHighest,
                          foregroundColor:
                              currentEmployee.data.points >=
                                  reward.pointsRequired
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
                        onPressed: () => redeemReward(
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
                buildEmployeeHistory(dialogContext, currentEmployee),
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
      color: isSelected
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _showEmployeeDialog(context),
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
