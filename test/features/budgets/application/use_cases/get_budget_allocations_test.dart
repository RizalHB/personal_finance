import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/use_cases/get_budget_allocations.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_allocation_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget_allocation.dart';

void main() {
  late FakeBudgetAllocationRepository repository;
  late GetBudgetAllocations useCase;

  setUp(() {
    repository = FakeBudgetAllocationRepository();

    useCase = GetBudgetAllocations(repository);
  });

  test('returns allocations for the normalized budget ID', () async {
    repository.allocations.addAll([
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
        createdAt: 1001,
        updatedAt: 1001,
      ),
      const BudgetAllocation(
        id: 'allocation-other',
        budgetId: 'budget-2',
        categoryId: 'category-other',
        plannedAmountMinor: 250_000,
        createdAt: 1002,
        updatedAt: 1002,
      ),
    ]);

    final result = await useCase.execute(budgetId: ' budget-1 ');

    expect(result, hasLength(2));
    expect(result.map((allocation) => allocation.id), [
      'allocation-food',
      'allocation-transport',
    ]);
    expect(repository.requestedBudgetIds, ['budget-1']);
  });

  test('rejects an empty budget ID', () {
    expect(
      () => useCase.execute(budgetId: '   '),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.requestedBudgetIds, isEmpty);
  });
}

class FakeBudgetAllocationRepository implements BudgetAllocationRepository {
  final List<BudgetAllocation> allocations = [];
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
    final index = allocations.indexWhere(
      (existing) => existing.id == allocation.id,
    );

    if (index == -1) {
      throw StateError('Allocation not found.');
    }

    allocations[index] = allocation;
    return allocation;
  }

  @override
  Future<void> delete(String id) async {
    allocations.removeWhere((allocation) => allocation.id == id);
  }
}
