import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/budget_vs_actual_notifier.dart';
import '../notifiers/category_spending_notifier.dart';
import '../notifiers/monthly_financial_summary_notifier.dart';
import '../widgets/budget_vs_actual_list_tile.dart';
import '../widgets/category_spending_list_tile.dart';
import '../widgets/monthly_financial_summary_card.dart';
import '../widgets/monthly_financial_summary_chart.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({this.period, this.budgetId, super.key});

  final DateTime? period;
  final String? budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportPeriod =
        period ?? DateTime(DateTime.now().year, DateTime.now().month);

    final summaryAsync = ref.watch(
      monthlyFinancialSummaryNotifierProvider(reportPeriod),
    );

    final categorySpendingAsync = ref.watch(
      categorySpendingNotifierProvider(reportPeriod),
    );

    final budgetVsActualAsync = budgetId == null
        ? null
        : ref.watch(budgetVsActualNotifierProvider(budgetId!));

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Monthly Reports',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              title: const Text('Report Period'),
              subtitle: Text(
                '${reportPeriod.year}-${reportPeriod.month.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_month),
            ),
          ),

          const SizedBox(height: 16),

          summaryAsync.when(
            data: (summary) {
              return MonthlyFinancialSummaryCard(summary: summary);
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to load monthly summary.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 16),

          summaryAsync.when(
            data: (summary) {
              return MonthlyFinancialSummaryChart(summary: summary);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Category Spending',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  categorySpendingAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No category spending for this period.'),
                        );
                      }

                      return Column(
                        children: [
                          for (final item in items)
                            CategorySpendingListTile(item: item),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load category spending.\n$error',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (budgetId != null) ...[
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Budget vs Actual',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 8),

                    budgetVsActualAsync!.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No budget allocations for this budget.',
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (final item in items)
                              BudgetVsActualListTile(item: item),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Failed to load budget vs actual.\n$error',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
