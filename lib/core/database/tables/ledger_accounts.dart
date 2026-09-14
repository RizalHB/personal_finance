import 'package:drift/drift.dart';

class LedgerAccounts extends Table {
  TextColumn get id => text()();

  IntColumn get kind => integer()();

  TextColumn get code => text().unique()();

  TextColumn get name => text()();

  BoolColumn get isSystem => boolean()();

  IntColumn get status => integer()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get archivedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (is_system IN (0, 1))'];
}
