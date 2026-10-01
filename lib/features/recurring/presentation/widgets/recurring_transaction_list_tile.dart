import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../models/recurring_transaction_list_item.dart';

class RecurringTransactionListTile extends StatelessWidget {
  const RecurringTransactionListTile({required this.item, super.key});

  final RecurringTransactionListItem item;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    final intervalLabel = item.interval == 1
        ? item.frequencyLabel
        : 'Every ${item.interval} ${item.frequencyLabel.toLowerCase()}';

    return ListTile(
      title: Text(
        formatter.formatAmount(
          amountMinor: item.amountMinor,
          currencyCode: item.currencyCode,
        ),
      ),
      subtitle: Text(
        [
          if (item.categoryId != null) item.categoryId!,
          intervalLabel,
        ].join(' • '),
      ),
      trailing: Icon(item.isActive ? Icons.repeat : Icons.pause_circle_outline),
    );
  }
}
