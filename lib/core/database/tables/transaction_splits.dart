import 'package:drift/drift.dart';

import 'categories.dart';
import 'transactions.dart';

class TransactionSplits extends Table {
  TextColumn get id => text()();

  TextColumn get transactionId =>
      text().references(Transactions, #id)();

  TextColumn get categoryId =>
      text().references(Categories, #id)();

  IntColumn get amountMinor => integer()();

  TextColumn get notes => text().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor > 0)',
  ];
}