import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:points_sheet/database.dart';

void main() {
  for (final (hasUndoData, hasIsUndone) in [
    (false, false),
    (true, false),
    (false, true),
    (true, true),
  ]) {
    test('upgrades version 11 with undo_data=$hasUndoData and '
        'is_undone=$hasIsUndone', () async {
      final database = AppDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute('''
                CREATE TABLE history_table (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  action_type TEXT NOT NULL,
                  description TEXT NOT NULL DEFAULT '',
                  actor TEXT NOT NULL DEFAULT '',
                  employee TEXT,
                  points TEXT,
                  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
                  ${hasUndoData ? ', undo_data TEXT' : ''}
                  ${hasIsUndone ? ', is_undone INTEGER NOT NULL DEFAULT 0' : ''}
                )
              ''');
            sqlite.execute('''
                INSERT INTO history_table (action_type, description
                  ${hasUndoData ? ', undo_data' : ''}
                  ${hasIsUndone ? ', is_undone' : ''})
                VALUES ('Points added', 'existing'
                  ${hasUndoData ? ", 'saved undo data'" : ''}
                  ${hasIsUndone ? ', 1' : ''})
              ''');
            sqlite.execute('PRAGMA user_version = 11');
          },
        ),
      );
      addTearDown(database.close);

      final entries = await HistoryDao(database).watchAllEntries().first;
      expect(entries, hasLength(1));
      expect(entries.single.description, 'existing');
      expect(entries.single.undoData, hasUndoData ? 'saved undo data' : null);
      expect(entries.single.isUndone, hasIsUndone);

      final columns = await database
          .customSelect('PRAGMA table_info(history_table)')
          .get();
      final names = columns.map((row) => row.read<String>('name')).toList();
      expect(names.where((name) => name == 'undo_data'), hasLength(1));
      expect(names.where((name) => name == 'is_undone'), hasLength(1));
      final version = await database.customSelect('PRAGMA user_version').get();
      expect(version.single.read<int>('user_version'), 12);
    });
  }
}
