import '../../domain/models/budget_actual.dart';

abstract interface class BudgetActualRepository {
  Future<List<BudgetActual>> getActualsForMonth({
    required int year,
    required int month,
  });
}
