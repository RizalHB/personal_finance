import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/application/report_dependencies.dart';
import 'package:personal_finance/features/reports/application/use_cases/get_monthly_financial_summary.dart';
import 'package:personal_finance/features/reports/domain/models/monthly_financial_summary.dart';
import 'package:personal_finance/features/reports/presentation/notifiers/monthly_financial_summary_notifier.dart';

void main() {
  test('loads the summary for the requested period', () async {
    final useCase = FakeGetMonthlyFinancialSummary(
      const MonthlyFinancialSummary(
        year: 2026,
        month: 9,
        totalIncomeMinor: 5_000_000,
        totalExpenseMinor: 3_500_000,
        netAmountMinor: 1_500_000,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        getMonthlyFinancialSummaryProvider.overrideWithValue(useCase),
      ],
    );

    addTearDown(container.dispose);

    final result = await container.read(
      monthlyFinancialSummaryNotifierProvider(DateTime(2026, 9)).future,
    );

    expect(result.year, 2026);
    expect(result.month, 9);
    expect(result.totalIncomeMinor, 5_000_000);
    expect(result.totalExpenseMinor, 3_500_000);
    expect(result.netAmountMinor, 1_500_000);

    expect(useCase.requestedYears, [2026]);
    expect(useCase.requestedMonths, [9]);
  });
}

class FakeGetMonthlyFinancialSummary implements GetMonthlyFinancialSummary {
  FakeGetMonthlyFinancialSummary(this.summary);

  final MonthlyFinancialSummary summary;
  final List<int> requestedYears = [];
  final List<int> requestedMonths = [];

  @override
  Future<MonthlyFinancialSummary> execute({
    required int year,
    required int month,
  }) async {
    requestedYears.add(year);
    requestedMonths.add(month);
    return summary;
  }
}
