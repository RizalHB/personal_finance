import 'package:flutter/material.dart';

import '../../../transactions/presentation/formatters/transaction_list_formatter.dart';
import '../../domain/models/monthly_financial_summary.dart';

class MonthlyFinancialSummaryChart extends StatelessWidget {
  const MonthlyFinancialSummaryChart({required this.summary, super.key});

  final MonthlyFinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    const formatter = TransactionListFormatter();
    final colorScheme = Theme.of(context).colorScheme;

    final maximum = [
      summary.totalIncomeMinor,
      summary.totalExpenseMinor,
    ].reduce((a, b) => a > b ? a : b);

    final incomeProgress = maximum == 0
        ? 0.0
        : summary.totalIncomeMinor / maximum;
    final expenseProgress = maximum == 0
        ? 0.0
        : summary.totalExpenseMinor / maximum;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expense',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _AmountBar(
              label: 'Income',
              amount: formatter.formatAmount(
                amountMinor: summary.totalIncomeMinor,
                currencyCode: 'IDR',
              ),
              progress: incomeProgress,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _AmountBar(
              label: 'Expense',
              amount: formatter.formatAmount(
                amountMinor: summary.totalExpenseMinor,
                currencyCode: 'IDR',
              ),
              progress: expenseProgress,
              color: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountBar extends StatelessWidget {
  const _AmountBar({
    required this.label,
    required this.amount,
    required this.progress,
    required this.color,
  });

  final String label;
  final String amount;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          color: color,
        ),
      ],
    );
  }
}
