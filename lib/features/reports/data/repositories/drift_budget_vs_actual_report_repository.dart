import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/models/budget_vs_actual.dart';
import 'budget_vs_actual_report_repository.dart';

class DriftBudgetVsActualReportRepository
    implements BudgetVsActualReportRepository {
  const DriftBudgetVsActualReportRepository(this._database);

  static const int _postedStatus = 1;

  final db.AppDatabase _database;

  @override
  Future<List<BudgetVsActual>> getBudgetVsActual({
    required String budgetId,
  }) async {
    final normalizedBudgetId = budgetId.trim();

    if (normalizedBudgetId.isEmpty) {
      throw ArgumentError('Budget ID cannot be empty.');
    }

    final budget = await (_database.select(
      _database.budgets,
    )..where((table) => table.id.equals(normalizedBudgetId))).getSingleOrNull();

    if (budget == null) {
      throw StateError('Budget not found: $normalizedBudgetId');
    }

    final startDate = DateTime(budget.year, budget.month);

    final endDate = DateTime(budget.year, budget.month + 1);

    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final rows = await _database
        .customSelect(
          '''
      WITH actuals AS (
        SELECT
          category_id,
          SUM(actual_amount_minor) AS actual_amount_minor
        FROM (
          SELECT
            t.category_id AS category_id,
            t.amount_minor AS actual_amount_minor
          FROM transactions t
          WHERE t.status = ?
            AND t.transaction_type = ?
            AND t.category_id IS NOT NULL
            AND t.transaction_date >= ?
            AND t.transaction_date < ?
            AND NOT EXISTS (
              SELECT 1
              FROM transaction_splits ts
              WHERE ts.transaction_id = t.id
            )

          UNION ALL

          SELECT
            ts.category_id AS category_id,
            ts.amount_minor AS actual_amount_minor
          FROM transactions t
          INNER JOIN transaction_splits ts
            ON ts.transaction_id = t.id
          WHERE t.status = ?
            AND t.transaction_type = ?
            AND t.transaction_date >= ?
            AND t.transaction_date < ?
        )
        GROUP BY category_id
      )
      SELECT
        ba.budget_id,
        ba.category_id,
        c.name AS category_name,
        ba.planned_amount_minor,
        COALESCE(a.actual_amount_minor, 0) AS actual_amount_minor,
        ba.planned_amount_minor
          - COALESCE(a.actual_amount_minor, 0)
          AS remaining_amount_minor,
        CASE
          WHEN ba.planned_amount_minor = 0 THEN 0
          ELSE
            (
              CAST(COALESCE(a.actual_amount_minor, 0) AS REAL)
              / ba.planned_amount_minor
            ) * 100
        END AS usage_percentage
      FROM budget_allocations ba
      INNER JOIN categories c
        ON c.id = ba.category_id
      LEFT JOIN actuals a
        ON a.category_id = ba.category_id
      WHERE ba.budget_id = ?
      ORDER BY ba.planned_amount_minor DESC, c.name ASC
      ''',
          variables: [
            Variable.withInt(_postedStatus),
            Variable.withInt(TransactionType.expense.code),
            Variable.withInt(startTimestamp),
            Variable.withInt(endTimestamp),
            Variable.withInt(_postedStatus),
            Variable.withInt(TransactionType.expense.code),
            Variable.withInt(startTimestamp),
            Variable.withInt(endTimestamp),
            Variable.withString(normalizedBudgetId),
          ],
          readsFrom: {
            _database.budgets,
            _database.budgetAllocations,
            _database.categories,
            _database.transactions,
            _database.transactionSplits,
          },
        )
        .get();

    return rows.map((row) {
      return BudgetVsActual(
        budgetId: row.read<String>('budget_id'),
        categoryId: row.read<String>('category_id'),
        categoryName: row.read<String>('category_name'),
        plannedAmountMinor: row.read<int>('planned_amount_minor'),
        actualAmountMinor: row.read<int>('actual_amount_minor'),
        remainingAmountMinor: row.read<int>('remaining_amount_minor'),
        usagePercentage: row.read<double>('usage_percentage'),
      );
    }).toList();
  }
}
