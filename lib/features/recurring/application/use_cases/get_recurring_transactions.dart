import '../../data/repositories/recurring_transaction_repository.dart';
import '../../domain/entities/recurring_transaction.dart';

class GetRecurringTransactions {
  const GetRecurringTransactions(this._repository);

  final RecurringTransactionRepository _repository;

  Future<List<RecurringTransaction>> execute() {
    return _repository.getAllActive();
  }
}
