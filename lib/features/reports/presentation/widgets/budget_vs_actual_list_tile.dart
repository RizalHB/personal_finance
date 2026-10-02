import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../../domain/models/budget_vs_actual.dart';

class BudgetVsActualListTile extends StatelessWidget {
  const BudgetVsActualListTile({required this.item, super.key});

  final BudgetVsActual item;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    final progress = (item.usagePercentage / 100).clamp(0.0, 1.0);
    final isOverspent = item.remainingAmountMinor < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(item.categoryName, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              Text(
                formatter.formatAmount(
                  amountMinor: item.actualAmountMinor,
                  currencyCode: 'IDR',
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Planned: ${formatter.formatAmount(amountMinor: item.plannedAmountMinor, currencyCode: 'IDR')}',
          ),
          const SizedBox(height: 4),
          Text(
            isOverspent
                ? 'Overspent: ${formatter.formatAmount(amountMinor: item.remainingAmountMinor.abs(), currencyCode: 'IDR')}'
                : 'Remaining: ${formatter.formatAmount(amountMinor: item.remainingAmountMinor, currencyCode: 'IDR')}',
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 4),
          Text(
            '${item.usagePercentage.toStringAsFixed(1)}% used',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
