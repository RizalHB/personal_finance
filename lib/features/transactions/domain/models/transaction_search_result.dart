import '../entities/transaction.dart';

class TransactionSearchResult {
  const TransactionSearchResult({
    required this.transaction,
    this.categoryName,
    this.merchantName,
    this.accountName,
  });

  final Transaction transaction;
  final String? categoryName;
  final String? merchantName;
  final String? accountName;
}
