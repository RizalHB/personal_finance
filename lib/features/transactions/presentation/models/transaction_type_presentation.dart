import 'package:personal_finance/core/domain/transaction_type.dart';

enum TransactionTypePresentation {
  income(TransactionType.income, 'income'),
  expense(TransactionType.expense, 'expense'),
  transfer(TransactionType.transfer, 'transfer'),
  adjustment(TransactionType.adjustment, 'adjustment'),
  openingBalance(TransactionType.openingBalance, 'opening_balance');

  const TransactionTypePresentation(this.type, this.localizationKey);

  final TransactionType type;
  final String localizationKey;

  static TransactionTypePresentation fromType(TransactionType type) {
    for (final value in values) {
      if (value.type == type) {
        return value;
      }
    }

    throw ArgumentError('Unsupported transaction type: $type');
  }
}
