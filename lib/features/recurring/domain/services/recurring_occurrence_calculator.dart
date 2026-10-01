import '../entities/recurring_transaction.dart';

class RecurringOccurrenceCalculator {
  const RecurringOccurrenceCalculator();

  int nextOccurrence({
    required RecurringTransaction recurringTransaction,
    required int occurrenceDate,
  }) {
    final date = DateTime.fromMillisecondsSinceEpoch(occurrenceDate);

    final nextDate = switch (recurringTransaction.frequency) {
      RecurringFrequency.daily => date.add(
        Duration(days: recurringTransaction.interval),
      ),
      RecurringFrequency.weekly => date.add(
        Duration(days: recurringTransaction.interval * 7),
      ),
      RecurringFrequency.monthly => _addMonths(
        date,
        recurringTransaction.interval,
      ),
      RecurringFrequency.yearly => _addYears(
        date,
        recurringTransaction.interval,
      ),
    };

    return nextDate.millisecondsSinceEpoch;
  }

  DateTime _addMonths(DateTime date, int months) {
    final targetMonth = date.month - 1 + months;
    final year = date.year + targetMonth ~/ 12;
    final month = targetMonth % 12 + 1;

    final lastDay = DateTime(
      year,
      month + 1,
      0,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    ).day;

    return DateTime(
      year,
      month,
      date.day > lastDay ? lastDay : date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  DateTime _addYears(DateTime date, int years) {
    final year = date.year + years;

    final lastDay = DateTime(
      year,
      date.month + 1,
      0,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    ).day;

    return DateTime(
      year,
      date.month,
      date.day > lastDay ? lastDay : date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}
