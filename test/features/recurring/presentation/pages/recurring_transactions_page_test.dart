import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/accounts/domain/entities/account.dart';
import 'package:personal_finance/features/accounts/presentation/providers/account_providers.dart';
import 'package:personal_finance/features/categories/presentation/models/category_picker_item.dart';
import 'package:personal_finance/features/categories/presentation/notifiers/category_picker_notifier.dart';
import 'package:personal_finance/features/categories/presentation/state/category_picker_state.dart';
import 'package:personal_finance/features/recurring/application/recurring_dependencies.dart';
import 'package:personal_finance/features/recurring/application/use_cases/create_recurring_transaction.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/features/recurring/presentation/notifiers/recurring_transaction_notifier.dart';
import 'package:personal_finance/features/recurring/presentation/pages/recurring_transactions_page.dart';
import 'package:personal_finance/features/recurring/presentation/state/recurring_transaction_state.dart';

void main() {
  testWidgets('refreshes recurring transactions after creating one', (
    tester,
  ) async {
    final createUseCase = FakeCreateRecurringTransaction();
    final notifier = FakeRecurringTransactionNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createRecurringTransactionProvider.overrideWithValue(createUseCase),
          recurringTransactionNotifierProvider.overrideWith(() => notifier),
          activeAccountsProvider.overrideWith(
            (ref) => Stream.value([
              const Account(
                id: 'account-cash',
                name: 'Cash',
                financialClass: 1,
                accountType: 1,
                currencyCode: 'IDR',
                status: 1,
                createdAt: 1000,
                updatedAt: 1000,
              ),
            ]),
          ),
          categoryPickerNotifierProvider.overrideWith(
            FakeCategoryPickerNotifier.new,
          ),
        ],
        child: const MaterialApp(home: RecurringTransactionsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Create Recurring Transaction'), findsOneWidget);

    // Category selection is already covered by the form test.
    // This page test only verifies the page-level refresh wiring.
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('recurring-amount')), '500000');

    final createButton = find.byType(FilledButton);
    expect(createButton, findsOneWidget);

    final button = tester.widget<FilledButton>(createButton);
    expect(button.onPressed, isNotNull);

    button.onPressed!();
    await tester.pumpAndSettle();

    expect(createUseCase.calls, hasLength(1));

    final call = createUseCase.calls.single;

    expect(call.transactionType, TransactionType.income);
    expect(call.amountMinor, 500000);
    expect(call.accountId, 'account-cash');
    expect(call.categoryId, isNull);
    expect(call.frequency, RecurringFrequency.monthly);
    expect(call.interval, 1);

    expect(notifier.refreshCallCount, 1);
  });
}

class FakeRecurringTransactionNotifier extends RecurringTransactionNotifier {
  int refreshCallCount = 0;

  @override
  Future<RecurringTransactionState> build() async {
    return const RecurringTransactionState();
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
  }
}

class FakeCategoryPickerNotifier extends CategoryPickerNotifier {
  @override
  Future<CategoryPickerState> build() async {
    return const CategoryPickerState(
      items: [CategoryPickerItem(categoryId: 'category-food', name: 'Food')],
    );
  }
}

class FakeCreateRecurringTransaction implements CreateRecurringTransaction {
  final List<CreateCall> calls = [];

  @override
  Future<RecurringTransaction> execute({
    required TransactionType transactionType,
    required int amountMinor,
    required String currencyCode,
    required String accountId,
    required String? categoryId,
    required String? merchantId,
    required String? notes,
    required RecurringFrequency frequency,
    required int interval,
    required int startDate,
    required int? endDate,
    required int nextOccurrenceDate,
  }) async {
    calls.add(
      CreateCall(
        transactionType: transactionType,
        amountMinor: amountMinor,
        accountId: accountId,
        categoryId: categoryId,
        frequency: frequency,
        interval: interval,
      ),
    );

    return RecurringTransaction(
      id: 'recurring-1',
      transactionType: transactionType,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      accountId: accountId,
      categoryId: categoryId,
      merchantId: merchantId,
      notes: notes,
      frequency: frequency,
      interval: interval,
      startDate: startDate,
      endDate: endDate,
      nextOccurrenceDate: nextOccurrenceDate,
      isActive: true,
      createdAt: 1000,
      updatedAt: 1000,
    );
  }
}

class CreateCall {
  const CreateCall({
    required this.transactionType,
    required this.amountMinor,
    required this.accountId,
    required this.categoryId,
    required this.frequency,
    required this.interval,
  });

  final TransactionType transactionType;
  final int amountMinor;
  final String accountId;
  final String? categoryId;
  final RecurringFrequency frequency;
  final int interval;
}
