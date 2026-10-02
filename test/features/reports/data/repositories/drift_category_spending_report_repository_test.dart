import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/reports/data/repositories/drift_category_spending_report_repository.dart';

void main() {
  late db.AppDatabase database;
  late DriftCategorySpendingReportRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftCategorySpendingReportRepository(database);
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

  test('aggregates spending by category and calculates percentages', () async {
    await insertExpenseTransaction(
      id: 'food-expense',
      categoryId: 'category-food',
      amountMinor: 250_000,
      transactionDate: september1,
    );

    await insertExpenseTransaction(
      id: 'transport-expense',
      categoryId: 'category-transport',
      amountMinor: 750_000,
      transactionDate: september1,
    );

    final spending = await repository.getCategorySpendingForMonth(
      year: 2026,
      month: 9,
    );

    expect(spending, hasLength(2));

    expect(spending[0].categoryId, 'category-transport');
    expect(spending[0].categoryName, 'Transport');
    expect(spending[0].amountMinor, 750_000);
    expect(spending[0].percentage, 75.0);

    expect(spending[1].categoryId, 'category-food');
    expect(spending[1].categoryName, 'Food');
    expect(spending[1].amountMinor, 250_000);
    expect(spending[1].percentage, 25.0);
  });

  test('uses split amounts instead of parent transaction amount', () async {
    await insertExpenseTransaction(
      id: 'split-expense',
      categoryId: 'category-food',
      amountMinor: 1_000_000,
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

    final spending = await repository.getCategorySpendingForMonth(
      year: 2026,
      month: 9,
    );

    expect(spending, hasLength(2));

    final spendingByCategory = {
      for (final item in spending) item.categoryId: item,
    };

    expect(spendingByCategory['category-food']!.amountMinor, 300_000);
    expect(spendingByCategory['category-food']!.percentage, 60.0);

    expect(spendingByCategory['category-transport']!.amountMinor, 200_000);
    expect(spendingByCategory['category-transport']!.percentage, 40.0);
  });

  test(
    'excludes voided transactions, transfers, and transactions outside month',
    () async {
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

      await insertExpenseTransaction(
        id: 'october-expense',
        categoryId: 'category-food',
        amountMinor: 800_000,
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
              amountMinor: 2_000_000,
              accountId: const drift.Value('account-cash'),
              categoryId: const drift.Value(null),
              merchantId: const drift.Value(null),
              notes: const drift.Value(null),
              relatedTransactionId: const drift.Value(null),
              recurringTransactionId: const drift.Value(null),
              createdAt: 1000,
              updatedAt: 1000,
              voidedAt: const drift.Value(null),
            ),
          );

      final spending = await repository.getCategorySpendingForMonth(
        year: 2026,
        month: 9,
      );

      expect(spending, hasLength(1));
      expect(spending.single.categoryId, 'category-food');
      expect(spending.single.amountMinor, 100_000);
      expect(spending.single.percentage, 100.0);
    },
  );

  test('returns empty list when there is no expense spending', () async {
    final spending = await repository.getCategorySpendingForMonth(
      year: 2026,
      month: 9,
    );

    expect(spending, isEmpty);
  });
}
