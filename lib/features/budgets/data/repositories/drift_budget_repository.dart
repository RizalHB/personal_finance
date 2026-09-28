import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;

import '../../domain/entities/budget.dart';
import 'budget_repository.dart';

class DriftBudgetRepository implements BudgetRepository {
  const DriftBudgetRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<Budget?> getByYearMonth({
    required int year,
    required int month,
  }) async {
    final row =
        await (_database.select(_database.budgets)..where(
              (budget) => budget.year.equals(year) & budget.month.equals(month),
            ))
            .getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<Budget?> getById(String id) async {
    final row = await (_database.select(
      _database.budgets,
    )..where((budget) => budget.id.equals(id))).getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<List<Budget>> getAll() async {
    final rows =
        await (_database.select(_database.budgets)..orderBy([
              (budget) => OrderingTerm.desc(budget.year),
              (budget) => OrderingTerm.desc(budget.month),
            ]))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<Budget> create({required Budget budget}) async {
    await _database
        .into(_database.budgets)
        .insert(
          db.BudgetsCompanion.insert(
            id: budget.id,
            year: budget.year,
            month: budget.month,
            name: budget.name,
            status: budget.status.code,
            createdAt: budget.createdAt,
            updatedAt: budget.updatedAt,
          ),
        );

    return budget;
  }

  @override
  Future<void> archive(String id) async {
    await (_database.update(_database.budgets)
          ..where((budget) => budget.id.equals(id)))
        .write(db.BudgetsCompanion(status: Value(BudgetStatus.archived.code)));
  }

  @override
  Future<void> restore(String id) async {
    await (_database.update(_database.budgets)
          ..where((budget) => budget.id.equals(id)))
        .write(db.BudgetsCompanion(status: Value(BudgetStatus.active.code)));
  }
}

extension on db.Budget {
  Budget toDomain() {
    return Budget(
      id: id,
      year: year,
      month: month,
      name: name,
      status: BudgetStatus.fromCode(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
