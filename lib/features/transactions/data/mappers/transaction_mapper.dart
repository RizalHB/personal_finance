import 'package:personal_finance/core/database/app_database.dart' as database;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/entities/transaction.dart';

extension TransactionMapper on database.Transaction {
  Transaction toDomain() {
    return Transaction(
      id: id,
      type: TransactionType.fromCode(transactionType),
      status: TransactionStatus.fromCode(status),
      transactionDate: transactionDate,
      currencyCode: currencyCode,
      amountMinor: amountMinor,
      accountId: accountId,
      categoryId: categoryId,
      merchantId: merchantId,
      notes: notes,
      relatedTransactionId: relatedTransactionId,
      recurringTransactionId: recurringTransactionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      voidedAt: voidedAt,
    );
  }
}
