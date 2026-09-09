import 'package:drift/drift.dart';

import 'ledger_accounts.dart';

class Accounts extends Table {
  TextColumn get id => text()();

  TextColumn get ledgerAccountId => text().references(LedgerAccounts, #id)();

  TextColumn get name => text()();

  IntColumn get financialClass => integer()();

  IntColumn get accountType => integer()();

  TextColumn get institutionName => text().nullable()();

  TextColumn get currencyCode => text()();

  TextColumn get iconCode => text().nullable()();

  TextColumn get colorCode => text().nullable()();

  TextColumn get notes => text().nullable()();

  IntColumn get status => integer()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get archivedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
