import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/budgets/data/repositories/drift_budget_allocation_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget_allocation.dart';

void main() {
  late db.AppDatabase database;
  late DriftBudgetAllocationRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftBudgetAllocationRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertBudgetAndCategory() async {
    await database
        .into(database.budgets)
        .insert(
          db.BudgetsCompanion.insert(
            id: 'budget-1',
            year: 2026,
            month: 9,
            name: 'September Budget',
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: 'ledger-food',
            kind: 4,
            code: 'food',
            name: 'Food',
            isSystem: false,
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: 'category-food',
            ledgerAccountId: 'ledger-food',
            name: 'Food',
            categoryType: 2,
            status: 1,
            sortOrder: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  test('creates and retrieves allocation by budget', () async {
    const allocation = BudgetAllocation(
      id: 'allocation-1',
      budgetId: 'budget-1',
      categoryId: 'category-food',
      plannedAmountMinor: 1_500_000,
      createdAt: 1000,
      updatedAt: 1000,
    );

    await insertBudgetAndCategory();

    await repository.create(allocation: allocation);

    final results = await repository.getByBudgetId('budget-1');

    expect(results, hasLength(1));
    expect(results.single.id, 'allocation-1');
    expect(results.single.categoryId, 'category-food');
    expect(results.single.plannedAmountMinor, 1_500_000);
  });

  test(
    'database rejects duplicate category allocation within the same budget',
    () async {
      const firstAllocation = BudgetAllocation(
        id: 'allocation-1',
        budgetId: 'budget-1',
        categoryId: 'category-food',
        plannedAmountMinor: 1_500_000,
        createdAt: 1000,
        updatedAt: 1000,
      );

      const duplicateAllocation = BudgetAllocation(
        id: 'allocation-2',
        budgetId: 'budget-1',
        categoryId: 'category-food',
        plannedAmountMinor: 2_000_000,
        createdAt: 2000,
        updatedAt: 2000,
      );

      await insertBudgetAndCategory();

      await repository.create(allocation: firstAllocation);

      expect(
        () => repository.create(allocation: duplicateAllocation),
        throwsA(isA<Exception>()),
      );
    },
  );
}
