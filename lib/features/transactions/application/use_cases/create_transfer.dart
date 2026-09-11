import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/services/transaction_validator.dart';

class CreateTransfer {
  const CreateTransfer(
    this._repository,
    this._validator,
  );

  final TransactionRepository _repository;
  final TransactionValidator _validator;

  Future<Transaction> execute({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String fromAccountId,
    required String toAccountId,
  }) {
    final normalizedCurrency = currencyCode.trim().toUpperCase();
    final normalizedFromAccountId = fromAccountId.trim();
    final normalizedToAccountId = toAccountId.trim();

    _validator.validateTransfer(
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      currencyCode: normalizedCurrency,
      fromAccountId: normalizedFromAccountId,
      toAccountId: normalizedToAccountId,
    );

    return _repository.createTransfer(
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      currencyCode: normalizedCurrency,
      fromAccountId: normalizedFromAccountId,
      toAccountId: normalizedToAccountId,
    );
  }
}