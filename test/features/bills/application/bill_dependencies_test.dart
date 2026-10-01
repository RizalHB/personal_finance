import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/bill_dependencies.dart';
import 'package:personal_finance/features/bills/application/use_cases/create_bill.dart';
import 'package:personal_finance/features/bills/application/use_cases/delete_bill.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bills.dart';
import 'package:personal_finance/features/bills/application/use_cases/update_bill.dart';
import 'package:personal_finance/features/bills/data/repositories/bill_repository.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';

void main() {
  test('bill providers resolve the expected use cases', () {
    final container = ProviderContainer(
      overrides: [
        billRepositoryProvider.overrideWithValue(FakeBillRepository()),
      ],
    );

    addTearDown(container.dispose);

    expect(container.read(createBillProvider), isA<CreateBill>());
    expect(container.read(getBillsProvider), isA<GetBills>());
    expect(container.read(updateBillProvider), isA<UpdateBill>());
    expect(container.read(deleteBillProvider), isA<DeleteBill>());
  });
}

class FakeBillRepository implements BillRepository {
  @override
  Future<Bill?> getById(String id) async => null;

  @override
  Future<List<Bill>> getAll() async => const [];

  @override
  Future<Bill> create({required Bill bill}) async {
    return bill;
  }

  @override
  Future<Bill> update({required Bill bill}) async {
    return bill;
  }

  @override
  Future<void> delete(String id) async {}
}
