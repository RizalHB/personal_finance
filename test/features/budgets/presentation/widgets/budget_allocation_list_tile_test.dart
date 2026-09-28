import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/presentation/models/budget_allocation_list_item.dart';
import 'package:personal_finance/features/budgets/presentation/widgets/budget_allocation_list_tile.dart';

void main() {
  const item = BudgetAllocationListItem(
    allocationId: 'allocation-1',
    categoryId: 'category-1',
    categoryName: 'Food',
    plannedAmountMinor: 500000,
    actualAmountMinor: 300000,
    remainingAmountMinor: 200000,
    usagePercentage: 60.0,
  );

  testWidgets('displays budget metrics and edit action', (tester) async {
    var editCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetAllocationListTile(
            item: item,
            onEdit: () {
              editCalled = true;
            },
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Rp500.000'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Actual: Rp300.000'), findsOneWidget);
    expect(find.text('Remaining: Rp200.000'), findsOneWidget);
    expect(find.text('60.0% used'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    expect(editCalled, isTrue);
  });

  testWidgets('displays overspent amount when actual exceeds planned', (
    tester,
  ) async {
    const overspentItem = BudgetAllocationListItem(
      allocationId: 'allocation-2',
      categoryId: 'category-2',
      categoryName: 'Transport',
      plannedAmountMinor: 500000,
      actualAmountMinor: 650000,
      remainingAmountMinor: -150000,
      usagePercentage: 130.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetAllocationListTile(
            item: overspentItem,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Actual: Rp650.000'), findsOneWidget);
    expect(find.text('Overspent: Rp150.000'), findsOneWidget);
    expect(find.text('130.0% used'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('calls delete callback from popup menu', (tester) async {
    var deleteCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetAllocationListTile(
            item: item,
            onEdit: () {},
            onDelete: () {
              deleteCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    expect(deleteCalled, isTrue);
  });
}
