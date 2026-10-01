import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/use_cases/update_bill.dart';
import 'package:personal_finance/features/bills/data/repositories/bill_repository.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';

void main() {
  late FakeBillRepository repository;
  late UpdateBill useCase;

  setUp(() {
    repository = FakeBillRepository();
    useCase = UpdateBill(repository);
  });

  test('updates a bill while preserving identity and creation time', () async {
    repository.bills.add(
      const Bill(
        id: 'bill-1',
        name: 'Electricity',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: 'account-cash',
        categoryId: 'category-utilities',
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    );

    final updated = await useCase.execute(
      id: ' bill-1 ',
      name: ' Electricity Updated ',
      amountMinor: 750_000,
      currencyCode: ' idr ',
      dueDate: 4_000,
      status: BillStatus.paid,
      accountId: ' account-bank ',
      categoryId: ' category-utilities ',
      notes: ' Paid in full ',
    );

    expect(updated.id, 'bill-1');
    expect(updated.name, 'Electricity Updated');
    expect(updated.amountMinor, 750_000);
    expect(updated.currencyCode, 'IDR');
    expect(updated.dueDate, 4_000);
    expect(updated.status, BillStatus.paid);
    expect(updated.accountId, 'account-bank');
    expect(updated.categoryId, 'category-utilities');
    expect(updated.notes, 'Paid in full');
    expect(updated.createdAt, 1_000);
    expect(updated.updatedAt, greaterThan(1_000));
    expect(updated.cancelledAt, isNull);

    expect(repository.updated, hasLength(1));
  });

  test('normalizes blank optional fields to null', () async {
    repository.bills.add(
      const Bill(
        id: 'bill-1',
        name: 'Internet',
        amountMinor: 300_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: 'account-cash',
        categoryId: 'category-internet',
        merchantId: 'merchant-1',
        notes: 'Old note',
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    );

    final updated = await useCase.execute(
      id: 'bill-1',
      name: 'Internet',
      amountMinor: 300_000,
      currencyCode: 'IDR',
      dueDate: 2_000,
      status: BillStatus.active,
      accountId: '   ',
      categoryId: '   ',
      merchantId: '   ',
      notes: '   ',
    );

    expect(updated.accountId, isNull);
    expect(updated.categoryId, isNull);
    expect(updated.merchantId, isNull);
    expect(updated.notes, isNull);
  });

  test('allows an unknown bill amount', () async {
    repository.bills.add(
      const Bill(
        id: 'bill-1',
        name: 'Variable Bill',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: null,
        categoryId: null,
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    );

    final updated = await useCase.execute(
      id: 'bill-1',
      name: 'Variable Bill',
      amountMinor: null,
      currencyCode: 'IDR',
      dueDate: 2_000,
      status: BillStatus.active,
    );

    expect(updated.amountMinor, isNull);
  });

  test('rejects update when the bill does not exist', () async {
    expect(
      () => useCase.execute(
        id: 'missing-bill',
        name: 'Electricity',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
      ),
      throwsA(isA<StateError>()),
    );

    expect(repository.updated, isEmpty);
  });

  test('rejects an empty bill ID', () {
    expect(
      () => useCase.execute(
        id: '   ',
        name: 'Electricity',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects an empty bill name', () async {
    repository.bills.add(
      const Bill(
        id: 'bill-1',
        name: 'Electricity',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: null,
        categoryId: null,
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    );

    expect(
      () => useCase.execute(
        id: 'bill-1',
        name: '   ',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

class FakeBillRepository implements BillRepository {
  final List<Bill> bills = [];
  final List<Bill> updated = [];

  @override
  Future<Bill?> getById(String id) async {
    for (final bill in bills) {
      if (bill.id == id) {
        return bill;
      }
    }

    return null;
  }

  @override
  Future<List<Bill>> getAll() async {
    return List.unmodifiable(bills);
  }

  @override
  Future<Bill> create({required Bill bill}) async {
    bills.add(bill);
    return bill;
  }

  @override
  Future<Bill> update({required Bill bill}) async {
    final index = bills.indexWhere((existing) => existing.id == bill.id);

    if (index == -1) {
      throw StateError('Bill not found.');
    }

    bills[index] = bill;
    updated.add(bill);
    return bill;
  }

  @override
  Future<void> delete(String id) async {
    bills.removeWhere((bill) => bill.id == id);
  }
}
