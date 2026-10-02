import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/models/category_spending.dart';
import 'category_spending_report_repository.dart';

class DriftCategorySpendingReportRepository
    implements CategorySpendingReportRepository {
  const DriftCategorySpendingReportRepository(this._database);

  static const int _postedStatus = 1;

  final db.AppDatabase _database;

  @override
  Future<List<CategorySpending>> getCategorySpendingForMonth({
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final rows = await _database
        .customSelect(
          '''
      WITH category_totals AS (
        SELECT
          category_id,
          SUM(actual_amount_minor) AS amount_minor
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
      ),
      total_expense AS (
        SELECT COALESCE(SUM(amount_minor), 0) AS total_amount_minor
        FROM category_totals
      )
      SELECT
        ct.category_id,
        c.name AS category_name,
        ct.amount_minor,
        CASE
          WHEN te.total_amount_minor = 0 THEN 0
          ELSE
            (CAST(ct.amount_minor AS REAL) /
              te.total_amount_minor) * 100
        END AS percentage
      FROM category_totals ct
      INNER JOIN categories c
        ON c.id = ct.category_id
      CROSS JOIN total_expense te
      ORDER BY ct.amount_minor DESC, c.name ASC
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
          ],
          readsFrom: {
            _database.transactions,
            _database.transactionSplits,
            _database.categories,
          },
        )
        .get();

    return rows.map((row) {
      return CategorySpending(
        categoryId: row.read<String>('category_id'),
        categoryName: row.read<String>('category_name'),
        amountMinor: row.read<int>('amount_minor'),
        percentage: row.read<double>('percentage'),
      );
    }).toList();
  }
}
