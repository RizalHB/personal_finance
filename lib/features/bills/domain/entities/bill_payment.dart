class BillPayment {
  const BillPayment({
    required this.id,
    required this.billId,
    required this.transactionId,
    required this.amountMinor,
    required this.paidAt,
    required this.createdAt,
  });

  final String id;
  final String billId;
  final String transactionId;
  final int amountMinor;
  final int paidAt;
  final int createdAt;
}
