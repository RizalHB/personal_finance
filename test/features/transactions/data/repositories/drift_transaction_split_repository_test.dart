import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart';
import 'package:personal_finance/features/transactions/data/repositories/drift_transaction_split_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction_split.dart'
    as domain;

void main() {
  late AppDatabase database;
  late DriftTransactionSplitRepository repository;

  setUp(() async {
    database = AppDatabase.test();
    repository = DriftTransactionSplitRepository(database);

    await database
        .into(database.ledgerAccounts)
        .insert(
          LedgerAccountsCompanion.insert(
            id: 'ledger-bca',
            kind: 1,
            code: 'account-bca',
            name: 'BCA',
            isSystem: false,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'account-bca',
            ledgerAccountId: 'ledger-bca',
            name: 'BCA',
            financialClass: 1,
            accountType: 2,
            currencyCode: 'IDR',
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.ledgerAccounts)
        .insert(
          LedgerAccountsCompanion.insert(
            id: 'ledger-food',
            kind: 4,
            code: 'expense-food',
            name: 'Food',
            isSystem: false,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'category-food',
            ledgerAccountId: 'ledger-food',
            name: 'Food',
            categoryType: 2,
            sortOrder: 0,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.ledgerAccounts)
        .insert(
          LedgerAccountsCompanion.insert(
            id: 'ledger-household',
            kind: 4,
            code: 'expense-household',
            name: 'Household',
            isSystem: false,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'category-household',
            ledgerAccountId: 'ledger-household',
            name: 'Household',
            categoryType: 2,
            sortOrder: 1,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.ledgerAccounts)
        .insert(
          LedgerAccountsCompanion.insert(
            id: 'ledger-salary',
            kind: 3,
            code: 'income-salary',
            name: 'Salary',
            isSystem: false,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'category-salary',
            ledgerAccountId: 'ledger-salary',
            name: 'Salary',
            categoryType: 1,
            sortOrder: 0,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'transaction-expense-1',
            transactionType: 2,
            status: 1,
            transactionDate: 1757548800000,
            currencyCode: 'IDR',
            amountMinor: 500000,
            accountId: const Value('account-bca'),
            categoryId: const Value('category-food'),
            merchantId: const Value(null),
            notes: const Value(null),
            relatedTransactionId: const Value(null),
            recurringTransactionId: const Value(null),
            createdAt: 1,
            updatedAt: 1,
            voidedAt: const Value(null),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and reads transaction splits', () async {
    final splits = [
      domain.TransactionSplit(
        id: 'split-food-1',
        transactionId: 'transaction-expense-1',
        categoryId: 'category-food',
        amountMinor: 350000,
        notes: 'Food',
        createdAt: 2,
        updatedAt: 2,
      ),
      domain.TransactionSplit(
        id: 'split-household-1',
        transactionId: 'transaction-expense-1',
        categoryId: 'category-household',
        amountMinor: 150000,
        notes: 'Household',
        createdAt: 3,
        updatedAt: 3,
      ),
    ];

    final result = await repository.replaceSplits(
      transactionId: 'transaction-expense-1',
      splits: splits,
    );

    expect(result, hasLength(2));
    expect(result[0].categoryId, 'category-food');
    expect(result[0].amountMinor, 350000);
    expect(result[1].categoryId, 'category-household');
    expect(result[1].amountMinor, 150000);
  });

  test('rejects splits whose total differs from transaction amount', () async {
    final splits = [
      domain.TransactionSplit(
        id: 'split-food-2',
        transactionId: 'transaction-expense-1',
        categoryId: 'category-food',
        amountMinor: 300000,
        notes: null,
        createdAt: 2,
        updatedAt: 2,
      ),
    ];

    expect(
      () => repository.replaceSplits(
        transactionId: 'transaction-expense-1',
        splits: splits,
      ),
      throwsA(isA<StateError>()),
    );

    final persisted = await repository.getByTransactionId(
      'transaction-expense-1',
    );

    expect(persisted, isEmpty);
  });

  test('rejects a non-expense category', () async {
    final splits = [
      domain.TransactionSplit(
        id: 'split-salary-1',
        transactionId: 'transaction-expense-1',
        categoryId: 'category-salary',
        amountMinor: 500000,
        notes: null,
        createdAt: 2,
        updatedAt: 2,
      ),
    ];

    expect(
      () => repository.replaceSplits(
        transactionId: 'transaction-expense-1',
        splits: splits,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('replaces an existing split set atomically', () async {
    await repository.replaceSplits(
      transactionId: 'transaction-expense-1',
      splits: [
        domain.TransactionSplit(
          id: 'split-food-3',
          transactionId: 'transaction-expense-1',
          categoryId: 'category-food',
          amountMinor: 500000,
          notes: null,
          createdAt: 2,
          updatedAt: 2,
        ),
      ],
    );

    await repository.replaceSplits(
      transactionId: 'transaction-expense-1',
      splits: [
        domain.TransactionSplit(
          id: 'split-food-4',
          transactionId: 'transaction-expense-1',
          categoryId: 'category-food',
          amountMinor: 300000,
          notes: null,
          createdAt: 3,
          updatedAt: 3,
        ),
        domain.TransactionSplit(
          id: 'split-household-2',
          transactionId: 'transaction-expense-1',
          categoryId: 'category-household',
          amountMinor: 200000,
          notes: null,
          createdAt: 4,
          updatedAt: 4,
        ),
      ],
    );

    final persisted = await repository.getByTransactionId(
      'transaction-expense-1',
    );

    expect(persisted, hasLength(2));
    expect(
      persisted.map((split) => split.amountMinor).reduce((a, b) => a + b),
      500000,
    );
  });

  test('rejects splits for a voided transaction', () async {
    await (database.update(
      database.transactions,
    )..where((tbl) => tbl.id.equals('transaction-expense-1'))).write(
      const TransactionsCompanion(
        status: Value(2),
        voidedAt: Value(1757548900000),
      ),
    );

    expect(
      () => repository.replaceSplits(
        transactionId: 'transaction-expense-1',
        splits: [
          domain.TransactionSplit(
            id: 'split-food-5',
            transactionId: 'transaction-expense-1',
            categoryId: 'category-food',
            amountMinor: 500000,
            notes: null,
            createdAt: 2,
            updatedAt: 2,
          ),
        ],
      ),
      throwsA(isA<StateError>()),
    );
  });
}
