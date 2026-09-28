import '../../domain/entities/budget.dart';

abstract interface class BudgetRepository {
  Future<Budget?> getByYearMonth({required int year, required int month});

  Future<Budget?> getById(String id);

  Future<List<Budget>> getAll();

  Future<Budget> create({required Budget budget});

  Future<void> archive(String id);

  Future<void> restore(String id);
}
