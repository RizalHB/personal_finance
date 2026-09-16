import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_list_item_mapper.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_presentation.dart';

void main() {
  test('maps transaction fields to list item', () {
    const transaction = Transaction(
      id: 'transaction-1',
      type: TransactionType.expense,
      status: TransactionStatus.posted,
      transactionDate: 1000,
      currencyCode: 'IDR',
      amountMinor: 50000,
      accountId: 'account-bca',
      categoryId: 'category-food',
      merchantId: 'merchant-1',
      notes: 'Makan',
      relatedTransactionId: null,
      recurringTransactionId: null,
      createdAt: 1000,
      updatedAt: 1000,
      voidedAt: null,
    );

    const mapper = TransactionListItemMapper();

    final item = mapper.map(transaction);

    expect(item.id, 'transaction-1');
    expect(item.type, TransactionTypePresentation.expense);
    expect(item.currencyCode, 'IDR');
    expect(item.amountMinor, 50000);
    expect(item.transactionDate, 1000);
  });
}
