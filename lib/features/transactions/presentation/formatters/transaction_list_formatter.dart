import 'package:intl/intl.dart';

class TransactionListFormatter {
  const TransactionListFormatter();

  String formatAmount({
    required int amountMinor,
    required String currencyCode,
    String locale = 'id_ID',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: currencyCode == 'IDR' ? 'Rp' : null,
      decimalDigits: currencyCode == 'IDR' ? 0 : 2,
    );

    return formatter.format(amountMinor);
  }

  String formatDate(int transactionDate, {String locale = 'id_ID'}) {
    final date = DateTime.fromMillisecondsSinceEpoch(transactionDate);

    return DateFormat.yMMMd(locale).format(date);
  }
}
