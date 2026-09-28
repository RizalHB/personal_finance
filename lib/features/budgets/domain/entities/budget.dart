enum BudgetStatus {
  active(1),
  archived(2);

  const BudgetStatus(this.code);

  final int code;

  static BudgetStatus fromCode(int code) {
    for (final status in values) {
      if (status.code == code) {
        return status;
      }
    }

    throw ArgumentError('Unknown budget status code: $code');
  }
}

class Budget {
  const Budget({
    required this.id,
    required this.year,
    required this.month,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int year;
  final int month;
  final String name;
  final BudgetStatus status;
  final int createdAt;
  final int updatedAt;
}
