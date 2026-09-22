import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/transaction_details_repository.dart';
import 'use_cases/get_transaction_by_id_with_details.dart';
import 'get_transaction_by_id.dart';
import '../data/repositories/transaction_details_search_repository.dart';
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
final transactionDetailsSearchRepositoryProvider =
    Provider<TransactionDetailsSearchRepository>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);

      return repository as TransactionDetailsSearchRepository;
    });
final transactionDetailsRepositoryProvider =
    Provider<TransactionDetailsRepository>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);

      return repository as TransactionDetailsRepository;
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
final getTransactionByIdProvider = Provider<GetTransactionById>((ref) {
  return GetTransactionById(ref.watch(transactionRepositoryProvider));
});
final getTransactionByIdWithDetailsProvider =
    Provider<GetTransactionByIdWithDetails>((ref) {
      return GetTransactionByIdWithDetails(
        ref.watch(transactionDetailsRepositoryProvider),
      );
    });
