import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/drift_dashboard_repository.dart';
import 'use_cases/get_dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftDashboardRepository(database);
});

final getDashboardSummaryProvider = Provider<GetDashboardSummary>((ref) {
  return GetDashboardSummary(ref.watch(dashboardRepositoryProvider));
});
