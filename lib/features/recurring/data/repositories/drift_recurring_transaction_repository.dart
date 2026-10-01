import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;

import '../../../../core/domain/transaction_type.dart';
import '../../domain/entities/recurring_transaction.dart';
import 'recurring_transaction_repository.dart';

class DriftRecurringTransactionRepository
    implements RecurringTransactionRepository {
  const DriftRecurringTransactionRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<RecurringTransaction?> getById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Recurring transaction ID cannot be empty.');
    }

    final row =
        await (_database.select(_database.recurringTransactions)
              ..where((transaction) => transaction.id.equals(normalizedId)))
            .getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<List<RecurringTransaction>> getAllActive() async {
    final rows =
        await (_database.select(_database.recurringTransactions)
              ..where((transaction) => transaction.isActive.equals(true))
              ..orderBy([
                (transaction) =>
                    OrderingTerm.asc(transaction.nextOccurrenceDate),
                (transaction) => OrderingTerm.asc(transaction.id),
              ]))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<RecurringTransaction> create({
    required RecurringTransaction recurringTransaction,
  }) async {
    await _database
        .into(_database.recurringTransactions)
        .insert(
          db.RecurringTransactionsCompanion.insert(
            id: recurringTransaction.id,
            transactionType: recurringTransaction.transactionType.code,
            amountMinor: recurringTransaction.amountMinor,
            currencyCode: recurringTransaction.currencyCode,
            accountId: recurringTransaction.accountId,
            categoryId: Value(recurringTransaction.categoryId),
            merchantId: Value(recurringTransaction.merchantId),
            notes: Value(recurringTransaction.notes),
            frequency: recurringTransaction.frequency.code,
            interval: recurringTransaction.interval,
            startDate: recurringTransaction.startDate,
            endDate: Value(recurringTransaction.endDate),
            nextOccurrenceDate: recurringTransaction.nextOccurrenceDate,
            isActive: recurringTransaction.isActive,
            createdAt: recurringTransaction.createdAt,
            updatedAt: recurringTransaction.updatedAt,
          ),
        );

    return recurringTransaction;
  }

  @override
  Future<RecurringTransaction> update({
    required RecurringTransaction recurringTransaction,
  }) async {
    await (_database.update(_database.recurringTransactions)..where(
          (transaction) => transaction.id.equals(recurringTransaction.id),
        ))
        .write(
          db.RecurringTransactionsCompanion(
            transactionType: Value(recurringTransaction.transactionType.code),
            amountMinor: Value(recurringTransaction.amountMinor),
            currencyCode: Value(recurringTransaction.currencyCode),
            accountId: Value(recurringTransaction.accountId),
            categoryId: Value(recurringTransaction.categoryId),
            merchantId: Value(recurringTransaction.merchantId),
            notes: Value(recurringTransaction.notes),
            frequency: Value(recurringTransaction.frequency.code),
            interval: Value(recurringTransaction.interval),
            startDate: Value(recurringTransaction.startDate),
            endDate: Value(recurringTransaction.endDate),
            nextOccurrenceDate: Value(recurringTransaction.nextOccurrenceDate),
            isActive: Value(recurringTransaction.isActive),
            updatedAt: Value(recurringTransaction.updatedAt),
          ),
        );

    return recurringTransaction;
  }

  @override
  Future<void> delete(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Recurring transaction ID cannot be empty.');
    }

    await (_database.delete(
      _database.recurringTransactions,
    )..where((transaction) => transaction.id.equals(normalizedId))).go();
  }
}

extension on db.RecurringTransaction {
  RecurringTransaction toDomain() {
    return RecurringTransaction(
      id: id,
      transactionType: TransactionType.fromCode(transactionType),
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      accountId: accountId,
      categoryId: categoryId,
      merchantId: merchantId,
      notes: notes,
      frequency: RecurringFrequency.fromCode(frequency),
      interval: interval,
      startDate: startDate,
      endDate: endDate,
      nextOccurrenceDate: nextOccurrenceDate,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
