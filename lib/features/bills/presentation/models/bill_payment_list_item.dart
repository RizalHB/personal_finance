class BillPaymentListItem {
  const BillPaymentListItem({
    required this.paymentId,
    required this.amountMinor,
    required this.paidAt,
  });

  final String paymentId;
  final int amountMinor;
  final int paidAt;
}
