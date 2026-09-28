import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/category_dependencies.dart';
import '../models/category_picker_item_mapper.dart';
import '../state/category_picker_state.dart';

class CategoryPickerNotifier extends AsyncNotifier<CategoryPickerState> {
  @override
  Future<CategoryPickerState> build() async {
    final useCase = ref.read(getActiveExpenseCategoriesProvider);
    const mapper = CategoryPickerItemMapper();

    final categories = await useCase.execute();

    return CategoryPickerState(items: mapper.mapList(categories));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return build();
    });
  }
}

final categoryPickerNotifierProvider =
    AsyncNotifierProvider<CategoryPickerNotifier, CategoryPickerState>(
      CategoryPickerNotifier.new,
    );
