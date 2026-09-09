import 'package:drift/drift.dart';

class Budgets extends Table {
  TextColumn get id => text()();

  IntColumn get year => integer()();

  IntColumn get month => integer()();

  TextColumn get name => text()();

  IntColumn get status => integer()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (month BETWEEN 1 AND 12)',
    'UNIQUE (year, month)',
  ];
}
