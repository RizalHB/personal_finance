import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/drift_recurring_transaction_repository.dart';
import '../data/repositories/recurring_transaction_repository.dart';
import '../domain/validators/recurring_transaction_validator.dart';
import 'use_cases/create_recurring_transaction.dart';
import 'use_cases/delete_recurring_transaction.dart';
import 'use_cases/update_recurring_transaction.dart';
import 'use_cases/get_recurring_transactions.dart';

import '../application/services/execute_due_recurring_transactions.dart';
import '../domain/services/recurring_occurrence_calculator.dart';
import '../../transactions/data/writers/drift_transaction_writer.dart';
import 'services/run_due_recurring_transactions.dart';

final recurringTransactionRepositoryProvider =
    Provider<RecurringTransactionRepository>((ref) {
      final database = ref.watch(appDatabaseProvider);

      return DriftRecurringTransactionRepository(database);
    });

final recurringTransactionValidatorProvider =
    Provider<RecurringTransactionValidator>((ref) {
      return const RecurringTransactionValidator();
    });

final createRecurringTransactionProvider = Provider<CreateRecurringTransaction>(
  (ref) {
    return CreateRecurringTransaction(
      ref.watch(recurringTransactionRepositoryProvider),
      ref.watch(recurringTransactionValidatorProvider),
      ref.watch(idGeneratorProvider),
    );
  },
);

final updateRecurringTransactionProvider = Provider<UpdateRecurringTransaction>(
  (ref) {
    return UpdateRecurringTransaction(
      ref.watch(recurringTransactionRepositoryProvider),
      ref.watch(recurringTransactionValidatorProvider),
    );
  },
);

final deleteRecurringTransactionProvider = Provider<DeleteRecurringTransaction>(
  (ref) {
    return DeleteRecurringTransaction(
      ref.watch(recurringTransactionRepositoryProvider),
    );
  },
);
final getRecurringTransactionsProvider = Provider<GetRecurringTransactions>((
  ref,
) {
  return GetRecurringTransactions(
    ref.watch(recurringTransactionRepositoryProvider),
  );
});
final recurringOccurrenceCalculatorProvider =
    Provider<RecurringOccurrenceCalculator>((ref) {
      return const RecurringOccurrenceCalculator();
    });

final executeDueRecurringTransactionsProvider =
    Provider<ExecuteDueRecurringTransactions>((ref) {
      return ExecuteDueRecurringTransactions(
        database: ref.watch(appDatabaseProvider),
        recurringTransactionRepository: ref.watch(
          recurringTransactionRepositoryProvider,
        ),
        transactionWriter: DriftTransactionWriter(
          ref.watch(appDatabaseProvider),
        ),
        occurrenceCalculator: ref.watch(recurringOccurrenceCalculatorProvider),
        idGenerator: ref.watch(idGeneratorProvider),
      );
    });
final runDueRecurringTransactionsProvider =
    Provider<RunDueRecurringTransactions>((ref) {
      return RunDueRecurringTransactions(
        ref.watch(executeDueRecurringTransactionsProvider),
      );
    });
