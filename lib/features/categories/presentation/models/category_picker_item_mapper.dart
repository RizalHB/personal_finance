import '../../domain/entities/category.dart';
import 'category_picker_item.dart';

class CategoryPickerItemMapper {
  const CategoryPickerItemMapper();

  CategoryPickerItem map(Category category) {
    return CategoryPickerItem(categoryId: category.id, name: category.name);
  }

  List<CategoryPickerItem> mapList(List<Category> categories) {
    return categories.map(map).toList();
  }
}
