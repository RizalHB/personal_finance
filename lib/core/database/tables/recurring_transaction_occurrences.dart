import 'package:drift/drift.dart';

import 'recurring_transactions.dart';
import 'transactions.dart';

class RecurringTransactionOccurrences extends Table {
  TextColumn get id => text()();

  TextColumn get recurringTransactionId =>
      text().references(RecurringTransactions, #id)();

  IntColumn get occurrenceDate => integer()();

  TextColumn get transactionId => text().references(Transactions, #id)();

  IntColumn get generatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'UNIQUE (recurring_transaction_id, occurrence_date)',
  ];
}
