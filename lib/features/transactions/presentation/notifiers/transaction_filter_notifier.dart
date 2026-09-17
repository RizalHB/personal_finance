import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../state/transaction_filter_state.dart';

class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() {
    return const TransactionFilterState();
  }

  void setType(TransactionType? type) {
    state = TransactionFilterState(
      type: type,
      fromDate: state.fromDate,
      toDate: state.toDate,
      minAmountMinor: state.minAmountMinor,
      maxAmountMinor: state.maxAmountMinor,
      searchQuery: state.searchQuery,
    );
  }

  void setDateRange({int? fromDate, int? toDate}) {
    state = TransactionFilterState(
      type: state.type,
      fromDate: fromDate,
      toDate: toDate,
      minAmountMinor: state.minAmountMinor,
      maxAmountMinor: state.maxAmountMinor,
      searchQuery: state.searchQuery,
    );
  }

  void setAmountRange({int? minAmountMinor, int? maxAmountMinor}) {
    state = TransactionFilterState(
      type: state.type,
      fromDate: state.fromDate,
      toDate: state.toDate,
      minAmountMinor: minAmountMinor,
      maxAmountMinor: maxAmountMinor,
      searchQuery: state.searchQuery,
    );
  }

  void setSearchQuery(String query) {
    state = TransactionFilterState(
      type: state.type,
      fromDate: state.fromDate,
      toDate: state.toDate,
      minAmountMinor: state.minAmountMinor,
      maxAmountMinor: state.maxAmountMinor,
      searchQuery: query,
    );
  }

  void reset() {
    state = const TransactionFilterState();
  }
}
