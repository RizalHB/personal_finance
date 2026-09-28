import 'package:personal_finance/core/utils/id_generator.dart';

import '../../data/repositories/budget_allocation_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../domain/entities/budget_allocation.dart';
import '../../domain/validators/budget_allocation_validator.dart';

class CreateBudgetAllocation {
  const CreateBudgetAllocation(
    this._budgetRepository,
    this._allocationRepository,
    this._validator,
    this._idGenerator,
  );

  final BudgetRepository _budgetRepository;
  final BudgetAllocationRepository _allocationRepository;
  final BudgetAllocationValidator _validator;
  final IdGenerator _idGenerator;

  Future<BudgetAllocation> execute({
    required String budgetId,
    required String categoryId,
    required int plannedAmountMinor,
  }) async {
    _validator.validateCreate(
      budgetId: budgetId,
      categoryId: categoryId,
      plannedAmountMinor: plannedAmountMinor,
    );

    final normalizedBudgetId = budgetId.trim();
    final normalizedCategoryId = categoryId.trim();

    final budget = await _budgetRepository.getById(normalizedBudgetId);

    if (budget == null) {
      throw StateError('Budget not found: $normalizedBudgetId');
    }

    final existing = await _allocationRepository.getByBudgetAndCategory(
      budgetId: normalizedBudgetId,
      categoryId: normalizedCategoryId,
    );

    if (existing != null) {
      throw StateError(
        'An allocation already exists for this budget and category.',
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final allocation = BudgetAllocation(
      id: _idGenerator.generate(),
      budgetId: normalizedBudgetId,
      categoryId: normalizedCategoryId,
      plannedAmountMinor: plannedAmountMinor,
      createdAt: now,
      updatedAt: now,
    );

    return _allocationRepository.create(allocation: allocation);
  }
}
