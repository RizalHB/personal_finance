import 'package:drift/drift.dart';

import 'ledger_accounts.dart';

class Categories extends Table {
  TextColumn get id => text()();

  TextColumn get ledgerAccountId => text().references(LedgerAccounts, #id)();

  TextColumn get parentId => text().nullable()();

  TextColumn get name => text()();

  IntColumn get categoryType => integer()();

  IntColumn get status => integer()();

  IntColumn get sortOrder => integer()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get archivedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
