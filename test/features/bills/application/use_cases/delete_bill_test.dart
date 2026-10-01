import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/use_cases/delete_bill.dart';
import 'package:personal_finance/features/bills/data/repositories/bill_repository.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';

void main() {
  late FakeBillRepository repository;
  late DeleteBill useCase;

  setUp(() {
    repository = FakeBillRepository();
    useCase = DeleteBill(repository);
  });

  test('deletes an existing bill', () async {
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

    await useCase.execute(' bill-1 ');

    expect(repository.bills, isEmpty);
    expect(repository.deleted, ['bill-1']);
  });

  test('rejects deletion when the bill does not exist', () async {
    expect(() => useCase.execute('missing-bill'), throwsA(isA<StateError>()));

    expect(repository.deleted, isEmpty);
  });

  test('rejects an empty bill ID', () {
    expect(() => useCase.execute('   '), throwsA(isA<ArgumentError>()));

    expect(repository.deleted, isEmpty);
  });
}

class FakeBillRepository implements BillRepository {
  final List<Bill> bills = [];
  final List<String> deleted = [];

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
    return bill;
  }

  @override
  Future<void> delete(String id) async {
    deleted.add(id);

    bills.removeWhere((bill) => bill.id == id);
  }
}
