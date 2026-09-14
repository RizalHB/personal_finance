import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/application/use_cases/search_transactions.dart';
import 'package:personal_finance/features/transactions/data/repositories/transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/domain/models/transaction_filter.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction_split.dart';

class FakeTransactionRepository implements TransactionRepository {
  TransactionFilter? receivedFilter;

  final List<Transaction> result = [];

  @override
  Future<List<Transaction>> search(TransactionFilter filter) async {
    receivedFilter = filter;
    return result;
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Transaction> createSplitExpense({
    required String id,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required List<TransactionSplit> splits,
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Transaction?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Transaction>> watchRecent({int limit = 50}) {
    throw UnimplementedError();
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
  test('delegates filter to repository and returns result', () async {
    final repository = FakeTransactionRepository();

    const filter = TransactionFilter(
      type: TransactionType.expense,
      accountId: 'account-bca',
      minAmountMinor: 50000,
      limit: 20,
    );

    final useCase = SearchTransactions(repository);

    final result = await useCase.execute(filter);

    expect(identical(repository.receivedFilter, filter), isTrue);
    expect(result, same(repository.result));
  });
}
