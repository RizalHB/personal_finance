import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_finance/features/bills/application/bill_dependencies.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bill.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bill_payments.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';
import 'package:personal_finance/features/bills/domain/entities/bill_payment.dart';
import 'package:personal_finance/features/bills/presentation/pages/bill_detail_page.dart';

void main() {
  testWidgets('displays bill details and payment history', (tester) async {
    final paidAt = DateTime(2026, 9, 15, 10).millisecondsSinceEpoch;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getBillProvider.overrideWithValue(FakeGetBill()),
          getBillPaymentsProvider.overrideWithValue(
            FakeGetBillPayments([
              BillPayment(
                id: 'payment-1',
                billId: 'bill-1',
                transactionId: 'transaction-1',
                amountMinor: 250_000,
                paidAt: paidAt,
                createdAt: 1000,
              ),
            ]),
          ),
        ],
        child: const MaterialApp(home: BillDetailPage(billId: 'bill-1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bill Details'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Status: active'), findsOneWidget);
    expect(find.text('Amount: 350000'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Rp250.000'), findsOneWidget);
    expect(find.textContaining('2026-09-15'), findsOneWidget);
  });

  testWidgets('displays empty state when there are no payments', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getBillProvider.overrideWithValue(FakeGetBill()),
          getBillPaymentsProvider.overrideWithValue(
            FakeGetBillPayments(const []),
          ),
        ],
        child: const MaterialApp(home: BillDetailPage(billId: 'bill-1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No payments recorded yet.'), findsOneWidget);
  });
}

class FakeGetBill implements GetBill {
  @override
  Future<Bill> execute(String id) async {
    return const Bill(
      id: 'bill-1',
      name: 'Internet',
      amountMinor: 350_000,
      currencyCode: 'IDR',
      dueDate: 2_000,
      status: BillStatus.active,
      accountId: 'account-cash',
      categoryId: 'category-internet',
      merchantId: null,
      notes: null,
      createdAt: 1_000,
      updatedAt: 1_000,
      cancelledAt: null,
    );
  }
}

class FakeGetBillPayments implements GetBillPayments {
  FakeGetBillPayments(this.payments);

  final List<BillPayment> payments;

  @override
  Future<List<BillPayment>> execute({required String billId}) async {
    return payments;
  }
}
