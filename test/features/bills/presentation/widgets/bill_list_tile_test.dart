import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/presentation/models/bill_list_item.dart';
import 'package:personal_finance/features/bills/presentation/widgets/bill_list_tile.dart';

void main() {
  testWidgets('displays bill name, amount, and status', (tester) async {
    var tapped = false;

    const item = BillListItem(
      billId: 'bill-1',
      name: 'Internet',
      amountMinor: 350_000,
      currencyCode: 'IDR',
      dueDate: 2_000,
      statusLabel: 'Active',
      isActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillListTile(
            item: item,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Rp350.000 • Active'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byType(ListTile));

    expect(tapped, isTrue);
  });

  testWidgets('displays unknown amount', (tester) async {
    const item = BillListItem(
      billId: 'bill-2',
      name: 'Electricity',
      amountMinor: null,
      currencyCode: 'IDR',
      dueDate: 2_000,
      statusLabel: 'Active',
      isActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillListTile(item: item, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Electricity'), findsOneWidget);
    expect(find.text('Amount unknown • Active'), findsOneWidget);
  });

  testWidgets('does not navigate for inactive bill', (tester) async {
    var tapped = false;

    const item = BillListItem(
      billId: 'bill-3',
      name: 'Cancelled Bill',
      amountMinor: 100_000,
      currencyCode: 'IDR',
      dueDate: 2_000,
      statusLabel: 'Cancelled',
      isActive: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillListTile(
            item: item,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Cancelled Bill'), findsOneWidget);
    expect(find.text('Rp100.000 • Cancelled'), findsOneWidget);

    await tester.tap(find.byType(ListTile));

    expect(tapped, isFalse);
  });
}
