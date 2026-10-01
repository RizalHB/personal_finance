import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/presentation/models/bill_payment_list_item.dart';
import 'package:personal_finance/features/bills/presentation/widgets/bill_payment_list_tile.dart';

void main() {
  testWidgets('displays formatted payment amount and payment date', (
    tester,
  ) async {
    final paidAt = DateTime(2026, 9, 15, 10).millisecondsSinceEpoch;

    final item = BillPaymentListItem(
      paymentId: 'payment-1',
      amountMinor: 250_000,
      paidAt: paidAt,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BillPaymentListTile(item: item)),
      ),
    );

    expect(find.text('Rp250.000'), findsOneWidget);
    expect(find.textContaining('2026-09-15'), findsOneWidget);
  });
}
