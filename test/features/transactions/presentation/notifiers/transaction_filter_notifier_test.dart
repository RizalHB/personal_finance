import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/presentation/notifiers/transaction_filter_notifier.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_list_providers.dart';

void main() {
  test('starts with an empty filter state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(transactionFilterNotifierProvider);

    expect(state.type, isNull);
    expect(state.fromDate, isNull);
    expect(state.toDate, isNull);
    expect(state.searchQuery, isEmpty);
  });

  test('setType preserves the other filter values', () {
    final container = ProviderContainer(
      overrides: [
        transactionFilterNotifierProvider.overrideWith(
          TransactionFilterNotifier.new,
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(transactionFilterNotifierProvider.notifier);

    notifier.setType(TransactionType.expense);

    final state = container.read(transactionFilterNotifierProvider);

    expect(state.type, TransactionType.expense);
    expect(state.fromDate, isNull);
    expect(state.toDate, isNull);
    expect(state.searchQuery, isEmpty);
  });

  test('reset returns to the default filter state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(transactionFilterNotifierProvider.notifier);

    notifier.setType(TransactionType.income);
    notifier.reset();

    final state = container.read(transactionFilterNotifierProvider);

    expect(state.type, isNull);
    expect(state.fromDate, isNull);
    expect(state.toDate, isNull);
    expect(state.searchQuery, isEmpty);
  });
  test('setDateRange updates dates and preserves transaction type', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(transactionFilterNotifierProvider.notifier);

    notifier.setType(TransactionType.expense);
    notifier.setDateRange(fromDate: 1000, toDate: 2000);

    final state = container.read(transactionFilterNotifierProvider);

    expect(state.type, TransactionType.expense);
    expect(state.fromDate, 1000);
    expect(state.toDate, 2000);
  });

  test('setSearchQuery updates the query', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(transactionFilterNotifierProvider.notifier);

    notifier.setSearchQuery('  Tokopedia  ');

    final state = container.read(transactionFilterNotifierProvider);

    expect(state.searchQuery, '  Tokopedia  ');
    expect(state.toDomain().searchQuery, 'Tokopedia');
  });
}
