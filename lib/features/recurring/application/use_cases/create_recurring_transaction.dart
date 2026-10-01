import '../../../../core/utils/id_generator.dart';
import '../../data/repositories/recurring_transaction_repository.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/validators/recurring_transaction_validator.dart';
import '../../../../core/domain/transaction_type.dart';

class CreateRecurringTransaction {
  const CreateRecurringTransaction(
    this._repository,
    this._validator,
    this._idGenerator,
  );

  final RecurringTransactionRepository _repository;
  final RecurringTransactionValidator _validator;
  final IdGenerator _idGenerator;

  Future<RecurringTransaction> execute({
    required TransactionType transactionType,
    required int amountMinor,
    required String currencyCode,
    required String accountId,
    required String? categoryId,
    required String? merchantId,
    required String? notes,
    required RecurringFrequency frequency,
    required int interval,
    required int startDate,
    required int? endDate,
    required int nextOccurrenceDate,
  }) async {
    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();
    final normalizedAccountId = accountId.trim();
    final normalizedCategoryId = categoryId?.trim();
    final normalizedMerchantId = merchantId?.trim();
    final normalizedNotes = notes?.trim();

    _validator.validateCreate(
      transactionType: transactionType,
      amountMinor: amountMinor,
      currencyCode: normalizedCurrencyCode,
      accountId: normalizedAccountId,
      categoryId: normalizedCategoryId,
      frequency: frequency,
      interval: interval,
      startDate: startDate,
      endDate: endDate,
      nextOccurrenceDate: nextOccurrenceDate,
    );

    final now = DateTime.now().millisecondsSinceEpoch;

    final recurringTransaction = RecurringTransaction(
      id: _idGenerator.generate(),
      transactionType: transactionType,
      amountMinor: amountMinor,
      currencyCode: normalizedCurrencyCode,
      accountId: normalizedAccountId,
      categoryId: normalizedCategoryId,
      merchantId: normalizedMerchantId,
      notes: normalizedNotes,
      frequency: frequency,
      interval: interval,
      startDate: startDate,
      endDate: endDate,
      nextOccurrenceDate: nextOccurrenceDate,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.create(recurringTransaction: recurringTransaction);
  }
}
