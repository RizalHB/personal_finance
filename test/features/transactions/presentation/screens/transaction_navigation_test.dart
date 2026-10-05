import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/localization/generated/app_localizations.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart'
    as domain;
import 'package:personal_finance/features/transactions/domain/models/transaction_search_result.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_list_item.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_presentation.dart';
import 'package:personal_finance/features/transactions/presentation/notifiers/transaction_detail_notifier.dart';
import 'package:personal_finance/features/transactions/presentation/notifiers/transaction_list_notifier.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_detail_providers.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_list_providers.dart';
import 'package:personal_finance/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:personal_finance/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_detail_state.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_list_state.dart';

void main() {
  testWidgets('navigates from transaction list to transaction detail', (
    tester,
  ) async {
    final transaction = domain.Transaction(
      id: 'transaction-1',
      type: TransactionType.expense,
      status: domain.TransactionStatus.posted,
      transactionDate: 1_757_078_400_000,
      currencyCode: 'IDR',
      amountMinor: 350_000,
      accountId: 'account-cash',
      categoryId: 'category-food',
      merchantId: null,
      notes: 'Lunch',
      relatedTransactionId: null,
      recurringTransactionId: null,
      createdAt: 1_000,
      updatedAt: 1_000,
      voidedAt: null,
    );

    final searchResult = TransactionSearchResult(
      transaction: transaction,
      categoryName: 'Food',
      merchantName: null,
      accountName: 'Cash',
    );

    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListNotifierProvider.overrideWith(
            FakeTransactionListNotifier.new,
          ),
          transactionDetailNotifierProvider.overrideWith(
            () => FakeTransactionDetailNotifier(searchResult),
          ),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TransactionListScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Food'), findsOneWidget);

    final transactionTile = find.byType(ListTile);

    expect(transactionTile, findsOneWidget);

    final initialPushCount = observer.pushCount;

    await tester.tap(transactionTile);
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      observer.pushCount,
      initialPushCount + 1,
      reason: 'TransactionListScreen should push TransactionDetailScreen.',
    );

    final pushedRoute = observer.lastRoute;

    expect(pushedRoute, isA<MaterialPageRoute>());

    final materialRoute = pushedRoute! as MaterialPageRoute;

    final detailWidget = materialRoute.builder(
      tester.element(find.byType(TransactionListScreen)),
    );

    expect(detailWidget, isA<TransactionDetailScreen>());
  });
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

class FakeTransactionListNotifier extends TransactionListNotifier {
  @override
  TransactionListState build() {
    return const TransactionListLoaded([
      TransactionListItem(
        id: 'transaction-1',
        type: TransactionTypePresentation.expense,
        currencyCode: 'IDR',
        amountMinor: 350_000,
        transactionDate: 1_757_078_400_000,
        merchantName: null,
        categoryName: 'Food',
        accountName: 'Cash',
      ),
    ]);
  }
}

class FakeTransactionDetailNotifier extends TransactionDetailNotifier {
  FakeTransactionDetailNotifier(this._result);

  final TransactionSearchResult _result;

  @override
  TransactionDetailState build() {
    return TransactionDetailLoaded(_result);
  }

  @override
  Future<void> load(String transactionId) async {
    if (transactionId == _result.transaction.id) {
      state = TransactionDetailLoaded(_result);
      return;
    }

    state = const TransactionDetailNotFound();
  }
}
