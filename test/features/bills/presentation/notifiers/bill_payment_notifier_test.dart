import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/bill_dependencies.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bill_payments.dart';
import 'package:personal_finance/features/bills/domain/entities/bill_payment.dart';
import 'package:personal_finance/features/bills/presentation/notifiers/bill_payment_notifier.dart';
import 'package:personal_finance/features/bills/presentation/state/bill_payment_state.dart';

void main() {
  test('loads and maps payments for the requested bill', () async {
    final useCase = FakeGetBillPayments([
      const BillPayment(
        id: 'payment-1',
        billId: 'bill-1',
        transactionId: 'transaction-1',
        amountMinor: 250_000,
        paidAt: 2_000,
        createdAt: 2_000,
      ),
      const BillPayment(
        id: 'payment-2',
        billId: 'bill-1',
        transactionId: 'transaction-2',
        amountMinor: 250_000,
        paidAt: 3_000,
        createdAt: 3_000,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [getBillPaymentsProvider.overrideWithValue(useCase)],
    );

    addTearDown(container.dispose);

    final state = await container.read(
      billPaymentNotifierProvider('bill-1').future,
    );

    expect(state, isA<BillPaymentState>());
    expect(state.items, hasLength(2));

    expect(state.items[0].paymentId, 'payment-1');
    expect(state.items[0].amountMinor, 250_000);
    expect(state.items[0].paidAt, 2_000);

    expect(state.items[1].paymentId, 'payment-2');
    expect(state.items[1].amountMinor, 250_000);
    expect(state.items[1].paidAt, 3_000);

    expect(useCase.requestedBillIds, ['bill-1']);
  });
}

class FakeGetBillPayments implements GetBillPayments {
  FakeGetBillPayments(this.payments);

  final List<BillPayment> payments;
  final List<String> requestedBillIds = [];

  @override
  Future<List<BillPayment>> execute({required String billId}) async {
    requestedBillIds.add(billId);
    return payments;
  }
}
