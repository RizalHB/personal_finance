import '../../domain/models/budget_vs_actual.dart';

abstract interface class BudgetVsActualReportRepository {
  Future<List<BudgetVsActual>> getBudgetVsActual({required String budgetId});
}
