import 'package:drift/drift.dart';

class Merchants extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get normalizedName => text()();

  IntColumn get status => integer()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get archivedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(name)) > 0)',
    'CHECK (length(trim(normalized_name)) > 0)',
  ];
}