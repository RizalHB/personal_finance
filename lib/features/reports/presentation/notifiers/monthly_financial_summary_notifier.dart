import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/report_dependencies.dart';
import '../../domain/models/monthly_financial_summary.dart';

class MonthlyFinancialSummaryNotifier
    extends AsyncNotifier<MonthlyFinancialSummary> {
  MonthlyFinancialSummaryNotifier(this.period);

  final DateTime period;

  @override
  Future<MonthlyFinancialSummary> build() {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_load);
  }

  Future<MonthlyFinancialSummary> _load() {
    final useCase = ref.read(getMonthlyFinancialSummaryProvider);

    return useCase.execute(year: period.year, month: period.month);
  }
}

final monthlyFinancialSummaryNotifierProvider =
    AsyncNotifierProvider.family<
      MonthlyFinancialSummaryNotifier,
      MonthlyFinancialSummary,
      DateTime
    >(MonthlyFinancialSummaryNotifier.new);
