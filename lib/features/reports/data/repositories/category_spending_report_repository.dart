import '../../domain/models/category_spending.dart';

abstract interface class CategorySpendingReportRepository {
  Future<List<CategorySpending>> getCategorySpendingForMonth({
    required int year,
    required int month,
  });
}
