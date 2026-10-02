import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/models/monthly_financial_summary.dart';
import 'monthly_financial_report_repository.dart';

class DriftMonthlyFinancialReportRepository
    implements MonthlyFinancialReportRepository {
  const DriftMonthlyFinancialReportRepository(this._database);

  static const int _postedStatus = 1;

  final db.AppDatabase _database;

  @override
  Future<MonthlyFinancialSummary> getMonthlySummary({
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
      SELECT
        COALESCE(
          SUM(
            CASE
              WHEN transaction_type = ? THEN actual_amount_minor
              ELSE 0
            END
          ),
          0
        ) AS total_income_minor,
        COALESCE(
          SUM(
            CASE
              WHEN transaction_type = ? THEN actual_amount_minor
              ELSE 0
            END
          ),
          0
        ) AS total_expense_minor
      FROM (
        SELECT
          t.transaction_type,
          t.amount_minor AS actual_amount_minor
        FROM transactions t
        WHERE t.status = ?
          AND t.transaction_date >= ?
          AND t.transaction_date < ?
          AND t.transaction_type = ?

        UNION ALL

        SELECT
          t.transaction_type,
          t.amount_minor AS actual_amount_minor
        FROM transactions t
        WHERE t.status = ?
          AND t.transaction_date >= ?
          AND t.transaction_date < ?
          AND t.transaction_type = ?
          AND t.category_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1
            FROM transaction_splits ts
            WHERE ts.transaction_id = t.id
          )

        UNION ALL

        SELECT
          t.transaction_type,
          ts.amount_minor AS actual_amount_minor
        FROM transactions t
        INNER JOIN transaction_splits ts
          ON ts.transaction_id = t.id
        WHERE t.status = ?
          AND t.transaction_date >= ?
          AND t.transaction_date < ?
          AND t.transaction_type = ?
      )
      ''',
          variables: [
            Variable.withInt(TransactionType.income.code),
            Variable.withInt(TransactionType.expense.code),

            Variable.withInt(_postedStatus),
            Variable.withInt(startTimestamp),
            Variable.withInt(endTimestamp),
            Variable.withInt(TransactionType.income.code),

            Variable.withInt(_postedStatus),
            Variable.withInt(startTimestamp),
            Variable.withInt(endTimestamp),
            Variable.withInt(TransactionType.expense.code),

            Variable.withInt(_postedStatus),
            Variable.withInt(startTimestamp),
            Variable.withInt(endTimestamp),
            Variable.withInt(TransactionType.expense.code),
          ],
          readsFrom: {_database.transactions, _database.transactionSplits},
        )
        .getSingle();

    final totalIncomeMinor = rows.read<int>('total_income_minor');
    final totalExpenseMinor = rows.read<int>('total_expense_minor');

    return MonthlyFinancialSummary(
      year: year,
      month: month,
      totalIncomeMinor: totalIncomeMinor,
      totalExpenseMinor: totalExpenseMinor,
      netAmountMinor: totalIncomeMinor - totalExpenseMinor,
    );
  }
}
