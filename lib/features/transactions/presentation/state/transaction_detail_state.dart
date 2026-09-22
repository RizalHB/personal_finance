import '../../domain/models/transaction_search_result.dart';
import '../../domain/entities/transaction.dart';

sealed class TransactionDetailState {
  const TransactionDetailState();
}

class TransactionDetailInitial extends TransactionDetailState {
  const TransactionDetailInitial();
}

class TransactionDetailLoading extends TransactionDetailState {
  const TransactionDetailLoading();
}

class TransactionDetailLoaded extends TransactionDetailState {
  const TransactionDetailLoaded(this.result);

  final TransactionSearchResult result;

  Transaction get transaction => result.transaction;
}

class TransactionDetailNotFound extends TransactionDetailState {
  const TransactionDetailNotFound();
}

class TransactionDetailError extends TransactionDetailState {
  const TransactionDetailError(this.message);

  final String message;
}
