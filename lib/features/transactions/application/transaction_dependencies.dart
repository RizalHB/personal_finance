import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/drift_transaction_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/services/transaction_validator.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftTransactionRepository(database);
});

final transactionValidatorProvider = Provider<TransactionValidator>((ref) {
  return TransactionValidator();
});
