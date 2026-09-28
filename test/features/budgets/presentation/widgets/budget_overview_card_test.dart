import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/domain/models/budget_overview.dart';
import 'package:personal_finance/features/budgets/presentation/widgets/budget_overview_card.dart';

void main() {
  testWidgets('displays budget overview metrics', (tester) async {
    const overview = BudgetOverview(
      budgetId: 'budget-1',
      year: 2026,
      month: 9,
      name: 'September Budget',
      totalPlannedAmountMinor: 1_500_000,
      totalActualAmountMinor: 350_000,
      totalRemainingAmountMinor: 1_150_000,
      usagePercentage: 23.333333,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BudgetOverviewCard(overview: overview)),
      ),
    );

    expect(find.text('September Budget'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Rp1.500.000'), findsOneWidget);
    expect(find.text('Actual'), findsOneWidget);
    expect(find.text('Rp350.000'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('Rp1.150.000'), findsOneWidget);
    expect(find.text('23.3% used'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('displays overspent amount when actual exceeds planned', (
    tester,
  ) async {
    const overview = BudgetOverview(
      budgetId: 'budget-1',
      year: 2026,
      month: 9,
      name: 'September Budget',
      totalPlannedAmountMinor: 1_000_000,
      totalActualAmountMinor: 1_250_000,
      totalRemainingAmountMinor: -250_000,
      usagePercentage: 125.0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BudgetOverviewCard(overview: overview)),
      ),
    );

    expect(find.text('Overspent'), findsOneWidget);
    expect(find.text('Rp250.000'), findsOneWidget);
    expect(find.text('125.0% used'), findsOneWidget);
  });
}
