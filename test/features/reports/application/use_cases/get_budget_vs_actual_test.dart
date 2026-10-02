import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/application/use_cases/get_budget_vs_actual.dart';
import 'package:personal_finance/features/reports/data/repositories/budget_vs_actual_report_repository.dart';
import 'package:personal_finance/features/reports/domain/models/budget_vs_actual.dart';

void main() {
  late FakeBudgetVsActualReportRepository repository;
  late GetBudgetVsActual useCase;

  setUp(() {
    repository = FakeBudgetVsActualReportRepository();
    useCase = GetBudgetVsActual(repository);
  });

  test('returns budget vs actual data from repository', () async {
    repository.result = const [
      BudgetVsActual(
        budgetId: 'budget-1',
        categoryId: 'category-food',
        categoryName: 'Food',
        plannedAmountMinor: 1_000_000,
        actualAmountMinor: 750_000,
        remainingAmountMinor: 250_000,
        usagePercentage: 75.0,
      ),
      BudgetVsActual(
        budgetId: 'budget-1',
        categoryId: 'category-transport',
        categoryName: 'Transport',
        plannedAmountMinor: 500_000,
        actualAmountMinor: 600_000,
        remainingAmountMinor: -100_000,
        usagePercentage: 120.0,
      ),
    ];

    final result = await useCase.execute(budgetId: ' budget-1 ');

    expect(result, hasLength(2));

    expect(result[0].categoryId, 'category-food');
    expect(result[0].plannedAmountMinor, 1_000_000);
    expect(result[0].actualAmountMinor, 750_000);
    expect(result[0].remainingAmountMinor, 250_000);
    expect(result[0].usagePercentage, 75.0);

    expect(result[1].categoryId, 'category-transport');
    expect(result[1].plannedAmountMinor, 500_000);
    expect(result[1].actualAmountMinor, 600_000);
    expect(result[1].remainingAmountMinor, -100_000);
    expect(result[1].usagePercentage, 120.0);

    expect(repository.requestedBudgetId, 'budget-1');
  });

  test('returns an empty list when there are no budget allocations', () async {
    final result = await useCase.execute(budgetId: 'budget-1');

    expect(result, isEmpty);
    expect(repository.requestedBudgetId, 'budget-1');
  });

  test('rejects an empty budget ID', () {
    expect(
      () => useCase.execute(budgetId: '   '),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.requestedBudgetId, isNull);
  });
}

class FakeBudgetVsActualReportRepository
    implements BudgetVsActualReportRepository {
  List<BudgetVsActual> result = const [];
  String? requestedBudgetId;

  @override
  Future<List<BudgetVsActual>> getBudgetVsActual({
    required String budgetId,
  }) async {
    requestedBudgetId = budgetId;
    return result;
  }
}
