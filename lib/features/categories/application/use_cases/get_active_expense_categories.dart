import '../../data/repositories/category_repository.dart';
import '../../domain/entities/category.dart';

class GetActiveExpenseCategories {
  const GetActiveExpenseCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> execute() {
    return _repository.getActiveExpenseCategories();
  }
}
