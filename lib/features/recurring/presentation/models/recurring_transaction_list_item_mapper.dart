import '../../domain/entities/recurring_transaction.dart';
import 'recurring_transaction_list_item.dart';

class RecurringTransactionListItemMapper {
  const RecurringTransactionListItemMapper();

  RecurringTransactionListItem map(RecurringTransaction recurringTransaction) {
    return RecurringTransactionListItem(
      recurringTransactionId: recurringTransaction.id,
      amountMinor: recurringTransaction.amountMinor,
      currencyCode: recurringTransaction.currencyCode,
      categoryId: recurringTransaction.categoryId,
      frequencyLabel: _frequencyLabel(recurringTransaction.frequency),
      interval: recurringTransaction.interval,
      nextOccurrenceDate: recurringTransaction.nextOccurrenceDate,
      isActive: recurringTransaction.isActive,
    );
  }

  List<RecurringTransactionListItem> mapList(
    List<RecurringTransaction> transactions,
  ) {
    return transactions.map(map).toList();
  }

  String _frequencyLabel(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }
}
