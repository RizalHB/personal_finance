import '../../data/repositories/transaction_details_repository.dart';
import '../../domain/models/transaction_search_result.dart';

class GetTransactionByIdWithDetails {
  const GetTransactionByIdWithDetails(this._repository);

  final TransactionDetailsRepository _repository;

  Future<TransactionSearchResult?> execute(String id) {
    return _repository.getByIdWithDetails(id);
  }
}
