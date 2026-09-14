class TransactionSplitValidator {
  const TransactionSplitValidator();

  void validate({
    required String transactionId,
    required String categoryId,
    required int amountMinor,
    String? notes,
  }) {
    final normalizedTransactionId = transactionId.trim();
    final normalizedCategoryId = categoryId.trim();

    if (normalizedTransactionId.isEmpty) {
      throw ArgumentError.value(
        transactionId,
        'transactionId',
        'Transaction ID must not be empty.',
      );
    }

    if (normalizedCategoryId.isEmpty) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Category ID must not be empty.',
      );
    }

    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be greater than zero.',
      );
    }

    final normalizedNotes = notes?.trim();

    if (normalizedNotes != null && normalizedNotes.length > 1000) {
      throw ArgumentError.value(
        notes,
        'notes',
        'Notes must not exceed 1000 characters.',
      );
    }
  }

  void validateTotal({
    required int transactionAmountMinor,
    required int splitTotalMinor,
  }) {
    if (transactionAmountMinor <= 0) {
      throw ArgumentError.value(
        transactionAmountMinor,
        'transactionAmountMinor',
        'Must be greater than zero.',
      );
    }

    if (splitTotalMinor != transactionAmountMinor) {
      throw ArgumentError('Split total must equal the transaction amount.');
    }
  }
}
