import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/use_cases/get_budget_overview.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_actual_repository.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_allocation_repository.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget_allocation.dart';
import 'package:personal_finance/features/budgets/domain/models/budget_actual.dart';

void main() {
  test('calculates planned, actual, remaining, and usage percentage', () async {
    final budget = const Budget(
      id: 'budget-1',
      year: 2026,
      month: 9,
      name: 'September Budget',
      status: BudgetStatus.active,
      createdAt: 1000,
      updatedAt: 1000,
    );

    final budgetRepository = FakeBudgetRepository(budget);

    final allocationRepository = FakeBudgetAllocationRepository([
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

    final useCase = GetBudgetOverview(
      budgetRepository,
      allocationRepository,
      actualRepository,
    );

    final overview = await useCase.execute(budgetId: ' budget-1 ');

    expect(overview.budgetId, 'budget-1');
    expect(overview.year, 2026);
    expect(overview.month, 9);
    expect(overview.name, 'September Budget');
    expect(overview.totalPlannedAmountMinor, 1_500_000);
    expect(overview.totalActualAmountMinor, 350_000);
    expect(overview.totalRemainingAmountMinor, 1_150_000);
    expect(overview.usagePercentage, closeTo(23.333333, 0.000001));

    expect(allocationRepository.requestedBudgetIds, ['budget-1']);
    expect(actualRepository.requestedMonths, ['2026-09']);
  });

  test('rejects an unknown budget', () async {
    final useCase = GetBudgetOverview(
      FakeBudgetRepository(null),
      FakeBudgetAllocationRepository(const []),
      FakeBudgetActualRepository(const []),
    );

    expect(
      () => useCase.execute(budgetId: 'missing-budget'),
      throwsA(isA<StateError>()),
    );
  });
}

class FakeBudgetRepository implements BudgetRepository {
  FakeBudgetRepository(this.budget);

  final Budget? budget;

  @override
  Future<Budget?> getById(String id) async {
    if (budget?.id == id) {
      return budget;
    }

    return null;
  }

  @override
  Future<Budget?> getByYearMonth({
    required int year,
    required int month,
  }) async {
    if (budget?.year == year && budget?.month == month) {
      return budget;
    }

    return null;
  }

  @override
  Future<List<Budget>> getAll() async {
    return budget == null ? [] : [budget!];
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

class FakeBudgetAllocationRepository implements BudgetAllocationRepository {
  FakeBudgetAllocationRepository(this.allocations);

  final List<BudgetAllocation> allocations;
  final List<String> requestedBudgetIds = [];

  @override
  Future<BudgetAllocation?> getById(String id) async {
    return null;
  }

  @override
  Future<List<BudgetAllocation>> getByBudgetId(String budgetId) async {
    requestedBudgetIds.add(budgetId);

    return allocations
        .where((allocation) => allocation.budgetId == budgetId)
        .toList();
  }

  @override
  Future<BudgetAllocation?> getByBudgetAndCategory({
    required String budgetId,
    required String categoryId,
  }) async {
    return null;
  }

  @override
  Future<BudgetAllocation> create({
    required BudgetAllocation allocation,
  }) async {
    allocations.add(allocation);
    return allocation;
  }

  @override
  Future<BudgetAllocation> update({
    required BudgetAllocation allocation,
  }) async {
    return allocation;
  }

  @override
  Future<void> delete(String id) async {}
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
