import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/reports/domain/models/category_spending.dart';
import 'package:personal_finance/features/reports/presentation/widgets/category_spending_list_tile.dart';

void main() {
  testWidgets('displays category spending metrics', (tester) async {
    const item = CategorySpending(
      categoryId: 'category-food',
      categoryName: 'Food',
      amountMinor: 750_000,
      percentage: 60.0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategorySpendingListTile(item: item)),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Rp750.000'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(progress.value, 0.6);
  });

  testWidgets('clamps progress when percentage exceeds 100', (tester) async {
    const item = CategorySpending(
      categoryId: 'category-food',
      categoryName: 'Food',
      amountMinor: 1_250_000,
      percentage: 125.0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategorySpendingListTile(item: item)),
      ),
    );

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(progress.value, 1.0);
    expect(find.text('125.0%'), findsOneWidget);
  });
}
