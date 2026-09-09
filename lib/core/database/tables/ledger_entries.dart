import 'package:drift/drift.dart';

import 'ledger_accounts.dart';
import 'transactions.dart';

class LedgerEntries extends Table {
  TextColumn get id => text()();

  TextColumn get transactionId => text().references(Transactions, #id)();

  TextColumn get ledgerAccountId => text().references(LedgerAccounts, #id)();

  IntColumn get entrySide => integer()();

  IntColumn get amountMinor => integer()();

  TextColumn get currencyCode => text()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (amount_minor > 0)'];
}
