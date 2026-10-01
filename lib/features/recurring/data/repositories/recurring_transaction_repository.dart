import '../../domain/entities/recurring_transaction.dart';

abstract interface class RecurringTransactionRepository {
  Future<RecurringTransaction?> getById(String id);

  Future<List<RecurringTransaction>> getAllActive();

  Future<RecurringTransaction> create({
    required RecurringTransaction recurringTransaction,
  });

  Future<RecurringTransaction> update({
    required RecurringTransaction recurringTransaction,
  });

  Future<void> delete(String id);
}
