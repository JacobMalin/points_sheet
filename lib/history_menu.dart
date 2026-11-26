import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:provider/provider.dart';

Color? pointsHistoryColor(
  BuildContext context,
  String actionType, {
  String? points,
}) {
  final colors = Theme.of(context).colorScheme;

  // For Points adjusted, check if the value is negative
  if (actionType == 'Points adjusted') {
    if (points != null && points.startsWith('-')) {
      return colors.error;
    }
    return colors.primary;
  }

  return switch (actionType) {
    'Mass add points' || 'Points added' => colors.primary,
    'Reward redeemed' || 'Writeup' || 'Points removed' => colors.error,
    _ => null,
  };
}

Color _managerColor(String manager) {
  var hash = 0x811c9dc3;
  for (final codeUnit in manager.trim().toLowerCase().codeUnits) {
    hash = ((hash ^ codeUnit) * 0x01000193) & 0xffffffff;
  }
  hash = hash + 9;

  return Colors.primaries[hash % Colors.primaries.length].shade700;
}

class ManagerBadge extends StatelessWidget {
  const ManagerBadge({super.key, required this.manager});

  final String manager;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _managerColor(manager),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            manager,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class HistoryMenu extends StatefulWidget {
  const HistoryMenu({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<HistoryMenu> createState() => _HistoryMenuState();
}

class _HistoryMenuState extends State<HistoryMenu> {
  late final Stream<List<HistoryTableData>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = HistoryDao(context.read<AppDatabase>()).watchAllEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<HistoryTableData>>(
            stream: _entries,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Could not load history: ${snapshot.error}'),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = snapshot.data!;
              if (entries.isEmpty) {
                return const Center(child: Text('No history entries yet.'));
              }

              return ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final manager = entry.actor.trim();
                  final employee = entry.employee?.trim() ?? '';
                  final description = entry.description.trim();
                  final detailStyle = Theme.of(context).textTheme.bodyMedium;
                  final pointsColor = pointsHistoryColor(
                    context,
                    entry.actionType,
                    points: entry.points,
                  );
                  return ListTile(
                    dense: true,
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.actionType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (manager.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ManagerBadge(manager: manager),
                        ],
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat.yMd().format(
                                entry.createdAt.toLocal(),
                              ),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              DateFormat.jm().format(entry.createdAt.toLocal()),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                employee.isEmpty ? '-' : employee,
                                overflow: TextOverflow.ellipsis,
                                style: detailStyle,
                              ),
                            ),
                            if (entry.points?.isNotEmpty ?? false) ...[
                              const SizedBox(width: 8),
                              Text(
                                entry.points!,
                                textAlign: TextAlign.right,
                                style: pointsColor == null
                                    ? detailStyle
                                    : detailStyle?.copyWith(
                                        color: pointsColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
