import 'package:personal_finance/core/utils/id_generator.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_split.dart';
import '../../domain/services/transaction_split_validator.dart';
import '../../domain/services/transaction_validator.dart';

class CreateSplitExpense {
  const CreateSplitExpense(
    this._repository,
    this._transactionValidator,
    this._splitValidator,
    this._idGenerator,
  );

  final TransactionRepository _repository;
  final TransactionValidator _transactionValidator;
  final TransactionSplitValidator _splitValidator;
  final IdGenerator _idGenerator;

  Future<Transaction> execute({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required List<TransactionSplit> splits,
    String? merchantId,
    String? notes,
  }) {
    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();
    final normalizedAccountId = accountId.trim();
    final normalizedMerchantId = merchantId?.trim();
    final normalizedNotes = notes?.trim();

    _transactionValidator.validateSplitExpense(
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      currencyCode: normalizedCurrencyCode,
      accountId: normalizedAccountId,
    );

    if (splits.isEmpty) {
      throw ArgumentError('At least one split is required.');
    }

    final transactionId = _idGenerator.generate();

    final normalizedSplits = <TransactionSplit>[];

    var totalMinor = 0;

    for (final split in splits) {
      _splitValidator.validate(
        transactionId: transactionId,
        categoryId: split.categoryId,
        amountMinor: split.amountMinor,
        notes: split.notes,
      );

      totalMinor += split.amountMinor;

      normalizedSplits.add(
        TransactionSplit(
          id: split.id,
          transactionId: transactionId,
          categoryId: split.categoryId.trim(),
          amountMinor: split.amountMinor,
          notes: split.notes?.trim().isEmpty == true
              ? null
              : split.notes?.trim(),
          createdAt: split.createdAt,
          updatedAt: split.updatedAt,
        ),
      );
    }

    _splitValidator.validateTotal(
      transactionAmountMinor: amountMinor,
      splitTotalMinor: totalMinor,
    );

    return _repository.createSplitExpense(
      id: transactionId,
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      currencyCode: normalizedCurrencyCode,
      accountId: normalizedAccountId,
      splits: normalizedSplits,
      merchantId: normalizedMerchantId?.isEmpty == true
          ? null
          : normalizedMerchantId,
      notes: normalizedNotes?.isEmpty == true ? null : normalizedNotes,
    );
  }
}
