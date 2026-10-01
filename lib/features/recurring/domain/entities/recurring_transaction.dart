import '../../../../core/domain/transaction_type.dart';

enum RecurringFrequency {
  daily(1),
  weekly(2),
  monthly(3),
  yearly(4);

  const RecurringFrequency(this.code);

  final int code;

  static RecurringFrequency fromCode(int code) {
    for (final frequency in values) {
      if (frequency.code == code) {
        return frequency;
      }
    }

    throw ArgumentError('Unknown recurring frequency code: $code');
  }
}

class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.transactionType,
    required this.amountMinor,
    required this.currencyCode,
    required this.accountId,
    required this.categoryId,
    required this.merchantId,
    required this.notes,
    required this.frequency,
    required this.interval,
    required this.startDate,
    required this.endDate,
    required this.nextOccurrenceDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final TransactionType transactionType;
  final int amountMinor;
  final String currencyCode;
  final String accountId;
  final String? categoryId;
  final String? merchantId;
  final String? notes;
  final RecurringFrequency frequency;
  final int interval;
  final int startDate;
  final int? endDate;
  final int nextOccurrenceDate;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
}
