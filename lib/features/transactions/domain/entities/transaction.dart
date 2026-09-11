import 'package:personal_finance/core/domain/transaction_type.dart';

enum TransactionStatus {
  posted(1),
  voided(2);

  const TransactionStatus(this.code);

  final int code;

  static TransactionStatus fromCode(int code) {
    for (final status in values) {
      if (status.code == code) {
        return status;
      }
    }

    throw ArgumentError('Unknown transaction status code: $code');
  }
}

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.transactionDate,
    required this.currencyCode,
    required this.amountMinor,
    required this.accountId,
    required this.categoryId,
    required this.merchantId,
    required this.notes,
    required this.relatedTransactionId,
    required this.recurringTransactionId,
    required this.createdAt,
    required this.updatedAt,
    required this.voidedAt,
  });

  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final int transactionDate;
  final String currencyCode;
  final int amountMinor;
  final String? accountId;
  final String? categoryId;
  final String? merchantId;
  final String? notes;
  final String? relatedTransactionId;
  final String? recurringTransactionId;
  final int createdAt;
  final int updatedAt;
  final int? voidedAt;
}
