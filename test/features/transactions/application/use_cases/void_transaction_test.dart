import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/application/use_cases/void_transaction.dart';
import 'package:personal_finance/features/transactions/data/repositories/transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/domain/services/transaction_validator.dart';

class _FakeTransactionRepository implements TransactionRepository {
  String? receivedId;
  int? receivedVoidedAt;

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
  }) {
    throw UnimplementedError();
  }

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
    receivedId = id;
    receivedVoidedAt = voidedAt;

    return Transaction(
      id: id,
      type: TransactionType.expense,
      status: TransactionStatus.voided,
      transactionDate: 1757548800000,
      currencyCode: 'IDR',
      amountMinor: 50000,
      accountId: 'account-1',
      categoryId: 'category-1',
      merchantId: null,
      notes: null,
      relatedTransactionId: null,
      recurringTransactionId: null,
      createdAt: 1757548800000,
      updatedAt: 1757548900000,
      voidedAt: voidedAt,
    );
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
  late VoidTransaction voidTransaction;

  setUp(() {
    repository = _FakeTransactionRepository();

    voidTransaction = VoidTransaction(repository, const TransactionValidator());
  });

  test('voids a transaction with normalized id', () async {
    final transaction = await voidTransaction.execute(
      id: ' transaction-1 ',
      voidedAt: 1757548900000,
    );

    expect(transaction.status, TransactionStatus.voided);
    expect(transaction.voidedAt, 1757548900000);
    expect(repository.receivedId, 'transaction-1');
    expect(repository.receivedVoidedAt, 1757548900000);
  });

  test('rejects an empty transaction id', () {
    expect(
      () => voidTransaction.execute(id: '   ', voidedAt: 1757548900000),
      throwsArgumentError,
    );

    expect(repository.receivedId, isNull);
  });

  test('rejects an invalid voidedAt timestamp', () {
    expect(
      () => voidTransaction.execute(id: 'transaction-1', voidedAt: 0),
      throwsArgumentError,
    );

    expect(repository.receivedId, isNull);
  });
}
