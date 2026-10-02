import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/dashboard/application/use_cases/get_dashboard_summary.dart';
import 'package:personal_finance/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:personal_finance/features/dashboard/domain/models/dashboard_summary.dart';

void main() {
  late FakeDashboardRepository repository;
  late GetDashboardSummary useCase;

  setUp(() {
    repository = FakeDashboardRepository();

    useCase = GetDashboardSummary(repository);
  });

  test('returns dashboard summary for the requested period', () async {
    repository.summary = const DashboardSummary(
      totalBalanceMinor: 5_000_000,
      monthlyIncomeMinor: 6_000_000,
      monthlyExpenseMinor: 1_500_000,
      monthlyNetMinor: 4_500_000,
    );

    final result = await useCase.execute(year: 2026, month: 9);

    expect(result.totalBalanceMinor, 5_000_000);
    expect(result.monthlyIncomeMinor, 6_000_000);
    expect(result.monthlyExpenseMinor, 1_500_000);
    expect(result.monthlyNetMinor, 4_500_000);

    expect(repository.requestedYear, 2026);
    expect(repository.requestedMonth, 9);
  });

  test('rejects invalid year', () {
    expect(
      () => useCase.execute(year: 0, month: 9),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.called, isFalse);
  });

  test('rejects month below one', () {
    expect(
      () => useCase.execute(year: 2026, month: 0),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.called, isFalse);
  });

  test('rejects month above twelve', () {
    expect(
      () => useCase.execute(year: 2026, month: 13),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.called, isFalse);
  });
}

class FakeDashboardRepository implements DashboardRepository {
  DashboardSummary? summary;

  int? requestedYear;
  int? requestedMonth;
  bool called = false;

  @override
  Future<DashboardSummary> getSummary({
    required int year,
    required int month,
  }) async {
    called = true;
    requestedYear = year;
    requestedMonth = month;

    return summary ??
        const DashboardSummary(
          totalBalanceMinor: 0,
          monthlyIncomeMinor: 0,
          monthlyExpenseMinor: 0,
          monthlyNetMinor: 0,
        );
  }
}
