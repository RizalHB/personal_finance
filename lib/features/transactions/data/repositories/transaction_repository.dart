import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/models/transaction_filter.dart';
import '../../domain/entities/transaction_split.dart';
import '../../domain/entities/transaction.dart';

abstract interface class TransactionRepository {
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
  });

  Future<Transaction> createTransfer({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String fromAccountId,
    required String toAccountId,
  });

  Future<Transaction?> getById(String id);

  Stream<List<Transaction>> watchRecent({int limit = 50});
  Future<List<Transaction>> search(TransactionFilter filter);

  Future<Transaction> voidTransaction({
    required String id,
    required int voidedAt,
  });
  Future<Transaction> createSplitExpense({
    required String id,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required List<TransactionSplit> splits,
    String? merchantId,
    String? notes,
  });
}
