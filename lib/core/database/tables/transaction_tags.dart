import 'package:drift/drift.dart';

import 'tags.dart';
import 'transactions.dart';

class TransactionTags extends Table {
  TextColumn get transactionId => text().references(Transactions, #id)();

  TextColumn get tagId => text().references(Tags, #id)();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}
