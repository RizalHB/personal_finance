import '../../data/repositories/transaction_details_search_repository.dart';
import '../../domain/models/transaction_filter.dart';
import '../../domain/models/transaction_search_result.dart';

class SearchTransactionsWithDetails {
  const SearchTransactionsWithDetails(this._repository);

  final TransactionDetailsSearchRepository _repository;

  Future<List<TransactionSearchResult>> execute(TransactionFilter filter) {
    return _repository.searchWithDetails(filter);
  }
}
