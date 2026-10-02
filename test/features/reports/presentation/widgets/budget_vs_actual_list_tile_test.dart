import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/domain/models/budget_vs_actual.dart';
import 'package:personal_finance/features/reports/presentation/widgets/budget_vs_actual_list_tile.dart';

void main() {
  testWidgets('displays budget versus actual metrics', (tester) async {
    const item = BudgetVsActual(
      budgetId: 'budget-1',
      categoryId: 'category-food',
      categoryName: 'Food',
      plannedAmountMinor: 1_000_000,
      actualAmountMinor: 600_000,
      remainingAmountMinor: 400_000,
      usagePercentage: 60.0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BudgetVsActualListTile(item: item)),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Rp600.000'), findsOneWidget);
    expect(find.text('Planned: Rp1.000.000'), findsOneWidget);
    expect(find.text('Remaining: Rp400.000'), findsOneWidget);
    expect(find.text('60.0% used'), findsOneWidget);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(progress.value, 0.6);
  });

  testWidgets('displays overspent amount and clamps progress', (tester) async {
    const item = BudgetVsActual(
      budgetId: 'budget-1',
      categoryId: 'category-food',
      categoryName: 'Food',
      plannedAmountMinor: 1_000_000,
      actualAmountMinor: 1_250_000,
      remainingAmountMinor: -250_000,
      usagePercentage: 125.0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BudgetVsActualListTile(item: item)),
      ),
    );

    expect(find.text('Overspent: Rp250.000'), findsOneWidget);
    expect(find.text('125.0% used'), findsOneWidget);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(progress.value, 1.0);
  });
}
