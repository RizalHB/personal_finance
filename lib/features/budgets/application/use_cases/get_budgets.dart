import '../../data/repositories/budget_repository.dart';
import '../../domain/entities/budget.dart';

class GetBudgets {
  const GetBudgets(this._repository);

  final BudgetRepository _repository;

  Future<List<Budget>> execute() {
    return _repository.getAll();
  }
}
