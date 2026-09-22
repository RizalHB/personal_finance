import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/application/transaction_dependencies.dart';
import 'package:personal_finance/features/transactions/data/repositories/transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction_split.dart';
import 'package:personal_finance/features/transactions/domain/models/transaction_filter.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_detail_providers.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_detail_state.dart';

void main() {
  group('TransactionDetailNotifier', () {
    test('loads transaction successfully', () async {
      final repository = _FakeTransactionRepository(
        transaction: _transaction(),
      );

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        transactionDetailNotifierProvider.notifier,
      );

      await notifier.load('transaction-1');

      expect(notifier.state, isA<TransactionDetailLoaded>());

      final state = notifier.state as TransactionDetailLoaded;
      expect(state.transaction.id, 'transaction-1');
    });

    test('reports not found when transaction does not exist', () async {
      final repository = _FakeTransactionRepository();

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        transactionDetailNotifierProvider.notifier,
      );

      await notifier.load('missing');

      expect(notifier.state, isA<TransactionDetailNotFound>());
    });

    test('reports error when loading fails', () async {
      final repository = _FakeTransactionRepository(
        error: StateError('load failed'),
      );

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        transactionDetailNotifierProvider.notifier,
      );

      await notifier.load('transaction-1');

      expect(notifier.state, isA<TransactionDetailError>());

      final state = notifier.state as TransactionDetailError;
      expect(state.message, contains('load failed'));
    });
  });
}

Transaction _transaction() {
  return Transaction(
    id: 'transaction-1',
    type: TransactionType.expense,
    status: TransactionStatus.posted,
    transactionDate: DateTime(2026, 9, 1).millisecondsSinceEpoch,
    currencyCode: 'IDR',
    amountMinor: 50000,
    accountId: 'account-1',
    categoryId: 'category-1',
    merchantId: null,
    notes: null,
    relatedTransactionId: null,
    recurringTransactionId: null,
    createdAt: DateTime(2026, 9, 1).millisecondsSinceEpoch,
    updatedAt: DateTime(2026, 9, 1).millisecondsSinceEpoch,
    voidedAt: null,
  );
}

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository({this.transaction, this.error});

  final Transaction? transaction;
  final Object? error;

  @override
  Future<Transaction?> getById(String id) async {
    if (error != null) {
      throw error!;
    }

    return transaction;
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
  Stream<List<Transaction>> watchRecent({int limit = 50}) {
    return const Stream.empty();
  }

  @override
  Future<List<Transaction>> search(TransactionFilter filter) {
    throw UnimplementedError();
  }

  @override
  Future<Transaction> voidTransaction({
    required String id,
    required int voidedAt,
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
}
