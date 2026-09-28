import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/budgets/application/use_cases/create_budget_allocation.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_allocation_repository.dart';
import 'package:personal_finance/features/budgets/data/repositories/budget_repository.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget_allocation.dart';
import 'package:personal_finance/features/budgets/domain/validators/budget_allocation_validator.dart';

void main() {
  late FakeBudgetRepository budgetRepository;
  late FakeBudgetAllocationRepository allocationRepository;
  late FakeIdGenerator idGenerator;
  late CreateBudgetAllocation useCase;

  setUp(() {
    budgetRepository = FakeBudgetRepository();
    allocationRepository = FakeBudgetAllocationRepository();
    idGenerator = FakeIdGenerator();

    useCase = CreateBudgetAllocation(
      budgetRepository,
      allocationRepository,
      const BudgetAllocationValidator(),
      idGenerator,
    );
  });

  test('creates allocation for an existing budget', () async {
    budgetRepository.budgets.add(
      const Budget(
        id: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final allocation = await useCase.execute(
      budgetId: ' budget-1 ',
      categoryId: ' category-food ',
      plannedAmountMinor: 1_500_000,
    );

    expect(allocation.id, 'allocation-1');
    expect(allocation.budgetId, 'budget-1');
    expect(allocation.categoryId, 'category-food');
    expect(allocation.plannedAmountMinor, 1_500_000);
    expect(allocation.createdAt, greaterThan(0));
    expect(allocation.updatedAt, allocation.createdAt);
    expect(allocationRepository.created, hasLength(1));
  });

  test(
    'rejects duplicate allocation for the same budget and category',
    () async {
      budgetRepository.budgets.add(
        const Budget(
          id: 'budget-1',
          year: 2026,
          month: 9,
          name: 'September Budget',
          status: BudgetStatus.active,
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );

      allocationRepository.allocations.add(
        const BudgetAllocation(
          id: 'allocation-existing',
          budgetId: 'budget-1',
          categoryId: 'category-food',
          plannedAmountMinor: 1_000_000,
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );

      expect(
        () => useCase.execute(
          budgetId: 'budget-1',
          categoryId: 'category-food',
          plannedAmountMinor: 1_500_000,
        ),
        throwsA(isA<StateError>()),
      );

      expect(allocationRepository.created, isEmpty);
    },
  );
}

class FakeIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() {
    _counter++;
    return 'allocation-$_counter';
  }
}

class FakeBudgetRepository implements BudgetRepository {
  final List<Budget> budgets = [];

  @override
  Future<Budget?> getByYearMonth({
    required int year,
    required int month,
  }) async {
    for (final budget in budgets) {
      if (budget.year == year && budget.month == month) {
        return budget;
      }
    }

    return null;
  }

  @override
  Future<Budget?> getById(String id) async {
    for (final budget in budgets) {
      if (budget.id == id) {
        return budget;
      }
    }

    return null;
  }

  @override
  Future<List<Budget>> getAll() async {
    return List.unmodifiable(budgets);
  }

  @override
  Future<Budget> create({required Budget budget}) async {
    budgets.add(budget);
    return budget;
  }

  @override
  Future<void> archive(String id) async {}

  @override
  Future<void> restore(String id) async {}
}

class FakeBudgetAllocationRepository implements BudgetAllocationRepository {
  final List<BudgetAllocation> allocations = [];
  final List<BudgetAllocation> created = [];

  @override
  Future<BudgetAllocation?> getById(String id) async {
    for (final allocation in allocations) {
      if (allocation.id == id) {
        return allocation;
      }
    }

    return null;
  }

  @override
  Future<List<BudgetAllocation>> getByBudgetId(String budgetId) async {
    return allocations
        .where((allocation) => allocation.budgetId == budgetId)
        .toList();
  }

  @override
  Future<BudgetAllocation?> getByBudgetAndCategory({
    required String budgetId,
    required String categoryId,
  }) async {
    for (final allocation in allocations) {
      if (allocation.budgetId == budgetId &&
          allocation.categoryId == categoryId) {
        return allocation;
      }
    }

    return null;
  }

  @override
  Future<BudgetAllocation> create({
    required BudgetAllocation allocation,
  }) async {
    allocations.add(allocation);
    created.add(allocation);
    return allocation;
  }

  @override
  Future<BudgetAllocation> update({
    required BudgetAllocation allocation,
  }) async {
    final index = allocations.indexWhere(
      (existing) => existing.id == allocation.id,
    );

    if (index == -1) {
      throw StateError('Allocation not found.');
    }

    allocations[index] = allocation;
    return allocation;
  }

  @override
  Future<void> delete(String id) async {
    allocations.removeWhere((allocation) => allocation.id == id);
  }
}
