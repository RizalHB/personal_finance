import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/recurring_dependencies.dart';
import '../models/recurring_transaction_list_item_mapper.dart';
import '../state/recurring_transaction_state.dart';

class RecurringTransactionNotifier
    extends AsyncNotifier<RecurringTransactionState> {
  @override
  Future<RecurringTransactionState> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_load);
  }

  Future<RecurringTransactionState> _load() async {
    final useCase = ref.read(getRecurringTransactionsProvider);
    const mapper = RecurringTransactionListItemMapper();

    final transactions = await useCase.execute();

    return RecurringTransactionState(items: mapper.mapList(transactions));
  }
}

final recurringTransactionNotifierProvider =
    AsyncNotifierProvider<
      RecurringTransactionNotifier,
      RecurringTransactionState
    >(RecurringTransactionNotifier.new);
