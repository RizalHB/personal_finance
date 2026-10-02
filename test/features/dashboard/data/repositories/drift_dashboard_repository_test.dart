import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/dashboard/data/repositories/drift_dashboard_repository.dart';
import 'package:personal_finance/features/dashboard/domain/models/dashboard_summary.dart';

void main() {
  late db.AppDatabase database;
  late DriftDashboardRepository repository;

  setUp(() async {
    database = db.AppDatabase.test();
    repository = DriftDashboardRepository(database);

    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: 'ledger-cash',
            kind: 1,
            code: 'cash',
            name: 'Cash',
            isSystem: false,
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: 'ledger-income',
            kind: 3,
            code: 'salary',
            name: 'Salary',
            isSystem: false,
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: 'ledger-expense',
            kind: 4,
            code: 'food',
            name: 'Food',
            isSystem: false,
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.accounts)
        .insert(
          db.AccountsCompanion.insert(
            id: 'account-cash',
            ledgerAccountId: 'ledger-cash',
            name: 'Cash',
            financialClass: 1,
            accountType: 1,
            currencyCode: 'IDR',
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: 'category-income',
            ledgerAccountId: 'ledger-income',
            name: 'Salary',
            categoryType: 1,
            status: 1,
            sortOrder: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: 'category-food',
            ledgerAccountId: 'ledger-expense',
            name: 'Food',
            categoryType: 2,
            status: 1,
            sortOrder: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('returns balance and monthly financial summary', () async {
    final september1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;

    final october1 = DateTime(2026, 10, 1).millisecondsSinceEpoch;

    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: 'income-1',
            transactionType: 1,
            status: 1,
            transactionDate: september1,
            currencyCode: 'IDR',
            amountMinor: 5_000_000,
            accountId: const Value('account-cash'),
            categoryId: const Value('category-income'),
            merchantId: const Value(null),
            notes: const Value(null),
            relatedTransactionId: const Value(null),
            recurringTransactionId: const Value(null),
            createdAt: 1000,
            updatedAt: 1000,
            voidedAt: const Value(null),
          ),
        );

    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: 'expense-1',
            transactionType: 2,
            status: 1,
            transactionDate: september1,
            currencyCode: 'IDR',
            amountMinor: 1_500_000,
            accountId: const Value('account-cash'),
            categoryId: const Value('category-food'),
            merchantId: const Value(null),
            notes: const Value(null),
            relatedTransactionId: const Value(null),
            recurringTransactionId: const Value(null),
            createdAt: 1000,
            updatedAt: 1000,
            voidedAt: const Value(null),
          ),
        );

    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: 'expense-outside-month',
            transactionType: 2,
            status: 1,
            transactionDate: october1,
            currencyCode: 'IDR',
            amountMinor: 900_000,
            accountId: const Value('account-cash'),
            categoryId: const Value('category-food'),
            merchantId: const Value(null),
            notes: const Value(null),
            relatedTransactionId: const Value(null),
            recurringTransactionId: const Value(null),
            createdAt: 1000,
            updatedAt: 1000,
            voidedAt: const Value(null),
          ),
        );

    await database
        .into(database.ledgerEntries)
        .insert(
          db.LedgerEntriesCompanion.insert(
            id: 'ledger-entry-income',
            transactionId: 'income-1',
            ledgerAccountId: 'ledger-cash',
            entrySide: 1,
            amountMinor: 5_000_000,
            currencyCode: 'IDR',
            createdAt: 1000,
          ),
        );

    await database
        .into(database.ledgerEntries)
        .insert(
          db.LedgerEntriesCompanion.insert(
            id: 'ledger-entry-expense',
            transactionId: 'expense-1',
            ledgerAccountId: 'ledger-cash',
            entrySide: 2,
            amountMinor: 1_500_000,
            currencyCode: 'IDR',
            createdAt: 1000,
          ),
        );

    final summary = await repository.getSummary(year: 2026, month: 9);

    expect(summary, isA<DashboardSummary>());
    expect(summary.totalBalanceMinor, 3_500_000);
    expect(summary.monthlyIncomeMinor, 5_000_000);
    expect(summary.monthlyExpenseMinor, 1_500_000);
    expect(summary.monthlyNetMinor, 3_500_000);
  });

  test(
    'returns zero balance and zero monthly totals when database is empty',
    () async {
      final summary = await repository.getSummary(year: 2026, month: 9);

      expect(summary.totalBalanceMinor, 0);
      expect(summary.monthlyIncomeMinor, 0);
      expect(summary.monthlyExpenseMinor, 0);
      expect(summary.monthlyNetMinor, 0);
    },
  );
}
