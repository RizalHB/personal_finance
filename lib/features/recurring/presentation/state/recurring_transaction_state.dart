import '../models/recurring_transaction_list_item.dart';

class RecurringTransactionState {
  const RecurringTransactionState({this.items = const []});

  final List<RecurringTransactionListItem> items;
}
