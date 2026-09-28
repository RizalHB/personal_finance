import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/use_cases/update_budget_allocation.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_allocation_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget_allocation.dart';
import 'package:personal_finance/features/budgets/domain/validators/budget_allocation_validator.dart';

void main() {
  late FakeBudgetAllocationRepository repository;
  late UpdateBudgetAllocation useCase;

  setUp(() {
    repository = FakeBudgetAllocationRepository();

    useCase = UpdateBudgetAllocation(
      repository,
      const BudgetAllocationValidator(),
    );
  });

  test(
    'updates allocation while preserving identity and creation time',
    () async {
      repository.allocations.add(
        const BudgetAllocation(
          id: 'allocation-1',
          budgetId: 'budget-1',
          categoryId: 'category-food',
          plannedAmountMinor: 1_000_000,
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );

      final updated = await useCase.execute(
        id: ' allocation-1 ',
        budgetId: ' budget-1 ',
        categoryId: ' category-food ',
        plannedAmountMinor: 1_500_000,
      );

      expect(updated.id, 'allocation-1');
      expect(updated.budgetId, 'budget-1');
      expect(updated.categoryId, 'category-food');
      expect(updated.plannedAmountMinor, 1_500_000);
      expect(updated.createdAt, 1000);
      expect(updated.updatedAt, greaterThan(1000));
      expect(repository.updated, hasLength(1));
    },
  );

  test('rejects update when allocation does not exist', () async {
    expect(
      () => useCase.execute(
        id: 'missing-allocation',
        budgetId: 'budget-1',
        categoryId: 'category-food',
        plannedAmountMinor: 1_500_000,
      ),
      throwsA(isA<StateError>()),
    );

    expect(repository.updated, isEmpty);
  });
}

class FakeBudgetAllocationRepository implements BudgetAllocationRepository {
  final List<BudgetAllocation> allocations = [];
  final List<BudgetAllocation> updated = [];

  @override
  Future<BudgetAllocation?> getById(String id) async {
    for (final allocation in allocations) {
      if (allocation.id == id) {
        return allocation;
      }
    }

    return null;
  }

  @override
  Future<List<BudgetAllocation>> getByBudgetId(String budgetId) async {
    return allocations
        .where((allocation) => allocation.budgetId == budgetId)
        .toList();
  }

  @override
  Future<BudgetAllocation?> getByBudgetAndCategory({
    required String budgetId,
    required String categoryId,
  }) async {
    for (final allocation in allocations) {
      if (allocation.budgetId == budgetId &&
          allocation.categoryId == categoryId) {
        return allocation;
      }
    }

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
    updated.add(allocation);
    return allocation;
  }

  @override
  Future<void> delete(String id) async {
    allocations.removeWhere((allocation) => allocation.id == id);
  }
}
