import '../../data/repositories/category_spending_report_repository.dart';
import '../../domain/models/category_spending.dart';

class GetCategorySpending {
  const GetCategorySpending(this._repository);

  final CategorySpendingReportRepository _repository;

  Future<List<CategorySpending>> execute({
    required int year,
    required int month,
  }) {
    if (year <= 0) {
      throw ArgumentError('Year must be greater than zero.');
    }

    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12.');
    }

    return _repository.getCategorySpendingForMonth(year: year, month: month);
  }
}
