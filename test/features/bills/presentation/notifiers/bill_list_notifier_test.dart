import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/bill_dependencies.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bills.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';
import 'package:personal_finance/features/bills/presentation/notifiers/bill_list_notifier.dart';
import 'package:personal_finance/features/bills/presentation/state/bill_list_state.dart';

void main() {
  test('loads and maps bills through GetBills', () async {
    final useCase = FakeGetBills([
      const Bill(
        id: 'bill-1',
        name: 'Food Bill',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
      const Bill(
        id: 'bill-2',
        name: 'Internet',
        amountMinor: 350_000,
        currencyCode: 'IDR',
        dueDate: 3_000,
        status: BillStatus.paid,
        accountId: 'account-cash',
        categoryId: 'category-internet',
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [getBillsProvider.overrideWithValue(useCase)],
    );

    addTearDown(container.dispose);

    final state = await container.read(billListNotifierProvider.future);

    expect(state, isA<BillListState>());
    expect(state.items, hasLength(2));

    expect(state.items[0].billId, 'bill-1');
    expect(state.items[0].name, 'Food Bill');
    expect(state.items[0].amountMinor, 500_000);
    expect(state.items[0].statusLabel, 'Active');
    expect(state.items[0].isActive, isTrue);

    expect(state.items[1].billId, 'bill-2');
    expect(state.items[1].name, 'Internet');
    expect(state.items[1].amountMinor, 350_000);
    expect(state.items[1].statusLabel, 'Paid');
    expect(state.items[1].isActive, isFalse);

    expect(useCase.called, isTrue);
  });
}

class FakeGetBills implements GetBills {
  FakeGetBills(this.bills);

  final List<Bill> bills;
  bool called = false;

  @override
  Future<List<Bill>> execute() async {
    called = true;
    return bills;
  }
}
