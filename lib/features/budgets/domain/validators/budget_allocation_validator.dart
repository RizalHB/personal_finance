class BudgetAllocationValidator {
  const BudgetAllocationValidator();

  void validateCreate({
    required String budgetId,
    required String categoryId,
    required int plannedAmountMinor,
  }) {
    if (budgetId.trim().isEmpty) {
      throw ArgumentError('Budget ID cannot be empty.');
    }

    if (categoryId.trim().isEmpty) {
      throw ArgumentError('Category ID cannot be empty.');
    }

    if (plannedAmountMinor <= 0) {
      throw ArgumentError('Planned amount must be greater than zero.');
    }
  }
}
