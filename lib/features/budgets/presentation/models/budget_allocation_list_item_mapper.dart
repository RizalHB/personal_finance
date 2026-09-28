import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/budget_allocation.dart';
import '../../domain/models/budget_actual.dart';
import 'budget_allocation_list_item.dart';

class BudgetAllocationListItemMapper {
  const BudgetAllocationListItemMapper();

  BudgetAllocationListItem map({
    required BudgetAllocation allocation,
    required Category category,
    required int actualAmountMinor,
  }) {
    final remainingAmountMinor =
        allocation.plannedAmountMinor - actualAmountMinor;

    final usagePercentage = allocation.plannedAmountMinor == 0
        ? 0.0
        : (actualAmountMinor / allocation.plannedAmountMinor) * 100;

    return BudgetAllocationListItem(
      allocationId: allocation.id,
      categoryId: allocation.categoryId,
      categoryName: category.name,
      plannedAmountMinor: allocation.plannedAmountMinor,
      actualAmountMinor: actualAmountMinor,
      remainingAmountMinor: remainingAmountMinor,
      usagePercentage: usagePercentage,
    );
  }

  List<BudgetAllocationListItem> mapList({
    required List<BudgetAllocation> allocations,
    required List<Category> categories,
    required List<BudgetActual> actuals,
  }) {
    final categoriesById = {
      for (final category in categories) category.id: category,
    };

    final actualsByCategoryId = {
      for (final actual in actuals) actual.categoryId: actual.actualAmountMinor,
    };

    return allocations.map((allocation) {
      final category = categoriesById[allocation.categoryId];

      if (category == null) {
        throw StateError('Category not found: ${allocation.categoryId}');
      }

      return map(
        allocation: allocation,
        category: category,
        actualAmountMinor: actualsByCategoryId[allocation.categoryId] ?? 0,
      );
    }).toList();
  }
}
