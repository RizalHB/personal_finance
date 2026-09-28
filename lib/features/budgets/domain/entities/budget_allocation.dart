class BudgetAllocation {
  const BudgetAllocation({
    required this.id,
    required this.budgetId,
    required this.categoryId,
    required this.plannedAmountMinor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String budgetId;
  final String categoryId;
  final int plannedAmountMinor;
  final int createdAt;
  final int updatedAt;
}
