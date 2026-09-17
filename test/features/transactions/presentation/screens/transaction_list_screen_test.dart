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

      final searchField = find.byType(TextField);

      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Tokopedia');

      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(filterNotifier.submittedQuery, 'Tokopedia');
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

  @override
  TransactionListState build() {
    return _state;
  }

  @override
  Future<void> searchWithCurrentFilter() async {}
}

class _FakeTransactionFilterNotifier extends TransactionFilterNotifier {
  String? submittedQuery;

  @override
  TransactionFilterState build() {
    return const TransactionFilterState();
  }

  @override
  void setSearchQuery(String query) {
    submittedQuery = query;
  }
}
