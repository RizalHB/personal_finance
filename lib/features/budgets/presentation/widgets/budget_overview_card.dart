import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../../domain/models/budget_overview.dart';

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({required this.overview, super.key});

  final BudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    final usage = (overview.usagePercentage / 100).clamp(0.0, 1.0);
    final isOverspent = overview.totalRemainingAmountMinor < 0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(overview.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _MetricRow(
              label: 'Planned',
              amount: formatter.formatAmount(
                amountMinor: overview.totalPlannedAmountMinor,
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 8),
            _MetricRow(
              label: 'Actual',
              amount: formatter.formatAmount(
                amountMinor: overview.totalActualAmountMinor,
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 8),
            _MetricRow(
              label: isOverspent ? 'Overspent' : 'Remaining',
              amount: formatter.formatAmount(
                amountMinor: overview.totalRemainingAmountMinor.abs(),
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: usage),
            const SizedBox(height: 6),
            Text('${overview.usagePercentage.toStringAsFixed(1)}% used'),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
