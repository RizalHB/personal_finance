import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/application/use_cases/get_budget_by_year_month.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';

class _FakeBudgetRepository implements BudgetRepository {
  Budget? budget;

  @override
  Future<Budget?> getByYearMonth({
    required int year,
    required int month,
  }) async {
    if (budget?.year == year && budget?.month == month) {
      return budget;
    }

    return null;
  }

  @override
  Future<Budget?> getById(String id) async => budget?.id == id ? budget : null;

  @override
  Future<List<Budget>> getAll() async {
    return [?budget];
  }

  @override
  Future<Budget> create({required Budget budget}) async {
    this.budget = budget;
    return budget;
  }

  @override
  Future<void> archive(String id) async {}

  @override
  Future<void> restore(String id) async {}
}

void main() {
  test('returns budget for the requested year and month', () async {
    final repository = _FakeBudgetRepository()
      ..budget = const Budget(
        id: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 1000,
        updatedAt: 1000,
      );

    final useCase = GetBudgetByYearMonth(repository);

    final result = await useCase.execute(year: 2026, month: 9);

    expect(result?.id, 'budget-1');
    expect(result?.name, 'September Budget');
  });

  test('returns null when no budget exists for the requested month', () async {
    final repository = _FakeBudgetRepository()
      ..budget = const Budget(
        id: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 1000,
        updatedAt: 1000,
      );

    final useCase = GetBudgetByYearMonth(repository);

    final result = await useCase.execute(year: 2026, month: 10);

    expect(result, isNull);
  });
}
