import '../../data/repositories/budget_allocation_repository.dart';

class DeleteBudgetAllocation {
  const DeleteBudgetAllocation(this._repository);

  final BudgetAllocationRepository _repository;

  Future<void> execute(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Allocation ID cannot be empty.');
    }

    final existing = await _repository.getById(normalizedId);

    if (existing == null) {
      throw StateError('Budget allocation not found: $normalizedId');
    }

    await _repository.delete(normalizedId);
  }
}
