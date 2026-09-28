import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../models/budget_allocation_list_item.dart';

class BudgetAllocationListTile extends StatelessWidget {
  const BudgetAllocationListTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final BudgetAllocationListItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    final usage = item.usagePercentage.clamp(0.0, 100.0) / 100.0;
    final isOverspent = item.remainingAmountMinor < 0;

    return ListTile(
      title: Text(item.categoryName),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actual: ${formatter.formatAmount(amountMinor: item.actualAmountMinor, currencyCode: 'IDR')}',
            ),
            const SizedBox(height: 4),
            Text(
              isOverspent
                  ? 'Overspent: ${formatter.formatAmount(amountMinor: item.remainingAmountMinor.abs(), currencyCode: 'IDR')}'
                  : 'Remaining: ${formatter.formatAmount(amountMinor: item.remainingAmountMinor, currencyCode: 'IDR')}',
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: usage),
            const SizedBox(height: 4),
            Text('${item.usagePercentage.toStringAsFixed(1)}% used'),
          ],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatter.formatAmount(
              amountMinor: item.plannedAmountMinor,
              currencyCode: 'IDR',
            ),
          ),
          const SizedBox(height: 4),
          const Text('Planned'),
        ],
      ),
      onTap: null,
      leading: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
            case 'delete':
              onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
