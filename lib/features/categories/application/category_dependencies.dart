import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/drift_category_repository.dart';
import 'use_cases/get_active_expense_categories.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftCategoryRepository(database);
});

final getActiveExpenseCategoriesProvider = Provider<GetActiveExpenseCategories>(
  (ref) {
    final repository = ref.watch(categoryRepositoryProvider);

    return GetActiveExpenseCategories(repository);
  },
);
