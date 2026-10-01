import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/features/recurring/domain/services/recurring_occurrence_calculator.dart';

void main() {
  const calculator = RecurringOccurrenceCalculator();

  RecurringTransaction schedule({
    required RecurringFrequency frequency,
    required int interval,
  }) {
    return RecurringTransaction(
      id: 'recurring-1',
      transactionType: TransactionType.expense,
      amountMinor: 100_000,
      currencyCode: 'IDR',
      accountId: 'account-1',
      categoryId: 'category-1',
      merchantId: null,
      notes: null,
      frequency: frequency,
      interval: interval,
      startDate: DateTime(2026, 1, 1).millisecondsSinceEpoch,
      endDate: null,
      nextOccurrenceDate: DateTime(2026, 1, 1).millisecondsSinceEpoch,
      isActive: true,
      createdAt: 1000,
      updatedAt: 1000,
    );
  }

  test('adds daily interval', () {
    final result = calculator.nextOccurrence(
      recurringTransaction: schedule(
        frequency: RecurringFrequency.daily,
        interval: 2,
      ),
      occurrenceDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
    );

    expect(DateTime.fromMillisecondsSinceEpoch(result), DateTime(2026, 9, 12));
  });

  test('adds weekly interval', () {
    final result = calculator.nextOccurrence(
      recurringTransaction: schedule(
        frequency: RecurringFrequency.weekly,
        interval: 2,
      ),
      occurrenceDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
    );

    expect(DateTime.fromMillisecondsSinceEpoch(result), DateTime(2026, 9, 24));
  });

  test('adds monthly interval and clamps end-of-month date', () {
    final result = calculator.nextOccurrence(
      recurringTransaction: schedule(
        frequency: RecurringFrequency.monthly,
        interval: 1,
      ),
      occurrenceDate: DateTime(2026, 1, 31).millisecondsSinceEpoch,
    );

    expect(DateTime.fromMillisecondsSinceEpoch(result), DateTime(2026, 2, 28));
  });

  test('adds yearly interval and clamps leap-day date', () {
    final result = calculator.nextOccurrence(
      recurringTransaction: schedule(
        frequency: RecurringFrequency.yearly,
        interval: 1,
      ),
      occurrenceDate: DateTime(2028, 2, 29).millisecondsSinceEpoch,
    );

    expect(DateTime.fromMillisecondsSinceEpoch(result), DateTime(2029, 2, 28));
  });
}
