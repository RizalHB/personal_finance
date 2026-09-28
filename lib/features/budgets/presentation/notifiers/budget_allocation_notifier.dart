import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/application/category_dependencies.dart';
import '../../application/budget_dependencies.dart';
import '../models/budget_allocation_list_item_mapper.dart';
import '../state/budget_allocation_state.dart';

class BudgetAllocationNotifier extends AsyncNotifier<BudgetAllocationState> {
  BudgetAllocationNotifier(this.budgetId);

  final String budgetId;

  @override
  Future<BudgetAllocationState> build() async {
    return _load(budgetId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _load(budgetId);
    });
  }

  Future<BudgetAllocationState> _load(String budgetId) async {
    final allocationUseCase = ref.read(getBudgetAllocationsProvider);
    final categoryUseCase = ref.read(getActiveExpenseCategoriesProvider);
    final actualRepository = ref.read(budgetActualRepositoryProvider);

    const mapper = BudgetAllocationListItemMapper();

    final allocations = await allocationUseCase.execute(budgetId: budgetId);

    final categories = await categoryUseCase.execute();

    final budget = await ref.read(budgetRepositoryProvider).getById(budgetId);

    if (budget == null) {
      throw StateError('Budget not found: $budgetId');
    }

    final actuals = await actualRepository.getActualsForMonth(
      year: budget.year,
      month: budget.month,
    );

    return BudgetAllocationState(
      items: mapper.mapList(
        allocations: allocations,
        categories: categories,
        actuals: actuals,
      ),
    );
  }
}
