import '../models/budget_allocation_list_item.dart';

class BudgetAllocationState {
  const BudgetAllocationState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<BudgetAllocationListItem> items;
  final bool isLoading;
  final String? errorMessage;

  BudgetAllocationState copyWith({
    List<BudgetAllocationListItem>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetAllocationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
