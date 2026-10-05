import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/bill_dependencies.dart';
import 'package:personal_finance/features/bills/application/use_cases/record_bill_payment.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';
import 'package:personal_finance/features/bills/domain/entities/bill_payment.dart';
import 'package:personal_finance/features/bills/presentation/notifiers/bill_payment_notifier.dart';
import 'package:personal_finance/features/bills/presentation/pages/bill_detail_page.dart';
import 'package:personal_finance/features/bills/presentation/state/bill_payment_state.dart';

void main() {
  testWidgets('records payment from bill detail and refreshes payments', (
    tester,
  ) async {
    final recordUseCase = FakeRecordBillPayment();
    final paymentNotifier = FakeBillPaymentNotifier();

    const bill = Bill(
      id: 'bill-1',
      name: 'Internet',
      amountMinor: 500_000,
      currencyCode: 'IDR',
      dueDate: 2_000,
      status: BillStatus.active,
      accountId: 'account-cash',
      categoryId: 'category-bills',
      merchantId: null,
      notes: null,
      createdAt: 1_000,
      updatedAt: 1_000,
      cancelledAt: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          billDetailProvider('bill-1').overrideWith((ref) async => bill),
          recordBillPaymentProvider.overrideWithValue(recordUseCase),
          billPaymentNotifierProvider('bill-1')
              .overrideWith(() => paymentNotifier),
        ],
        child: const MaterialApp(home: BillDetailPage(billId: 'bill-1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bill Details'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Record Payment'), findsOneWidget);
    expect(find.text('No payments recorded yet.'), findsOneWidget);

    await tester.tap(find.text('Record Payment').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bill-payment-amount')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('bill-payment-amount')),
      '250000',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(recordUseCase.calls, hasLength(1));

    final call = recordUseCase.calls.single;

    expect(call.billId, 'bill-1');
    expect(call.amountMinor, 250_000);
    expect(call.paidAt, greaterThan(0));

    expect(paymentNotifier.refreshCallCount, 1);

    expect(find.text('Bill payment recorded.'), findsOneWidget);
  });
}

class FakeRecordBillPayment implements RecordBillPayment {
  final List<RecordPaymentCall> calls = [];

  @override
  Future<BillPayment> execute({
    required String billId,
    required int amountMinor,
    required int paidAt,
  }) async {
    calls.add(
      RecordPaymentCall(
        billId: billId,
        amountMinor: amountMinor,
        paidAt: paidAt,
      ),
    );

    return BillPayment(
      id: 'payment-1',
      billId: billId,
      transactionId: 'transaction-1',
      amountMinor: amountMinor,
      paidAt: paidAt,
      createdAt: paidAt,
    );
  }
}

class RecordPaymentCall {
  const RecordPaymentCall({
    required this.billId,
    required this.amountMinor,
    required this.paidAt,
  });

  final String billId;
  final int amountMinor;
  final int paidAt;
}

class FakeBillPaymentNotifier extends BillPaymentNotifier {
  FakeBillPaymentNotifier() : super('bill-1');

  int refreshCallCount = 0;

  @override
  Future<BillPaymentState> build() async {
    return const BillPaymentState();
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
  }
}
