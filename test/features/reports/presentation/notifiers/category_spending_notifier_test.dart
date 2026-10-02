import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/application/report_dependencies.dart';
import 'package:personal_finance/features/reports/application/use_cases/get_category_spending.dart';
import 'package:personal_finance/features/reports/domain/models/category_spending.dart';
import 'package:personal_finance/features/reports/presentation/notifiers/category_spending_notifier.dart';

void main() {
  test('loads category spending for the requested month', () async {
    final useCase = FakeGetCategorySpending([
      const CategorySpending(
        categoryId: 'category-food',
        categoryName: 'Food',
        amountMinor: 750_000,
        percentage: 60.0,
      ),
      const CategorySpending(
        categoryId: 'category-transport',
        categoryName: 'Transport',
        amountMinor: 500_000,
        percentage: 40.0,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [getCategorySpendingProvider.overrideWithValue(useCase)],
    );

    addTearDown(container.dispose);

    final state = await container.read(
      categorySpendingNotifierProvider(DateTime(2026, 9)).future,
    );

    expect(state, hasLength(2));

    expect(state[0].categoryId, 'category-food');
    expect(state[0].categoryName, 'Food');
    expect(state[0].amountMinor, 750_000);
    expect(state[0].percentage, 60.0);

    expect(state[1].categoryId, 'category-transport');
    expect(state[1].categoryName, 'Transport');
    expect(state[1].amountMinor, 500_000);
    expect(state[1].percentage, 40.0);

    expect(useCase.requestedPeriods, [DateTime(2026, 9)]);
  });
}

class FakeGetCategorySpending implements GetCategorySpending {
  FakeGetCategorySpending(this.items);

  final List<CategorySpending> items;
  final List<DateTime> requestedPeriods = [];

  @override
  Future<List<CategorySpending>> execute({
    required int year,
    required int month,
  }) async {
    requestedPeriods.add(DateTime(year, month));
    return items;
  }
}
