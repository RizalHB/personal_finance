import '../../domain/entities/transaction_split.dart';

abstract interface class TransactionSplitRepository {
  Future<List<TransactionSplit>> getByTransactionId(String transactionId);

  Future<List<TransactionSplit>> replaceSplits({
    required String transactionId,
    required List<TransactionSplit> splits,
  });
}
