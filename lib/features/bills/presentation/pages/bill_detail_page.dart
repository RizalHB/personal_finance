import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/bill_payment_list_tile.dart';
import '../../application/bill_dependencies.dart';
import '../../domain/entities/bill.dart';
import '../notifiers/bill_payment_notifier.dart';

final billDetailProvider = FutureProvider.family<Bill, String>((ref, billId) {
  return ref.read(getBillProvider).execute(billId);
});

class BillDetailPage extends ConsumerWidget {
  const BillDetailPage({required this.billId, super.key});

  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billDetailProvider(billId));

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Details')),
      body: billAsync.when(
        data: (bill) {
          final paymentsAsync = ref.watch(billPaymentNotifierProvider(billId));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(bill.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text('Status: ${bill.status.name}'),
              const SizedBox(height: 8),
              Text(
                bill.amountMinor == null
                    ? 'Amount unknown'
                    : 'Amount: ${bill.amountMinor}',
              ),
              if (bill.status == BillStatus.active) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final amountController = TextEditingController(
                      text: bill.amountMinor?.toString() ?? '',
                    );

                    try {
                      final shouldSave = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Record Payment'),
                            content: TextField(
                              key: const Key('bill-payment-amount'),
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Payment Amount',
                                prefixText: 'Rp',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );

                      if (!context.mounted || shouldSave != true) {
                        return;
                      }

                      final amountMinor = int.tryParse(
                        amountController.text.trim(),
                      );

                      if (amountMinor == null || amountMinor <= 0) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Payment amount must be greater than zero.',
                            ),
                          ),
                        );
                        return;
                      }

                      await ref
                          .read(recordBillPaymentProvider)
                          .execute(
                            billId: bill.id,
                            amountMinor: amountMinor,
                            paidAt: DateTime.now().millisecondsSinceEpoch,
                          );

                      if (!context.mounted) {
                        return;
                      }

                      ref.invalidate(billDetailProvider(billId));

                      await ref
                          .read(billPaymentNotifierProvider(billId).notifier)
                          .refresh();

                      if (!context.mounted) {
                        return;
                      }

                      messenger.showSnackBar(
                        const SnackBar(content: Text('Bill payment recorded.')),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to record payment.\n$error'),
                        ),
                      );
                    } finally {
                      amountController.dispose();
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Record Payment'),
                ),
              ],
              const SizedBox(height: 24),
              Text('Payments', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              paymentsAsync.when(
                data: (state) {
                  if (state.items.isEmpty) {
                    return const Text('No payments recorded yet.');
                  }

                  return Column(
                    children: [
                      for (final payment in state.items)
                        BillPaymentListTile(item: payment),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Failed to load payments.\n$error'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load bill.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
