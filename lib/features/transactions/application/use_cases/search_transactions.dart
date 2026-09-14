import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/models/transaction_filter.dart';

class SearchTransactions {
  const SearchTransactions(this._repository);

  final TransactionRepository _repository;

  Future<List<Transaction>> execute(TransactionFilter filter) {
    return _repository.search(filter);
  }
}
