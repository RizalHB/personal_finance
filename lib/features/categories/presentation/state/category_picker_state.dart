import '../models/category_picker_item.dart';

class CategoryPickerState {
  const CategoryPickerState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<CategoryPickerItem> items;
  final bool isLoading;
  final String? errorMessage;

  CategoryPickerState copyWith({
    List<CategoryPickerItem>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryPickerState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
