import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../../domain/models/monthly_financial_summary.dart';

class MonthlyFinancialSummaryCard extends StatelessWidget {
  const MonthlyFinancialSummaryCard({required this.summary, super.key});

  final MonthlyFinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _MetricRow(
              label: 'Income',
              amount: formatter.formatAmount(
                amountMinor: summary.totalIncomeMinor,
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 8),
            _MetricRow(
              label: 'Expense',
              amount: formatter.formatAmount(
                amountMinor: summary.totalExpenseMinor,
                currencyCode: 'IDR',
              ),
            ),
            const SizedBox(height: 8),
            _MetricRow(
              label: 'Net',
              amount: formatter.formatAmount(
                amountMinor: summary.netAmountMinor,
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
