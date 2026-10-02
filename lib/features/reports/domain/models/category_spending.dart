class CategorySpending {
  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.amountMinor,
    required this.percentage,
  });

  final String categoryId;
  final String categoryName;
  final int amountMinor;
  final double percentage;
}
