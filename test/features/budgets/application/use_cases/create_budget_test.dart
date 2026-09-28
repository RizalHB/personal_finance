import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/budgets/application/use_cases/create_budget.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance/features/budgets/domain/validators/budget_validator.dart';

class _FakeIdGenerator implements IdGenerator {
  @override
  String generate() => 'budget-1';
}

class _FakeBudgetRepository implements BudgetRepository {
  Budget? existingBudget;
  Budget? createdBudget;

  @override
  Future<Budget?> getByYearMonth({
    required int year,
    required int month,
  }) async {
    return existingBudget;
  }

  @override
  Future<Budget?> getById(String id) async => createdBudget;

  @override
  Future<List<Budget>> getAll() async {
    return [?createdBudget];
  }

  @override
  Future<Budget> create({required Budget budget}) async {
    createdBudget = budget;
    return budget;
  }

  @override
  Future<void> archive(String id) async {}

  @override
  Future<void> restore(String id) async {}
}

void main() {
  test('creates an active budget with normalized name', () async {
    final repository = _FakeBudgetRepository();
    final createBudget = CreateBudget(
      repository,
      const BudgetValidator(),
      _FakeIdGenerator(),
    );

    final result = await createBudget.execute(
      year: 2026,
      month: 9,
      name: '  September Budget  ',
    );

    expect(result.id, 'budget-1');
    expect(result.year, 2026);
    expect(result.month, 9);
    expect(result.name, 'September Budget');
    expect(result.status, BudgetStatus.active);
    expect(repository.createdBudget, same(result));
  });

  test('rejects duplicate budget for the same year and month', () async {
    final repository = _FakeBudgetRepository()
      ..existingBudget = Budget(
        id: 'existing',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 0,
        updatedAt: 0,
      );

    final createBudget = CreateBudget(
      repository,
      const BudgetValidator(),
      _FakeIdGenerator(),
    );

    expect(
      () => createBudget.execute(year: 2026, month: 9, name: 'Another Budget'),
      throwsA(isA<StateError>()),
    );
  });
}
