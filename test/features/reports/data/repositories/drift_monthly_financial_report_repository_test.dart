import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/reports/data/repositories/drift_monthly_financial_report_repository.dart';

void main() {
  late db.AppDatabase database;
  late DriftMonthlyFinancialReportRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftMonthlyFinancialReportRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  final september1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;
  final october1 = DateTime(2026, 10, 1).millisecondsSinceEpoch;

  Future<void> insertTransaction({
    required String id,
    required int transactionType,
    required int amountMinor,
    required int transactionDate,
    int status = 1,
    String? categoryId,
  }) async {
    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: id,
            transactionType: transactionType,
            status: status,
            transactionDate: transactionDate,
            currencyCode: 'IDR',
            amountMinor: amountMinor,
            accountId: const drift.Value(null),
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

  Future<void> insertCategory({
    required String id,
    required String name,
  }) async {
    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: 'ledger-$id',
            kind: 4,
            code: id,
            name: name,
            isSystem: false,
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: id,
            ledgerAccountId: 'ledger-$id',
            name: name,
            categoryType: 2,
            status: 1,
            sortOrder: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  }

  test('aggregates monthly income and expenses using split amounts', () async {
    await insertCategory(id: 'category-food', name: 'Food');

    await insertCategory(id: 'category-transport', name: 'Transport');

    await insertTransaction(
      id: 'income-1',
      transactionType: 1,
      amountMinor: 5_000_000,
      transactionDate: september1,
    );

    await insertTransaction(
      id: 'expense-1',
      transactionType: 2,
      amountMinor: 250_000,
      transactionDate: september1,
      categoryId: 'category-food',
    );

    await insertTransaction(
      id: 'split-expense',
      transactionType: 2,
      amountMinor: 700_000,
      transactionDate: september1,
      categoryId: 'category-food',
    );

    await insertSplit(
      id: 'split-food',
      transactionId: 'split-expense',
      categoryId: 'category-food',
      amountMinor: 400_000,
    );

    await insertSplit(
      id: 'split-transport',
      transactionId: 'split-expense',
      categoryId: 'category-transport',
      amountMinor: 100_000,
    );

    final summary = await repository.getMonthlySummary(year: 2026, month: 9);

    expect(summary.year, 2026);
    expect(summary.month, 9);
    expect(summary.totalIncomeMinor, 5_000_000);
    expect(summary.totalExpenseMinor, 750_000);
    expect(summary.netAmountMinor, 4_250_000);
  });

  test(
    'excludes voided transactions, transfers, and transactions outside month',
    () async {
      await insertCategory(id: 'category-food', name: 'Food');

      await insertTransaction(
        id: 'posted-expense',
        transactionType: 2,
        amountMinor: 100_000,
        transactionDate: september1,
        categoryId: 'category-food',
      );

      await insertTransaction(
        id: 'voided-expense',
        transactionType: 2,
        amountMinor: 900_000,
        transactionDate: september1,
        status: 2,
        categoryId: 'category-food',
      );

      await insertTransaction(
        id: 'transfer',
        transactionType: 3,
        amountMinor: 2_000_000,
        transactionDate: september1,
      );

      await insertTransaction(
        id: 'october-expense',
        transactionType: 2,
        amountMinor: 800_000,
        transactionDate: october1,
        categoryId: 'category-food',
      );

      final summary = await repository.getMonthlySummary(year: 2026, month: 9);

      expect(summary.totalIncomeMinor, 0);
      expect(summary.totalExpenseMinor, 100_000);
      expect(summary.netAmountMinor, -100_000);
    },
  );

  test(
    'returns zero totals when month has no reportable transactions',
    () async {
      final summary = await repository.getMonthlySummary(year: 2026, month: 9);

      expect(summary.totalIncomeMinor, 0);
      expect(summary.totalExpenseMinor, 0);
      expect(summary.netAmountMinor, 0);
    },
  );
}
