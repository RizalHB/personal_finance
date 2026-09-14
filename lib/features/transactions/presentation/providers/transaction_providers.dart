import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/use_cases/create_split_expense.dart';
import '../../application/use_cases/create_transfer.dart';
import '../../application/use_cases/void_transaction.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../application/transaction_dependencies.dart';
import '../../application/use_cases/create_transaction.dart';
import '../../application/use_cases/replace_transaction_splits.dart';

final createTransactionProvider = Provider<CreateTransaction>((ref) {
  return CreateTransaction(
    ref.watch(transactionRepositoryProvider),
    ref.watch(transactionValidatorProvider),
    ref.watch(idGeneratorProvider),
  );
});
final voidTransactionProvider = Provider<VoidTransaction>((ref) {
  return VoidTransaction(
    ref.watch(transactionRepositoryProvider),
    ref.watch(transactionValidatorProvider),
  );
});
final createTransferProvider = Provider<CreateTransfer>((ref) {
  return CreateTransfer(
    ref.watch(transactionRepositoryProvider),
    ref.watch(transactionValidatorProvider),
  );
});
final replaceTransactionSplitsProvider = Provider<ReplaceTransactionSplits>((
  ref,
) {
  return ReplaceTransactionSplits(
    ref.watch(transactionSplitRepositoryProvider),
    ref.watch(transactionSplitValidatorProvider),
  );
});
final createSplitExpenseProvider = Provider<CreateSplitExpense>((ref) {
  return CreateSplitExpense(
    ref.watch(transactionRepositoryProvider),
    ref.watch(transactionValidatorProvider),
    ref.watch(transactionSplitValidatorProvider),
    ref.watch(idGeneratorProvider),
  );
});
