class BudgetVsActual {
  const BudgetVsActual({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.plannedAmountMinor,
    required this.actualAmountMinor,
    required this.remainingAmountMinor,
    required this.usagePercentage,
  });

  final String budgetId;
  final String categoryId;
  final String categoryName;
  final int plannedAmountMinor;
  final int actualAmountMinor;
  final int remainingAmountMinor;
  final double usagePercentage;
}
