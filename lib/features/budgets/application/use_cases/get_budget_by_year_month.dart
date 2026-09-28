import '../../data/repositories/budget_repository.dart';
import '../../domain/entities/budget.dart';

class GetBudgetByYearMonth {
  const GetBudgetByYearMonth(this._repository);

  final BudgetRepository _repository;

  Future<Budget?> execute({required int year, required int month}) {
    return _repository.getByYearMonth(year: year, month: month);
  }
}
