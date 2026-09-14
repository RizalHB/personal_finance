import 'package:personal_finance/core/domain/transaction_type.dart';

import '../entities/transaction.dart';

class TransactionFilter {
  const TransactionFilter({
    this.fromDate,
    this.toDate,
    this.type,
    this.status,
    this.accountId,
    this.categoryId,
    this.merchantId,
    this.minAmountMinor,
    this.maxAmountMinor,
    this.searchQuery,
    this.limit = 50,
  });

  final int? fromDate;
  final int? toDate;
  final TransactionType? type;
  final TransactionStatus? status;
  final String? accountId;
  final String? categoryId;
  final String? merchantId;
  final int? minAmountMinor;
  final int? maxAmountMinor;
  final String? searchQuery;
  final int limit;
}
