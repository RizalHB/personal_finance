import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/localization/generated/app_localizations.dart';

import '../formatters/transaction_list_formatter.dart';
import '../models/transaction_status_localizer.dart';
import '../models/transaction_type_localizer.dart';
import '../models/transaction_type_presentation.dart';
import '../providers/transaction_detail_providers.dart';
import '../state/transaction_detail_state.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref
          .read(transactionDetailNotifierProvider.notifier)
          .load(widget.transactionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final state = ref.watch(transactionDetailNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.transactionUntitled)),
      body: switch (state) {
        TransactionDetailInitial() || TransactionDetailLoading() =>
          const Center(child: CircularProgressIndicator()),

        TransactionDetailNotFound() => Center(
          child: Text(localizations.transactionsSearchEmpty),
        ),

        TransactionDetailError(:final message) => Center(child: Text(message)),

        TransactionDetailLoaded(:final result) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              const TransactionListFormatter().formatAmount(
                amountMinor: result.transaction.amountMinor,
                currencyCode: result.transaction.currencyCode,
                locale: localizations.localeName,
              ),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            Text(result.transaction.currencyCode),
            const SizedBox(height: 8),

            Text(
              const TransactionListFormatter().formatDate(
                result.transaction.transactionDate,
                locale: localizations.localeName,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              localizations.transactionDetailId,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(result.transaction.id),

            const SizedBox(height: 16),

            Text(
              localizations.transactionDetailType,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              const TransactionTypeLocalizer().label(
                TransactionTypePresentation.fromType(result.transaction.type),
                localizations,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              localizations.transactionDetailStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              const TransactionStatusLocalizer().label(
                result.transaction.status,
                localizations,
              ),
            ),
          ],
        ),
      },
    );
  }
}
