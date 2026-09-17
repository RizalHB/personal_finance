import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/transactions/domain/models/transaction_search_result.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/application/transaction_dependencies.dart';
import 'package:personal_finance/features/transactions/data/repositories/transaction_repository.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction_split.dart';
import 'package:personal_finance/features/transactions/domain/models/transaction_filter.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_list_providers.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_list_state.dart';
import 'package:personal_finance/features/transactions/data/repositories/transaction_details_search_repository.dart';

void main() {
  group('TransactionListNotifier', () {
    test('starts in initial state', () {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final state = container.read(transactionListNotifierProvider);

      expect(state, isA<TransactionListInitial>());
    });

    test('sets loaded state when search returns transactions', () async {
      final transaction = _buildTransaction();

      final repository = FakeTransactionRepository(result: [transaction]);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(transactionListNotifierProvider.notifier);

      await notifier.search(const TransactionFilter());

      final state = container.read(transactionListNotifierProvider);

      expect(state, isA<TransactionListLoaded>());
      final item = (state as TransactionListLoaded).transactions.single;

      expect(item.id, transaction.id);
      expect(item.amountMinor, transaction.amountMinor);
      expect(item.currencyCode, transaction.currencyCode);
    });

    test('sets empty state when search returns no transactions', () async {
      final repository = FakeTransactionRepository();

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(transactionListNotifierProvider.notifier);

      await notifier.search(const TransactionFilter());

      final state = container.read(transactionListNotifierProvider);

      expect(state, isA<TransactionListEmpty>());
    });

    test('sets error state when search fails', () async {
      final repository = FakeTransactionRepository(
        error: StateError('Search failed'),
      );

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(transactionListNotifierProvider.notifier);

      await notifier.search(const TransactionFilter());

      final state = container.read(transactionListNotifierProvider);

      expect(state, isA<TransactionListError>());
      expect(
        (state as TransactionListError).message,
        contains('Search failed'),
      );
    });
    test('searchWithCurrentFilter uses the current filter state', () async {
      TransactionFilter? receivedFilter;

      final repository = FakeTransactionRepository(
        result: [_buildTransaction()],
        onSearch: (filter) {
          receivedFilter = filter;
        },
      );

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );

      addTearDown(container.dispose);

      final filterNotifier = container.read(
        transactionFilterNotifierProvider.notifier,
      );

      filterNotifier.setType(TransactionType.expense);

      final notifier = container.read(transactionListNotifierProvider.notifier);

      await notifier.searchWithCurrentFilter();

      expect(receivedFilter, isNotNull);
      expect(receivedFilter!.type, TransactionType.expense);
    });
  });
}

Transaction _buildTransaction() {
  return const Transaction(
    id: 'transaction-1',
    type: TransactionType.expense,
    status: TransactionStatus.posted,
    transactionDate: 1000,
    currencyCode: 'IDR',
    amountMinor: 50000,
    accountId: 'account-bca',
    categoryId: 'category-food',
    merchantId: null,
    notes: 'Makan',
    relatedTransactionId: null,
    recurringTransactionId: null,
    createdAt: 1000,
    updatedAt: 1000,
    voidedAt: null,
  );
}

class FakeTransactionRepository
    implements TransactionRepository, TransactionDetailsSearchRepository {
  FakeTransactionRepository({
    this.result = const [],
    this.error,
    this.onSearch,
  });

  final List<Transaction> result;
  final Object? error;
  final void Function(TransactionFilter filter)? onSearch;

  @override
  Future<List<Transaction>> search(TransactionFilter filter) async {
    if (error != null) {
      throw error!;
    }

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

  @override
  Future<List<TransactionSearchResult>> searchWithDetails(
    TransactionFilter filter,
  ) async {
    if (error != null) {
      throw error!;
    }

    onSearch?.call(filter);

    return result
        .map((transaction) => TransactionSearchResult(transaction: transaction))
        .toList();
  }
}
