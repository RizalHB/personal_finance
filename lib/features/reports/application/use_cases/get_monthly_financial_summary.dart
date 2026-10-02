import '../../data/repositories/monthly_financial_report_repository.dart';
import '../../domain/models/monthly_financial_summary.dart';

class GetMonthlyFinancialSummary {
  const GetMonthlyFinancialSummary(this._repository);

  final MonthlyFinancialReportRepository _repository;

  Future<MonthlyFinancialSummary> execute({
    required int year,
    required int month,
  }) {
    if (year <= 0) {
      throw ArgumentError('Year must be greater than zero.');
    }

    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12.');
    }

    return _repository.getMonthlySummary(year: year, month: month);
  }
}
