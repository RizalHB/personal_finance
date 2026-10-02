import '../../domain/models/monthly_financial_summary.dart';

abstract interface class MonthlyFinancialReportRepository {
  Future<MonthlyFinancialSummary> getMonthlySummary({
    required int year,
    required int month,
  });
}
