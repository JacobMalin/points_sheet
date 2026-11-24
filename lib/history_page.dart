import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:points_sheet/database.dart';
import 'package:provider/provider.dart';

const Map<int, TableColumnWidth> _historyColumnWidths = {
  0: FixedColumnWidth(112),
  1: FixedColumnWidth(104),
  2: FixedColumnWidth(212),
  3: FixedColumnWidth(220),
  4: FixedColumnWidth(112),
  5: FixedColumnWidth(352),
};
const double _historyTableWidth = 1112;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final Stream<List<HistoryTableData>> _entries;
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _entries = HistoryDao(context.read<AppDatabase>()).watchAllEntries();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  Widget _buildHistoryHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final headerStyle = Theme.of(context).textTheme.titleSmall
        ?.copyWith(fontWeight: FontWeight.w600);

    Widget cell(String label) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(label, style: headerStyle),
    );

    return SizedBox(
      height: 56,
      child: Material(
        color: colors.surfaceContainerHighest,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.outlineVariant)),
          ),
          child: Table(
            columnWidths: _historyColumnWidths,
            children: [
              TableRow(
                children: [
                  cell('Date'),
                  cell('Manager'),
                  cell('Action'),
                  cell('Employee'),
                  cell('Points'),
                  cell('Description'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, HistoryTableData entry) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    Widget cell(Widget child) =>
        Padding(padding: const EdgeInsets.all(16), child: child);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        columnWidths: _historyColumnWidths,
        children: [
          TableRow(
            children: [
              cell(Text(DateFormat.yMd().format(entry.createdAt.toLocal()))),
              cell(Text(entry.actor.isEmpty ? '-' : entry.actor)),
              cell(Text(entry.actionType)),
              cell(
                Text(entry.employee?.isEmpty ?? true ? '-' : entry.employee!),
              ),
              cell(Text(entry.points == null ? '-' : entry.points!)),
              cell(Text(entry.description)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '',
          icon: const BackButtonIcon(),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('History'),
      ),
      body: StreamBuilder<List<HistoryTableData>>(
        stream: _entries,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load history: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data!;
          if (entries.isEmpty) {
            return const Center(child: Text('No history entries yet.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) => Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _historyTableWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      _buildHistoryHeader(context),
                      Expanded(
                        child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) =>
                              _buildHistoryRow(context, entries[index]),
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
    );
  }
}
