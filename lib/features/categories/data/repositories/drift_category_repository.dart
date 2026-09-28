import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;

import '../../domain/entities/category.dart';
import 'category_repository.dart';

class DriftCategoryRepository implements CategoryRepository {
  const DriftCategoryRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<Category?> getById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Category ID cannot be empty.');
    }

    final row = await (_database.select(
      _database.categories,
    )..where((category) => category.id.equals(normalizedId))).getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<List<Category>> getActiveExpenseCategories() async {
    final rows =
        await (_database.select(_database.categories)
              ..where(
                (category) =>
                    category.categoryType.equals(CategoryType.expense.code) &
                    category.status.equals(CategoryStatus.active.code),
              )
              ..orderBy([
                (category) => OrderingTerm.asc(category.sortOrder),
                (category) => OrderingTerm.asc(category.name),
              ]))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }
}

extension on db.Category {
  Category toDomain() {
    return Category(
      id: id,
      ledgerAccountId: ledgerAccountId,
      parentId: parentId,
      name: name,
      categoryType: CategoryType.fromCode(categoryType),
      status: CategoryStatus.fromCode(status),
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      archivedAt: archivedAt,
    );
  }
}
