import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/domain/models/monthly_financial_summary.dart';
import 'package:personal_finance/features/reports/presentation/widgets/monthly_financial_summary_chart.dart';

void main() {
  testWidgets('displays income and expense amounts', (tester) async {
    const summary = MonthlyFinancialSummary(
      year: 2026,
      month: 9,
      totalIncomeMinor: 2_000_000,
      totalExpenseMinor: 850_000,
      netAmountMinor: 1_150_000,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MonthlyFinancialSummaryChart(summary: summary)),
      ),
    );

    expect(find.text('Income vs Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Rp2.000.000'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Rp850.000'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });

  testWidgets('handles a month with zero income and expense', (tester) async {
    const summary = MonthlyFinancialSummary(
      year: 2026,
      month: 9,
      totalIncomeMinor: 0,
      totalExpenseMinor: 0,
      netAmountMinor: 0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MonthlyFinancialSummaryChart(summary: summary)),
      ),
    );

    expect(find.text('Income vs Expense'), findsOneWidget);
    expect(find.text('Rp0'), findsNWidgets(2));
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });
}
