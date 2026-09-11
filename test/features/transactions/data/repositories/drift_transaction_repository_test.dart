import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';

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

    expect(voided.status, TransactionStatus.voided);
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
}
