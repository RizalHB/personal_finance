class BudgetAllocationListItem {
  const BudgetAllocationListItem({
    required this.allocationId,
    required this.categoryId,
    required this.categoryName,
    required this.plannedAmountMinor,
  });

  final String allocationId;
  final String categoryId;
  final String categoryName;
  final int plannedAmountMinor;
}
