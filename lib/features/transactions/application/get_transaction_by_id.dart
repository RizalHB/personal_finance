import '../data/repositories/transaction_repository.dart';
import '../domain/entities/transaction.dart';

class GetTransactionById {
  const GetTransactionById(this._repository);

  final TransactionRepository _repository;

  Future<Transaction?> execute(String id) {
    return _repository.getById(id);
  }
}
