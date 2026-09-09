import 'package:drift/drift.dart';

import 'bills.dart';
import 'transactions.dart';

class BillPayments extends Table {
  TextColumn get id => text()();

  TextColumn get billId =>
      text().references(Bills, #id)();

  TextColumn get transactionId =>
      text().references(Transactions, #id)();

  IntColumn get amountMinor => integer()();

  IntColumn get paidAt => integer()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor > 0)',
    'UNIQUE (bill_id, transaction_id)',
  ];
}