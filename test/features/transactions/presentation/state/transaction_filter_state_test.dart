import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_filter_state.dart';

void main() {
  test('converts presentation state to domain filter', () {
    const state = TransactionFilterState(
      type: TransactionType.expense,
      fromDate: 1000,
      toDate: 2000,
      minAmountMinor: 10000,
      maxAmountMinor: 50000,
      searchQuery: '  Tokopedia  ',
    );

    final filter = state.toDomain();

    expect(filter.type, TransactionType.expense);
    expect(filter.fromDate, 1000);
    expect(filter.toDate, 2000);
    expect(filter.minAmountMinor, 10000);
    expect(filter.maxAmountMinor, 50000);
    expect(filter.searchQuery, 'Tokopedia');
  });

  test('converts blank search query to null', () {
    const state = TransactionFilterState(searchQuery: '   ');

    final filter = state.toDomain();

    expect(filter.searchQuery, isNull);
  });
}
