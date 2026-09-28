import '../../data/repositories/budget_actual_repository.dart';
import '../../data/repositories/budget_allocation_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../domain/models/budget_overview.dart';

class GetBudgetOverview {
  const GetBudgetOverview(
    this._budgetRepository,
    this._allocationRepository,
    this._actualRepository,
  );

  final BudgetRepository _budgetRepository;
  final BudgetAllocationRepository _allocationRepository;
  final BudgetActualRepository _actualRepository;

  Future<BudgetOverview> execute({required String budgetId}) async {
    final normalizedBudgetId = budgetId.trim();

    if (normalizedBudgetId.isEmpty) {
      throw ArgumentError('Budget ID cannot be empty.');
    }

    final budget = await _budgetRepository.getById(normalizedBudgetId);

    if (budget == null) {
      throw StateError('Budget not found: $normalizedBudgetId');
    }

    final allocations = await _allocationRepository.getByBudgetId(
      normalizedBudgetId,
    );

    final actuals = await _actualRepository.getActualsForMonth(
      year: budget.year,
      month: budget.month,
    );

    final totalPlannedAmountMinor = allocations.fold<int>(
      0,
      (total, allocation) => total + allocation.plannedAmountMinor,
    );

    final totalActualAmountMinor = actuals.fold<int>(
      0,
      (total, actual) => total + actual.actualAmountMinor,
    );

    final totalRemainingAmountMinor =
        totalPlannedAmountMinor - totalActualAmountMinor;

    final usagePercentage = totalPlannedAmountMinor == 0
        ? 0.0
        : (totalActualAmountMinor / totalPlannedAmountMinor) * 100;

    return BudgetOverview(
      budgetId: budget.id,
      year: budget.year,
      month: budget.month,
      name: budget.name,
      totalPlannedAmountMinor: totalPlannedAmountMinor,
      totalActualAmountMinor: totalActualAmountMinor,
      totalRemainingAmountMinor: totalRemainingAmountMinor,
      usagePercentage: usagePercentage,
    );
  }
}
