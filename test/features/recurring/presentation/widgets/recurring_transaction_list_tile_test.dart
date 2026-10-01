import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/recurring/presentation/models/recurring_transaction_list_item.dart';
import 'package:personal_finance/features/recurring/presentation/widgets/recurring_transaction_list_tile.dart';

void main() {
  testWidgets('displays formatted amount, category, and monthly frequency', (
    tester,
  ) async {
    const item = RecurringTransactionListItem(
      recurringTransactionId: 'recurring-1',
      amountMinor: 500000,
      currencyCode: 'IDR',
      categoryId: 'category-food',
      frequencyLabel: 'Monthly',
      interval: 1,
      nextOccurrenceDate: 1_757_078_400_000,
      isActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecurringTransactionListTile(item: item)),
      ),
    );

    expect(find.text('Rp500.000'), findsOneWidget);
    expect(find.text('category-food • Monthly'), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_outline), findsNothing);
  });

  testWidgets('displays interval label for interval greater than one', (
    tester,
  ) async {
    const item = RecurringTransactionListItem(
      recurringTransactionId: 'recurring-2',
      amountMinor: 1_000_000,
      currencyCode: 'IDR',
      categoryId: 'category-transport',
      frequencyLabel: 'Weekly',
      interval: 2,
      nextOccurrenceDate: 1_757_078_400_000,
      isActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecurringTransactionListTile(item: item)),
      ),
    );

    expect(find.text('Rp1.000.000'), findsOneWidget);
    expect(find.text('category-transport • Every 2 weekly'), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
  });

  testWidgets(
    'displays inactive icon and omits category when category is null',
    (tester) async {
      const item = RecurringTransactionListItem(
        recurringTransactionId: 'recurring-3',
        amountMinor: 250000,
        currencyCode: 'IDR',
        categoryId: null,
        frequencyLabel: 'Daily',
        interval: 1,
        nextOccurrenceDate: 1_757_078_400_000,
        isActive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecurringTransactionListTile(item: item)),
        ),
      );

      expect(find.text('Rp250.000'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsNothing);
    },
  );
}
