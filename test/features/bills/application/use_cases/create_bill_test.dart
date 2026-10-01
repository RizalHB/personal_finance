import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/bills/application/use_cases/create_bill.dart';
import 'package:personal_finance/features/bills/data/repositories/bill_repository.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';

void main() {
  late FakeBillRepository repository;
  late FakeIdGenerator idGenerator;
  late CreateBill useCase;

  setUp(() {
    repository = FakeBillRepository();
    idGenerator = FakeIdGenerator();

    useCase = CreateBill(repository, idGenerator);
  });

  test('creates a normalized active bill', () async {
    final bill = await useCase.execute(
      name: ' Electricity ',
      amountMinor: 500_000,
      currencyCode: ' idr ',
      dueDate: 2_000,
      accountId: ' account-cash ',
      categoryId: ' category-utilities ',
      merchantId: ' merchant-pln ',
      notes: ' Monthly bill ',
    );

    expect(bill.id, 'bill-1');
    expect(bill.name, 'Electricity');
    expect(bill.amountMinor, 500_000);
    expect(bill.currencyCode, 'IDR');
    expect(bill.dueDate, 2_000);
    expect(bill.status, BillStatus.active);
    expect(bill.accountId, 'account-cash');
    expect(bill.categoryId, 'category-utilities');
    expect(bill.merchantId, 'merchant-pln');
    expect(bill.notes, 'Monthly bill');
    expect(bill.createdAt, greaterThan(0));
    expect(bill.updatedAt, bill.createdAt);
    expect(bill.cancelledAt, isNull);

    expect(repository.created, hasLength(1));
    expect(repository.created.single.id, 'bill-1');
  });

  test('allows an unknown bill amount', () async {
    final bill = await useCase.execute(
      name: 'Variable Bill',
      amountMinor: null,
      currencyCode: 'IDR',
      dueDate: 2_000,
    );

    expect(bill.amountMinor, isNull);
    expect(bill.status, BillStatus.active);
  });

  test('normalizes blank optional fields to null', () async {
    final bill = await useCase.execute(
      name: 'Internet',
      amountMinor: 300_000,
      currencyCode: 'IDR',
      dueDate: 2_000,
      accountId: '   ',
      categoryId: '   ',
      merchantId: '   ',
      notes: '   ',
    );

    expect(bill.accountId, isNull);
    expect(bill.categoryId, isNull);
    expect(bill.merchantId, isNull);
    expect(bill.notes, isNull);
  });

  test('rejects an empty name', () {
    expect(
      () => useCase.execute(
        name: '   ',
        amountMinor: 100_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.created, isEmpty);
  });

  test('rejects a non-positive amount', () {
    expect(
      () => useCase.execute(
        name: 'Electricity',
        amountMinor: 0,
        currencyCode: 'IDR',
        dueDate: 2_000,
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.created, isEmpty);
  });

  test('rejects an invalid currency code', () {
    expect(
      () => useCase.execute(
        name: 'Electricity',
        amountMinor: 100_000,
        currencyCode: 'ID',
        dueDate: 2_000,
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.created, isEmpty);
  });
}

class FakeIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() {
    _counter++;
    return 'bill-$_counter';
  }
}

class FakeBillRepository implements BillRepository {
  final List<Bill> bills = [];
  final List<Bill> created = [];

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
    created.add(bill);
    return bill;
  }

  @override
  Future<Bill> update({required Bill bill}) async {
    final index = bills.indexWhere((existing) => existing.id == bill.id);

    if (index == -1) {
      throw StateError('Bill not found.');
    }

    bills[index] = bill;
    return bill;
  }

  @override
  Future<void> delete(String id) async {
    bills.removeWhere((bill) => bill.id == id);
  }
}
