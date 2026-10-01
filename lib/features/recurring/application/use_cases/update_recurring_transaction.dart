import '../../../../core/domain/transaction_type.dart';
import '../../data/repositories/recurring_transaction_repository.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/validators/recurring_transaction_validator.dart';

class UpdateRecurringTransaction {
  const UpdateRecurringTransaction(this._repository, this._validator);

  final RecurringTransactionRepository _repository;
  final RecurringTransactionValidator _validator;

  Future<RecurringTransaction> execute({
    required String id,
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
    required bool isActive,
  }) async {
    final normalizedId = id.trim();
    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();
    final normalizedAccountId = accountId.trim();
    final normalizedCategoryId = categoryId?.trim();
    final normalizedMerchantId = merchantId?.trim();
    final normalizedNotes = notes?.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Recurring transaction ID cannot be empty.');
    }

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

    final existing = await _repository.getById(normalizedId);

    if (existing == null) {
      throw StateError('Recurring transaction not found: $normalizedId');
    }

    final updated = RecurringTransaction(
      id: existing.id,
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
      isActive: isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    return _repository.update(recurringTransaction: updated);
  }
}
