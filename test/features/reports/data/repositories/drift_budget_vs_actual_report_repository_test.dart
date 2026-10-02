import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/reports/data/repositories/drift_budget_vs_actual_report_repository.dart';

void main() {
  late db.AppDatabase database;
  late DriftBudgetVsActualReportRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftBudgetVsActualReportRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertLedgerAccount({
    required String id,
    required String code,
    required String name,
    required int kind,
  }) async {
    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: id,
            kind: kind,
            code: code,
            name: name,
            isSystem: false,
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  Future<void> insertCategory({
    required String id,
    required String ledgerAccountId,
    required String name,
    required int sortOrder,
  }) async {
    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: id,
            ledgerAccountId: ledgerAccountId,
            name: name,
            categoryType: 2,
            status: 1,
            sortOrder: sortOrder,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  Future<void> insertAccount({
    required String id,
    required String ledgerAccountId,
    required String name,
  }) async {
    await database
        .into(database.accounts)
        .insert(
          db.AccountsCompanion.insert(
            id: id,
            ledgerAccountId: ledgerAccountId,
            name: name,
            financialClass: 1,
            accountType: 1,
            currencyCode: 'IDR',
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  Future<void> insertBudget() async {
    await database
        .into(database.budgets)
        .insert(
          db.BudgetsCompanion.insert(
            id: 'budget-1',
            year: 2026,
            month: 9,
            name: 'September Budget',
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  Future<void> insertAllocation({
    required String id,
    required String categoryId,
    required int plannedAmountMinor,
  }) async {
    await database
        .into(database.budgetAllocations)
        .insert(
          db.BudgetAllocationsCompanion.insert(
            id: id,
            budgetId: 'budget-1',
            categoryId: categoryId,
            plannedAmountMinor: plannedAmountMinor,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  Future<void> insertExpenseTransaction({
    required String id,
    required String categoryId,
    required int amountMinor,
    required int transactionDate,
    int status = 1,
  }) async {
    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: id,
            transactionType: 2,
            status: status,
            transactionDate: transactionDate,
            currencyCode: 'IDR',
            amountMinor: amountMinor,
            accountId: const drift.Value('account-cash'),
            categoryId: drift.Value(categoryId),
            merchantId: const drift.Value(null),
            notes: const drift.Value(null),
            relatedTransactionId: const drift.Value(null),
            recurringTransactionId: const drift.Value(null),
            createdAt: 1000,
            updatedAt: 1000,
            voidedAt: status == 2
                ? const drift.Value(2000)
                : const drift.Value(null),
          ),
        );
  }

  Future<void> insertSplit({
    required String id,
    required String transactionId,
    required String categoryId,
    required int amountMinor,
  }) async {
    await database
        .into(database.transactionSplits)
        .insert(
          db.TransactionSplitsCompanion.insert(
            id: id,
            transactionId: transactionId,
            categoryId: categoryId,
            amountMinor: amountMinor,
            notes: const drift.Value(null),
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  setUp(() async {
    await insertLedgerAccount(
      id: 'ledger-food',
      code: 'food',
      name: 'Food',
      kind: 4,
    );

    await insertLedgerAccount(
      id: 'ledger-transport',
      code: 'transport',
      name: 'Transport',
      kind: 4,
    );

    await insertLedgerAccount(
      id: 'ledger-cash',
      code: 'cash',
      name: 'Cash',
      kind: 1,
    );

    await insertCategory(
      id: 'category-food',
      ledgerAccountId: 'ledger-food',
      name: 'Food',
      sortOrder: 1,
    );

    await insertCategory(
      id: 'category-transport',
      ledgerAccountId: 'ledger-transport',
      name: 'Transport',
      sortOrder: 2,
    );

    await insertAccount(
      id: 'account-cash',
      ledgerAccountId: 'ledger-cash',
      name: 'Cash',
    );

    await insertBudget();
  });

  test(
    'returns planned, actual, remaining, and usage for allocations',
    () async {
      await insertAllocation(
        id: 'allocation-food',
        categoryId: 'category-food',
        plannedAmountMinor: 1_000_000,
      );

      await insertAllocation(
        id: 'allocation-transport',
        categoryId: 'category-transport',
        plannedAmountMinor: 500_000,
      );

      await insertExpenseTransaction(
        id: 'expense-food',
        categoryId: 'category-food',
        amountMinor: 250_000,
        transactionDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
      );

      await insertExpenseTransaction(
        id: 'expense-transport',
        categoryId: 'category-transport',
        amountMinor: 600_000,
        transactionDate: DateTime(2026, 9, 11).millisecondsSinceEpoch,
      );

      final result = await repository.getBudgetVsActual(budgetId: ' budget-1 ');

      expect(result, hasLength(2));

      final resultByCategory = {
        for (final item in result) item.categoryId: item,
      };

      final transport = resultByCategory['category-transport']!;

      expect(transport.categoryName, 'Transport');
      expect(transport.plannedAmountMinor, 500_000);
      expect(transport.actualAmountMinor, 600_000);
      expect(transport.remainingAmountMinor, -100_000);
      expect(transport.usagePercentage, 120.0);

      final food = resultByCategory['category-food']!;

      expect(food.categoryName, 'Food');
      expect(food.plannedAmountMinor, 1_000_000);
      expect(food.actualAmountMinor, 250_000);
      expect(food.remainingAmountMinor, 750_000);
      expect(food.usagePercentage, 25.0);
    },
  );

  test('includes allocations with no actual spending', () async {
    await insertAllocation(
      id: 'allocation-food',
      categoryId: 'category-food',
      plannedAmountMinor: 1_000_000,
    );

    final result = await repository.getBudgetVsActual(budgetId: 'budget-1');

    expect(result, hasLength(1));
    expect(result.single.actualAmountMinor, 0);
    expect(result.single.remainingAmountMinor, 1_000_000);
    expect(result.single.usagePercentage, 0.0);
  });

  test('uses split amounts instead of the parent transaction amount', () async {
    await insertAllocation(
      id: 'allocation-food',
      categoryId: 'category-food',
      plannedAmountMinor: 1_000_000,
    );

    await insertAllocation(
      id: 'allocation-transport',
      categoryId: 'category-transport',
      plannedAmountMinor: 500_000,
    );

    await insertExpenseTransaction(
      id: 'split-expense',
      categoryId: 'category-food',
      amountMinor: 500_000,
      transactionDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
    );

    await insertSplit(
      id: 'split-food',
      transactionId: 'split-expense',
      categoryId: 'category-food',
      amountMinor: 300_000,
    );

    await insertSplit(
      id: 'split-transport',
      transactionId: 'split-expense',
      categoryId: 'category-transport',
      amountMinor: 200_000,
    );

    final result = await repository.getBudgetVsActual(budgetId: 'budget-1');

    final resultByCategory = {for (final item in result) item.categoryId: item};

    expect(resultByCategory['category-food']!.actualAmountMinor, 300_000);
    expect(resultByCategory['category-food']!.remainingAmountMinor, 700_000);
    expect(resultByCategory['category-transport']!.actualAmountMinor, 200_000);
    expect(
      resultByCategory['category-transport']!.remainingAmountMinor,
      300_000,
    );
  });

  test('excludes voided expenses and non-expense transactions', () async {
    await insertAllocation(
      id: 'allocation-food',
      categoryId: 'category-food',
      plannedAmountMinor: 1_000_000,
    );

    await insertExpenseTransaction(
      id: 'posted-expense',
      categoryId: 'category-food',
      amountMinor: 100_000,
      transactionDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
    );

    await insertExpenseTransaction(
      id: 'voided-expense',
      categoryId: 'category-food',
      amountMinor: 900_000,
      transactionDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
      status: 2,
    );

    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: 'transfer',
            transactionType: 3,
            status: 1,
            transactionDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
            currencyCode: 'IDR',
            amountMinor: 500_000,
            accountId: const drift.Value('account-cash'),
            categoryId: drift.Value('category-food'),
            merchantId: const drift.Value(null),
            notes: const drift.Value(null),
            relatedTransactionId: const drift.Value(null),
            recurringTransactionId: const drift.Value(null),
            createdAt: 1000,
            updatedAt: 1000,
            voidedAt: const drift.Value(null),
          ),
        );

    final result = await repository.getBudgetVsActual(budgetId: 'budget-1');

    expect(result.single.actualAmountMinor, 100_000);
    expect(result.single.remainingAmountMinor, 900_000);
    expect(result.single.usagePercentage, 10.0);
  });

  test('rejects an empty budget ID', () async {
    expect(
      repository.getBudgetVsActual(budgetId: '   '),
      throwsA(isA<ArgumentError>()),
    );
  });
  test('ignores actuals outside the budget month', () async {
    await database
        .into(database.budgetAllocations)
        .insert(
          db.BudgetAllocationsCompanion.insert(
            id: 'allocation-food',
            budgetId: 'budget-1',
            categoryId: 'category-food',
            plannedAmountMinor: 1_000_000,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await insertExpenseTransaction(
      id: 'september-expense',
      categoryId: 'category-food',
      amountMinor: 250_000,
      transactionDate: DateTime(2026, 9, 15).millisecondsSinceEpoch,
    );

    await insertExpenseTransaction(
      id: 'october-expense',
      categoryId: 'category-food',
      amountMinor: 900_000,
      transactionDate: DateTime(2026, 10, 1).millisecondsSinceEpoch,
    );

    final result = await repository.getBudgetVsActual(budgetId: 'budget-1');

    expect(result, hasLength(1));

    final item = result.single;

    expect(item.categoryId, 'category-food');
    expect(item.categoryName, 'Food');
    expect(item.plannedAmountMinor, 1_000_000);
    expect(item.actualAmountMinor, 250_000);
    expect(item.remainingAmountMinor, 750_000);
    expect(item.usagePercentage, 25.0);
  });
}
