import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/application/use_cases/get_monthly_financial_summary.dart';
import 'package:personal_finance/features/reports/data/repositories/monthly_financial_report_repository.dart';
import 'package:personal_finance/features/reports/domain/models/monthly_financial_summary.dart';

void main() {
  late FakeMonthlyFinancialReportRepository repository;
  late GetMonthlyFinancialSummary useCase;

  setUp(() {
    repository = FakeMonthlyFinancialReportRepository();
    useCase = GetMonthlyFinancialSummary(repository);
  });

  test('returns the monthly summary from the repository', () async {
    repository.summary = const MonthlyFinancialSummary(
      year: 2026,
      month: 9,
      totalIncomeMinor: 5_000_000,
      totalExpenseMinor: 2_500_000,
      netAmountMinor: 2_500_000,
    );

    final result = await useCase.execute(year: 2026, month: 9);

    expect(result.year, 2026);
    expect(result.month, 9);
    expect(result.totalIncomeMinor, 5_000_000);
    expect(result.totalExpenseMinor, 2_500_000);
    expect(result.netAmountMinor, 2_500_000);

    expect(repository.requestedYear, 2026);
    expect(repository.requestedMonth, 9);
  });

  test('rejects an invalid month', () {
    expect(
      () => useCase.execute(year: 2026, month: 13),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.requestedYear, isNull);
    expect(repository.requestedMonth, isNull);
  });

  test('rejects an invalid year', () {
    expect(
      () => useCase.execute(year: 0, month: 9),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.requestedYear, isNull);
    expect(repository.requestedMonth, isNull);
  });
}

class FakeMonthlyFinancialReportRepository
    implements MonthlyFinancialReportRepository {
  MonthlyFinancialSummary? summary;
  int? requestedYear;
  int? requestedMonth;

  @override
  Future<MonthlyFinancialSummary> getMonthlySummary({
    required int year,
    required int month,
  }) async {
    requestedYear = year;
    requestedMonth = month;

    return summary!;
  }
}
