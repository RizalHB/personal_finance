class RecurringTransactionListItem {
  const RecurringTransactionListItem({
    required this.recurringTransactionId,
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    required this.frequencyLabel,
    required this.interval,
    required this.nextOccurrenceDate,
    required this.isActive,
  });

  final String recurringTransactionId;
  final int amountMinor;
  final String currencyCode;
  final String? categoryId;
  final String frequencyLabel;
  final int interval;
  final int nextOccurrenceDate;
  final bool isActive;
}
