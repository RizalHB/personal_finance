import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/budget_dependencies.dart';
import '../../domain/models/budget_overview.dart';

class BudgetOverviewNotifier extends AsyncNotifier<BudgetOverview> {
  BudgetOverviewNotifier(this.budgetId);

  final String budgetId;

  @override
  Future<BudgetOverview> build() async {
    final useCase = ref.read(getBudgetOverviewProvider);

    return useCase.execute(budgetId: budgetId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return build();
    });
  }
}

final budgetOverviewNotifierProvider =
    AsyncNotifierProvider.family<
      BudgetOverviewNotifier,
      BudgetOverview,
      String
    >(BudgetOverviewNotifier.new);
