import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/domain/models/monthly_financial_summary.dart';
import 'package:personal_finance/features/reports/presentation/widgets/monthly_financial_summary_card.dart';

void main() {
  testWidgets('displays monthly financial metrics', (tester) async {
    const summary = MonthlyFinancialSummary(
      year: 2026,
      month: 9,
      totalIncomeMinor: 5_000_000,
      totalExpenseMinor: 3_250_000,
      netAmountMinor: 1_750_000,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: MonthlyFinancialSummaryCard(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Monthly Summary'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Rp5.000.000'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Rp3.250.000'), findsOneWidget);
    expect(find.text('Net'), findsOneWidget);
    expect(find.text('Rp1.750.000'), findsOneWidget);
  });
}
