import 'package:personal_finance/core/database/app_database.dart' as database;

import '../../domain/entities/transaction_split.dart';

extension TransactionSplitMapper on database.TransactionSplit {
  TransactionSplit toDomain() {
    return TransactionSplit(
      id: id,
      transactionId: transactionId,
      categoryId: categoryId,
      amountMinor: amountMinor,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
