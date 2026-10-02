import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;

import '../../../reports/data/repositories/drift_monthly_financial_report_repository.dart';
import '../../domain/models/dashboard_summary.dart';
import 'dashboard_repository.dart';

class DriftDashboardRepository implements DashboardRepository {
  const DriftDashboardRepository(this._database);

  final db.AppDatabase _database;

  static const int _activeAccountStatus = 1;
  static const int _assetFinancialClass = 1;
  static const int _debitSide = 1;
  static const int _creditSide = 2;

  @override
  Future<DashboardSummary> getSummary({
    required int year,
    required int month,
  }) async {
    final monthlyReport = DriftMonthlyFinancialReportRepository(_database);

    final monthlySummary = await monthlyReport.getMonthlySummary(
      year: year,
      month: month,
    );

    final balanceRow = await _database
        .customSelect(
          '''
      SELECT
        COALESCE(
          SUM(
            CASE
              WHEN le.entry_side = ? THEN le.amount_minor
              WHEN le.entry_side = ? THEN -le.amount_minor
              ELSE 0
            END
          ),
          0
        ) AS total_balance_minor
      FROM accounts a
      INNER JOIN ledger_entries le
        ON le.ledger_account_id = a.ledger_account_id
      WHERE a.status = ?
        AND a.financial_class = ?
      ''',
          variables: [
            Variable.withInt(_debitSide),
            Variable.withInt(_creditSide),
            Variable.withInt(_activeAccountStatus),
            Variable.withInt(_assetFinancialClass),
          ],
          readsFrom: {_database.accounts, _database.ledgerEntries},
        )
        .getSingle();

    return DashboardSummary(
      totalBalanceMinor: balanceRow.read<int>('total_balance_minor'),
      monthlyIncomeMinor: monthlySummary.totalIncomeMinor,
      monthlyExpenseMinor: monthlySummary.totalExpenseMinor,
      monthlyNetMinor: monthlySummary.netAmountMinor,
    );
  }
}
