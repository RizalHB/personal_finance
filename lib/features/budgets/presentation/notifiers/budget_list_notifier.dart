import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/budget_dependencies.dart';
import '../../domain/entities/budget.dart';

class BudgetListNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() {
    return ref.read(getBudgetsProvider).execute();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return ref.read(getBudgetsProvider).execute();
    });
  }
}

final budgetListNotifierProvider =
    AsyncNotifierProvider<BudgetListNotifier, List<Budget>>(
      BudgetListNotifier.new,
    );
