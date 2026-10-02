import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:personal_finance/features/dashboard/presentation/notifiers/dashboard_notifier.dart';
import 'package:personal_finance/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:personal_finance/features/dashboard/presentation/state/dashboard_state.dart';

void main() {
  testWidgets('displays dashboard summary', (tester) async {
    const summary = DashboardSummary(
      totalBalanceMinor: 5_000_000,
      monthlyIncomeMinor: 6_000_000,
      monthlyExpenseMinor: 1_500_000,
      monthlyNetMinor: 4_500_000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardNotifierProvider.overrideWith(
            () => FakeDashboardNotifier(summary),
          ),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('Rp5.000.000'), findsOneWidget);
    expect(find.text('Income This Month'), findsOneWidget);
    expect(find.text('Rp6.000.000'), findsOneWidget);
    expect(find.text('Expense This Month'), findsOneWidget);
    expect(find.text('Rp1.500.000'), findsOneWidget);
    expect(find.text('Net This Month'), findsOneWidget);
    expect(find.text('Rp4.500.000'), findsOneWidget);
  });

  testWidgets('displays dashboard loading state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardNotifierProvider.overrideWith(
            () => LoadingDashboardNotifier(),
          ),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays dashboard error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardNotifierProvider.overrideWith(
            () => ErrorDashboardNotifier(),
          ),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pump();

    expect(find.textContaining('Failed to load dashboard.'), findsOneWidget);
  });
}

class FakeDashboardNotifier extends DashboardNotifier {
  FakeDashboardNotifier(this.summary);

  final DashboardSummary summary;

  @override
  Future<DashboardState> build() async {
    return DashboardState(summary: summary);
  }
}

class LoadingDashboardNotifier extends DashboardNotifier {
  final _completer = Completer<DashboardState>();

  @override
  Future<DashboardState> build() {
    return _completer.future;
  }
}

class ErrorDashboardNotifier extends DashboardNotifier {
  @override
  Future<DashboardState> build() {
    throw StateError('Dashboard failed.');
  }
}
