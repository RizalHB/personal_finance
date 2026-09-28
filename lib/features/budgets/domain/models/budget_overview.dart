class BudgetOverview {
  const BudgetOverview({
    required this.budgetId,
    required this.year,
    required this.month,
    required this.name,
    required this.totalPlannedAmountMinor,
    required this.totalActualAmountMinor,
    required this.totalRemainingAmountMinor,
    required this.usagePercentage,
  });

  final String budgetId;
  final int year;
  final int month;
  final String name;
  final int totalPlannedAmountMinor;
  final int totalActualAmountMinor;
  final int totalRemainingAmountMinor;
  final double usagePercentage;
}
