import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/report_dependencies.dart';
import '../../domain/models/budget_vs_actual.dart';

class BudgetVsActualNotifier extends AsyncNotifier<List<BudgetVsActual>> {
  BudgetVsActualNotifier(this.budgetId);

  final String budgetId;

  @override
  Future<List<BudgetVsActual>> build() {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_load);
  }

  Future<List<BudgetVsActual>> _load() {
    final useCase = ref.read(getBudgetVsActualProvider);

    return useCase.execute(budgetId: budgetId);
  }
}

final budgetVsActualNotifierProvider =
    AsyncNotifierProvider.family<
      BudgetVsActualNotifier,
      List<BudgetVsActual>,
      String
    >(BudgetVsActualNotifier.new);
