import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/dashboard_repository.dart';
import 'use_cases/get_dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  throw UnimplementedError('dashboardRepositoryProvider must be overridden.');
});

final getDashboardSummaryProvider = Provider<GetDashboardSummary>((ref) {
  return GetDashboardSummary(ref.watch(dashboardRepositoryProvider));
});
