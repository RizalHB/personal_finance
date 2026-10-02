import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/application/use_cases/get_category_spending.dart';
import 'package:personal_finance/features/reports/data/repositories/category_spending_report_repository.dart';
import 'package:personal_finance/features/reports/domain/models/category_spending.dart';

void main() {
  late FakeCategorySpendingReportRepository repository;
  late GetCategorySpending useCase;

  setUp(() {
    repository = FakeCategorySpendingReportRepository();
    useCase = GetCategorySpending(repository);
  });

  test('returns category spending from the repository', () async {
    repository.result = const [
      CategorySpending(
        categoryId: 'category-food',
        categoryName: 'Food',
        amountMinor: 1_500_000,
        percentage: 60.0,
      ),
      CategorySpending(
        categoryId: 'category-transport',
        categoryName: 'Transport',
        amountMinor: 1_000_000,
        percentage: 40.0,
      ),
    ];

    final result = await useCase.execute(year: 2026, month: 9);

    expect(result, hasLength(2));
    expect(result[0].categoryId, 'category-food');
    expect(result[0].categoryName, 'Food');
    expect(result[0].amountMinor, 1_500_000);
    expect(result[0].percentage, 60.0);

    expect(result[1].categoryId, 'category-transport');
    expect(result[1].categoryName, 'Transport');
    expect(result[1].amountMinor, 1_000_000);
    expect(result[1].percentage, 40.0);

    expect(repository.requestedYear, 2026);
    expect(repository.requestedMonth, 9);
  });

  test('returns an empty list when the repository has no spending', () async {
    repository.result = const [];

    final result = await useCase.execute(year: 2026, month: 9);

    expect(result, isEmpty);
    expect(repository.requestedYear, 2026);
    expect(repository.requestedMonth, 9);
  });

  test('rejects an invalid month', () {
    expect(
      () => useCase.execute(year: 2026, month: 13),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.requestedYear, isNull);
    expect(repository.requestedMonth, isNull);
  });

  test('rejects an invalid year', () {
    expect(
      () => useCase.execute(year: 0, month: 9),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.requestedYear, isNull);
    expect(repository.requestedMonth, isNull);
  });
}

class FakeCategorySpendingReportRepository
    implements CategorySpendingReportRepository {
  List<CategorySpending> result = const [];

  int? requestedYear;
  int? requestedMonth;

  @override
  Future<List<CategorySpending>> getCategorySpendingForMonth({
    required int year,
    required int month,
  }) async {
    requestedYear = year;
    requestedMonth = month;

    return result;
  }
}
