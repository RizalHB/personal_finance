import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/utils/id_generator.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/services/transaction_validator.dart';

class CreateTransaction {
  CreateTransaction(this._repository, this._validator, this._idGenerator);

  final TransactionRepository _repository;
  final TransactionValidator _validator;
  final IdGenerator _idGenerator;

  Future<Transaction> execute({
    required TransactionType type,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required String categoryId,
    String? merchantId,
    String? notes,
  }) {
    _validator.validateCreate(
      type: type,
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      currencyCode: currencyCode,
      accountId: accountId,
      categoryId: categoryId,
      notes: notes,
    );

    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();
    final normalizedAccountId = accountId.trim();
    final normalizedCategoryId = categoryId.trim();
    final normalizedMerchantId = merchantId?.trim();
    final normalizedNotes = notes?.trim();

    return _repository.createTransaction(
      id: _idGenerator.generate(),
      type: type,
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      currencyCode: normalizedCurrencyCode,
      accountId: normalizedAccountId,
      categoryId: normalizedCategoryId,
      merchantId: normalizedMerchantId?.isEmpty == true
          ? null
          : normalizedMerchantId,
      notes: normalizedNotes?.isEmpty == true ? null : normalizedNotes,
    );
  }
}
