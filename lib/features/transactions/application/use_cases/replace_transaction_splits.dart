import '../../data/repositories/transaction_split_repository.dart';
import '../../domain/entities/transaction_split.dart';
import '../../domain/services/transaction_split_validator.dart';

class ReplaceTransactionSplits {
  const ReplaceTransactionSplits(this._repository, this._validator);

  final TransactionSplitRepository _repository;
  final TransactionSplitValidator _validator;

  Future<List<TransactionSplit>> execute({
    required String transactionId,
    required int transactionAmountMinor,
    required List<TransactionSplit> splits,
  }) async {
    final normalizedTransactionId = transactionId.trim();

    if (normalizedTransactionId.isEmpty) {
      throw ArgumentError.value(
        transactionId,
        'transactionId',
        'Transaction ID must not be empty.',
      );
    }

    if (splits.isEmpty) {
      throw ArgumentError('At least one split is required.');
    }

    var totalMinor = 0;

    for (final split in splits) {
      _validator.validate(
        transactionId: normalizedTransactionId,
        categoryId: split.categoryId,
        amountMinor: split.amountMinor,
        notes: split.notes,
      );

      if (split.transactionId != normalizedTransactionId) {
        throw ArgumentError(
          'Split transaction ID does not match parent transaction.',
        );
      }

      totalMinor += split.amountMinor;
    }

    _validator.validateTotal(
      transactionAmountMinor: transactionAmountMinor,
      splitTotalMinor: totalMinor,
    );

    return _repository.replaceSplits(
      transactionId: normalizedTransactionId,
      splits: splits,
    );
  }
}
