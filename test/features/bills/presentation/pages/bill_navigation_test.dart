import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/bills/presentation/models/bill_list_item.dart';
import 'package:personal_finance/features/bills/presentation/notifiers/bill_list_notifier.dart';
import 'package:personal_finance/features/bills/presentation/pages/bill_detail_page.dart';
import 'package:personal_finance/features/bills/presentation/pages/bills_page.dart';
import 'package:personal_finance/features/bills/presentation/state/bill_list_state.dart';

void main() {
  testWidgets('navigates from bills list to bill detail', (tester) async {
    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          billListNotifierProvider.overrideWith(FakeBillListNotifier.new),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const BillsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);

    final billTileFinder = find.byType(ListTile);

    expect(billTileFinder, findsOneWidget);

    final billTile = tester.widget<ListTile>(billTileFinder);

    expect(billTile.onTap, isNotNull);

    final initialPushCount = observer.pushCount;

    billTile.onTap!();

    expect(observer.pushCount, initialPushCount + 1);

    final pushedRoute = observer.lastRoute;

    expect(pushedRoute, isA<MaterialPageRoute>());

    final materialRoute = pushedRoute! as MaterialPageRoute;

    final routeWidget = materialRoute.builder(
      tester.element(find.byType(BillsPage)),
    );

    expect(routeWidget, isA<BillDetailPage>());

    final detailPage = routeWidget as BillDetailPage;

    expect(detailPage.billId, 'bill-1');
  });
}

class FakeBillListNotifier extends BillListNotifier {
  @override
  Future<BillListState> build() async {
    return const BillListState(
      items: [
        BillListItem(
          billId: 'bill-1',
          name: 'Internet',
          amountMinor: 350_000,
          currencyCode: 'IDR',
          dueDate: 2_000,
          statusLabel: 'Active',
          isActive: true,
        ),
      ],
    );
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
