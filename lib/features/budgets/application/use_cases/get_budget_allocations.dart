import '../../data/repositories/budget_allocation_repository.dart';
import '../../domain/entities/budget_allocation.dart';

class GetBudgetAllocations {
  const GetBudgetAllocations(this._repository);

  final BudgetAllocationRepository _repository;

  Future<List<BudgetAllocation>> execute({required String budgetId}) {
    final normalizedBudgetId = budgetId.trim();

    if (normalizedBudgetId.isEmpty) {
      throw ArgumentError('Budget ID cannot be empty.');
    }

    return _repository.getByBudgetId(normalizedBudgetId);
  }
}
