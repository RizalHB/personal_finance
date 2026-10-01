import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/transaction_type.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../categories/presentation/notifiers/category_picker_notifier.dart';
import '../../application/recurring_dependencies.dart';
import '../../domain/entities/recurring_transaction.dart';

class CreateRecurringTransactionForm extends ConsumerStatefulWidget {
  const CreateRecurringTransactionForm({this.onCreated, super.key});

  final VoidCallback? onCreated;

  @override
  ConsumerState<CreateRecurringTransactionForm> createState() =>
      _CreateRecurringTransactionFormState();
}

class _CreateRecurringTransactionFormState
    extends ConsumerState<CreateRecurringTransactionForm> {
  final _amountController = TextEditingController();
  final _intervalController = TextEditingController(text: '1');

  TransactionType _transactionType = TransactionType.expense;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  RecurringFrequency _frequency = RecurringFrequency.monthly;

  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final amount = int.tryParse(_amountController.text.trim());
    final interval = int.tryParse(_intervalController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Amount must be greater than zero.';
      });
      return;
    }

    if (interval == null || interval <= 0) {
      setState(() {
        _errorMessage = 'Interval must be greater than zero.';
      });
      return;
    }

    if (_selectedAccountId == null) {
      setState(() {
        _errorMessage = 'Please select an account.';
      });
      return;
    }

    if (_transactionType == TransactionType.expense &&
        _selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'Please select a category.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final startDate = DateTime.now().millisecondsSinceEpoch;

    try {
      await ref
          .read(createRecurringTransactionProvider)
          .execute(
            transactionType: _transactionType,
            amountMinor: amount,
            currencyCode: 'IDR',
            accountId: _selectedAccountId!,
            categoryId: _transactionType == TransactionType.expense
                ? _selectedCategoryId
                : null,
            merchantId: null,
            notes: null,
            frequency: _frequency,
            interval: interval,
            startDate: startDate,
            endDate: null,
            nextOccurrenceDate: startDate,
          );

      if (!mounted) {
        return;
      }

      _amountController.clear();
      _intervalController.text = '1';

      setState(() {
        _saving = false;
        _selectedCategoryId = null;
        _errorMessage = null;
      });

      widget.onCreated?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(activeAccountsProvider);
    final categoriesAsync = ref.watch(categoryPickerNotifierProvider);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Recurring Transaction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                  ),
                ],
                selected: {_transactionType},
                onSelectionChanged: _saving
                    ? null
                    : (selection) {
                        setState(() {
                          _transactionType = selection.first;
                          _selectedCategoryId = null;
                          _errorMessage = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('recurring-amount'),
                controller: _amountController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rp',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const Text('No active accounts available.');
                  }

                  _selectedAccountId ??= accounts.first.id;

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final account in accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedAccountId = value;
                              _errorMessage = null;
                            });
                          },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Failed to load accounts.\n$error'),
              ),
              if (_transactionType == TransactionType.expense) ...[
                const SizedBox(height: 12),
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
                        for (final category in state.items)
                          DropdownMenuItem(
                            value: category.categoryId,
                            child: Text(category.name),
                          ),
                      ],
                      onChanged: _saving
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
                  error: (error, _) =>
                      Text('Failed to load categories.\n$error'),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<RecurringFrequency>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: RecurringFrequency.daily,
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: RecurringFrequency.weekly,
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: RecurringFrequency.monthly,
                    child: Text('Monthly'),
                  ),
                  DropdownMenuItem(
                    value: RecurringFrequency.yearly,
                    child: Text('Yearly'),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _frequency = value;
                          _errorMessage = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _intervalController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Every',
                  suffixText: 'interval(s)',
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
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
