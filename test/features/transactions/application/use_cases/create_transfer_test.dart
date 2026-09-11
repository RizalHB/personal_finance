import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/application/use_cases/create_transfer.dart';
import 'package:personal_finance/features/transactions/data/repositories/transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/domain/services/transaction_validator.dart';

class _FakeTransactionRepository implements TransactionRepository {
  String? receivedFromAccountId;
  String? receivedToAccountId;
  String? receivedCurrencyCode;
  int? receivedAmountMinor;

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
  Future<Transaction> createTransfer({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String fromAccountId,
    required String toAccountId,
  }) async {
    receivedAmountMinor = amountMinor;
    receivedCurrencyCode = currencyCode;
    receivedFromAccountId = fromAccountId;
    receivedToAccountId = toAccountId;

    return Transaction(
      id: 'transfer-1',
      type: TransactionType.transfer,
      status: TransactionStatus.posted,
      transactionDate: transactionDate,
      currencyCode: currencyCode,
      amountMinor: amountMinor,
      accountId: fromAccountId,
      categoryId: null,
      merchantId: null,
      notes: null,
      relatedTransactionId: null,
      recurringTransactionId: null,
      createdAt: transactionDate,
      updatedAt: transactionDate,
      voidedAt: null,
    );
  }

  @override
  Future<Transaction?> getById(String id) async {
    return null;
  }

  @override
  Stream<List<Transaction>> watchRecent({
    int limit = 50,
  }) {
    return const Stream.empty();
  }

  @override
  Future<Transaction> voidTransaction({
    required String id,
    required int voidedAt,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeTransactionRepository repository;
  late CreateTransfer createTransfer;

  setUp(() {
    repository = _FakeTransactionRepository();

    createTransfer = CreateTransfer(
      repository,
      const TransactionValidator(),
    );
  });

  test('creates a normalized transfer', () async {
    final transaction = await createTransfer.execute(
      amountMinor: 1000000,
      transactionDate: 1757548800000,
      currencyCode: ' idr ',
      fromAccountId: ' account-bca ',
      toAccountId: ' account-savings ',
    );

    expect(transaction.type, TransactionType.transfer);
    expect(transaction.amountMinor, 1000000);
    expect(repository.receivedCurrencyCode, 'IDR');
    expect(repository.receivedFromAccountId, 'account-bca');
    expect(repository.receivedToAccountId, 'account-savings');
  });

  test('rejects same source and destination account', () {
    expect(
      () => createTransfer.execute(
        amountMinor: 1000000,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        fromAccountId: 'account-bca',
        toAccountId: 'account-bca',
      ),
      throwsArgumentError,
    );

    expect(repository.receivedFromAccountId, isNull);
  });

  test('rejects zero amount', () {
    expect(
      () => createTransfer.execute(
        amountMinor: 0,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        fromAccountId: 'account-bca',
        toAccountId: 'account-savings',
      ),
      throwsArgumentError,
    );

    expect(repository.receivedFromAccountId, isNull);
  });
}