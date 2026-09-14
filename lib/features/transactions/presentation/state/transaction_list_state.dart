import '../../domain/entities/transaction.dart';

sealed class TransactionListState {
  const TransactionListState();
}

final class TransactionListInitial extends TransactionListState {
  const TransactionListInitial();
}

final class TransactionListLoading extends TransactionListState {
  const TransactionListLoading();
}

final class TransactionListLoaded extends TransactionListState {
  const TransactionListLoaded(this.transactions);

  final List<Transaction> transactions;
}

final class TransactionListEmpty extends TransactionListState {
  const TransactionListEmpty();
}

final class TransactionListError extends TransactionListState {
  const TransactionListError(this.message);

  final String message;
}
