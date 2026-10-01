import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/application/bill_dependencies.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bill.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bill_payments.dart';
import 'package:personal_finance/features/bills/application/use_cases/get_bills.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';
import 'package:personal_finance/features/bills/domain/entities/bill_payment.dart';
import 'package:personal_finance/features/bills/presentation/pages/bills_page.dart';

void main() {
  testWidgets('displays bills', (tester) async {
    final useCase = FakeGetBills([
      const Bill(
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
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [getBillsProvider.overrideWithValue(useCase)],
        child: const MaterialApp(home: BillsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Rp350.000 • Active'), findsOneWidget);
  });

  testWidgets('displays empty state when there are no bills', (tester) async {
    final useCase = FakeGetBills(const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [getBillsProvider.overrideWithValue(useCase)],
        child: const MaterialApp(home: BillsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No bills yet.'), findsOneWidget);
  });

  testWidgets('opens bill detail page when an active bill is tapped', (
    tester,
  ) async {
    final getBills = FakeGetBills([
      const Bill(
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
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getBillsProvider.overrideWithValue(getBills),
          getBillProvider.overrideWithValue(FakeGetBill()),
          getBillPaymentsProvider.overrideWithValue(FakeGetBillPayments()),
        ],
        child: const MaterialApp(home: BillsPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Internet'));
    await tester.pumpAndSettle();

    expect(find.text('Bill Details'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
  });
}

class FakeGetBills implements GetBills {
  FakeGetBills(this.bills);

  final List<Bill> bills;

  @override
  Future<List<Bill>> execute() async {
    return bills;
  }
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
  @override
  Future<List<BillPayment>> execute({required String billId}) async {
    return const [];
  }
}
