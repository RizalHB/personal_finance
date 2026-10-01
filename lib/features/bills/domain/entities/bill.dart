enum BillStatus {
  active(1),
  paid(2),
  cancelled(3);

  const BillStatus(this.code);

  final int code;

  static BillStatus fromCode(int code) {
    for (final status in values) {
      if (status.code == code) {
        return status;
      }
    }

    throw ArgumentError('Unknown bill status code: $code');
  }
}

class Bill {
  const Bill({
    required this.id,
    required this.name,
    required this.amountMinor,
    required this.currencyCode,
    required this.dueDate,
    required this.status,
    required this.accountId,
    required this.categoryId,
    required this.merchantId,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.cancelledAt,
  });

  final String id;
  final String name;
  final int? amountMinor;
  final String currencyCode;
  final int dueDate;
  final BillStatus status;
  final String? accountId;
  final String? categoryId;
  final String? merchantId;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  final int? cancelledAt;
}
