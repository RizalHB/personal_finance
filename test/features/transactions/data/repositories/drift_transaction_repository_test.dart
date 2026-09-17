import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart'
    as domain_transaction;
import 'package:personal_finance/features/transactions/domain/entities/transaction_split.dart'
    as domain;
import 'package:personal_finance/features/transactions/domain/models/transaction_filter.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_list_item_mapper.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_presentation.dart';

void main() {
  late AppDatabase database;
  late DriftTransactionRepository repository;

  setUp(() async {
    database = AppDatabase.test();
    repository = DriftTransactionRepository(database);

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
            id: 'ledger-savings',
            kind: 1,
            code: 'account-savings',
            name: 'Savings',
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
            id: 'account-savings',
            ledgerAccountId: 'ledger-savings',
            name: 'Savings',
            financialClass: 1,
            accountType: 4,
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
            sortOrder: 0,
            categoryType: 2,
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await database
        .into(database.ledgerAccounts)
        .insert(
          LedgerAccountsCompanion.insert(
            id: 'ledger-transport',
            kind: 4,
            code: 'expense-transport',
            name: 'Transport',
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
            id: 'category-transport',
            ledgerAccountId: 'ledger-transport',
            name: 'Transport',
            sortOrder: 0,
            categoryType: 2,
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
        .into(database.merchants)
        .insert(
          MerchantsCompanion.insert(
            id: 'merchant-tokopedia',
            name: 'Tokopedia',
            normalizedName: 'tokopedia',
            status: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('creates expense with balanced ledger entries', () async {
    final transaction = await repository.createTransaction(
      id: 'transaction-expense-1',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1757548800000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    expect(transaction.type, TransactionType.expense);
    expect(transaction.amountMinor, 50000);

    final entries = await database.select(database.ledgerEntries).get();

    expect(entries, hasLength(2));

    final debit = entries.singleWhere((entry) => entry.entrySide == 1);
    final credit = entries.singleWhere((entry) => entry.entrySide == 2);

    expect(debit.ledgerAccountId, 'ledger-food');
    expect(credit.ledgerAccountId, 'ledger-bca');
    expect(debit.amountMinor, 50000);
    expect(credit.amountMinor, 50000);
  });

  test('creates income with balanced ledger entries', () async {
    final transaction = await repository.createTransaction(
      id: 'transaction-income-1',
      type: TransactionType.income,
      amountMinor: 5000000,
      transactionDate: 1757548800000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-salary',
    );

    expect(transaction.type, TransactionType.income);
    expect(transaction.amountMinor, 5000000);

    final entries = await database.select(database.ledgerEntries).get();

    expect(entries, hasLength(2));

    final debit = entries.singleWhere((entry) => entry.entrySide == 1);
    final credit = entries.singleWhere((entry) => entry.entrySide == 2);

    expect(debit.ledgerAccountId, 'ledger-bca');
    expect(credit.ledgerAccountId, 'ledger-salary');
    expect(debit.amountMinor, 5000000);
    expect(credit.amountMinor, 5000000);
  });

  test('rejects category with wrong category type', () async {
    expect(
      () => repository.createTransaction(
        id: 'transaction-invalid-1',
        type: TransactionType.expense,
        amountMinor: 50000,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        accountId: 'account-bca',
        categoryId: 'category-salary',
      ),
      throwsStateError,
    );

    final transactions = await database.select(database.transactions).get();
    final entries = await database.select(database.ledgerEntries).get();

    expect(transactions, isEmpty);
    expect(entries, isEmpty);
  });

  test(
    'rejects transaction currency that differs from account currency',
    () async {
      expect(
        () => repository.createTransaction(
          id: 'transaction-invalid-2',
          type: TransactionType.expense,
          amountMinor: 50000,
          transactionDate: 1757548800000,
          currencyCode: 'USD',
          accountId: 'account-bca',
          categoryId: 'category-food',
        ),
        throwsStateError,
      );

      final transactions = await database.select(database.transactions).get();

      expect(transactions, isEmpty);
    },
  );

  test('getById returns the persisted transaction', () async {
    final transaction = await repository.createTransaction(
      id: 'transaction-read-1',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    final result = await repository.getById(transaction.id);

    expect(result, isNotNull);
    expect(result!.id, transaction.id);
    expect(result.amountMinor, 50000);
    expect(result.type, TransactionType.expense);
  });

  test('getById returns null when transaction does not exist', () async {
    final result = await repository.getById('does-not-exist');

    expect(result, isNull);
  });

  test('voids a transaction without deleting its ledger entries', () async {
    final transaction = await repository.createTransaction(
      id: 'transaction-void-1',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1757548800000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    final voided = await repository.voidTransaction(
      id: transaction.id,
      voidedAt: 1757548900000,
    );

    expect(voided.status, domain_transaction.TransactionStatus.voided);
    expect(voided.voidedAt, 1757548900000);

    final entries = await (database.select(
      database.ledgerEntries,
    )..where((tbl) => tbl.transactionId.equals(transaction.id))).get();

    expect(entries, hasLength(2));
  });

  test('throws when voiding a transaction that does not exist', () async {
    expect(
      () => repository.voidTransaction(
        id: 'transaction-missing',
        voidedAt: 1757548900000,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('throws when voiding an already voided transaction', () async {
    await repository.createTransaction(
      id: 'transaction-void-2',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 1757548800000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.voidTransaction(
      id: 'transaction-void-2',
      voidedAt: 1757548900000,
    );

    expect(
      () => repository.voidTransaction(
        id: 'transaction-void-2',
        voidedAt: 1757549000000,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('creates a transfer with balanced ledger entries', () async {
    final transaction = await repository.createTransfer(
      amountMinor: 1000000,
      transactionDate: 1757548800000,
      currencyCode: 'IDR',
      fromAccountId: 'account-bca',
      toAccountId: 'account-savings',
    );

    expect(transaction.type, TransactionType.transfer);
    expect(transaction.amountMinor, 1000000);
    expect(transaction.accountId, 'account-bca');
    expect(transaction.categoryId, isNull);

    final entries = await (database.select(
      database.ledgerEntries,
    )..where((tbl) => tbl.transactionId.equals(transaction.id))).get();

    expect(entries, hasLength(2));

    final debitEntries = entries
        .where((entry) => entry.entrySide == 1)
        .toList();
    final creditEntries = entries
        .where((entry) => entry.entrySide == 2)
        .toList();

    expect(debitEntries, hasLength(1));
    expect(creditEntries, hasLength(1));
    expect(debitEntries.single.amountMinor, 1000000);
    expect(creditEntries.single.amountMinor, 1000000);
    expect(debitEntries.single.ledgerAccountId, 'ledger-savings');
    expect(creditEntries.single.ledgerAccountId, 'ledger-bca');
  });

  test('rejects a transfer when currencies do not match', () async {
    await (database.update(database.accounts)
          ..where((tbl) => tbl.id.equals('account-savings')))
        .write(const AccountsCompanion(currencyCode: Value('USD')));

    expect(
      () => repository.createTransfer(
        amountMinor: 1000000,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        fromAccountId: 'account-bca',
        toAccountId: 'account-savings',
      ),
      throwsA(isA<StateError>()),
    );

    final transactions = await database.select(database.transactions).get();

    expect(transactions, isEmpty);
  });
  test(
    'creates split expense with null parent category and persisted splits',
    () async {
      final transaction = await repository.createSplitExpense(
        id: 'transaction-split-1',
        amountMinor: 100000,
        transactionDate: 1700000000000,
        currencyCode: 'IDR',
        accountId: 'account-bca',
        splits: [
          domain.TransactionSplit(
            id: 'split-food-1',
            transactionId: 'transaction-split-1',
            categoryId: 'category-food',
            amountMinor: 60000,
            notes: 'Lunch',
            createdAt: 1700000000000,
            updatedAt: 1700000000000,
          ),
          domain.TransactionSplit(
            id: 'split-transport-1',
            transactionId: 'transaction-split-1',
            categoryId: 'category-transport',
            amountMinor: 40000,
            notes: 'Taxi',
            createdAt: 1700000000000,
            updatedAt: 1700000000000,
          ),
        ],
      );

      expect(transaction.id, 'transaction-split-1');
      expect(transaction.amountMinor, 100000);
      expect(transaction.categoryId, isNull);

      final storedTransaction = await (database.select(
        database.transactions,
      )..where((tbl) => tbl.id.equals('transaction-split-1'))).getSingle();

      expect(storedTransaction.categoryId, isNull);
      expect(storedTransaction.transactionType, 2);

      final splits = await (database.select(
        database.transactionSplits,
      )..where((tbl) => tbl.transactionId.equals('transaction-split-1'))).get();

      expect(splits, hasLength(2));

      final splitAmounts = splits.map((split) => split.amountMinor).toList()
        ..sort();

      expect(splitAmounts, [40000, 60000]);
    },
  );
  test('creates balanced ledger entries for split expense', () async {
    await repository.createSplitExpense(
      id: 'transaction-split-2',
      amountMinor: 100000,
      transactionDate: 1700000000000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      splits: [
        domain.TransactionSplit(
          id: 'split-food-2',
          transactionId: 'transaction-split-2',
          categoryId: 'category-food',
          amountMinor: 60000,
          notes: null,
          createdAt: 1700000000000,
          updatedAt: 1700000000000,
        ),
        domain.TransactionSplit(
          id: 'split-transport-2',
          transactionId: 'transaction-split-2',
          categoryId: 'category-transport',
          amountMinor: 40000,
          notes: null,
          createdAt: 1700000000000,
          updatedAt: 1700000000000,
        ),
      ],
    );

    final entries = await (database.select(
      database.ledgerEntries,
    )..where((tbl) => tbl.transactionId.equals('transaction-split-2'))).get();

    expect(entries, hasLength(3));

    final debitEntries = entries
        .where((entry) => entry.entrySide == 1)
        .toList();

    final creditEntries = entries
        .where((entry) => entry.entrySide == 2)
        .toList();

    expect(debitEntries, hasLength(2));
    expect(creditEntries, hasLength(1));

    final debitTotal = debitEntries.fold<int>(
      0,
      (total, entry) => total + entry.amountMinor,
    );

    final creditTotal = creditEntries.fold<int>(
      0,
      (total, entry) => total + entry.amountMinor,
    );

    expect(debitTotal, 100000);
    expect(creditTotal, 100000);
    expect(debitTotal, creditTotal);

    expect(debitEntries.map((entry) => entry.amountMinor).toList()..sort(), [
      40000,
      60000,
    ]);

    expect(creditEntries.single.amountMinor, 100000);
    expect(creditEntries.single.ledgerAccountId, 'ledger-bca');
  });
  test('does not persist split expense when split total is invalid', () async {
    expect(
      () => repository.createSplitExpense(
        id: 'transaction-split-invalid',
        amountMinor: 100000,
        transactionDate: 1700000000000,
        currencyCode: 'IDR',
        accountId: 'account-bca',
        splits: [
          domain.TransactionSplit(
            id: 'split-invalid-1',
            transactionId: 'transaction-split-invalid',
            categoryId: 'category-food',
            amountMinor: 60000,
            notes: null,
            createdAt: 1700000000000,
            updatedAt: 1700000000000,
          ),
        ],
      ),
      throwsArgumentError,
    );

    final transaction =
        await (database.select(database.transactions)
              ..where((tbl) => tbl.id.equals('transaction-split-invalid')))
            .getSingleOrNull();

    expect(transaction, isNull);

    final splits =
        await (database.select(database.transactionSplits)..where(
              (tbl) => tbl.transactionId.equals('transaction-split-invalid'),
            ))
            .get();

    expect(splits, isEmpty);

    final entries =
        await (database.select(database.ledgerEntries)..where(
              (tbl) => tbl.transactionId.equals('transaction-split-invalid'),
            ))
            .get();

    expect(entries, isEmpty);
  });
  test(
    'does not persist split expense when a split category is invalid',
    () async {
      expect(
        () => repository.createSplitExpense(
          id: 'transaction-split-invalid-category',
          amountMinor: 100000,
          transactionDate: 1700000000000,
          currencyCode: 'IDR',
          accountId: 'account-bca',
          splits: [
            domain.TransactionSplit(
              id: 'split-valid-1',
              transactionId: 'transaction-split-invalid-category',
              categoryId: 'category-food',
              amountMinor: 60000,
              notes: null,
              createdAt: 1700000000000,
              updatedAt: 1700000000000,
            ),
            domain.TransactionSplit(
              id: 'split-invalid-category',
              transactionId: 'transaction-split-invalid-category',
              categoryId: 'category-does-not-exist',
              amountMinor: 40000,
              notes: null,
              createdAt: 1700000000000,
              updatedAt: 1700000000000,
            ),
          ],
        ),
        throwsStateError,
      );

      final transaction =
          await (database.select(database.transactions)..where(
                (tbl) => tbl.id.equals('transaction-split-invalid-category'),
              ))
              .getSingleOrNull();

      expect(transaction, isNull);

      final splits =
          await (database.select(database.transactionSplits)..where(
                (tbl) => tbl.transactionId.equals(
                  'transaction-split-invalid-category',
                ),
              ))
              .get();

      expect(splits, isEmpty);

      final entries =
          await (database.select(database.ledgerEntries)..where(
                (tbl) => tbl.transactionId.equals(
                  'transaction-split-invalid-category',
                ),
              ))
              .get();

      expect(entries, isEmpty);
    },
  );
  test('search filters transactions by type', () async {
    await repository.createTransaction(
      id: 'search-type-expense',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-type-income',
      type: TransactionType.income,
      amountMinor: 5000000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-salary',
    );

    final results = await repository.search(
      const TransactionFilter(type: TransactionType.expense),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'search-type-expense');
    expect(results.single.type, TransactionType.expense);
  });

  test('search filters transactions by account', () async {
    await repository.createTransaction(
      id: 'search-account-bca',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-account-savings',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-savings',
      categoryId: 'category-food',
    );

    final results = await repository.search(
      const TransactionFilter(accountId: 'account-savings'),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'search-account-savings');
  });

  test('search filters transactions by category', () async {
    await repository.createTransaction(
      id: 'search-category-food',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-category-transport',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-transport',
    );

    final results = await repository.search(
      const TransactionFilter(categoryId: 'category-transport'),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'search-category-transport');
  });

  test('search filters transactions by merchant', () async {
    await repository.createTransaction(
      id: 'search-merchant-match',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      merchantId: 'merchant-tokopedia',
    );

    await repository.createTransaction(
      id: 'search-merchant-other',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    final results = await repository.search(
      const TransactionFilter(merchantId: 'merchant-tokopedia'),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'search-merchant-match');
  });
  test('search matches text in notes and merchant name', () async {
    await repository.createTransaction(
      id: 'search-text-notes',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      notes: 'Belanja bulanan',
    );

    await repository.createTransaction(
      id: 'search-text-merchant',
      type: TransactionType.expense,
      amountMinor: 150000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      merchantId: 'merchant-tokopedia',
    );

    await repository.createTransaction(
      id: 'search-text-unrelated',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 3000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      notes: 'Makan siang',
    );

    final noteResults = await repository.search(
      const TransactionFilter(searchQuery: 'bulanan'),
    );

    expect(noteResults, hasLength(1));
    expect(noteResults.single.id, 'search-text-notes');

    final merchantResults = await repository.search(
      const TransactionFilter(searchQuery: 'Tokopedia'),
    );

    expect(merchantResults, hasLength(1));
    expect(merchantResults.single.id, 'search-text-merchant');
  });

  test('search filters transactions by date range', () async {
    await repository.createTransaction(
      id: 'search-date-before',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-date-inside',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-date-after',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 3000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    final results = await repository.search(
      const TransactionFilter(fromDate: 2000, toDate: 2000),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'search-date-inside');
  });

  test('search filters transactions by amount range', () async {
    await repository.createTransaction(
      id: 'search-amount-low',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-amount-inside',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-amount-high',
      type: TransactionType.expense,
      amountMinor: 200000,
      transactionDate: 3000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    final results = await repository.search(
      const TransactionFilter(minAmountMinor: 75000, maxAmountMinor: 150000),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'search-amount-inside');
  });

  test('search filters transactions by status', () async {
    await repository.createTransaction(
      id: 'search-status-posted',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-status-voided',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.voidTransaction(
      id: 'search-status-voided',
      voidedAt: 3000,
    );

    final postedResults = await repository.search(
      const TransactionFilter(
        status: domain_transaction.TransactionStatus.posted,
      ),
    );

    expect(postedResults, hasLength(1));
    expect(postedResults.single.id, 'search-status-posted');

    final voidedResults = await repository.search(
      const TransactionFilter(
        status: domain_transaction.TransactionStatus.voided,
      ),
    );

    expect(voidedResults, hasLength(1));
    expect(voidedResults.single.id, 'search-status-voided');
  });

  test('search combines multiple filters', () async {
    await repository.createTransaction(
      id: 'search-combined-match',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      merchantId: 'merchant-tokopedia',
      notes: 'Belanja bulanan',
    );

    await repository.createTransaction(
      id: 'search-combined-wrong-account',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-savings',
      categoryId: 'category-food',
      merchantId: 'merchant-tokopedia',
      notes: 'Belanja bulanan',
    );

    await repository.createTransaction(
      id: 'search-combined-wrong-date',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 5000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      merchantId: 'merchant-tokopedia',
      notes: 'Belanja bulanan',
    );

    final results = await repository.search(
      const TransactionFilter(
        type: TransactionType.expense,
        accountId: 'account-bca',
        categoryId: 'category-food',
        merchantId: 'merchant-tokopedia',
        fromDate: 1000,
        toDate: 3000,
        minAmountMinor: 50000,
        maxAmountMinor: 150000,
        searchQuery: 'bulanan',
      ),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'search-combined-match');
  });

  test('search orders by date and created time and respects limit', () async {
    await repository.createTransaction(
      id: 'search-limit-old',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-limit-new',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 3000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    await repository.createTransaction(
      id: 'search-limit-middle',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
    );

    final results = await repository.search(const TransactionFilter(limit: 2));

    expect(results, hasLength(2));
    expect(results.map((transaction) => transaction.id).toList(), [
      'search-limit-new',
      'search-limit-middle',
    ]);
  });

  test('search rejects invalid filter values', () async {
    expect(
      () => repository.search(const TransactionFilter(limit: 0)),
      throwsArgumentError,
    );

    expect(
      () => repository.search(const TransactionFilter(minAmountMinor: -1)),
      throwsArgumentError,
    );

    expect(
      () => repository.search(const TransactionFilter(maxAmountMinor: -1)),
      throwsArgumentError,
    );

    expect(
      () => repository.search(
        const TransactionFilter(minAmountMinor: 200000, maxAmountMinor: 100000),
      ),
      throwsArgumentError,
    );

    expect(
      () => repository.search(
        const TransactionFilter(fromDate: 3000, toDate: 2000),
      ),
      throwsArgumentError,
    );

    expect(
      () => repository.search(const TransactionFilter(fromDate: 0)),
      throwsArgumentError,
    );

    expect(
      () => repository.search(const TransactionFilter(toDate: 0)),
      throwsArgumentError,
    );
  });
  test('search treats SQL LIKE wildcards as literal text', () async {
    await repository.createTransaction(
      id: 'search-wildcard-percent',
      type: TransactionType.expense,
      amountMinor: 100000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      notes: 'Diskon 10%',
    );

    await repository.createTransaction(
      id: 'search-wildcard-underscore',
      type: TransactionType.expense,
      amountMinor: 50000,
      transactionDate: 2000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      notes: 'Kode ABC_123',
    );

    await repository.createTransaction(
      id: 'search-wildcard-unrelated',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 3000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      notes: 'Belanja biasa',
    );

    final percentResults = await repository.search(
      const TransactionFilter(searchQuery: '10%'),
    );

    expect(percentResults, hasLength(1));
    expect(percentResults.single.id, 'search-wildcard-percent');

    final underscoreResults = await repository.search(
      const TransactionFilter(searchQuery: 'ABC_123'),
    );

    expect(underscoreResults, hasLength(1));
    expect(underscoreResults.single.id, 'search-wildcard-underscore');
  });
  test('category filter finds split expense by split category', () async {
    final transaction = await repository.createSplitExpense(
      id: 'search-split-category',
      amountMinor: 150000,
      transactionDate: 4000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      splits: [
        domain.TransactionSplit(
          id: 'search-split-food',
          transactionId: 'search-split-category',
          categoryId: 'category-food',
          amountMinor: 100000,
          notes: null,
          createdAt: 4000,
          updatedAt: 4000,
        ),
        domain.TransactionSplit(
          id: 'search-split-transport',
          transactionId: 'search-split-category',
          categoryId: 'category-transport',
          amountMinor: 50000,
          notes: null,
          createdAt: 4000,
          updatedAt: 4000,
        ),
      ],
    );

    final results = await repository.search(
      const TransactionFilter(categoryId: 'category-transport'),
    );

    expect(results, hasLength(1));
    expect(results.single.id, transaction.id);
  });
  test('text search finds split expense by split category name', () async {
    final transaction = await repository.createSplitExpense(
      id: 'search-split-category-name',
      amountMinor: 150000,
      transactionDate: 5000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      splits: [
        domain.TransactionSplit(
          id: 'search-split-category-name-food',
          transactionId: 'search-split-category-name',
          categoryId: 'category-food',
          amountMinor: 100000,
          notes: null,
          createdAt: 5000,
          updatedAt: 5000,
        ),
        domain.TransactionSplit(
          id: 'search-split-category-name-transport',
          transactionId: 'search-split-category-name',
          categoryId: 'category-transport',
          amountMinor: 50000,
          notes: null,
          createdAt: 5000,
          updatedAt: 5000,
        ),
      ],
    );

    final results = await repository.search(
      const TransactionFilter(searchQuery: 'Transport'),
    );

    expect(results, hasLength(1));
    expect(results.single.id, transaction.id);
  });
  test('maps transaction to list item', () {
    final transaction = domain_transaction.Transaction(
      id: 'transaction-1',
      type: TransactionType.expense,
      status: domain_transaction.TransactionStatus.posted,
      transactionDate: 1,
      currencyCode: 'IDR',
      amountMinor: 50000,
      accountId: 'account-1',
      categoryId: 'category-1',
      merchantId: null,
      notes: null,
      relatedTransactionId: null,
      recurringTransactionId: null,
      createdAt: 1,
      updatedAt: 1,
      voidedAt: null,
    );

    const mapper = TransactionListItemMapper();

    final result = mapper.map(transaction);

    expect(result.id, 'transaction-1');
    expect(result.type, TransactionTypePresentation.expense);
    expect(result.currencyCode, 'IDR');
    expect(result.amountMinor, 50000);
    expect(result.transactionDate, 1);
  });
  test('searchWithDetails returns transaction metadata', () async {
    await repository.createTransaction(
      id: 'search-details',
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 1000,
      currencyCode: 'IDR',
      accountId: 'account-bca',
      categoryId: 'category-food',
      merchantId: 'merchant-tokopedia',
    );

    final results = await repository.searchWithDetails(
      const TransactionFilter(merchantId: 'merchant-tokopedia'),
    );

    expect(results, hasLength(1));

    final result = results.single;

    expect(result.transaction.id, 'search-details');
    expect(result.accountName, 'BCA');
    expect(result.categoryName, 'Food');
    expect(result.merchantName, 'Tokopedia');
  });
}
