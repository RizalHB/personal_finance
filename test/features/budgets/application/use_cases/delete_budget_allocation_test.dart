import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/use_cases/delete_budget_allocation.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_allocation_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget_allocation.dart';

void main() {
  late FakeBudgetAllocationRepository repository;
  late DeleteBudgetAllocation useCase;

  setUp(() {
    repository = FakeBudgetAllocationRepository();

    useCase = DeleteBudgetAllocation(repository);
  });

  test('deletes an existing allocation', () async {
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

    await useCase.execute(' allocation-1 ');

    expect(repository.allocations, isEmpty);
    expect(repository.deleted, ['allocation-1']);
  });

  test('rejects deletion when allocation does not exist', () async {
    expect(
      () => useCase.execute('missing-allocation'),
      throwsA(isA<StateError>()),
    );

    expect(repository.deleted, isEmpty);
  });
}

class FakeBudgetAllocationRepository implements BudgetAllocationRepository {
  final List<BudgetAllocation> allocations = [];
  final List<String> deleted = [];

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
    return allocation;
  }

  @override
  Future<void> delete(String id) async {
    deleted.add(id);

    allocations.removeWhere((allocation) => allocation.id == id);
  }
}
