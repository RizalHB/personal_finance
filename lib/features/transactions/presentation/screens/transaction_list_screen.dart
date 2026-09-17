import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/localization/generated/app_localizations.dart';

import '../formatters/transaction_list_formatter.dart';
import '../models/transaction_type_localizer.dart';
import '../providers/transaction_list_providers.dart';
import '../state/transaction_list_state.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionListNotifierProvider);
    final localizations = AppLocalizations.of(context)!;
    const formatter = TransactionListFormatter();

    return Scaffold(
      appBar: AppBar(title: Text(localizations.transactionsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: localizations.transactionsSearchHint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                ref
                    .read(transactionFilterNotifierProvider.notifier)
                    .setSearchQuery(value);

                ref
                    .read(transactionListNotifierProvider.notifier)
                    .searchWithCurrentFilter();
              },
            ),
          ),
          Expanded(
            child: switch (state) {
              TransactionListInitial() => Center(
                child: Text(localizations.transactionsInitialEmpty),
              ),

              TransactionListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),

              TransactionListLoaded(:final transactions) => ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  const typeLocalizer = TransactionTypeLocalizer();

                  return ListTile(
                    title: Text(
                      transaction.merchantName ??
                          transaction.categoryName ??
                          localizations.transactionUntitled,
                    ),
                    subtitle: Text(
                      [
                        typeLocalizer.label(transaction.type, localizations),
                        transaction.categoryName,
                        transaction.accountName,
                        formatter.formatDate(
                          transaction.transactionDate,
                          locale: localizations.localeName,
                        ),
                      ].whereType<String>().join(' • '),
                    ),
                    trailing: Text(
                      formatter.formatAmount(
                        amountMinor: transaction.amountMinor,
                        currencyCode: transaction.currencyCode,
                      ),
                    ),
                  );
                },
              ),

              TransactionListEmpty() => Center(
                child: Text(localizations.transactionsSearchEmpty),
              ),

              TransactionListError(:final message) => Center(
                child: Text(message),
              ),
            },
          ),
        ],
      ),
    );
  }
}
