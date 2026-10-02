import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/report_dependencies.dart';
import '../../domain/models/category_spending.dart';

class CategorySpendingNotifier extends AsyncNotifier<List<CategorySpending>> {
  CategorySpendingNotifier(this.period);

  final DateTime period;

  @override
  Future<List<CategorySpending>> build() {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<CategorySpending>> _load() {
    final useCase = ref.read(getCategorySpendingProvider);

    return useCase.execute(year: period.year, month: period.month);
  }
}

final categorySpendingNotifierProvider =
    AsyncNotifierProvider.family<
      CategorySpendingNotifier,
      List<CategorySpending>,
      DateTime
    >(CategorySpendingNotifier.new);
