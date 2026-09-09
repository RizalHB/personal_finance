import 'package:drift/drift.dart';

import 'accounts.dart';
import 'categories.dart';
import 'merchants.dart';

class Bills extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  IntColumn get amountMinor => integer().nullable()();

  TextColumn get currencyCode => text()();

  IntColumn get dueDate => integer()();

  IntColumn get status => integer()();

  TextColumn get accountId =>
      text().nullable().references(Accounts, #id)();

  TextColumn get categoryId =>
      text().nullable().references(Categories, #id)();

  TextColumn get merchantId =>
      text().nullable().references(Merchants, #id)();

  TextColumn get notes => text().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get cancelledAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor IS NULL OR amount_minor > 0)',
  ];
}