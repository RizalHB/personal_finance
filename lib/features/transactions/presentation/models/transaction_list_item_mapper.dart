import '../../domain/entities/transaction.dart';
import 'transaction_list_item.dart';
import 'transaction_type_presentation.dart';

class TransactionListItemMapper {
  const TransactionListItemMapper();

  TransactionListItem map(Transaction transaction) {
    return TransactionListItem(
      id: transaction.id,
      type: TransactionTypePresentation.fromType(transaction.type),
      currencyCode: transaction.currencyCode,
      amountMinor: transaction.amountMinor,
      transactionDate: transaction.transactionDate,
    );
  }
}
