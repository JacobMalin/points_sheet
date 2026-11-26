import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:points_sheet/history_menu.dart';
import 'package:provider/provider.dart';

class PointsGrid extends StatefulWidget {
  const PointsGrid({super.key, required this.useDetailsPanel});

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
            contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                    padding: const EdgeInsets.fromLTRB(48, 24, 48, 16),
                    child: SizedBox(
                      width: double.infinity,
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
                            textAlign: TextAlign.center,
                            style: Theme.of(dialogContext)
                                .textTheme
                                .headlineSmall,
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
                  Center(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(dialogContext)
                            .colorScheme
                            .secondaryContainer,
                        foregroundColor: Theme.of(dialogContext)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                      onPressed: () async {
                        final updated = await showDialog<Employee>(
                          context: dialogContext,
                          barrierDismissible: false,
                          builder: (_) =>
                              _AdjustPointsDialog(employee: currentEmployee),
                        );
                        if (dialogContext.mounted && updated != null) {
                          if (currentEmployee.data.id == updated.data.id) {
                            setDialogState(() => currentEmployee = updated);
                          }
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Points'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EmployeeRewards(
                    employee: currentEmployee,
                    onRedeemed: (employee) =>
                        setDialogState(() => currentEmployee = employee),
                  ),
                  const SizedBox(height: 16),
                  _EmployeeWriteups(
                    employee: currentEmployee,
                    onWritten: (employee) =>
                        setDialogState(() => currentEmployee = employee),
                  ),
                  if (MediaQuery.sizeOf(dialogContext).height >= 524)
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

  Future<void> _showSearchAndAdjustDialog(
    BuildContext context,
    List<Employee> employees,
  ) async {
    final searchController = TextEditingController();
    final amountController = TextEditingController();
    final managerController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    Employee? selectedEmployee;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredEmployees = searchController.text.isEmpty
              ? employees
              : employees
                    .where(
                      (e) => e.name.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ),
                    )
                    .toList();

          return AlertDialog(
            title: const Text('Add Points'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedEmployee == null) ...[
                        TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search employee',
                            hintText: 'Type name...',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (_) => setDialogState(() {}),
                        ),
                        const SizedBox(height: 16),
                        if (filteredEmployees.isEmpty)
                          const Text('No employees found')
                        else
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredEmployees.length,
                              itemBuilder: (context, index) {
                                final employee = filteredEmployees[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(employee.name),
                                  subtitle: Text(employee.formattedPoints),
                                  selected:
                                      selectedEmployee?.data.id ==
                                      employee.data.id,
                                  onTap: () => setDialogState(
                                    () => selectedEmployee = employee,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                      if (selectedEmployee != null) ...[
                        const SizedBox(height: 16),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setDialogState(() {
                              selectedEmployee = null;
                              searchController.clear();
                            }),
                            child: _HoverableEmployeeCard(
                              employee: selectedEmployee!,
                              onTap: () => setDialogState(() {
                                selectedEmployee = null;
                                searchController.clear();
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: amountController,
                          enabled: !isSaving,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9\-]'),
                            ),
                            LengthLimitingTextInputFormatter(19),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Points',
                          ),
                          validator: (value) {
                            final amount = int.tryParse(value ?? '');
                            return amount == null
                                ? 'Enter a number (can be negative)'
                                : null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: managerController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Manager',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selectedEmployee == null || isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => isSaving = true);

                        try {
                          final database = context.read<AppDatabase>();
                          final amount = int.parse(amountController.text);
                          await database.transaction(() async {
                            final employeeDao = EmployeeDao(database);
                            final current = await employeeDao.getEmployee(
                              selectedEmployee!.data.id,
                            );
                            if (current == null) {
                              throw StateError('Employee was not found.');
                            }

                            final result =
                                BigInt.from(current.points) +
                                BigInt.from(amount);
                            final minPoints = -(BigInt.one << 63);
                            final maxPoints = (BigInt.one << 63) - BigInt.one;
                            if (result < minPoints || result > maxPoints) {
                              throw StateError(
                                'The resulting points balance is out of range.',
                              );
                            }
                            final newEmployee = current.copyWith(
                              points: result.toInt(),
                            );
                            if (!await employeeDao.updateEmployee(
                              newEmployee,
                            )) {
                              throw StateError('Employee was not found.');
                            }
                            await HistoryDao(database).addEntry(
                              actionType: 'Points adjusted',
                              description: descriptionController.text.trim(),
                              actor: managerController.text.trim(),
                              employee:
                                  '${current.firstName} ${current.lastName}'
                                      .trim(),
                              points:
                                  '${amount >= 0 ? '+' : ''}${NumberFormat().format(amount)}',
                            );
                          });

                          if (mounted && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } catch (error) {
                          if (mounted) {
                            setDialogState(() => isSaving = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not adjust points: $error',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
    searchController.dispose();
    amountController.dispose();
    managerController.dispose();
    descriptionController.dispose();
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
                  return Scaffold(
                    body: grid,
                    floatingActionButton: FloatingActionButton(
                      onPressed: () =>
                          _showSearchAndAdjustDialog(context, employees),
                      child: const Icon(Icons.add),
                    ),
                  );
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

                return Scaffold(
                  body: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            grid,
                            AnimatedPositioned(
                              duration: drawerDuration,
                              curve: Curves.easeOutCubic,
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton(
                                onPressed: () => _showSearchAndAdjustDialog(
                                  context,
                                  employees,
                                ),
                                child: const Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget _wrapChips(List<Widget> chips) => _ChipRows(chips: chips);

class _ChipRows extends StatefulWidget {
  const _ChipRows({required this.chips});

  final List<Widget> chips;

  @override
  State<_ChipRows> createState() => _ChipRowsState();
}

class _ChipRowsState extends State<_ChipRows> {
  final _controller = ScrollController();
  bool _overflows = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          NotificationListener<ScrollMetricsNotification>(
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
                  padding: EdgeInsets.only(bottom: _overflows ? 16 : 0),
                  child: _ChipRowLayout(
                    viewportWidth: constraints.maxWidth,
                    children: widget.chips,
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class _ChipRowLayout extends MultiChildRenderObjectWidget {
  const _ChipRowLayout({required this.viewportWidth, required super.children});

  final double viewportWidth;

  @override
  _RenderChipRows createRenderObject(BuildContext context) =>
      _RenderChipRows(viewportWidth, Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, _RenderChipRows renderObject) {
    renderObject
      ..viewportWidth = viewportWidth
      ..textDirection = Directionality.of(context);
  }
}

class _ChipRowParentData extends ContainerBoxParentData<RenderBox> {
  int row = 0;
}

class _RenderChipRows extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ChipRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ChipRowParentData> {
  _RenderChipRows(this._viewportWidth, this._textDirection);

  double _viewportWidth;
  TextDirection _textDirection;

  set viewportWidth(double value) {
    if (_viewportWidth == value) return;
    _viewportWidth = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ChipRowParentData) {
      child.parentData = _ChipRowParentData();
    }
  }

  @override
  void performLayout() {
    const spacing = 8.0;
    final widths = [0.0, 0.0];
    final heights = [0.0, 0.0];
    final counts = [0, 0];
    var totalWidth = 0.0;
    var index = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(
        BoxConstraints(maxHeight: constraints.maxHeight),
        parentUsesSize: true,
      );
      final row = widths[0] <= widths[1] ? 0 : 1;
      (child.parentData! as _ChipRowParentData).row = row;
      if (counts[row] > 0) widths[row] += spacing;
      widths[row] += child.size.width;
      heights[row] = math.max(heights[row], child.size.height);
      counts[row]++;
      if (index > 0) totalWidth += spacing;
      totalWidth += child.size.width;
      index++;
    }

    final singleRow = totalWidth <= _viewportWidth;
    final contentWidth = singleRow
        ? _viewportWidth
        : math.max(_viewportWidth, math.max(widths[0], widths[1]));
    final contentHeight = singleRow
        ? math.max(heights[0], heights[1])
        : heights[0] + (counts[1] > 0 ? spacing + heights[1] : 0);
    size = constraints.constrain(Size(contentWidth, contentHeight));

    final insets = singleRow
        ? [(size.width - totalWidth) / 2, 0.0]
        : contentWidth <= _viewportWidth
        ? [(size.width - widths[0]) / 2, (size.width - widths[1]) / 2]
        : [0.0, 0.0];
    final positions = _textDirection == TextDirection.ltr
        ? insets
        : [size.width - insets[0], size.width - insets[1]];
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final data = child.parentData! as _ChipRowParentData;
      final row = singleRow ? 0 : data.row;
      final rowHeight = singleRow ? contentHeight : heights[row];
      final y =
          (row == 1 ? heights[0] + spacing : 0) +
          (rowHeight - child.size.height) / 2;
      final x = _textDirection == TextDirection.ltr
          ? positions[row]
          : positions[row] - child.size.width;
      data.offset = Offset(x, y);
      positions[row] +=
          (child.size.width + spacing) *
          (_textDirection == TextDirection.ltr ? 1 : -1);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
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
  const _EmployeeRewards({required this.employee, required this.onRedeemed});

  final Employee employee;
  final ValueChanged<Employee> onRedeemed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Rewards', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        StreamBuilder<List<RewardTableData>>(
          stream: context.read<AppDatabase>().watchRewards(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Could not load rewards: ${snapshot.error}');
            }
            if (!snapshot.hasData) return const _DelayedProgressIndicator();
            return _wrapChips([
              for (final reward in snapshot.data!)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        employee.data.points >= reward.pointsRequired
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor:
                        employee.data.points >= reward.pointsRequired
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    '-${NumberFormat().format(reward.pointsRequired)} points',
                    textAlign: TextAlign.center,
                  ),
                ),
            ]);
          },
        ),
      ],
    );
  }
}

class _EmployeeWriteups extends StatelessWidget {
  const _EmployeeWriteups({required this.employee, required this.onWritten});

  final Employee employee;
  final ValueChanged<Employee> onWritten;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Writeups', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        StreamBuilder<List<WriteupTableData>>(
          stream: context.read<AppDatabase>().watchWriteups(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Could not load writeups: ${snapshot.error}');
            }
            if (!snapshot.hasData) return const _DelayedProgressIndicator();
            return _wrapChips([
              for (final writeup in snapshot.data!)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color.lerp(
                      Colors.grey.shade900,
                      Colors.red.shade900,
                      0.3,
                    ),
                    foregroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    '-${NumberFormat().format(writeup.points)} points',
                    textAlign: TextAlign.center,
                  ),
                ),
            ]);
          },
        ),
      ],
    );
  }
}

class _EmployeeDetailsPanel extends StatefulWidget {
  const _EmployeeDetailsPanel({required this.employee, required this.onClose});

  final Employee employee;
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
                padding: const EdgeInsets.fromLTRB(48, 24, 48, 16),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                        onPressed: () async {
                          final updated = await showDialog<Employee>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                _AdjustPointsDialog(employee: _employee),
                          );
                          if (context.mounted && updated != null) {
                            if (_employee.data.id == updated.data.id) {
                              setState(() => _employee = updated);
                            }
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Points'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EmployeeRewards(
                      employee: _employee,
                      onRedeemed: (employee) =>
                          setState(() => _employee = employee),
                    ),
                    const SizedBox(height: 16),
                    _EmployeeWriteups(
                      employee: _employee,
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

class _AdjustPointsDialog extends StatefulWidget {
  const _AdjustPointsDialog({required this.employee});

  final Employee employee;

  @override
  State<_AdjustPointsDialog> createState() => _AdjustPointsDialogState();
}

class _AdjustPointsDialogState extends State<_AdjustPointsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _manager = TextEditingController();
  final _description = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _manager.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final database = context.read<AppDatabase>();
      final amount = int.parse(_amount.text);
      final updated = await database.transaction(() async {
        final employeeDao = EmployeeDao(database);
        final current = await employeeDao.getEmployee(widget.employee.data.id);
        if (current == null) throw StateError('Employee was not found.');

        final result = BigInt.from(current.points) + BigInt.from(amount);
        final minPoints = -(BigInt.one << 63);
        final maxPoints = (BigInt.one << 63) - BigInt.one;
        if (result < minPoints || result > maxPoints) {
          throw StateError('The resulting points balance is out of range.');
        }
        final newEmployee = current.copyWith(points: result.toInt());
        if (!await employeeDao.updateEmployee(newEmployee)) {
          throw StateError('Employee was not found.');
        }
        await HistoryDao(database).addEntry(
          actionType: 'Points adjusted',
          description: _description.text.trim(),
          actor: _manager.text.trim(),
          employee: '${current.firstName} ${current.lastName}'.trim(),
          points: '${amount >= 0 ? '+' : ''}${NumberFormat().format(amount)}',
        );
        return Employee(newEmployee);
      });

      if (mounted) Navigator.of(context).pop(updated);
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not adjust points: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: AlertDialog(
        title: Text('Adjust points for ${widget.employee.name}'),
        content: SizedBox(
          width: 320,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _amount,
                    autofocus: true,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                      LengthLimitingTextInputFormatter(19),
                    ],
                    decoration: const InputDecoration(labelText: 'Points'),
                    validator: (value) {
                      final amount = int.tryParse(value ?? '');
                      return amount == null
                          ? 'Enter a number (can be negative)'
                          : null;
                    },
                  ),
                  TextField(
                    controller: _manager,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(labelText: 'Manager'),
                  ),
                  TextField(
                    controller: _description,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class PointCard extends StatelessWidget {
  const PointCard({
    super.key,
    required this.employee,
    this.onTap,
    this.isSelected = false,
  });

  final Employee employee;
  final VoidCallback? onTap;
  final bool isSelected;

  static bool _isPointsHistoryEntry(HistoryTableData entry) =>
      entry.actionType == 'Mass add points' ||
      entry.actionType == 'Points added' ||
      entry.actionType == 'Points removed' ||
      entry.actionType == 'Points adjusted' ||
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
            final received =
                entry.actionType == 'Mass add points' ||
                entry.actionType == 'Points added' ||
                (entry.actionType == 'Points adjusted' &&
                    !(entry.points?.startsWith('-') ?? false));
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
                                description.isEmpty
                                    ? (received
                                          ? 'Points received'
                                          : 'Points removed')
                                    : description,
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
                      color: pointsHistoryColor(
                        context,
                        entry.actionType,
                        points: item.points,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
    WriteupTableData writeup,
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
    RewardTableData reward,
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
                Center(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(dialogContext)
                          .colorScheme
                          .secondaryContainer,
                      foregroundColor: Theme.of(dialogContext)
                          .colorScheme
                          .onSecondaryContainer,
                    ),
                    onPressed: () async {
                      final updated = await showDialog<Employee>(
                        context: dialogContext,
                        barrierDismissible: false,
                        builder: (_) =>
                            _AdjustPointsDialog(employee: currentEmployee),
                      );
                      if (dialogContext.mounted && updated != null) {
                        if (currentEmployee.data.id == updated.data.id) {
                          setDialogState(() => currentEmployee = updated);
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Points'),
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<RewardTableData>>(
                  stream: context.read<AppDatabase>().watchRewards(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Could not load rewards: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const _DelayedProgressIndicator();
                    }
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final reward in snapshot.data!)
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
                              '-${NumberFormat().format(reward.pointsRequired)} points',
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    );
                  },
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

class _HoverableEmployeeCard extends StatefulWidget {
  const _HoverableEmployeeCard({required this.employee, required this.onTap});

  final Employee employee;
  final VoidCallback onTap;

  @override
  State<_HoverableEmployeeCard> createState() => _HoverableEmployeeCardState();
}

class _HoverableEmployeeCardState extends State<_HoverableEmployeeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.employee.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              widget.employee.formattedPoints,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
