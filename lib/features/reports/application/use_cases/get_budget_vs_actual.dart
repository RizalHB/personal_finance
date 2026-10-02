import '../../data/repositories/budget_vs_actual_report_repository.dart';
import '../../domain/models/budget_vs_actual.dart';

class GetBudgetVsActual {
  const GetBudgetVsActual(this._repository);

  final BudgetVsActualReportRepository _repository;

  Future<List<BudgetVsActual>> execute({required String budgetId}) {
    final normalizedBudgetId = budgetId.trim();

    if (normalizedBudgetId.isEmpty) {
      throw ArgumentError('Budget ID cannot be empty.');
    }

    return _repository.getBudgetVsActual(budgetId: normalizedBudgetId);
  }
}
