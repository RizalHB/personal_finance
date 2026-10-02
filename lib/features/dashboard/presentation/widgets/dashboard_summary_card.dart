import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../../domain/models/dashboard_summary.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({required this.summary, super.key});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _MetricRow(
              label: 'Total Balance',
              amount: formatter.formatAmount(
                amountMinor: summary.totalBalanceMinor,
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Income This Month',
              amount: formatter.formatAmount(
                amountMinor: summary.monthlyIncomeMinor,
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Expense This Month',
              amount: formatter.formatAmount(
                amountMinor: summary.monthlyExpenseMinor,
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Net This Month',
              amount: formatter.formatAmount(
                amountMinor: summary.monthlyNetMinor,
                currencyCode: 'IDR',
              ),
            ),
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
