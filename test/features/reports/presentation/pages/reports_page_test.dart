import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_finance/features/reports/domain/models/budget_vs_actual.dart';
import 'package:personal_finance/features/reports/domain/models/category_spending.dart';
import 'package:personal_finance/features/reports/domain/models/monthly_financial_summary.dart';
import 'package:personal_finance/features/reports/presentation/notifiers/budget_vs_actual_notifier.dart';
import 'package:personal_finance/features/reports/presentation/notifiers/category_spending_notifier.dart';
import 'package:personal_finance/features/reports/presentation/notifiers/monthly_financial_summary_notifier.dart';
import 'package:personal_finance/features/reports/presentation/pages/reports_page.dart';

void main() {
  testWidgets('displays monthly report summary', (tester) async {
    const summary = MonthlyFinancialSummary(
      year: 2026,
      month: 9,
      totalIncomeMinor: 2_000_000,
      totalExpenseMinor: 850_000,
      netAmountMinor: 1_150_000,
    );

    final period = DateTime(2026, 9);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monthlyFinancialSummaryNotifierProvider(period)
              .overrideWith(() => FakeMonthlyFinancialSummaryNotifier(summary)),
          categorySpendingNotifierProvider(period).overrideWith(
            () => FakeCategorySpendingNotifier(const [
              CategorySpending(
                categoryId: 'category-food',
                categoryName: 'Food',
                amountMinor: 500_000,
                percentage: 58.8235,
              ),
            ]),
          ),
        ],
        child: MaterialApp(home: ReportsPage(period: period)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Monthly Reports'), findsOneWidget);
    expect(find.text('Report Period'), findsOneWidget);
    expect(find.text('2026-09'), findsOneWidget);

    expect(find.text('Monthly Summary'), findsOneWidget);

    expect(find.text('Income'), findsNWidgets(2));
    expect(find.text('Expense'), findsNWidgets(2));

    expect(find.text('Rp2.000.000'), findsNWidgets(2));
    expect(find.text('Rp850.000'), findsNWidgets(2));

    expect(find.text('Net'), findsOneWidget);
    expect(find.text('Rp1.150.000'), findsOneWidget);

    expect(find.text('Income vs Expense'), findsOneWidget);

    expect(find.text('Category Spending'), findsOneWidget);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Rp500.000'), findsOneWidget);
    expect(find.text('58.8%'), findsOneWidget);

    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
  });

  testWidgets('displays budget versus actual section', (tester) async {
    const summary = MonthlyFinancialSummary(
      year: 2026,
      month: 9,
      totalIncomeMinor: 2_000_000,
      totalExpenseMinor: 850_000,
      netAmountMinor: 1_150_000,
    );

    const categorySpending = [
      CategorySpending(
        categoryId: 'category-food',
        categoryName: 'Food',
        amountMinor: 350_000,
        percentage: 100.0,
      ),
    ];

    const budgetVsActual = [
      BudgetVsActual(
        budgetId: 'budget-1',
        categoryId: 'category-food',
        categoryName: 'Food',
        plannedAmountMinor: 1_000_000,
        actualAmountMinor: 600_000,
        remainingAmountMinor: 400_000,
        usagePercentage: 60.0,
      ),
    ];

    final period = DateTime(2026, 9);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monthlyFinancialSummaryNotifierProvider(period)
              .overrideWith(() => FakeMonthlyFinancialSummaryNotifier(summary)),
          categorySpendingNotifierProvider(
            period,
          ).overrideWith(() => FakeCategorySpendingNotifier(categorySpending)),
          budgetVsActualNotifierProvider('budget-1')
              .overrideWith(() => FakeBudgetVsActualNotifier(budgetVsActual)),
        ],
        child: MaterialApp(
          home: ReportsPage(period: period, budgetId: 'budget-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Monthly Summary'), findsOneWidget);
    expect(find.text('Income vs Expense'), findsOneWidget);
    expect(find.text('Category Spending'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Budget vs Actual'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Budget vs Actual'), findsOneWidget);
    expect(find.text('Food'), findsNWidgets(2));
    expect(find.text('Rp600.000'), findsOneWidget);
    expect(find.text('Planned: Rp1.000.000'), findsOneWidget);
    expect(find.text('Remaining: Rp400.000'), findsOneWidget);
    expect(find.text('60.0% used'), findsOneWidget);

    expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
  });

  testWidgets(
    'does not display budget versus actual section without a budget ID',
    (tester) async {
      const summary = MonthlyFinancialSummary(
        year: 2026,
        month: 9,
        totalIncomeMinor: 2_000_000,
        totalExpenseMinor: 850_000,
        netAmountMinor: 1_150_000,
      );

      final period = DateTime(2026, 9);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyFinancialSummaryNotifierProvider(
              period,
            ).overrideWith(() => FakeMonthlyFinancialSummaryNotifier(summary)),
            categorySpendingNotifierProvider(period)
                .overrideWith(() => FakeCategorySpendingNotifier(const [])),
          ],
          child: MaterialApp(home: ReportsPage(period: period)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Monthly Summary'), findsOneWidget);
      expect(find.text('Income vs Expense'), findsOneWidget);
      expect(find.text('Category Spending'), findsOneWidget);
      expect(find.text('Budget vs Actual'), findsNothing);
    },
  );
}

class FakeMonthlyFinancialSummaryNotifier
    extends MonthlyFinancialSummaryNotifier {
  FakeMonthlyFinancialSummaryNotifier(this._summary) : super(DateTime(2026, 9));

  final MonthlyFinancialSummary _summary;

  @override
  Future<MonthlyFinancialSummary> build() async {
    return _summary;
  }
}

class FakeCategorySpendingNotifier extends CategorySpendingNotifier {
  FakeCategorySpendingNotifier(this._items) : super(DateTime(2026, 9));

  final List<CategorySpending> _items;

  @override
  Future<List<CategorySpending>> build() async {
    return _items;
  }
}

class FakeBudgetVsActualNotifier extends BudgetVsActualNotifier {
  FakeBudgetVsActualNotifier(this._items) : super('budget-1');

  final List<BudgetVsActual> _items;

  @override
  Future<List<BudgetVsActual>> build() async {
    return _items;
  }
}
