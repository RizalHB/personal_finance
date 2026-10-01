import '../../../../core/domain/transaction_type.dart';
import '../entities/recurring_transaction.dart';

class RecurringTransactionValidator {
  const RecurringTransactionValidator();

  void validateCreate({
    required TransactionType transactionType,
    required int amountMinor,
    required String currencyCode,
    required String accountId,
    required String? categoryId,
    required RecurringFrequency frequency,
    required int interval,
    required int startDate,
    required int? endDate,
    required int nextOccurrenceDate,
  }) {
    if (transactionType != TransactionType.income &&
        transactionType != TransactionType.expense) {
      throw ArgumentError(
        'Recurring transaction type must be income or expense.',
      );
    }

    if (amountMinor <= 0) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    final normalizedCurrencyCode = currencyCode.trim();

    if (normalizedCurrencyCode.length != 3) {
      throw ArgumentError('Currency code must contain 3 characters.');
    }

    if (accountId.trim().isEmpty) {
      throw ArgumentError('Account ID cannot be empty.');
    }

    if (transactionType == TransactionType.expense &&
        categoryId != null &&
        categoryId.trim().isEmpty) {
      throw ArgumentError('Category ID cannot be empty.');
    }

    if (interval <= 0) {
      throw ArgumentError('Interval must be greater than zero.');
    }

    if (endDate != null && endDate < startDate) {
      throw ArgumentError('End date cannot be before start date.');
    }

    if (nextOccurrenceDate < startDate) {
      throw ArgumentError('Next occurrence date cannot be before start date.');
    }

    switch (frequency) {
      case RecurringFrequency.daily:
      case RecurringFrequency.weekly:
      case RecurringFrequency.monthly:
      case RecurringFrequency.yearly:
        break;
    }
  }
}
