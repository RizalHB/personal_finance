import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transaction_list_providers.dart';
import '../models/transaction_list_item_mapper.dart';
import '../providers/transaction_providers.dart';
import '../../domain/models/transaction_filter.dart';
import '../state/transaction_list_state.dart';

class TransactionListNotifier extends Notifier<TransactionListState> {
  @override
  TransactionListState build() {
    return const TransactionListInitial();
  }

  Future<void> search(TransactionFilter filter) async {
    state = const TransactionListLoading();

    try {
      final searchTransactions = ref.read(
        searchTransactionsWithDetailsProvider,
      );
      final results = await searchTransactions.execute(filter);

      if (results.isEmpty) {
        state = const TransactionListEmpty();
        return;
      }

      const mapper = TransactionListItemMapper();

      final items = results.map(mapper.mapSearchResult).toList();

      state = TransactionListLoaded(items);
    } catch (error) {
      state = TransactionListError(error.toString());
    }
  }

  Future<void> searchWithCurrentFilter() async {
    final filter = ref.read(transactionFilterNotifierProvider).toDomain();

    await search(filter);
  }
}
