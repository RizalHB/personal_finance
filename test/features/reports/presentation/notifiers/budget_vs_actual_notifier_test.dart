import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/application/report_dependencies.dart';
import 'package:personal_finance/features/reports/application/use_cases/get_budget_vs_actual.dart';
import 'package:personal_finance/features/reports/domain/models/budget_vs_actual.dart';
import 'package:personal_finance/features/reports/presentation/notifiers/budget_vs_actual_notifier.dart';

void main() {
  test('loads budget vs actual for the requested budget', () async {
    final useCase = FakeGetBudgetVsActual([
      const BudgetVsActual(
        budgetId: 'budget-1',
        categoryId: 'category-food',
        categoryName: 'Food',
        plannedAmountMinor: 1_000_000,
        actualAmountMinor: 750_000,
        remainingAmountMinor: 250_000,
        usagePercentage: 75.0,
      ),
      const BudgetVsActual(
        budgetId: 'budget-1',
        categoryId: 'category-transport',
        categoryName: 'Transport',
        plannedAmountMinor: 500_000,
        actualAmountMinor: 600_000,
        remainingAmountMinor: -100_000,
        usagePercentage: 120.0,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [getBudgetVsActualProvider.overrideWithValue(useCase)],
    );

    addTearDown(container.dispose);

    final state = await container.read(
      budgetVsActualNotifierProvider('budget-1').future,
    );

    expect(state, hasLength(2));

    expect(state[0].budgetId, 'budget-1');
    expect(state[0].categoryId, 'category-food');
    expect(state[0].categoryName, 'Food');
    expect(state[0].plannedAmountMinor, 1_000_000);
    expect(state[0].actualAmountMinor, 750_000);
    expect(state[0].remainingAmountMinor, 250_000);
    expect(state[0].usagePercentage, 75.0);

    expect(state[1].categoryId, 'category-transport');
    expect(state[1].actualAmountMinor, 600_000);
    expect(state[1].remainingAmountMinor, -100_000);
    expect(state[1].usagePercentage, 120.0);

    expect(useCase.requestedBudgetIds, ['budget-1']);
  });
}

class FakeGetBudgetVsActual implements GetBudgetVsActual {
  FakeGetBudgetVsActual(this.items);

  final List<BudgetVsActual> items;
  final List<String> requestedBudgetIds = [];

  @override
  Future<List<BudgetVsActual>> execute({required String budgetId}) async {
    requestedBudgetIds.add(budgetId);
    return items;
  }
}
