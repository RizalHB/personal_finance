import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/budget_dependencies.dart';
import 'package:personal_finance/features/budgets/application/use_cases/get_budget_overview.dart';
import 'package:personal_finance/features/budgets/domain/models/budget_overview.dart';
import 'package:personal_finance/features/budgets/presentation/notifiers/budget_overview_notifier.dart';

void main() {
  test('loads the budget overview for the requested budget', () async {
    final useCase = FakeGetBudgetOverview(
      const BudgetOverview(
        budgetId: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        totalPlannedAmountMinor: 1_500_000,
        totalActualAmountMinor: 350_000,
        totalRemainingAmountMinor: 1_150_000,
        usagePercentage: 23.333333,
      ),
    );

    final container = ProviderContainer(
      overrides: [getBudgetOverviewProvider.overrideWithValue(useCase)],
    );

    addTearDown(container.dispose);

    final overview = await container.read(
      budgetOverviewNotifierProvider('budget-1').future,
    );

    expect(overview.budgetId, 'budget-1');
    expect(overview.year, 2026);
    expect(overview.month, 9);
    expect(overview.name, 'September Budget');
    expect(overview.totalPlannedAmountMinor, 1_500_000);
    expect(overview.totalActualAmountMinor, 350_000);
    expect(overview.totalRemainingAmountMinor, 1_150_000);
    expect(overview.usagePercentage, 23.333333);

    expect(useCase.requestedBudgetIds, ['budget-1']);
  });
}

class FakeGetBudgetOverview implements GetBudgetOverview {
  FakeGetBudgetOverview(this.overview);

  final BudgetOverview overview;
  final List<String> requestedBudgetIds = [];

  @override
  Future<BudgetOverview> execute({required String budgetId}) async {
    requestedBudgetIds.add(budgetId);
    return overview;
  }
}
