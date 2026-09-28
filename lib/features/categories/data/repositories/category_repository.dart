import '../../domain/entities/category.dart';

abstract interface class CategoryRepository {
  Future<Category?> getById(String id);

  Future<List<Category>> getActiveExpenseCategories();
}
