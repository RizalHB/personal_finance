import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/budgets/domain/entities/budget.dart';
import 'package:personal_finance/features/budgets/presentation/notifiers/budget_list_notifier.dart';
import 'package:personal_finance/features/budgets/presentation/pages/budget_allocations_page.dart';
import 'package:personal_finance/features/budgets/presentation/pages/budgets_page.dart';

void main() {
  testWidgets('navigates from budgets list to budget allocations', (
    tester,
  ) async {
    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetListNotifierProvider.overrideWith(FakeBudgetListNotifier.new),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const BudgetsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('September Budget'), findsOneWidget);

    final budgetTileFinder = find.byType(ListTile);
    expect(budgetTileFinder, findsOneWidget);

    final budgetTile = tester.widget<ListTile>(budgetTileFinder);

    expect(budgetTile.onTap, isNotNull);

    final initialPushCount = observer.pushCount;

    budgetTile.onTap!();

    expect(observer.pushCount, initialPushCount + 1);

    final pushedRoute = observer.lastRoute;

    expect(pushedRoute, isA<MaterialPageRoute>());

    final materialRoute = pushedRoute! as MaterialPageRoute;

    final routeWidget = materialRoute.builder(
      tester.element(find.byType(BudgetsPage)),
    );

    expect(routeWidget, isA<BudgetAllocationsPage>());

    final allocationsPage = routeWidget as BudgetAllocationsPage;

    expect(allocationsPage.budgetId, 'budget-1');
  });
}

class FakeBudgetListNotifier extends BudgetListNotifier {
  @override
  Future<List<Budget>> build() async {
    return [
      const Budget(
        id: 'budget-1',
        year: 2026,
        month: 9,
        name: 'September Budget',
        status: BudgetStatus.active,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    ];
  }
}

class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  Route<dynamic>? lastRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
    lastRoute = route;
    super.didPush(route, previousRoute);
  }
}
