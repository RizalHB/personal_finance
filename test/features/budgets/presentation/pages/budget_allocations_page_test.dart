import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/budget_dependencies.dart';
import 'package:personal_finance/features/budgets/domain/models/budget_overview.dart';
import 'package:personal_finance/features/budgets/presentation/models/budget_allocation_list_item.dart';
import 'package:personal_finance/features/budgets/presentation/notifiers/budget_allocation_notifier.dart';
import 'package:personal_finance/features/budgets/presentation/notifiers/budget_overview_notifier.dart';
import 'package:personal_finance/features/budgets/presentation/pages/budget_allocations_page.dart';
import 'package:personal_finance/features/budgets/presentation/state/budget_allocation_state.dart';
import 'package:personal_finance/features/categories/presentation/models/category_picker_item.dart';
import 'package:personal_finance/features/categories/presentation/notifiers/category_picker_notifier.dart';
import 'package:personal_finance/features/categories/presentation/state/category_picker_state.dart';

void main() {
  testWidgets('displays budget allocations', (tester) async {
    final allocationState = BudgetAllocationState(
      items: [
        const BudgetAllocationListItem(
          allocationId: 'allocation-1',
          categoryId: 'category-food',
          categoryName: 'Food',
          plannedAmountMinor: 1_000_000,
          actualAmountMinor: 250_000,
          remainingAmountMinor: 750_000,
          usagePercentage: 25.0,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetAllocationNotifierProvider(
            'budget-1',
          ).overrideWith(() => FakeBudgetAllocationNotifier(allocationState)),
          budgetOverviewNotifierProvider('budget-1')
              .overrideWith(() => FakeBudgetOverviewNotifier()),
          categoryPickerNotifierProvider.overrideWith(
            FakeCategoryPickerNotifier.new,
          ),
        ],
        child: const MaterialApp(
          home: BudgetAllocationsPage(budgetId: 'budget-1'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Budget Allocations'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Actual: Rp250.000'), findsOneWidget);
    expect(find.text('Remaining: Rp750.000'), findsOneWidget);
    expect(find.text('25.0% used'), findsOneWidget);
    expect(find.text('Rp1.000.000'), findsOneWidget);
  });

  testWidgets('displays empty state when there are no allocations', (
    tester,
  ) async {
    const allocationState = BudgetAllocationState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetAllocationNotifierProvider(
            'budget-1',
          ).overrideWith(() => FakeBudgetAllocationNotifier(allocationState)),
          budgetOverviewNotifierProvider('budget-1')
              .overrideWith(() => FakeBudgetOverviewNotifier()),
          categoryPickerNotifierProvider.overrideWith(
            FakeCategoryPickerNotifier.new,
          ),
        ],
        child: const MaterialApp(
          home: BudgetAllocationsPage(budgetId: 'budget-1'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No budget allocations yet.'), findsOneWidget);
  });
}

class FakeBudgetAllocationNotifier extends BudgetAllocationNotifier {
  FakeBudgetAllocationNotifier(this._state) : super('budget-1');

  final BudgetAllocationState _state;

  @override
  Future<BudgetAllocationState> build() async {
    return _state;
  }
}

class FakeBudgetOverviewNotifier extends BudgetOverviewNotifier {
  FakeBudgetOverviewNotifier() : super('budget-1');

  @override
  Future<BudgetOverview> build() async {
    return const BudgetOverview(
      budgetId: 'budget-1',
      year: 2026,
      month: 9,
      name: 'September Budget',
      totalPlannedAmountMinor: 0,
      totalActualAmountMinor: 0,
      totalRemainingAmountMinor: 0,
      usagePercentage: 0.0,
    );
  }
}

class FakeCategoryPickerNotifier extends CategoryPickerNotifier {
  @override
  Future<CategoryPickerState> build() async {
    return CategoryPickerState(
      items: [
        const CategoryPickerItem(categoryId: 'category-food', name: 'Food'),
      ],
    );
  }
}
