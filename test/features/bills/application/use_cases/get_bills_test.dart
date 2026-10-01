import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bills.dart';
import 'package:personal_finance/features/bills/data/repositories/bill_repository.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';

void main() {
  late FakeBillRepository repository;
  late GetBills useCase;

  setUp(() {
    repository = FakeBillRepository();
    useCase = GetBills(repository);
  });

  test('returns all bills from the repository', () async {
    repository.bills.addAll([
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
      const Bill(
        id: 'bill-2',
        name: 'Internet',
        amountMinor: 300_000,
        currencyCode: 'IDR',
        dueDate: 3_000,
        status: BillStatus.paid,
        accountId: 'account-cash',
        categoryId: 'category-utilities',
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    ]);

    final result = await useCase.execute();

    expect(result, hasLength(2));
    expect(result.map((bill) => bill.id), ['bill-1', 'bill-2']);
    expect(repository.called, isTrue);
  });

  test('returns an empty list when there are no bills', () async {
    final result = await useCase.execute();

    expect(result, isEmpty);
    expect(repository.called, isTrue);
  });
}

class FakeBillRepository implements BillRepository {
  final List<Bill> bills = [];
  bool called = false;

  @override
  Future<Bill?> getById(String id) async {
    return null;
  }

  @override
  Future<List<Bill>> getAll() async {
    called = true;
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
    bills.removeWhere((bill) => bill.id == id);
  }
}
