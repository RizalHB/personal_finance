import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../../domain/models/category_spending.dart';

class CategorySpendingListTile extends StatelessWidget {
  const CategorySpendingListTile({required this.item, super.key});

  final CategorySpending item;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    final percentage = item.percentage.clamp(0.0, 100.0);
    final progress = percentage / 100.0;

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
                  amountMinor: item.amountMinor,
                  currencyCode: 'IDR',
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 4),
          Text(
            '${item.percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
