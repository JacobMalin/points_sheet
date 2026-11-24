import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:provider/provider.dart';

import 'history_page.dart';

class _EmployeeName {
  const _EmployeeName(this.firstName, this.lastName);

  final String firstName;
  final String lastName;
}

class _EmployeesToAdd {
  const _EmployeesToAdd(this.employees);

  final List<_EmployeeName> employees;
}

class ActionsBar extends StatelessWidget {
  const new({super.key});

  Future<void> _addEmployee(BuildContext context) async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final lastNameFocusNode = FocusNode();
    final multipleNamesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var multiple = false;

    try {
      final employeesToAdd = await showDialog<_EmployeesToAdd>(
        context: context,
        builder: (dialogContext) {
          final availableHeight =
              MediaQuery.sizeOf(dialogContext).height -
              MediaQuery.viewInsetsOf(dialogContext).bottom;
          final inputMaxHeight = availableHeight > 432
              ? availableHeight - 320
              : 112.0;

          void submit() {
            if (!formKey.currentState!.validate()) return;

            final employees = multiple
                ? _parseEmployeeNames(multipleNamesController.text)
                : [
                    _EmployeeName(
                      firstNameController.text.trim(),
                      lastNameController.text.trim(),
                    ),
                  ];
            Navigator.of(dialogContext).pop(_EmployeesToAdd(employees));
          }

          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text('Add employee'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DefaultTabController(
                        length: 2,
                        initialIndex: multiple ? 1 : 0,
                        child: TabBar(
                          onTap: (index) {
                            setDialogState(() => multiple = index == 1);
                          },
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: const [
                            Tab(
                              height: 36,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_outline, size: 18),
                                  SizedBox(width: 6),
                                  Text('One'),
                                ],
                              ),
                            ),
                            Tab(
                              height: 36,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.groups_outlined, size: 18),
                                  SizedBox(width: 6),
                                  Text('Multiple'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 112,
                          maxHeight: inputMaxHeight,
                        ),
                        child: multiple
                            ? TextFormField(
                                controller: multipleNamesController,
                                autofocus: true,
                                minLines: 3,
                                maxLines: null,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: const InputDecoration(
                                  labelText: 'Employees',
                                  hintText: 'Firstname Lastname\nFirstname Lastname\n...',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    _parseEmployeeNames(value ?? '').isEmpty
                                    ? 'Enter at least one employee'
                                    : null,
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: firstNameController,
                                    autofocus: true,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        lastNameFocusNode.requestFocus(),
                                    decoration: const InputDecoration(
                                      labelText: 'First name',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? 'Enter a first name'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: lastNameController,
                                    focusNode: lastNameFocusNode,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => submit(),
                                    decoration: const InputDecoration(
                                      labelText: 'Last name',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(onPressed: submit, child: const Text('Add')),
              ],
            ),
          );
        },
      );

      if (employeesToAdd == null || !context.mounted) return;

      try {
        final database = context.read<AppDatabase>();
        final duplicateNames = await database.transaction(() async {
          final dao = EmployeeDao(database);
          final existingNames = (await dao.getAllEmployees())
              .map(
                (employee) => _employeeNameKey(
                  employee.data.firstName,
                  employee.data.lastName,
                ),
              )
              .toSet();
          final duplicates = <String>{};
          final uniqueEmployees = <_EmployeeName>[];

          for (final employee in employeesToAdd.employees) {
            if (!existingNames.add(
              _employeeNameKey(employee.firstName, employee.lastName),
            )) {
              duplicates.add(
                '${employee.firstName} ${employee.lastName}'.trim(),
              );
            } else {
              uniqueEmployees.add(employee);
            }
          }

          final historyDao = HistoryDao(database);
          for (final employee in uniqueEmployees) {
            await dao.addEmployee(
              firstName: employee.firstName,
              lastName: employee.lastName,
            );
          }
          if (uniqueEmployees.isNotEmpty) {
            await historyDao.addEntry(
              actionType: uniqueEmployees.length == 1
                  ? 'Employee added'
                  : 'Employees added',
              description: '',
              employee: uniqueEmployees
                  .map(
                    (employee) =>
                        '${employee.firstName} ${employee.lastName}'.trim(),
                  )
                  .join('\n'),
              actor: '',
            );
          }
          return duplicates.toList();
        });

        if (duplicateNames.isNotEmpty && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Skipped duplicate employee names: '
                '${duplicateNames.join(', ')}',
              ),
            ),
          );
        }
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              employeesToAdd.employees.length == 1
                  ? 'Could not add employee: $error'
                  : 'Could not add employees: $error',
            ),
          ),
        );
      }
    } finally {
      firstNameController.dispose();
      lastNameController.dispose();
      lastNameFocusNode.dispose();
      multipleNamesController.dispose();
    }
  }

  Future<void> _massAddPoints(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _MassAddPointsDialog(),
    );
  }

  Future<void> _openHistory(BuildContext context) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HistoryPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    );
  }

  Future<void> _deleteEmployee(BuildContext context) async {
    final database = context.read<AppDatabase>();
    List<Employee> employees;

    try {
      employees = await EmployeeDao(database).getAllEmployees();
      employees.sort((a, b) {
        final firstNameComparison = a.data.firstName.toLowerCase().compareTo(
          b.data.firstName.toLowerCase(),
        );
        if (firstNameComparison != 0) return firstNameComparison;
        return a.data.lastName.toLowerCase().compareTo(
          b.data.lastName.toLowerCase(),
        );
      });
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load employees: $error')),
      );
      return;
    }

    if (!context.mounted) return;

    final selectedEmployeeIds = <int>{};
    final selectedEmployees = await showDialog<List<Employee>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          constraints: const BoxConstraints(maxWidth: 1400),
          title: const Text('Delete employees'),
          content: employees.isEmpty
              ? const Text('No employees to delete.')
              : SizedBox(
                  width: 1320,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.6,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 210,
                            mainAxisExtent: 54,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        final employeeId = employee.data.id;
                        final isSelected = selectedEmployeeIds.contains(
                          employeeId,
                        );

                        void updateSelection(bool? selected) {
                          setDialogState(() {
                            if (selected == true) {
                              selectedEmployeeIds.add(employeeId);
                            } else {
                              selectedEmployeeIds.remove(employeeId);
                            }
                          });
                        }

                        return Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox.expand(
                            child: InkWell(
                              onTap: () => updateSelection(!isSelected),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: updateSelection,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            employee.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Points: ${employee.formattedPoints}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedEmployeeIds.isEmpty
                  ? null
                  : () => Navigator.of(dialogContext).pop(
                      employees
                          .where(
                            (employee) =>
                                selectedEmployeeIds.contains(employee.data.id),
                          )
                          .toList(),
                    ),
              child: Text('Continue (${selectedEmployeeIds.length})'),
            ),
          ],
        ),
      ),
    );

    if (selectedEmployees == null ||
        selectedEmployees.isEmpty ||
        !context.mounted) {
      return;
    }

    final employeeLabel = selectedEmployees.length == 1
        ? 'employee'
        : 'employees';
    final totalPoints = selectedEmployees.fold<int>(
      0,
      (total, employee) => total + employee.data.points,
    );
    final selectedEmployeeNames = selectedEmployees
        .map(
          (employee) =>
              '${employee.data.firstName} ${employee.data.lastName}'.trim(),
        )
        .toList();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${selectedEmployees.length} $employeeLabel?'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This will permanently delete the selected $employeeLabel:'),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: selectedEmployeeNames.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(selectedEmployeeNames[index]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total points to be deleted: ${NumberFormat().format(totalPoints)}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete selected'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await database.transaction(() async {
        final dao = EmployeeDao(database);
        final historyDao = HistoryDao(database);
        final employeeNames = <String>[];
        final deletedPointValues = <String>[];
        var totalPointsDeleted = 0;
        final currentEmployees = {
          for (final employee in await dao.getAllEmployees())
            employee.data.id: employee,
        };
        for (final selectedEmployee in selectedEmployees) {
          final employee = currentEmployees[selectedEmployee.data.id];
          if (employee == null) continue;

          final deletedRows = await dao.deleteEmployee(employee);
          if (deletedRows == 0) continue;

          final employeeName =
              '${employee.data.firstName} ${employee.data.lastName}'.trim();
          employeeNames.add(employeeName);
          totalPointsDeleted += employee.data.points;
          deletedPointValues.add(employee.formattedPoints);
        }
        if (employeeNames.isNotEmpty) {
          await historyDao.addEntry(
            actionType: 'Employees deleted',
            description:
                'Total points deleted: ${NumberFormat().format(totalPointsDeleted)}',
            actor: '',
            employee: employeeNames.join('\n'),
            points: deletedPointValues.join('\n'),
          );
        }
      });
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete $employeeLabel: $error')),
      );
    }
  }

  static List<_EmployeeName> _parseEmployeeNames(String text) {
    final employees = <_EmployeeName>[];

    for (final line in text.split('\n')) {
      final name = line.trim();
      if (name.isEmpty) continue;

      final parts = name.split(RegExp(r'\s+'));
      employees.add(
        _EmployeeName(
          parts.first,
          parts.length > 1 ? parts.sublist(1).join(' ') : '',
        ),
      );
    }

    return employees;
  }

  static String _employeeNameKey(String firstName, String lastName) =>
      '${firstName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ')} '
      '${lastName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            FilledButton(
              onPressed: () => _addEmployee(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              child: const Text('Add employee'),
            ),
            SizedBox(
              height: 16,
              child: VerticalDivider(
                width: 16,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            FilledButton(
              onPressed: () => _massAddPoints(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              child: const Text('Mass add points'),
            ),
            SizedBox(
              height: 16,
              child: VerticalDivider(
                width: 16,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            FilledButton(
              onPressed: () => _deleteEmployee(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              child: const Text('Delete employee'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _openHistory(context),
              icon: const Icon(Icons.history),
              label: const Text('History'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MassAddPointsDialog extends StatefulWidget {
  const _MassAddPointsDialog();

  @override
  State<_MassAddPointsDialog> createState() => _MassAddPointsDialogState();
}

class _MassAddPointsDialogState extends State<_MassAddPointsDialog> {
  static const _employeeRowExtent = 32.0;

  final _formKey = GlobalKey<FormState>();
  final _horizontalScrollController = ScrollController();
  final Map<int, TextEditingController> _controllers = {};
  List<Employee> _employees = [];
  Object? _loadError;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final employees = await EmployeeDao(context.read<AppDatabase>())
          .getAllEmployees();
      employees.sort((a, b) {
        final firstNameComparison = a.data.firstName.toLowerCase().compareTo(
          b.data.firstName.toLowerCase(),
        );
        if (firstNameComparison != 0) return firstNameComparison;
        return a.data.lastName.toLowerCase().compareTo(
          b.data.lastName.toLowerCase(),
        );
      });

      if (!mounted) return;
      for (final controller in _controllers.values) {
        controller.dispose();
      }
      _controllers
        ..clear()
        ..addEntries(
          employees.map(
            (employee) => MapEntry(employee.data.id, TextEditingController()),
          ),
        );
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final database = context.read<AppDatabase>();
      await database.transaction(() async {
        final dao = EmployeeDao(database);
        final historyDao = HistoryDao(database);
        final employeeNames = <String>[];
        final pointsAdded = <String>[];
        final currentEmployees = await dao.getAllEmployees();
        for (final employee in currentEmployees) {
          final amountText = _controllers[employee.data.id]?.text.trim() ?? '';
          if (amountText.isEmpty) continue;

          final amount = int.parse(amountText);
          if (amount == 0) continue;
          final updated = await dao.updateEmployee(
            employee.data.copyWith(points: employee.data.points + amount),
          );
          if (!updated) continue;

          final employeeName =
              '${employee.data.firstName} ${employee.data.lastName}'.trim();
          employeeNames.add(employeeName);
          pointsAdded.add('+${NumberFormat().format(amount)}');
        }
        if (employeeNames.isNotEmpty) {
          await historyDao.addEntry(
            actionType: 'Mass add points',
            description: '',
            actor: '',
            employee: employeeNames.reversed.join('\n'),
            points: pointsAdded.reversed.join('\n'),
          );
        }
      });

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not add points: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildEmployeeRow(Employee employee, int traversalIndex) {
    return SizedBox(
      height: _employeeRowExtent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${employee.data.firstName} ${employee.data.lastName}'.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: FocusTraversalOrder(
                order: NumericFocusOrder(traversalIndex.toDouble()),
                child: TextFormField(
                  controller: _controllers[employee.data.id],
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(18),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  validator: (value) {
                    final amount = value?.trim() ?? '';
                    return amount.isNotEmpty && int.tryParse(amount) == null
                        ? 'Invalid amount'
                        : null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPointsButton() {
    final child = _isSaving
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text('Add points');

    return FilledButton.tonal(
      onPressed:
          _isSaving || _isLoading || _loadError != null || _employees.isEmpty
          ? null
          : _save,
      child: child,
    );
  }

  Widget _buildEmployeeColumns(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const columnSpacing = 20.0;
              const columnWidth = 200.0;
              final availableHeight = constraints.maxHeight;
              final rowsThatFit = availableHeight.isFinite
                  ? (availableHeight / _employeeRowExtent)
                        .floor()
                        .clamp(1, _employees.length)
                        .toInt()
                  : _employees.length;
              final columnCount =
                  (_employees.length + rowsThatFit - 1) ~/ rowsThatFit;
              final employeesPerColumn = rowsThatFit;
              final contentWidth =
                  columnWidth * columnCount + columnSpacing * (columnCount - 1);
              final columns = <Widget>[];

              for (var column = 0; column < columnCount; column++) {
                if (column > 0) {
                  columns.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: VerticalDivider(
                        width: columnSpacing,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  );
                }

                final columnStart = column * employeesPerColumn;
                final remainingEmployees = _employees.length - columnStart;
                final columnEmployeeCount =
                    remainingEmployees < employeesPerColumn
                    ? remainingEmployees
                    : employeesPerColumn;
                columns.add(
                  SizedBox(
                    width: columnWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var row = 0; row < columnEmployeeCount; row++)
                          _buildEmployeeRow(
                            _employees[columnStart + row],
                            columnStart + row,
                          ),
                        SizedBox(
                          height:
                              (employeesPerColumn - columnEmployeeCount) *
                              _employeeRowExtent,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentWidth,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: columns,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogHeight = (MediaQuery.sizeOf(context).height - 240).clamp(
      160.0,
      640.0,
    );

    return AlertDialog(
      constraints: const BoxConstraints(maxWidth: 900),
      title: const Text('Mass add points'),
      content: SizedBox(
        width: 820,
        height: dialogHeight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Could not load employees: $_loadError'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _loadEmployees,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _employees.isEmpty
            ? const Center(child: Text('No employees to add points to.'))
            : _buildEmployeeColumns(context),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        _buildAddPointsButton(),
      ],
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
