import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/dashboard_dependencies.dart';
import '../state/dashboard_state.dart';

class DashboardNotifier extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final now = DateTime.now();

    return _load(year: now.year, month: now.month);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final now = DateTime.now();

      return _load(year: now.year, month: now.month);
    });
  }

  Future<DashboardState> _load({required int year, required int month}) async {
    final useCase = ref.read(getDashboardSummaryProvider);

    final summary = await useCase.execute(year: year, month: month);

    return DashboardState(summary: summary);
  }
}

final dashboardNotifierProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardState>(
      DashboardNotifier.new,
    );
