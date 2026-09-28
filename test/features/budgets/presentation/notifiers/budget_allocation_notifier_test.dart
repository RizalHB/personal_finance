import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/budget_dependencies.dart';
import 'package:personal_finance/features/budgets/application/use_cases/get_budget_allocations.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_actual_repository.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget_allocation.dart';
import 'package:personal_finance/features/budgets/domain/models/budget_actual.dart';
import 'package:personal_finance/features/budgets/presentation/state/budget_allocation_state.dart';
import 'package:personal_finance/features/categories/application/use_cases/get_active_expense_categories.dart';
import 'package:personal_finance/features/categories/domain/entities/category.dart';
import 'package:personal_finance/features/categories/application/category_dependencies.dart';

void main() {
  test('loads and maps allocations with categories and actuals', () async {
    final allocationUseCase = FakeGetBudgetAllocations([
      const BudgetAllocation(
        id: 'allocation-food',
        budgetId: 'budget-1',
        categoryId: 'category-food',
        plannedAmountMinor: 1_000_000,
        createdAt: 1000,
        updatedAt: 1000,
      ),
      const BudgetAllocation(
        id: 'allocation-transport',
        budgetId: 'budget-1',
        categoryId: 'category-transport',
        plannedAmountMinor: 500_000,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    ]);

    final categoryUseCase = FakeGetActiveExpenseCategories([
      const Category(
        id: 'category-food',
        ledgerAccountId: 'ledger-food',
        parentId: null,
        name: 'Food',
        categoryType: CategoryType.expense,
        status: CategoryStatus.active,
        sortOrder: 1,
        createdAt: 1000,
        updatedAt: 1000,
        archivedAt: null,
      ),
      const Category(
        id: 'category-transport',
        ledgerAccountId: 'ledger-transport',
        parentId: null,
        name: 'Transport',
        categoryType: CategoryType.expense,
        status: CategoryStatus.active,
        sortOrder: 2,
        createdAt: 1000,
        updatedAt: 1000,
        archivedAt: null,
      ),
    ]);

    final budgetRepository = FakeBudgetRepository(
      const Budget(
        id: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final actualRepository = FakeBudgetActualRepository([
      const BudgetActual(
        categoryId: 'category-food',
        actualAmountMinor: 250_000,
      ),
      const BudgetActual(
        categoryId: 'category-transport',
        actualAmountMinor: 100_000,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        getBudgetAllocationsProvider.overrideWithValue(allocationUseCase),
        getActiveExpenseCategoriesProvider.overrideWithValue(categoryUseCase),
        budgetRepositoryProvider.overrideWithValue(budgetRepository),
        budgetActualRepositoryProvider.overrideWithValue(actualRepository),
      ],
    );

    addTearDown(container.dispose);

    final state = await container.read(
      budgetAllocationNotifierProvider('budget-1').future,
    );

    expect(state, isA<BudgetAllocationState>());
    expect(state.items, hasLength(2));

    final food = state.items[0];

    expect(food.allocationId, 'allocation-food');
    expect(food.categoryId, 'category-food');
    expect(food.categoryName, 'Food');
    expect(food.plannedAmountMinor, 1_000_000);
    expect(food.actualAmountMinor, 250_000);
    expect(food.remainingAmountMinor, 750_000);
    expect(food.usagePercentage, 25.0);

    final transport = state.items[1];

    expect(transport.allocationId, 'allocation-transport');
    expect(transport.categoryId, 'category-transport');
    expect(transport.categoryName, 'Transport');
    expect(transport.plannedAmountMinor, 500_000);
    expect(transport.actualAmountMinor, 100_000);
    expect(transport.remainingAmountMinor, 400_000);
    expect(transport.usagePercentage, 20.0);

    expect(allocationUseCase.requestedBudgetIds, ['budget-1']);
    expect(actualRepository.requestedMonths, ['2026-09']);
  });
}

class FakeGetBudgetAllocations implements GetBudgetAllocations {
  FakeGetBudgetAllocations(this.allocations);

  final List<BudgetAllocation> allocations;
  final List<String> requestedBudgetIds = [];

  @override
  Future<List<BudgetAllocation>> execute({required String budgetId}) async {
    requestedBudgetIds.add(budgetId);
    return allocations;
  }
}

class FakeGetActiveExpenseCategories implements GetActiveExpenseCategories {
  FakeGetActiveExpenseCategories(this.categories);

  final List<Category> categories;

  @override
  Future<List<Category>> execute() async {
    return categories;
  }
}

class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository(this.budget);

  final Budget budget;

  @override
  Future<Budget?> getById(String id) async {
    if (id == budget.id) {
      return budget;
    }

    return null;
  }

  @override
  Future<Budget?> getByYearMonth({
    required int year,
    required int month,
  }) async {
    if (budget.year == year && budget.month == month) {
      return budget;
    }

    return null;
  }

  @override
  Future<List<Budget>> getAll() async {
    return [budget];
  }

  @override
  Future<Budget> create({required Budget budget}) async {
    return budget;
  }

  @override
  Future<void> archive(String id) async {}

  @override
  Future<void> restore(String id) async {}
}

class FakeBudgetActualRepository implements BudgetActualRepository {
  FakeBudgetActualRepository(this.actuals);

  final List<BudgetActual> actuals;
  final List<String> requestedMonths = [];

  @override
  Future<List<BudgetActual>> getActualsForMonth({
    required int year,
    required int month,
  }) async {
    requestedMonths.add(
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}',
    );

    return actuals;
  }
}
