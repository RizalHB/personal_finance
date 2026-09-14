import 'package:drift/drift.dart';

class Goals extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  IntColumn get targetAmountMinor => integer()();

  IntColumn get currentAmountMinor => integer()();

  TextColumn get currencyCode => text()();

  IntColumn get deadline => integer().nullable()();

  IntColumn get status => integer()();

  TextColumn get notes => text().nullable()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (target_amount_minor > 0)',
    'CHECK (current_amount_minor >= 0)',
  ];
}
