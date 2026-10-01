import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/recurring/application/recurring_dependencies.dart';
import 'package:personal_finance/features/recurring/application/use_cases/get_recurring_transactions.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/features/recurring/presentation/notifiers/recurring_transaction_notifier.dart';
import 'package:personal_finance/features/recurring/presentation/state/recurring_transaction_state.dart';

void main() {
  test('loads and maps recurring transactions', () async {
    final useCase = FakeGetRecurringTransactions([
      const RecurringTransaction(
        id: 'recurring-1',
        transactionType: TransactionType.expense,
        amountMinor: 500_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Monthly food',
        frequency: RecurringFrequency.monthly,
        interval: 1,
        startDate: 1_000,
        endDate: null,
        nextOccurrenceDate: 2_000,
        isActive: true,
        createdAt: 1_000,
        updatedAt: 1_000,
      ),
      const RecurringTransaction(
        id: 'recurring-2',
        transactionType: TransactionType.expense,
        amountMinor: 250_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-transport',
        merchantId: null,
        notes: null,
        frequency: RecurringFrequency.weekly,
        interval: 2,
        startDate: 1_000,
        endDate: null,
        nextOccurrenceDate: 3_000,
        isActive: true,
        createdAt: 1_000,
        updatedAt: 1_000,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [getRecurringTransactionsProvider.overrideWithValue(useCase)],
    );

    addTearDown(container.dispose);

    final state = await container.read(
      recurringTransactionNotifierProvider.future,
    );

    expect(state, isA<RecurringTransactionState>());
    expect(state.items, hasLength(2));

    expect(state.items[0].recurringTransactionId, 'recurring-1');
    expect(state.items[0].amountMinor, 500_000);
    expect(state.items[0].currencyCode, 'IDR');
    expect(state.items[0].categoryId, 'category-food');
    expect(state.items[0].frequencyLabel, 'Monthly');
    expect(state.items[0].interval, 1);
    expect(state.items[0].nextOccurrenceDate, 2_000);
    expect(state.items[0].isActive, isTrue);

    expect(state.items[1].recurringTransactionId, 'recurring-2');
    expect(state.items[1].frequencyLabel, 'Weekly');
    expect(state.items[1].interval, 2);

    expect(useCase.called, isTrue);
  });
}

class FakeGetRecurringTransactions implements GetRecurringTransactions {
  FakeGetRecurringTransactions(this.transactions);

  final List<RecurringTransaction> transactions;
  bool called = false;

  @override
  Future<List<RecurringTransaction>> execute() async {
    called = true;
    return transactions;
  }
}
