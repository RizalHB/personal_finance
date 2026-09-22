import '../../domain/models/transaction_search_result.dart';

abstract interface class TransactionDetailsRepository {
  Future<TransactionSearchResult?> getByIdWithDetails(String id);
}
