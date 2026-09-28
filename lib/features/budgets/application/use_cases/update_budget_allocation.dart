import '../../data/repositories/budget_allocation_repository.dart';
import '../../domain/entities/budget_allocation.dart';
import '../../domain/validators/budget_allocation_validator.dart';

class UpdateBudgetAllocation {
  const UpdateBudgetAllocation(this._repository, this._validator);

  final BudgetAllocationRepository _repository;
  final BudgetAllocationValidator _validator;

  Future<BudgetAllocation> execute({
    required String id,
    required String budgetId,
    required String categoryId,
    required int plannedAmountMinor,
  }) async {
    final normalizedId = id.trim();
    final normalizedBudgetId = budgetId.trim();
    final normalizedCategoryId = categoryId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Allocation ID cannot be empty.');
    }

    _validator.validateCreate(
      budgetId: normalizedBudgetId,
      categoryId: normalizedCategoryId,
      plannedAmountMinor: plannedAmountMinor,
    );

    final existing = await _repository.getById(normalizedId);

    if (existing == null) {
      throw StateError('Budget allocation not found: $normalizedId');
    }

    final updatedAllocation = BudgetAllocation(
      id: existing.id,
      budgetId: normalizedBudgetId,
      categoryId: normalizedCategoryId,
      plannedAmountMinor: plannedAmountMinor,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    return _repository.update(allocation: updatedAllocation);
  }
}
