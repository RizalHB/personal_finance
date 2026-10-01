import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/bills/data/repositories/drift_bill_repository.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';

void main() {
  late db.AppDatabase database;
  late DriftBillRepository repository;

  setUp(() {
    database = db.AppDatabase.test();
    repository = DriftBillRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Bill createBill({
    required String id,
    required int dueDate,
    int? amountMinor = 500_000,
    BillStatus status = BillStatus.active,
    String? accountId = 'account-cash',
    String? categoryId = 'category-food',
    String? merchantId,
    String? notes,
    int createdAt = 1000,
    int updatedAt = 1000,
    int? cancelledAt,
  }) {
    return Bill(
      id: id,
      name: 'Electricity',
      amountMinor: amountMinor,
      currencyCode: 'IDR',
      dueDate: dueDate,
      status: status,
      accountId: accountId,
      categoryId: categoryId,
      merchantId: merchantId,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cancelledAt: cancelledAt,
    );
  }

  test('creates and reads a bill', () async {
    final bill = createBill(id: 'bill-1', dueDate: 2_000);

    final created = await repository.create(bill: bill);

    expect(created.id, 'bill-1');

    final result = await repository.getById(' bill-1 ');

    expect(result, isNotNull);
    expect(result!.id, 'bill-1');
    expect(result.name, 'Electricity');
    expect(result.amountMinor, 500_000);
    expect(result.currencyCode, 'IDR');
    expect(result.dueDate, 2_000);
    expect(result.status, BillStatus.active);
    expect(result.accountId, 'account-cash');
    expect(result.categoryId, 'category-food');
  });

  test('preserves nullable bill fields', () async {
    final bill = createBill(
      id: 'bill-unknown',
      dueDate: 3_000,
      amountMinor: null,
      accountId: null,
      categoryId: null,
      merchantId: null,
      notes: null,
    );

    await repository.create(bill: bill);

    final result = await repository.getById('bill-unknown');

    expect(result, isNotNull);
    expect(result!.amountMinor, isNull);
    expect(result.accountId, isNull);
    expect(result.categoryId, isNull);
    expect(result.merchantId, isNull);
    expect(result.notes, isNull);
    expect(result.cancelledAt, isNull);
  });

  test('returns all bills ordered by due date then ID', () async {
    await repository.create(bill: createBill(id: 'bill-later', dueDate: 3_000));

    await repository.create(
      bill: createBill(id: 'bill-earlier', dueDate: 2_000),
    );

    await repository.create(
      bill: createBill(id: 'bill-same-date-b', dueDate: 2_000),
    );

    await repository.create(
      bill: createBill(id: 'bill-same-date-a', dueDate: 2_000),
    );

    final result = await repository.getAll();

    expect(result.map((bill) => bill.id), [
      'bill-earlier',
      'bill-same-date-a',
      'bill-same-date-b',
      'bill-later',
    ]);
  });

  test('updates a bill', () async {
    await repository.create(bill: createBill(id: 'bill-1', dueDate: 2_000));

    final updated = createBill(
      id: 'bill-1',
      dueDate: 4_000,
      amountMinor: 750_000,
      status: BillStatus.paid,
      notes: 'Paid in full',
      updatedAt: 3_000,
    );

    final result = await repository.update(bill: updated);

    expect(result.amountMinor, 750_000);
    expect(result.dueDate, 4_000);
    expect(result.status, BillStatus.paid);
    expect(result.notes, 'Paid in full');
    expect(result.updatedAt, 3_000);

    final persisted = await repository.getById('bill-1');

    expect(persisted, isNotNull);
    expect(persisted!.amountMinor, 750_000);
    expect(persisted.dueDate, 4_000);
    expect(persisted.status, BillStatus.paid);
    expect(persisted.notes, 'Paid in full');
  });

  test('deletes a bill', () async {
    await repository.create(bill: createBill(id: 'bill-1', dueDate: 2_000));

    await repository.delete(' bill-1 ');

    expect(await repository.getById('bill-1'), isNull);
  });

  test('rejects empty ID when reading or deleting', () async {
    expect(() => repository.getById('   '), throwsA(isA<ArgumentError>()));

    expect(() => repository.delete('   '), throwsA(isA<ArgumentError>()));
  });
}
