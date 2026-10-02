import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/dashboard/application/dashboard_dependencies.dart';
import 'package:personal_finance/features/dashboard/application/use_cases/get_dashboard_summary.dart';
import 'package:personal_finance/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:personal_finance/features/dashboard/presentation/notifiers/dashboard_notifier.dart';
import 'package:personal_finance/features/dashboard/presentation/state/dashboard_state.dart';

void main() {
  test('loads dashboard summary through GetDashboardSummary', () async {
    final useCase = FakeGetDashboardSummary(
      const DashboardSummary(
        totalBalanceMinor: 5_000_000,
        monthlyIncomeMinor: 6_000_000,
        monthlyExpenseMinor: 1_500_000,
        monthlyNetMinor: 4_500_000,
      ),
    );

    final container = ProviderContainer(
      overrides: [getDashboardSummaryProvider.overrideWithValue(useCase)],
    );

    addTearDown(container.dispose);

    final state = await container.read(dashboardNotifierProvider.future);

    expect(state, isA<DashboardState>());
    expect(state.summary.totalBalanceMinor, 5_000_000);
    expect(state.summary.monthlyIncomeMinor, 6_000_000);
    expect(state.summary.monthlyExpenseMinor, 1_500_000);
    expect(state.summary.monthlyNetMinor, 4_500_000);

    expect(useCase.called, isTrue);
  });
}

class FakeGetDashboardSummary implements GetDashboardSummary {
  FakeGetDashboardSummary(this.summary);

  final DashboardSummary summary;
  bool called = false;

  @override
  Future<DashboardSummary> execute({
    required int year,
    required int month,
  }) async {
    called = true;
    return summary;
  }
}
