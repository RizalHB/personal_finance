import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'use_cases/get_budgets.dart';
import '../data/repositories/budget_actual_repository.dart';
import '../data/repositories/drift_budget_actual_repository.dart';
import '../presentation/notifiers/budget_allocation_notifier.dart';
import '../presentation/state/budget_allocation_state.dart';
import 'use_cases/get_budget_allocations.dart';
import 'use_cases/delete_budget_allocation.dart';
import 'use_cases/update_budget_allocation.dart';
import '../domain/validators/budget_allocation_validator.dart';
import 'use_cases/create_budget_allocation.dart';
import '../data/repositories/budget_allocation_repository.dart';
import '../data/repositories/drift_budget_allocation_repository.dart';
import 'use_cases/get_budget_by_year_month.dart';
import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/drift_budget_repository.dart';
import '../domain/validators/budget_validator.dart';
import 'use_cases/create_budget.dart';
import 'use_cases/get_budget_overview.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return DriftBudgetRepository(ref.watch(appDatabaseProvider));
});

final budgetValidatorProvider = Provider<BudgetValidator>((ref) {
  return const BudgetValidator();
});

final createBudgetProvider = Provider<CreateBudget>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  final validator = ref.watch(budgetValidatorProvider);
  final idGenerator = ref.watch(idGeneratorProvider);

  return CreateBudget(repository, validator, idGenerator);
});

final getBudgetByYearMonthProvider = Provider<GetBudgetByYearMonth>((ref) {
  return GetBudgetByYearMonth(ref.watch(budgetRepositoryProvider));
});
final budgetAllocationRepositoryProvider = Provider<BudgetAllocationRepository>(
  (ref) {
    return DriftBudgetAllocationRepository(ref.watch(appDatabaseProvider));
  },
);
final budgetAllocationValidatorProvider = Provider<BudgetAllocationValidator>((
  ref,
) {
  return const BudgetAllocationValidator();
});

final createBudgetAllocationProvider = Provider<CreateBudgetAllocation>((ref) {
  return CreateBudgetAllocation(
    ref.watch(budgetRepositoryProvider),
    ref.watch(budgetAllocationRepositoryProvider),
    ref.watch(budgetAllocationValidatorProvider),
    ref.watch(idGeneratorProvider),
  );
});
final updateBudgetAllocationProvider = Provider<UpdateBudgetAllocation>((ref) {
  return UpdateBudgetAllocation(
    ref.watch(budgetAllocationRepositoryProvider),
    ref.watch(budgetAllocationValidatorProvider),
  );
});
final deleteBudgetAllocationProvider = Provider<DeleteBudgetAllocation>((ref) {
  return DeleteBudgetAllocation(ref.watch(budgetAllocationRepositoryProvider));
});
final getBudgetAllocationsProvider = Provider<GetBudgetAllocations>((ref) {
  return GetBudgetAllocations(ref.watch(budgetAllocationRepositoryProvider));
});
final budgetAllocationNotifierProvider =
    AsyncNotifierProvider.family<
      BudgetAllocationNotifier,
      BudgetAllocationState,
      String
    >(BudgetAllocationNotifier.new);
final budgetActualRepositoryProvider = Provider<BudgetActualRepository>((ref) {
  return DriftBudgetActualRepository(ref.watch(appDatabaseProvider));
});
final getBudgetOverviewProvider = Provider<GetBudgetOverview>((ref) {
  return GetBudgetOverview(
    ref.watch(budgetRepositoryProvider),
    ref.watch(budgetAllocationRepositoryProvider),
    ref.watch(budgetActualRepositoryProvider),
  );
});
final getBudgetsProvider = Provider<GetBudgets>((ref) {
  return GetBudgets(ref.watch(budgetRepositoryProvider));
});
