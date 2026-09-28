import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/budgets/data/repositories/drift_budget_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';

void main() {
  late db.AppDatabase database;
  late DriftBudgetRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftBudgetRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and retrieves a budget by year and month', () async {
    const budget = Budget(
      id: 'budget-1',
      year: 2026,
      month: 9,
      name: 'September Budget',
      status: BudgetStatus.active,
      createdAt: 1000,
      updatedAt: 1000,
    );

    await repository.create(budget: budget);

    final result = await repository.getByYearMonth(year: 2026, month: 9);

    expect(result?.id, 'budget-1');
    expect(result?.name, 'September Budget');
    expect(result?.status, BudgetStatus.active);
  });

  test(
    'database rejects duplicate budget for the same year and month',
    () async {
      const firstBudget = Budget(
        id: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 1000,
        updatedAt: 1000,
      );

      const duplicateBudget = Budget(
        id: 'budget-2',
        year: 2026,
        month: 9,
        name: 'Another September Budget',
        status: BudgetStatus.active,
        createdAt: 2000,
        updatedAt: 2000,
      );

      await repository.create(budget: firstBudget);

      expect(
        () => repository.create(budget: duplicateBudget),
        throwsA(isA<Exception>()),
      );
    },
  );
}
