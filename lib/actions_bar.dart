import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
// import 'package:points_sheet/sling.dart';
import 'package:provider/provider.dart';

class _EmployeeName {
  const _EmployeeName(this.firstName, this.lastName);

  final String firstName;
  final String lastName;
}

class _EmployeesToAdd {
  const _EmployeesToAdd(this.employees);

  final List<_EmployeeName> employees;
}

class ActionsBar extends StatefulWidget {
  const ActionsBar({
    super.key,
    required this.authorizationToken,
    required this.showHistoryButton,
    this.onOpenHistory,
  });

  final String? authorizationToken;
  final bool showHistoryButton;
  final VoidCallback? onOpenHistory;

  @override
  State<ActionsBar> createState() => _ActionsBarState();
}

class _ActionsBarState extends State<ActionsBar> {
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

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
          final addedEmployeeIds = <int>[];

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
            addedEmployeeIds.add(
              await dao.addEmployee(
                firstName: employee.firstName,
                lastName: employee.lastName,
              ),
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
              undoData: HistoryDao.employeesAddedUndoData(addedEmployeeIds),
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

  Future<void> _manageRewardsAndWriteups(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _RewardWriteupManagerDialog(),
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
        final deletedEmployees = <EmployeeTableData>[];
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
          deletedEmployees.add(employee.data);
        }
        if (employeeNames.isNotEmpty) {
          await historyDao.addEntry(
            actionType: 'Employees deleted',
            description:
                'Total points deleted: ${NumberFormat().format(totalPointsDeleted)}',
            actor: '',
            employee: employeeNames.join('\n'),
            points: deletedPointValues.join('\n'),
            undoData: HistoryDao.employeesDeletedUndoData(deletedEmployees),
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
    final buttons = [
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
      FilledButton(
        onPressed: () => _manageRewardsAndWriteups(context),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        child: const Text('Edit rewards & writeups'),
      ),
      // SlingButton(authorizationToken: widget.authorizationToken),
    ];

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: LayoutBuilder(
        builder: (context, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (
                          var index = 0;
                          index < buttons.length;
                          index++
                        ) ...[
                          if (index > 0)
                            SizedBox(
                              height: 16,
                              child: VerticalDivider(
                                width: 16,
                                thickness: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                          buttons[index],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.showHistoryButton) ...[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: widget.onOpenHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardWriteupValues {
  const _RewardWriteupValues(this.name, this.points);

  final String name;
  final int points;
}

class _RewardWriteupManagerDialog extends StatefulWidget {
  const _RewardWriteupManagerDialog();

  @override
  State<_RewardWriteupManagerDialog> createState() =>
      _RewardWriteupManagerDialogState();
}

class _RewardWriteupManagerDialogState
    extends State<_RewardWriteupManagerDialog> {
  late final _rewardsStream = context.read<AppDatabase>().watchRewards();
  late final _writeupsStream = context.read<AppDatabase>().watchWriteups();
  List<int>? _pendingRewardOrder;
  List<int>? _pendingWriteupOrder;
  bool _isReordering = false;
  String? _reorderError;

  List<T> _displayOrder<T extends Object>(
    List<T> items,
    List<int>? pending,
    int Function(T) idOf,
    VoidCallback onConfirmed,
  ) {
    if (pending == null) return items;
    final byId = {for (final item in items) idOf(item): item};
    final pendingIds = pending.toSet();
    if (listEquals(
      items.map(idOf).where(pendingIds.contains).toList(),
      pending.where(byId.containsKey).toList(),
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onConfirmed();
      });
    }
    return [
      for (final id in pending) ?byId[id],
      for (final item in items)
        if (!pendingIds.contains(idOf(item))) item,
    ];
  }

  Future<void> _reorder(
    List<int> ids,
    int oldIndex,
    int newIndex,
    Future<void> Function(List<int>) save,
    void Function(List<int>?) setPending,
  ) async {
    if (_isReordering || oldIndex == newIndex) return;
    ids.insert(newIndex, ids.removeAt(oldIndex));
    setState(() {
      setPending(ids);
      _isReordering = true;
      _reorderError = null;
    });
    try {
      await save(ids);
    } catch (error) {
      if (mounted) {
        setState(() {
          setPending(null);
          _reorderError = 'Could not reorder: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isReordering = false);
    }
  }

  Future<_RewardWriteupValues?> _editEntry({
    required String title,
    required String nameLabel,
    required String pointsLabel,
    String initialName = '',
    int? initialPoints,
  }) => showDialog<_RewardWriteupValues>(
    context: context,
    builder: (context) => _RewardWriteupEditorDialog(
      title: title,
      nameLabel: nameLabel,
      pointsLabel: pointsLabel,
      initialName: initialName,
      initialPoints: initialPoints,
    ),
  );

  Future<void> _editReward([RewardTableData? reward]) async {
    final values = await _editEntry(
      title: reward == null ? 'Add reward' : 'Edit reward',
      nameLabel: 'Reward name',
      pointsLabel: 'Points required',
      initialName: reward?.name ?? '',
      initialPoints: reward?.pointsRequired,
    );
    if (values == null || !mounted) return;

    final database = context.read<AppDatabase>();
    try {
      if (reward == null) {
        await database
            .into(database.rewardTable)
            .insert(
              RewardTableCompanion.insert(
                name: values.name,
                pointsRequired: values.points,
              ),
            );
      } else {
        final updated =
            await (database.update(
              database.rewardTable,
            )..where((row) => row.id.equals(reward.id))).write(
              RewardTableCompanion(
                name: Value(values.name),
                pointsRequired: Value(values.points),
              ),
            );
        if (updated == 0) throw StateError('The reward no longer exists.');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save reward: $error')));
    }
  }

  Future<void> _editWriteup([WriteupTableData? writeup]) async {
    final values = await _editEntry(
      title: writeup == null ? 'Add writeup' : 'Edit writeup',
      nameLabel: 'Writeup title',
      pointsLabel: 'Points removed',
      initialName: writeup?.title ?? '',
      initialPoints: writeup?.points,
    );
    if (values == null || !mounted) return;

    final database = context.read<AppDatabase>();
    try {
      if (writeup == null) {
        await database
            .into(database.writeupTable)
            .insert(
              WriteupTableCompanion.insert(
                title: values.name,
                points: values.points,
              ),
            );
      } else {
        final updated =
            await (database.update(
              database.writeupTable,
            )..where((row) => row.id.equals(writeup.id))).write(
              WriteupTableCompanion(
                title: Value(values.name),
                points: Value(values.points),
              ),
            );
        if (updated == 0) throw StateError('The writeup no longer exists.');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save writeup: $error')));
    }
  }

  Future<bool> _confirmDelete(String title, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Delete $title?'),
            content: Text('Delete "$name"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteReward(RewardTableData reward) async {
    if (!await _confirmDelete('reward', reward.name) || !mounted) return;
    final database = context.read<AppDatabase>();
    try {
      await (database.delete(
        database.rewardTable,
      )..where((row) => row.id.equals(reward.id))).go();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete reward: $error')),
      );
    }
  }

  Future<void> _deleteWriteup(WriteupTableData writeup) async {
    if (!await _confirmDelete('writeup', writeup.title) || !mounted) return;
    final database = context.read<AppDatabase>();
    try {
      await (database.delete(
        database.writeupTable,
      )..where((row) => row.id.equals(writeup.id))).go();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete writeup: $error')),
      );
    }
  }

  Widget _buildRewards() {
    return StreamBuilder<List<RewardTableData>>(
      stream: _rewardsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load rewards: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final pending = _pendingRewardOrder;
        final rewards = _displayOrder(
          snapshot.data!,
          pending,
          (RewardTableData reward) => reward.id,
          () {
            if (identical(_pendingRewardOrder, pending)) {
              setState(() => _pendingRewardOrder = null);
            }
          },
        );
        return Column(
          children: [
            Expanded(
              child: rewards.isEmpty
                  ? const Center(child: Text('No rewards yet.'))
                  : ReorderableListView.builder(
                      itemCount: rewards.length,
                      buildDefaultDragHandles: false,
                      onReorderItem: (oldIndex, newIndex) => _reorder(
                        rewards.map((reward) => reward.id).toList(),
                        oldIndex,
                        newIndex,
                        context.read<AppDatabase>().reorderRewards,
                        (order) => _pendingRewardOrder = order,
                      ),
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        return ListTile(
                          key: ValueKey('reward-${reward.id}'),
                          title: Text(reward.name),
                          subtitle: Text(
                            '${NumberFormat().format(reward.pointsRequired)} points required',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _isReordering
                                    ? null
                                    : () => _editReward(reward),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  semanticLabel: 'Edit reward',
                                ),
                              ),
                              IconButton(
                                onPressed: _isReordering
                                    ? null
                                    : () => _deleteReward(reward),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  semanticLabel: 'Delete reward',
                                ),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                enabled: !_isReordering,
                                child: const SizedBox(
                                  width: 40,
                                  height: 48,
                                  child: Icon(
                                    Icons.drag_handle,
                                    semanticLabel: 'Reorder reward',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _editReward(),
                icon: const Icon(Icons.add),
                label: const Text('Add reward'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWriteups() {
    return StreamBuilder<List<WriteupTableData>>(
      stream: _writeupsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load writeups: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final pending = _pendingWriteupOrder;
        final writeups = _displayOrder(
          snapshot.data!,
          pending,
          (WriteupTableData writeup) => writeup.id,
          () {
            if (identical(_pendingWriteupOrder, pending)) {
              setState(() => _pendingWriteupOrder = null);
            }
          },
        );
        return Column(
          children: [
            Expanded(
              child: writeups.isEmpty
                  ? const Center(child: Text('No writeups yet.'))
                  : ReorderableListView.builder(
                      itemCount: writeups.length,
                      buildDefaultDragHandles: false,
                      onReorderItem: (oldIndex, newIndex) => _reorder(
                        writeups.map((writeup) => writeup.id).toList(),
                        oldIndex,
                        newIndex,
                        context.read<AppDatabase>().reorderWriteups,
                        (order) => _pendingWriteupOrder = order,
                      ),
                      itemBuilder: (context, index) {
                        final writeup = writeups[index];
                        return ListTile(
                          key: ValueKey('writeup-${writeup.id}'),
                          title: Text(writeup.title),
                          subtitle: Text(
                            '${NumberFormat().format(writeup.points)} points removed',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _isReordering
                                    ? null
                                    : () => _editWriteup(writeup),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  semanticLabel: 'Edit writeup',
                                ),
                              ),
                              IconButton(
                                onPressed: _isReordering
                                    ? null
                                    : () => _deleteWriteup(writeup),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  semanticLabel: 'Delete writeup',
                                ),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                enabled: !_isReordering,
                                child: const SizedBox(
                                  width: 40,
                                  height: 48,
                                  child: Icon(
                                    Icons.drag_handle,
                                    semanticLabel: 'Reorder writeup',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _editWriteup(),
                icon: const Icon(Icons.add),
                label: const Text('Add writeup'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        title: const Text('Edit rewards & writeups'),
        content: SizedBox(
          width: 480,
          height: 420,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Rewards'),
                  Tab(text: 'Writeups'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [_buildRewards(), _buildWriteups()],
                ),
              ),
              if (_reorderError != null)
                Text(
                  _reorderError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isReordering ? null : () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _RewardWriteupEditorDialog extends StatefulWidget {
  const _RewardWriteupEditorDialog({
    required this.title,
    required this.nameLabel,
    required this.pointsLabel,
    required this.initialName,
    required this.initialPoints,
  });

  final String title;
  final String nameLabel;
  final String pointsLabel;
  final String initialName;
  final int? initialPoints;

  @override
  State<_RewardWriteupEditorDialog> createState() =>
      _RewardWriteupEditorDialogState();
}

class _RewardWriteupEditorDialogState
    extends State<_RewardWriteupEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pointsController = TextEditingController(
      text: widget.initialPoints?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: widget.nameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: widget.pointsLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final points = int.tryParse(value ?? '');
                  return points == null || points <= 0
                      ? 'Enter a number greater than zero'
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              _RewardWriteupValues(
                _nameController.text.trim(),
                int.parse(_pointsController.text),
              ),
            );
          },
          child: Text(widget.initialPoints == null ? 'Add' : 'Save'),
        ),
      ],
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
  final _managerController = TextEditingController();
  final _descriptionController = TextEditingController();
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
        final pointChanges = <int, int>{};
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
          pointChanges[employee.data.id] = amount;
        }
        if (employeeNames.isNotEmpty) {
          await historyDao.addEntry(
            actionType: 'Mass add points',
            description: _descriptionController.text.trim(),
            actor: _managerController.text.trim(),
            employee: employeeNames.reversed.join('\n'),
            points: pointsAdded.reversed.join('\n'),
            undoData: HistoryDao.pointsUndoData(pointChanges),
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

  Widget _buildDetailsFields() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: TextField(
              controller: _managerController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Manager',
                isDense: true,
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _descriptionController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Description',
                isDense: true,
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeColumns(BuildContext context, double availableHeight) {
    const columnSpacing = 20.0;
    const columnWidth = 200.0;
    final rowsThatFit = (availableHeight / _employeeRowExtent)
        .floor()
        .clamp(1, _employees.length)
        .toInt();
    final columnCount = (_employees.length + rowsThatFit - 1) ~/ rowsThatFit;
    final employeesPerColumn = rowsThatFit;
    final contentWidth =
        columnWidth * columnCount + columnSpacing * (columnCount - 1);
    final columns = <Widget>[];

    for (var column = 0; column < columnCount; column++) {
      if (column > 0) {
        columns.add(
          Column(
            children: [
              SizedBox(
                height: rowsThatFit * _employeeRowExtent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: VerticalDivider(
                    width: columnSpacing,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      }

      final columnStart = column * employeesPerColumn;
      final remainingEmployees = _employees.length - columnStart;
      final columnEmployeeCount = remainingEmployees < employeesPerColumn
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

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Scrollbar(
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogHeight = (screenSize.height - 240).clamp(160.0, 640.0);
    const columnSpacing = 20.0;
    const columnWidth = 212.0;
    const horizontalPadding = 32.0;
    const detailsMinimumWidth = 720.0;
    var employeeGridHeight = (dialogHeight - 56).clamp(
      _employeeRowExtent,
      dialogHeight,
    );
    var rowsThatFit = _employees.isEmpty
        ? 1
        : (employeeGridHeight / _employeeRowExtent)
              .floor()
              .clamp(1, _employees.length)
              .toInt();
    var columnCount = _employees.isEmpty
        ? 0
        : (_employees.length + rowsThatFit - 1) ~/ rowsThatFit;
    var employeeContentWidth = columnCount == 0
        ? 0.0
        : columnWidth * columnCount + columnSpacing * (columnCount - 1);
    final maxDialogWidth = (screenSize.width - 64).clamp(320.0, 1900.0);

    if (employeeContentWidth + horizontalPadding > maxDialogWidth) {
      employeeGridHeight = (employeeGridHeight - 12).clamp(
        _employeeRowExtent,
        dialogHeight,
      );
      rowsThatFit = _employees.isEmpty
          ? 1
          : (employeeGridHeight / _employeeRowExtent)
                .floor()
                .clamp(1, _employees.length)
                .toInt();
      columnCount = _employees.isEmpty
          ? 0
          : (_employees.length + rowsThatFit - 1) ~/ rowsThatFit;
      employeeContentWidth = columnCount == 0
          ? 0.0
          : columnWidth * columnCount + columnSpacing * (columnCount - 1);
    }

    final dialogWidth = ([
      detailsMinimumWidth,
      employeeContentWidth + horizontalPadding,
    ].reduce((a, b) => a > b ? a : b)).clamp(320.0, maxDialogWidth);

    return AlertDialog(
      constraints: BoxConstraints(maxWidth: dialogWidth),
      title: const Text('Mass add points'),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
                  : _buildEmployeeColumns(context, employeeGridHeight),
            ),
            _buildDetailsFields(),
          ],
        ),
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
    _managerController.dispose();
    _descriptionController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
