import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transaction_list_providers.dart';
import '../state/transaction_list_state.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: switch (state) {
        TransactionListInitial() => const Center(
          child: Text('Belum ada transaksi.'),
        ),
        TransactionListLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        TransactionListLoaded(:final transactions) => ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];

            return ListTile(
              title: Text(transaction.id),
              subtitle: Text(transaction.currencyCode),
              trailing: Text(transaction.amountMinor.toString()),
            );
          },
        ),
        TransactionListEmpty() => const Center(
          child: Text('Tidak ada transaksi yang ditemukan.'),
        ),
        TransactionListError(:final message) => Center(child: Text(message)),
      },
    );
  }
}
