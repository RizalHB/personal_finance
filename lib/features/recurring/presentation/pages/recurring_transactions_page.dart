import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/recurring_transaction_notifier.dart';
import '../widgets/create_recurring_transaction_form.dart';
import '../widgets/recurring_transaction_list_tile.dart';

class RecurringTransactionsPage extends ConsumerWidget {
  const RecurringTransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringTransactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: CreateRecurringTransactionForm(
              onCreated: () {
                ref
                    .read(recurringTransactionNotifierProvider.notifier)
                    .refresh();
              },
            ),
          ),
          Expanded(
            child: recurringAsync.when(
              data: (state) {
                if (state.items.isEmpty) {
                  return const Center(
                    child: Text('No recurring transactions yet.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return RecurringTransactionListTile(
                      item: state.items[index],
                    );
                  },
                );
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, stackTrace) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load recurring transactions.\n$error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
