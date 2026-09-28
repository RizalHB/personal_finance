import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/models/budget_actual.dart';
import 'budget_actual_repository.dart';

class DriftBudgetActualRepository implements BudgetActualRepository {
  const DriftBudgetActualRepository(this._database);

  static const int _postedStatus = 1;

  final db.AppDatabase _database;

  @override
  Future<List<BudgetActual>> getActualsForMonth({
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
      SELECT category_id, SUM(actual_amount_minor) AS actual_amount_minor
      FROM (
        SELECT
          t.category_id AS category_id,
          t.amount_minor AS actual_amount_minor
        FROM transactions t
        WHERE t.transaction_type = ?
          AND t.status = ?
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
        WHERE t.transaction_type = ?
          AND t.status = ?
          AND t.transaction_date >= ?
          AND t.transaction_date < ?
      )
      GROUP BY category_id
      ORDER BY category_id
      ''',
          variables: [
            Variable.withInt(TransactionType.expense.code),
            Variable.withInt(_postedStatus),
            Variable.withInt(startTimestamp),
            Variable.withInt(endTimestamp),
            Variable.withInt(TransactionType.expense.code),
            Variable.withInt(_postedStatus),
            Variable.withInt(startTimestamp),
            Variable.withInt(endTimestamp),
          ],
          readsFrom: {_database.transactions, _database.transactionSplits},
        )
        .get();

    return rows.map((row) {
      return BudgetActual(
        categoryId: row.read<String>('category_id'),
        actualAmountMinor: row.read<int>('actual_amount_minor'),
      );
    }).toList();
  }
}
