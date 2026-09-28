import '../../domain/entities/budget_allocation.dart';

abstract interface class BudgetAllocationRepository {
  Future<BudgetAllocation?> getById(String id);

  Future<List<BudgetAllocation>> getByBudgetId(String budgetId);

  Future<BudgetAllocation?> getByBudgetAndCategory({
    required String budgetId,
    required String categoryId,
  });

  Future<BudgetAllocation> create({required BudgetAllocation allocation});

  Future<BudgetAllocation> update({required BudgetAllocation allocation});

  Future<void> delete(String id);
}
