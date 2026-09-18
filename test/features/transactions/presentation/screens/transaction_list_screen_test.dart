import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/localization/generated/app_localizations.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_list_item.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_presentation.dart';
import 'package:personal_finance/features/transactions/presentation/notifiers/transaction_list_notifier.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_list_providers.dart';
import 'package:personal_finance/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_list_state.dart';
import 'package:personal_finance/features/transactions/presentation/notifiers/transaction_filter_notifier.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_filter_state.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/presentation/formatters/transaction_list_formatter.dart';

void main() {
  group('TransactionListScreen', () {
    testWidgets('renders initial state', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const TransactionListInitial()));

      expect(find.text('Belum ada transaksi.'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const TransactionListLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const TransactionListEmpty()));

      expect(find.text('Tidak ada transaksi yang ditemukan.'), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(const TransactionListError('Gagal memuat transaksi.')),
      );

      expect(find.text('Gagal memuat transaksi.'), findsOneWidget);
    });

    testWidgets('renders loaded transactions', (tester) async {
      const transaction = TransactionListItem(
        id: 'transaction-1',
        type: TransactionTypePresentation.expense,
        currencyCode: 'IDR',
        amountMinor: 50000,
        transactionDate: 1000,
        merchantName: 'Tokopedia',
        categoryName: 'Food',
        accountName: 'BCA',
      );

      await tester.pumpWidget(
        _buildTestWidget(const TransactionListLoaded([transaction])),
      );

      expect(find.text('Tokopedia'), findsOneWidget);
      expect(find.textContaining('Pengeluaran •'), findsOneWidget);
      expect(find.textContaining('Food'), findsOneWidget);
      expect(find.textContaining('BCA'), findsOneWidget);
      expect(find.text('Rp50.000'), findsOneWidget);
    });

    testWidgets('renders English localization', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          const TransactionListInitial(),
          locale: const Locale('en'),
        ),
      );

      expect(find.text('No transactions yet.'), findsOneWidget);
    });

    testWidgets(
      'uses localized untitled fallback when merchant and category are absent',
      (tester) async {
        const transaction = TransactionListItem(
          id: 'transaction-untitled',
          type: TransactionTypePresentation.expense,
          currencyCode: 'IDR',
          amountMinor: 50000,
          transactionDate: 1000,
        );

        await tester.pumpWidget(
          _buildTestWidget(const TransactionListLoaded([transaction])),
        );

        expect(find.text('Transaksi'), findsNWidgets(2));
      },
    );

    testWidgets(
      'uses English untitled fallback when merchant and category are absent',
      (tester) async {
        const transaction = TransactionListItem(
          id: 'transaction-untitled-en',
          type: TransactionTypePresentation.expense,
          currencyCode: 'IDR',
          amountMinor: 50000,
          transactionDate: 1000,
        );

        await tester.pumpWidget(
          _buildTestWidget(
            const TransactionListLoaded([transaction]),
            locale: const Locale('en'),
          ),
        );

        expect(find.text('Transaction'), findsOneWidget);
      },
    );

    testWidgets('submits search query to filter notifier', (tester) async {
      final filterNotifier = _FakeTransactionFilterNotifier();

      await tester.pumpWidget(
        _buildTestWidget(
          const TransactionListInitial(),
          filterNotifier: filterNotifier,
        ),
      );

      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Cari transaksi',
      );

      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Tokopedia');

      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(filterNotifier.submittedQuery, 'Tokopedia');
    });
    testWidgets('renders selected date range', (tester) async {
      final filterNotifier = _FakeTransactionFilterNotifier(
        initialState: TransactionFilterState(
          fromDate: DateTime(2026, 9, 1).millisecondsSinceEpoch,
          toDate: DateTime(2026, 9, 30).millisecondsSinceEpoch,
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const TransactionListInitial(),
          filterNotifier: filterNotifier,
        ),
      );

      final localizations = AppLocalizations.of(
        tester.element(find.byType(TransactionListScreen)),
      )!;

      const formatter = TransactionListFormatter();

      final start = formatter.formatDate(
        DateTime(2026, 9, 1).millisecondsSinceEpoch,
        locale: localizations.localeName,
      );

      final end = formatter.formatDate(
        DateTime(2026, 9, 30).millisecondsSinceEpoch,
        locale: localizations.localeName,
      );

      expect(
        find.text(localizations.transactionFilterDateRangeSelected(start, end)),
        findsOneWidget,
      );
    });
    testWidgets('resets filters and refreshes transactions', (tester) async {
      final filterNotifier = _FakeTransactionFilterNotifier(
        initialState: TransactionFilterState(
          searchQuery: 'Tokopedia',
          fromDate: DateTime(2026, 9, 1).millisecondsSinceEpoch,
          toDate: DateTime(2026, 9, 30).millisecondsSinceEpoch,
          minAmountMinor: 10000,
          maxAmountMinor: 500000,
        ),
      );

      final listNotifier = _FakeTransactionListNotifier(
        const TransactionListInitial(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionListNotifierProvider.overrideWith(() => listNotifier),
            transactionFilterNotifierProvider.overrideWith(
              () => filterNotifier,
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TransactionListScreen(),
          ),
        ),
      );

      final localizations = AppLocalizations.of(
        tester.element(find.byType(TransactionListScreen)),
      )!;

      final resetButton = find.text(localizations.transactionFilterReset);

      expect(resetButton, findsOneWidget);

      await tester.tap(resetButton);
      await tester.pump();

      expect(filterNotifier.resetCalled, isTrue);
      expect(listNotifier.searchCalled, isTrue);
    });
  });
}

Widget _buildTestWidget(
  TransactionListState state, {
  Locale locale = const Locale('id'),
  TransactionFilterNotifier? filterNotifier,
}) {
  return ProviderScope(
    overrides: [
      transactionListNotifierProvider.overrideWith(
        () => _FakeTransactionListNotifier(state),
      ),
      if (filterNotifier != null)
        transactionFilterNotifierProvider.overrideWith(() => filterNotifier),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TransactionListScreen(),
    ),
  );
}

class _FakeTransactionListNotifier extends TransactionListNotifier {
  _FakeTransactionListNotifier(this._state);

  final TransactionListState _state;

  bool searchCalled = false;

  @override
  TransactionListState build() {
    return _state;
  }

  @override
  Future<void> searchWithCurrentFilter() async {
    searchCalled = true;
  }
}

class _FakeTransactionFilterNotifier extends TransactionFilterNotifier {
  _FakeTransactionFilterNotifier({
    this.initialState = const TransactionFilterState(),
  });

  final TransactionFilterState initialState;

  String? submittedQuery;
  TransactionType? selectedType;
  bool resetCalled = false;

  @override
  TransactionFilterState build() {
    return initialState;
  }

  @override
  void setSearchQuery(String query) {
    submittedQuery = query;
  }

  @override
  void setType(TransactionType? type) {
    selectedType = type;
  }

  @override
  void reset() {
    resetCalled = true;
  }
}
