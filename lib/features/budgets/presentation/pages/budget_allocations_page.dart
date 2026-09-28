import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/presentation/notifiers/category_picker_notifier.dart';
import '../../application/budget_dependencies.dart';
import '../models/budget_allocation_list_item.dart';
import '../notifiers/budget_overview_notifier.dart';
import '../widgets/budget_allocation_list_tile.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/create_budget_allocation_form.dart';

class BudgetAllocationsPage extends ConsumerWidget {
  const BudgetAllocationsPage({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allocationsAsync = ref.watch(
      budgetAllocationNotifierProvider(budgetId),
    );

    final overviewAsync = ref.watch(budgetOverviewNotifierProvider(budgetId));

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Allocations')),
      body: Column(
        children: [
          overviewAsync.when(
            data: (overview) => BudgetOverviewCard(overview: overview),
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to load budget overview.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          CreateBudgetAllocationForm(
            budgetId: budgetId,
            onCreated: () {
              ref
                  .read(budgetAllocationNotifierProvider(budgetId).notifier)
                  .refresh();

              ref
                  .read(budgetOverviewNotifierProvider(budgetId).notifier)
                  .refresh();
            },
          ),
          Expanded(
            child: allocationsAsync.when(
              data: (state) {
                if (state.items.isEmpty) {
                  return const Center(
                    child: Text('No budget allocations yet.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.items[index];

                    return BudgetAllocationListTile(
                      item: item,
                      onEdit: () {
                        _editAllocation(context, ref, item);
                      },
                      onDelete: () {
                        _deleteAllocation(context, ref, item);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load budget allocations.\n$error',
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

  Future<void> _editAllocation(
    BuildContext context,
    WidgetRef ref,
    BudgetAllocationListItem item,
  ) async {
    final categoriesAsync = ref.read(categoryPickerNotifierProvider);

    final categories = categoriesAsync.asData?.value.items ?? [];

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expense categories available.')),
      );
      return;
    }

    final amountController = TextEditingController(
      text: item.plannedAmountMinor.toString(),
    );

    var selectedCategoryId = item.categoryId;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Budget Allocation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category.categoryId,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Planned Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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
      },
    );

    if (shouldSave != true) {
      amountController.dispose();
      return;
    }

    final plannedAmountMinor = int.tryParse(amountController.text.trim());

    amountController.dispose();

    if (plannedAmountMinor == null || plannedAmountMinor <= 0) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than zero.')),
      );
      return;
    }

    try {
      await ref
          .read(updateBudgetAllocationProvider)
          .execute(
            id: item.allocationId,
            budgetId: budgetId,
            categoryId: selectedCategoryId,
            plannedAmountMinor: plannedAmountMinor,
          );

      if (!context.mounted) {
        return;
      }

      await ref
          .read(budgetAllocationNotifierProvider(budgetId).notifier)
          .refresh();

      if (!context.mounted) {
        return;
      }

      await ref
          .read(budgetOverviewNotifierProvider(budgetId).notifier)
          .refresh();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget allocation updated.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update allocation.\n$error')),
      );
    }
  }

  Future<void> _deleteAllocation(
    BuildContext context,
    WidgetRef ref,
    BudgetAllocationListItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Budget Allocation'),
          content: Text('Delete the allocation for ${item.categoryName}?'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(deleteBudgetAllocationProvider).execute(item.allocationId);

      if (!context.mounted) {
        return;
      }

      await ref
          .read(budgetAllocationNotifierProvider(budgetId).notifier)
          .refresh();

      if (!context.mounted) {
        return;
      }

      await ref
          .read(budgetOverviewNotifierProvider(budgetId).notifier)
          .refresh();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget allocation deleted.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete allocation.\n$error')),
      );
    }
  }
}
