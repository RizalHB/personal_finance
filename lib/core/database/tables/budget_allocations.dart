import 'package:drift/drift.dart';

import 'budgets.dart';
import 'categories.dart';

class BudgetAllocations extends Table {
  TextColumn get id => text()();

  TextColumn get budgetId => text().references(Budgets, #id)();

  TextColumn get categoryId => text().references(Categories, #id)();

  IntColumn get plannedAmountMinor => integer()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (planned_amount_minor > 0)',
    'UNIQUE (budget_id, category_id)',
  ];
}
