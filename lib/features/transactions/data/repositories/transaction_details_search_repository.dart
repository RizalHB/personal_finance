import '../../domain/models/transaction_filter.dart';
import '../../domain/models/transaction_search_result.dart';

abstract interface class TransactionDetailsSearchRepository {
  Future<List<TransactionSearchResult>> searchWithDetails(
    TransactionFilter filter,
  );
}
