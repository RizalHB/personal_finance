import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/categories/data/repositories/drift_category_repository.dart';
import 'package:personal_finance/features/categories/domain/entities/category.dart';

void main() {
  late db.AppDatabase database;
  late DriftCategoryRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftCategoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('returns category by ID', () async {
    await _insertLedgerAccount(
      database,
      id: 'ledger-food',
      code: 'food',
      name: 'Food',
      kind: 4,
    );

    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: 'category-food',
            ledgerAccountId: 'ledger-food',
            name: 'Food',
            categoryType: CategoryType.expense.code,
            status: CategoryStatus.active.code,
            sortOrder: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    final category = await repository.getById(' category-food ');

    expect(category, isNotNull);
    expect(category!.id, 'category-food');
    expect(category.name, 'Food');
    expect(category.categoryType, CategoryType.expense);
    expect(category.status, CategoryStatus.active);
  });

  test('returns only active expense categories in sort order', () async {
    await _insertLedgerAccount(
      database,
      id: 'ledger-food',
      code: 'food',
      name: 'Food',
      kind: 4,
    );

    await _insertLedgerAccount(
      database,
      id: 'ledger-transport',
      code: 'transport',
      name: 'Transport',
      kind: 4,
    );

    await _insertLedgerAccount(
      database,
      id: 'ledger-salary',
      code: 'salary',
      name: 'Salary',
      kind: 3,
    );

    await _insertLedgerAccount(
      database,
      id: 'ledger-archived',
      code: 'archived',
      name: 'Archived',
      kind: 4,
    );

    await database.batch((batch) {
      batch.insertAll(database.categories, [
        db.CategoriesCompanion.insert(
          id: 'category-transport',
          ledgerAccountId: 'ledger-transport',
          name: 'Transport',
          categoryType: CategoryType.expense.code,
          status: CategoryStatus.active.code,
          sortOrder: 2,
          createdAt: 1000,
          updatedAt: 1000,
        ),
        db.CategoriesCompanion.insert(
          id: 'category-food',
          ledgerAccountId: 'ledger-food',
          name: 'Food',
          categoryType: CategoryType.expense.code,
          status: CategoryStatus.active.code,
          sortOrder: 1,
          createdAt: 1000,
          updatedAt: 1000,
        ),
        db.CategoriesCompanion.insert(
          id: 'category-salary',
          ledgerAccountId: 'ledger-salary',
          name: 'Salary',
          categoryType: CategoryType.income.code,
          status: CategoryStatus.active.code,
          sortOrder: 0,
          createdAt: 1000,
          updatedAt: 1000,
        ),
        db.CategoriesCompanion.insert(
          id: 'category-archived',
          ledgerAccountId: 'ledger-archived',
          name: 'Archived',
          categoryType: CategoryType.expense.code,
          status: CategoryStatus.archived.code,
          sortOrder: 0,
          createdAt: 1000,
          updatedAt: 1000,
        ),
      ]);
    });

    final categories = await repository.getActiveExpenseCategories();

    expect(categories, hasLength(2));
    expect(categories.map((category) => category.id), [
      'category-food',
      'category-transport',
    ]);
  });

  test('rejects empty category ID', () async {
    expect(() => repository.getById('   '), throwsArgumentError);
  });
}

Future<void> _insertLedgerAccount(
  db.AppDatabase database, {
  required String id,
  required String code,
  required String name,
  required int kind,
}) async {
  await database
      .into(database.ledgerAccounts)
      .insert(
        db.LedgerAccountsCompanion.insert(
          id: id,
          kind: kind,
          code: code,
          name: name,
          isSystem: false,
          status: 1,
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );
}
