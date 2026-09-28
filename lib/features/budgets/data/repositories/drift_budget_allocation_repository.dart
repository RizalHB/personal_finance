import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;

import '../../domain/entities/budget_allocation.dart';
import 'budget_allocation_repository.dart';

class DriftBudgetAllocationRepository implements BudgetAllocationRepository {
  const DriftBudgetAllocationRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<BudgetAllocation?> getById(String id) async {
    final row = await (_database.select(
      _database.budgetAllocations,
    )..where((allocation) => allocation.id.equals(id))).getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<List<BudgetAllocation>> getByBudgetId(String budgetId) async {
    final rows =
        await (_database.select(_database.budgetAllocations)
              ..where((allocation) => allocation.budgetId.equals(budgetId))
              ..orderBy([
                (allocation) => OrderingTerm.asc(allocation.createdAt),
              ]))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<BudgetAllocation?> getByBudgetAndCategory({
    required String budgetId,
    required String categoryId,
  }) async {
    final row =
        await (_database.select(_database.budgetAllocations)..where(
              (allocation) =>
                  allocation.budgetId.equals(budgetId) &
                  allocation.categoryId.equals(categoryId),
            ))
            .getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<BudgetAllocation> create({
    required BudgetAllocation allocation,
  }) async {
    await _database
        .into(_database.budgetAllocations)
        .insert(
          db.BudgetAllocationsCompanion.insert(
            id: allocation.id,
            budgetId: allocation.budgetId,
            categoryId: allocation.categoryId,
            plannedAmountMinor: allocation.plannedAmountMinor,
            createdAt: allocation.createdAt,
            updatedAt: allocation.updatedAt,
          ),
        );

    return allocation;
  }

  @override
  Future<BudgetAllocation> update({
    required BudgetAllocation allocation,
  }) async {
    await (_database.update(
      _database.budgetAllocations,
    )..where((row) => row.id.equals(allocation.id))).write(
      db.BudgetAllocationsCompanion(
        budgetId: Value(allocation.budgetId),
        categoryId: Value(allocation.categoryId),
        plannedAmountMinor: Value(allocation.plannedAmountMinor),
        updatedAt: Value(allocation.updatedAt),
      ),
    );

    return allocation;
  }

  @override
  Future<void> delete(String id) async {
    await (_database.delete(
      _database.budgetAllocations,
    )..where((allocation) => allocation.id.equals(id))).go();
  }
}

extension on db.BudgetAllocation {
  BudgetAllocation toDomain() {
    return BudgetAllocation(
      id: id,
      budgetId: budgetId,
      categoryId: categoryId,
      plannedAmountMinor: plannedAmountMinor,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
