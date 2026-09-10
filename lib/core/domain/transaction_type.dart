enum TransactionType {
  income(1),
  expense(2),
  transfer(3),
  adjustment(4),
  openingBalance(5);

  const TransactionType(this.code);

  final int code;

  static TransactionType fromCode(int code) {
    for (final type in values) {
      if (type.code == code) {
        return type;
      }
    }

    throw ArgumentError('Unknown transaction type code: $code');
  }
}
