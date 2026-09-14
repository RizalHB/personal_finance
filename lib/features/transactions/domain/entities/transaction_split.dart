class TransactionSplit {
  const TransactionSplit({
    required this.id,
    required this.transactionId,
    required this.categoryId,
    required this.amountMinor,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String transactionId;
  final String categoryId;
  final int amountMinor;
  final String? notes;
  final int createdAt;
  final int updatedAt;
}
