import 'package:drift/drift.dart';

import 'accounts.dart';
import 'categories.dart';
import 'merchants.dart';

class RecurringTransactions extends Table {
  TextColumn get id => text()();

  IntColumn get transactionType => integer()();

  IntColumn get amountMinor => integer()();

  TextColumn get currencyCode => text()();

  TextColumn get accountId =>
      text().references(Accounts, #id)();

  TextColumn get categoryId =>
      text().nullable().references(Categories, #id)();

  TextColumn get merchantId =>
      text().nullable().references(Merchants, #id)();

  TextColumn get notes => text().nullable()();

  IntColumn get frequency => integer()();

  IntColumn get interval => integer()();

  IntColumn get startDate => integer()();

  IntColumn get endDate => integer().nullable()();

  IntColumn get nextOccurrenceDate => integer()();

  BoolColumn get isActive => boolean()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor > 0)',
    'CHECK (interval > 0)',
    'CHECK (is_active IN (0, 1))',
  ];
}