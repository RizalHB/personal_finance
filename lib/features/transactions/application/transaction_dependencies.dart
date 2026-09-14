import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/transaction_split_validator.dart';
import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/drift_transaction_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/services/transaction_validator.dart';
import '../data/repositories/drift_transaction_split_repository.dart';
import '../data/repositories/transaction_split_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftTransactionRepository(database);
});

final transactionValidatorProvider = Provider<TransactionValidator>((ref) {
  return TransactionValidator();
});
final transactionSplitValidatorProvider = Provider<TransactionSplitValidator>((
  ref,
) {
  return const TransactionSplitValidator();
});
final transactionSplitRepositoryProvider = Provider<TransactionSplitRepository>(
  (ref) {
    final database = ref.watch(appDatabaseProvider);

    return DriftTransactionSplitRepository(database);
  },
);
