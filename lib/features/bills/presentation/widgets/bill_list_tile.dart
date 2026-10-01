import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../models/bill_list_item.dart';

class BillListTile extends StatelessWidget {
  const BillListTile({required this.item, required this.onTap, super.key});

  final BillListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    final amountText = item.amountMinor == null
        ? 'Amount unknown'
        : formatter.formatAmount(
            amountMinor: item.amountMinor!,
            currencyCode: item.currencyCode,
          );

    return ListTile(
      title: Text(item.name),
      subtitle: Text('$amountText • ${item.statusLabel}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: item.isActive ? onTap : null,
    );
  }
}
