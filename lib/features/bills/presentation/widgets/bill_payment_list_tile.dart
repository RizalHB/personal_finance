import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../models/bill_payment_list_item.dart';

class BillPaymentListTile extends StatelessWidget {
  const BillPaymentListTile({required this.item, super.key});

  final BillPaymentListItem item;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        formatter.formatAmount(
          amountMinor: item.amountMinor,
          currencyCode: 'IDR',
        ),
      ),
      subtitle: Text(
        DateTime.fromMillisecondsSinceEpoch(item.paidAt).toLocal().toString(),
      ),
    );
  }
}
