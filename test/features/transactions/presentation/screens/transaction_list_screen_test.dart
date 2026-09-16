import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_list_item.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_presentation.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_list_providers.dart';
import 'package:personal_finance/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_list_state.dart';
import 'package:personal_finance/features/transactions/presentation/notifiers/transaction_list_notifier.dart';
import 'package:personal_finance/core/localization/generated/app_localizations.dart';

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
      );

      await tester.pumpWidget(
        _buildTestWidget(const TransactionListLoaded([transaction])),
      );

      expect(find.text('transaction-1'), findsOneWidget);
      expect(find.textContaining('Pengeluaran •'), findsOneWidget);
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
  });
}

Widget _buildTestWidget(
  TransactionListState state, {
  Locale locale = const Locale('id'),
}) {
  return ProviderScope(
    overrides: [
      transactionListNotifierProvider.overrideWith(
        () => _FakeTransactionListNotifier(state),
      ),
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
}
