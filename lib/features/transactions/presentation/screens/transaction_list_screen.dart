import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/localization/generated/app_localizations.dart';

import '../formatters/transaction_list_formatter.dart';
import '../models/transaction_type_localizer.dart';
import '../providers/transaction_list_providers.dart';
import '../state/transaction_list_state.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionListNotifierProvider);
    final localizations = AppLocalizations.of(context)!;
    final filter = ref.watch(transactionFilterNotifierProvider);
    const formatter = TransactionListFormatter();

    return Scaffold(
      appBar: AppBar(title: Text(localizations.transactionsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: localizations.transactionsSearchHint,
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: MaterialLocalizations.of(context)
                            .deleteButtonTooltip,
                        onPressed: () {
                          _searchController.clear();

                          ref
                              .read(transactionFilterNotifierProvider.notifier)
                              .setSearchQuery('');

                          ref
                              .read(transactionListNotifierProvider.notifier)
                              .searchWithCurrentFilter();

                          setState(() {});
                        },
                      ),
              ),
              onChanged: (_) {
                setState(() {});
              },
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  filter.fromDate != null && filter.toDate != null
                      ? localizations.transactionFilterDateRangeSelected(
                          formatter.formatDate(
                            filter.fromDate!,
                            locale: localizations.localeName,
                          ),
                          formatter.formatDate(
                            filter.toDate!,
                            locale: localizations.localeName,
                          ),
                        )
                      : localizations.transactionFilterDateRange,
                ),
                onPressed: () async {
                  final filter = ref.read(transactionFilterNotifierProvider);

                  final initialDateRange =
                      filter.fromDate != null && filter.toDate != null
                      ? DateTimeRange(
                          start: DateTime.fromMillisecondsSinceEpoch(
                            filter.fromDate!,
                          ),
                          end: DateTime.fromMillisecondsSinceEpoch(
                            filter.toDate!,
                          ),
                        )
                      : null;

                  final selectedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDateRange: initialDateRange,
                  );

                  if (!mounted || selectedRange == null) {
                    return;
                  }

                  ref
                      .read(transactionFilterNotifierProvider.notifier)
                      .setDateRange(
                        fromDate: selectedRange.start.millisecondsSinceEpoch,
                        toDate: selectedRange.end.millisecondsSinceEpoch,
                      );

                  await ref
                      .read(transactionListNotifierProvider.notifier)
                      .searchWithCurrentFilter();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: localizations.transactionFilterMinAmount,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      final amount = int.tryParse(value.trim());

                      ref
                          .read(transactionFilterNotifierProvider.notifier)
                          .setAmountRange(
                            minAmountMinor: amount,
                            maxAmountMinor: filter.maxAmountMinor,
                          );

                      ref
                          .read(transactionListNotifierProvider.notifier)
                          .searchWithCurrentFilter();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: localizations.transactionFilterMaxAmount,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      final amount = int.tryParse(value.trim());

                      ref
                          .read(transactionFilterNotifierProvider.notifier)
                          .setAmountRange(
                            minAmountMinor: filter.minAmountMinor,
                            maxAmountMinor: amount,
                          );

                      ref
                          .read(transactionListNotifierProvider.notifier)
                          .searchWithCurrentFilter();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.filter_alt_off),
                label: Text(localizations.transactionFilterReset),
                onPressed: () {
                  _searchController.clear();

                  ref.read(transactionFilterNotifierProvider.notifier).reset();

                  ref
                      .read(transactionListNotifierProvider.notifier)
                      .searchWithCurrentFilter();

                  setState(() {});
                },
              ),
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
