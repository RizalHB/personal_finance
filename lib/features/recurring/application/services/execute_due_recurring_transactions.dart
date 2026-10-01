import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/utils/id_generator.dart';

import '../../data/repositories/recurring_transaction_repository.dart';
import '../../../transactions/data/writers/drift_transaction_writer.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/services/recurring_occurrence_calculator.dart';

class ExecuteDueRecurringTransactions {
  const ExecuteDueRecurringTransactions({
    required this.database,
    required this.recurringTransactionRepository,
    required this.transactionWriter,
    required this.occurrenceCalculator,
    required this.idGenerator,
  });

  final db.AppDatabase database;
  final RecurringTransactionRepository recurringTransactionRepository;
  final DriftTransactionWriter transactionWriter;
  final RecurringOccurrenceCalculator occurrenceCalculator;
  final IdGenerator idGenerator;

  Future<int> execute({required int executionDate}) async {
    final recurringTransactions = await recurringTransactionRepository
        .getAllActive();

    var generatedCount = 0;

    for (final recurringTransaction in recurringTransactions) {
      generatedCount += await _executeSchedule(
        recurringTransaction: recurringTransaction,
        executionDate: executionDate,
      );
    }

    return generatedCount;
  }

  Future<int> _executeSchedule({
    required RecurringTransaction recurringTransaction,
    required int executionDate,
  }) async {
    return database.transaction(() async {
      var occurrenceDate = recurringTransaction.nextOccurrenceDate;
      var generatedCount = 0;

      while (occurrenceDate <= executionDate) {
        final endDate = recurringTransaction.endDate;

        if (endDate != null && occurrenceDate > endDate) {
          break;
        }

        final occurrenceId = '${recurringTransaction.id}-$occurrenceDate';

        final existingOccurrence =
            await (database.select(database.recurringTransactionOccurrences)
                  ..where((occurrence) => occurrence.id.equals(occurrenceId)))
                .getSingleOrNull();

        if (existingOccurrence == null) {
          final transactionId = idGenerator.generate();
          final generatedAt = DateTime.now().millisecondsSinceEpoch;

          await transactionWriter.write(
            id: transactionId,
            type: recurringTransaction.transactionType,
            amountMinor: recurringTransaction.amountMinor,
            transactionDate: occurrenceDate,
            currencyCode: recurringTransaction.currencyCode,
            accountId: recurringTransaction.accountId,
            categoryId: recurringTransaction.categoryId!,
            merchantId: recurringTransaction.merchantId,
            notes: recurringTransaction.notes,
            recurringTransactionId: recurringTransaction.id,
            createdAt: generatedAt,
          );

          await database
              .into(database.recurringTransactionOccurrences)
              .insert(
                db.RecurringTransactionOccurrencesCompanion.insert(
                  id: occurrenceId,
                  recurringTransactionId: recurringTransaction.id,
                  occurrenceDate: occurrenceDate,
                  transactionId: transactionId,
                  generatedAt: generatedAt,
                ),
              );

          generatedCount++;
        }

        final nextOccurrenceDate = occurrenceCalculator.nextOccurrence(
          recurringTransaction: recurringTransaction,
          occurrenceDate: occurrenceDate,
        );

        await (database.update(database.recurringTransactions)..where(
              (transaction) => transaction.id.equals(recurringTransaction.id),
            ))
            .write(
              db.RecurringTransactionsCompanion(
                nextOccurrenceDate: Value(nextOccurrenceDate),
                updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
              ),
            );

        occurrenceDate = nextOccurrenceDate;
      }

      return generatedCount;
    });
  }
}
