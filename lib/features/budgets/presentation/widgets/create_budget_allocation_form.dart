import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/presentation/notifiers/category_picker_notifier.dart';
import '../../application/budget_dependencies.dart';

class CreateBudgetAllocationForm extends ConsumerStatefulWidget {
  const CreateBudgetAllocationForm({
    required this.budgetId,
    required this.onCreated,
    super.key,
  });

  final String budgetId;
  final VoidCallback onCreated;

  @override
  ConsumerState<CreateBudgetAllocationForm> createState() =>
      _CreateBudgetAllocationFormState();
}

class _CreateBudgetAllocationFormState
    extends ConsumerState<CreateBudgetAllocationForm> {
  late final TextEditingController _amountController;

  String? _selectedCategoryId;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final categoryId = _selectedCategoryId;

    if (categoryId == null) {
      setState(() {
        _errorMessage = 'Please select a category.';
      });
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Amount must be greater than zero.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(createBudgetAllocationProvider)
          .execute(
            budgetId: widget.budgetId,
            categoryId: categoryId,
            plannedAmountMinor: amount,
          );

      if (!mounted) {
        return;
      }

      _amountController.clear();

      setState(() {
        _selectedCategoryId = null;
        _isSaving = false;
      });

      widget.onCreated();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryPickerNotifierProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Budget Allocation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (state) {
                if (state.items.isEmpty) {
                  return const Text('No expense categories available.');
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final item in state.items)
                      DropdownMenuItem(
                        value: item.categoryId,
                        child: Text(item.name),
                      ),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategoryId = value;
                            _errorMessage = null;
                          });
                        },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Failed to load categories.\n$error'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Planned Amount',
                hintText: 'Example: 500000',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Add Allocation'),
            ),
          ],
        ),
      ),
    );
  }
}
