class BillListItem {
  const BillListItem({
    required this.billId,
    required this.name,
    required this.amountMinor,
    required this.currencyCode,
    required this.dueDate,
    required this.statusLabel,
    required this.isActive,
  });

  final String billId;
  final String name;
  final int? amountMinor;
  final String currencyCode;
  final int dueDate;
  final String statusLabel;
  final bool isActive;
}
