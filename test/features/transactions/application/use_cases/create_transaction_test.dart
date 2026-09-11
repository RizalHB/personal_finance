import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/transactions/application/use_cases/create_transaction.dart';
import 'package:personal_finance/features/transactions/data/repositories/transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/domain/services/transaction_validator.dart';

class _FakeIdGenerator implements IdGenerator {
  @override
  String generate() => 'transaction-1';
}

class _FakeTransactionRepository implements TransactionRepository {
  Transaction? createdTransaction;

  @override
  Future<Transaction?> getById(String id) async {
    return null;
  }

  @override
  Stream<List<Transaction>> watchRecent({int limit = 50}) {
    return const Stream.empty();
  }

  @override
  Future<Transaction> voidTransaction({
    required String id,
    required int voidedAt,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Transaction> createTransaction({
    required String id,
    required TransactionType type,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required String categoryId,
    String? merchantId,
    String? notes,
  }) async {
    final transaction = Transaction(
      id: id,
      type: type,
      status: TransactionStatus.posted,
      transactionDate: transactionDate,
      currencyCode: currencyCode,
      amountMinor: amountMinor,
      accountId: accountId,
      categoryId: categoryId,
      merchantId: merchantId,
      notes: notes,
      relatedTransactionId: null,
      recurringTransactionId: null,
      createdAt: transactionDate,
      updatedAt: transactionDate,
      voidedAt: null,
    );

    createdTransaction = transaction;
    return transaction;
  }
    @override
  Future<Transaction> createTransfer({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String fromAccountId,
    required String toAccountId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeTransactionRepository repository;
  late CreateTransaction createTransaction;

  setUp(() {
    repository = _FakeTransactionRepository();

    createTransaction = CreateTransaction(
      repository,
      const TransactionValidator(),
      _FakeIdGenerator(),
    );
  });

  test('creates a normalized expense transaction', () async {
    final transaction = await createTransaction.execute(
      type: TransactionType.expense,
      amountMinor: 75000,
      transactionDate: 1757548800000,
      currencyCode: ' idr ',
      accountId: ' account-1 ',
      categoryId: ' category-1 ',
      merchantId: ' merchant-1 ',
      notes: '  Lunch  ',
    );

    expect(transaction.id, 'transaction-1');
    expect(transaction.type, TransactionType.expense);
    expect(transaction.currencyCode, 'IDR');
    expect(transaction.accountId, 'account-1');
    expect(transaction.categoryId, 'category-1');
    expect(transaction.merchantId, 'merchant-1');
    expect(transaction.notes, 'Lunch');
  });

  test('converts blank optional fields to null', () async {
    final transaction = await createTransaction.execute(
      type: TransactionType.income,
      amountMinor: 5000000,
      transactionDate: 1757548800000,
      currencyCode: 'IDR',
      accountId: 'account-1',
      categoryId: 'category-1',
      merchantId: '   ',
      notes: '   ',
    );

    expect(transaction.merchantId, isNull);
    expect(transaction.notes, isNull);
  });

  test('does not call repository when validation fails', () {
    expect(
      () => createTransaction.execute(
        type: TransactionType.expense,
        amountMinor: 0,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        accountId: 'account-1',
        categoryId: 'category-1',
      ),
      throwsArgumentError,
    );

    expect(repository.createdTransaction, isNull);
  });
}
