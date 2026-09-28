import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/budget_dependencies.dart';
import 'package:personal_finance/features/budgets/application/use_cases/get_budgets.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance/features/budgets/presentation/pages/budget_allocations_page.dart';
import 'package:personal_finance/features/budgets/presentation/pages/budgets_page.dart';

void main() {
  testWidgets('displays budgets and opens allocation page', (tester) async {
    final useCase = FakeGetBudgets([
      const Budget(
        id: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [getBudgetsProvider.overrideWithValue(useCase)],
        child: const MaterialApp(home: BudgetsPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('September Budget'), findsOneWidget);
    expect(find.text('2026-09'), findsOneWidget);

    await tester.tap(find.text('September Budget'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BudgetAllocationsPage), findsOneWidget);
  });
}

class FakeGetBudgets implements GetBudgets {
  FakeGetBudgets(this.budgets);

  final List<Budget> budgets;

  @override
  Future<List<Budget>> execute() async {
    return budgets;
  }
}
