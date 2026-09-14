import 'package:personal_finance/core/domain/transaction_type.dart';

import '../entities/transaction.dart';

class TransactionValidator {
  const TransactionValidator();

  void validateCreate({
    required TransactionType type,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String? accountId,
    required String? categoryId,
    String? notes,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Amount must be greater than zero.',
      );
    }

    if (transactionDate <= 0) {
      throw ArgumentError.value(
        transactionDate,
        'transactionDate',
        'Transaction date must be a valid timestamp.',
      );
    }

    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();

    if (normalizedCurrencyCode.length != 3) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Currency code must contain exactly 3 characters.',
      );
    }

    switch (type) {
      case TransactionType.income:
      case TransactionType.expense:
        _validateAccount(accountId);
        _validateCategory(categoryId);
        break;

      case TransactionType.transfer:
        _validateAccount(accountId);
        break;

      case TransactionType.adjustment:
        _validateAccount(accountId);
        break;

      case TransactionType.openingBalance:
        _validateAccount(accountId);
        break;
    }

    if (notes != null && notes.trim().length > 1000) {
      throw ArgumentError.value(
        notes,
        'notes',
        'Notes must not exceed 1000 characters.',
      );
    }
  }

  void validateStatus({
    required TransactionStatus status,
    required int? voidedAt,
  }) {
    switch (status) {
      case TransactionStatus.posted:
        if (voidedAt != null) {
          throw ArgumentError(
            'A posted transaction cannot have a voided timestamp.',
          );
        }

      case TransactionStatus.voided:
        if (voidedAt == null || voidedAt <= 0) {
          throw ArgumentError(
            'A voided transaction must have a valid voided timestamp.',
          );
        }
    }
  }

  void _validateAccount(String? accountId) {
    if (accountId == null || accountId.trim().isEmpty) {
      throw ArgumentError.value(accountId, 'accountId', 'Account is required.');
    }
  }

  void _validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.trim().isEmpty) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Category is required.',
      );
    }
  }

  void validateVoid({required String id, required int voidedAt}) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Transaction ID must not be empty.');
    }

    if (voidedAt <= 0) {
      throw ArgumentError.value(
        voidedAt,
        'voidedAt',
        'Must be greater than zero.',
      );
    }
  }

  void validateTransfer({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String fromAccountId,
    required String toAccountId,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be greater than zero.',
      );
    }

    if (transactionDate <= 0) {
      throw ArgumentError.value(
        transactionDate,
        'transactionDate',
        'Must be greater than zero.',
      );
    }

    final normalizedCurrency = currencyCode.trim().toUpperCase();

    if (normalizedCurrency.length != 3) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Currency code must contain exactly 3 characters.',
      );
    }

    final normalizedFromAccountId = fromAccountId.trim();
    final normalizedToAccountId = toAccountId.trim();

    if (normalizedFromAccountId.isEmpty) {
      throw ArgumentError.value(
        fromAccountId,
        'fromAccountId',
        'Source account ID must not be empty.',
      );
    }

    if (normalizedToAccountId.isEmpty) {
      throw ArgumentError.value(
        toAccountId,
        'toAccountId',
        'Destination account ID must not be empty.',
      );
    }

    if (normalizedFromAccountId == normalizedToAccountId) {
      throw ArgumentError('Source and destination accounts must be different.');
    }
  }

  void validateSplitExpense({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
  }) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be greater than zero.',
      );
    }

    if (transactionDate <= 0) {
      throw ArgumentError.value(
        transactionDate,
        'transactionDate',
        'Must be greater than zero.',
      );
    }

    final normalizedCurrency = currencyCode.trim().toUpperCase();

    if (normalizedCurrency.length != 3) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Currency code must contain exactly 3 characters.',
      );
    }

    if (accountId.trim().isEmpty) {
      throw ArgumentError.value(
        accountId,
        'accountId',
        'Account ID must not be empty.',
      );
    }
  }
}
