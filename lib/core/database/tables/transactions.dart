import 'package:drift/drift.dart';

import 'accounts.dart';
import 'categories.dart';
import 'merchants.dart';
import 'recurring_transactions.dart';

class Transactions extends Table {
  TextColumn get id => text()();

  IntColumn get transactionType => integer()();

  IntColumn get status => integer()();

  IntColumn get transactionDate => integer()();

  TextColumn get currencyCode => text()();

  IntColumn get amountMinor => integer()();

  TextColumn get accountId => text().nullable().references(Accounts, #id)();

  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  TextColumn get merchantId => text().nullable().references(Merchants, #id)();

  TextColumn get notes => text().nullable()();

  TextColumn get relatedTransactionId =>
      text().nullable().references(Transactions, #id)();

  TextColumn get recurringTransactionId =>
      text().nullable().references(RecurringTransactions, #id)();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get voidedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (amount_minor > 0)'];
}
