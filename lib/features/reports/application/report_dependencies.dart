import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/budget_vs_actual_report_repository.dart';
import '../data/repositories/category_spending_report_repository.dart';
import '../data/repositories/drift_budget_vs_actual_report_repository.dart';
import '../data/repositories/drift_category_spending_report_repository.dart';
import '../data/repositories/drift_monthly_financial_report_repository.dart';
import '../data/repositories/monthly_financial_report_repository.dart';
import 'use_cases/get_budget_vs_actual.dart';
import 'use_cases/get_category_spending.dart';
import 'use_cases/get_monthly_financial_summary.dart';

final monthlyFinancialReportRepositoryProvider =
    Provider<MonthlyFinancialReportRepository>((ref) {
      final database = ref.watch(appDatabaseProvider);

      return DriftMonthlyFinancialReportRepository(database);
    });

final categorySpendingReportRepositoryProvider =
    Provider<CategorySpendingReportRepository>((ref) {
      final database = ref.watch(appDatabaseProvider);

      return DriftCategorySpendingReportRepository(database);
    });

final budgetVsActualReportRepositoryProvider =
    Provider<BudgetVsActualReportRepository>((ref) {
      final database = ref.watch(appDatabaseProvider);

      return DriftBudgetVsActualReportRepository(database);
    });

final getMonthlyFinancialSummaryProvider = Provider<GetMonthlyFinancialSummary>(
  (ref) {
    return GetMonthlyFinancialSummary(
      ref.watch(monthlyFinancialReportRepositoryProvider),
    );
  },
);

final getCategorySpendingProvider = Provider<GetCategorySpending>((ref) {
  return GetCategorySpending(
    ref.watch(categorySpendingReportRepositoryProvider),
  );
});

final getBudgetVsActualProvider = Provider<GetBudgetVsActual>((ref) {
  return GetBudgetVsActual(ref.watch(budgetVsActualReportRepositoryProvider));
});
