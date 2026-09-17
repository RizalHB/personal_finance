import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/models/transaction_filter.dart';

class TransactionFilterState {
  const TransactionFilterState({
    this.type,
    this.fromDate,
    this.toDate,
    this.minAmountMinor,
    this.maxAmountMinor,
    this.searchQuery = '',
  });

  final TransactionType? type;
  final int? fromDate;
  final int? toDate;
  final int? minAmountMinor;
  final int? maxAmountMinor;
  final String searchQuery;

  TransactionFilter toDomain() {
    return TransactionFilter(
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      minAmountMinor: minAmountMinor,
      maxAmountMinor: maxAmountMinor,
      searchQuery: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
    );
  }
}
