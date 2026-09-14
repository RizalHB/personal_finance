import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final searchTransactions = ref.read(searchTransactionsProvider);
      final transactions = await searchTransactions.execute(filter);

      if (transactions.isEmpty) {
        state = const TransactionListEmpty();
        return;
      }

      state = TransactionListLoaded(transactions);
    } catch (error) {
      state = TransactionListError(error.toString());
    }
  }
}
