import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/budgets/data/repositories/drift_budget_actual_repository.dart';
import 'package:drift/drift.dart';

void main() {
  late db.AppDatabase database;
  late DriftBudgetActualRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftBudgetActualRepository(database);
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
            accountId: const Value('account-cash'),
            categoryId: Value(categoryId),
            merchantId: const Value(null),
            notes: const Value(null),
            relatedTransactionId: const Value(null),
            recurringTransactionId: const Value(null),
            createdAt: 1000,
            updatedAt: 1000,
            voidedAt: status == 2 ? const Value(2000) : const Value(null),
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
            notes: const Value(null),
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  final september1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;
  final october1 = DateTime(2026, 10, 1).millisecondsSinceEpoch;

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
  });

  test('aggregates posted normal expenses by category', () async {
    await insertExpenseTransaction(
      id: 'expense-1',
      categoryId: 'category-food',
      amountMinor: 100_000,
      transactionDate: september1,
    );

    await insertExpenseTransaction(
      id: 'expense-2',
      categoryId: 'category-food',
      amountMinor: 150_000,
      transactionDate: september1,
    );

    await insertExpenseTransaction(
      id: 'expense-3',
      categoryId: 'category-transport',
      amountMinor: 75_000,
      transactionDate: september1,
    );

    final actuals = await repository.getActualsForMonth(year: 2026, month: 9);

    expect(actuals, hasLength(2));

    final actualsByCategory = {
      for (final actual in actuals) actual.categoryId: actual.actualAmountMinor,
    };

    expect(actualsByCategory['category-food'], 250_000);
    expect(actualsByCategory['category-transport'], 75_000);
  });

  test('uses split amounts instead of the parent transaction amount', () async {
    await insertExpenseTransaction(
      id: 'split-expense',
      categoryId: 'category-food',
      amountMinor: 500_000,
      transactionDate: september1,
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

    final actuals = await repository.getActualsForMonth(year: 2026, month: 9);

    final actualsByCategory = {
      for (final actual in actuals) actual.categoryId: actual.actualAmountMinor,
    };

    expect(actualsByCategory['category-food'], 300_000);
    expect(actualsByCategory['category-transport'], 200_000);
  });

  test('excludes voided expenses', () async {
    await insertExpenseTransaction(
      id: 'posted-expense',
      categoryId: 'category-food',
      amountMinor: 100_000,
      transactionDate: september1,
    );

    await insertExpenseTransaction(
      id: 'voided-expense',
      categoryId: 'category-food',
      amountMinor: 900_000,
      transactionDate: september1,
      status: 2,
    );

    final actuals = await repository.getActualsForMonth(year: 2026, month: 9);

    expect(actuals, hasLength(1));
    expect(actuals.single.actualAmountMinor, 100_000);
  });

  test(
    'excludes transfers and transactions outside the requested month',
    () async {
      await insertExpenseTransaction(
        id: 'september-expense',
        categoryId: 'category-food',
        amountMinor: 100_000,
        transactionDate: september1,
      );

      await insertExpenseTransaction(
        id: 'october-expense',
        categoryId: 'category-food',
        amountMinor: 900_000,
        transactionDate: october1,
      );

      await database
          .into(database.transactions)
          .insert(
            db.TransactionsCompanion.insert(
              id: 'transfer',
              transactionType: 3,
              status: 1,
              transactionDate: september1,
              currencyCode: 'IDR',
              amountMinor: 500_000,
              accountId: const Value('account-cash'),
              categoryId: const Value(null),
              merchantId: const Value(null),
              notes: const Value(null),
              relatedTransactionId: const Value(null),
              recurringTransactionId: const Value(null),
              createdAt: 1000,
              updatedAt: 1000,
              voidedAt: const Value(null),
            ),
          );

      final actuals = await repository.getActualsForMonth(year: 2026, month: 9);

      expect(actuals, hasLength(1));
      expect(actuals.single.categoryId, 'category-food');
      expect(actuals.single.actualAmountMinor, 100_000);
    },
  );
}
