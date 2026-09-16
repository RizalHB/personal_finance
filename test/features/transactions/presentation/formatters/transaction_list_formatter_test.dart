import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personal_finance/features/transactions/presentation/formatters/transaction_list_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  const formatter = TransactionListFormatter();

  group('formatAmount', () {
    test('formats IDR without decimal digits', () {
      final result = formatter.formatAmount(
        amountMinor: 50000,
        currencyCode: 'IDR',
      );

      expect(result, 'Rp50.000');
    });

    test('formats zero IDR correctly', () {
      final result = formatter.formatAmount(
        amountMinor: 0,
        currencyCode: 'IDR',
      );

      expect(result, 'Rp0');
    });
  });

  group('formatDate', () {
    test('formats Indonesian date', () {
      final result = formatter.formatDate(
        DateTime(2026, 9, 14).millisecondsSinceEpoch,
      );

      expect(result, '14 Sep 2026');
    });
  });
}
