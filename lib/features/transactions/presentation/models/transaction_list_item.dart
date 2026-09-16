import 'transaction_type_presentation.dart';

class TransactionListItem {
  const TransactionListItem({
    required this.id,
    required this.type,
    required this.currencyCode,
    required this.amountMinor,
    required this.transactionDate,
    this.merchantName,
    this.categoryName,
    this.accountName,
  });

  final String id;
  final TransactionTypePresentation type;
  final String currencyCode;
  final int amountMinor;
  final int transactionDate;
  final String? merchantName;
  final String? categoryName;
  final String? accountName;
}
