import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/presentation/providers/transaction_list_providers.dart';
import 'package:personal_finance/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:personal_finance/features/transactions/presentation/state/transaction_list_state.dart';
import 'package:personal_finance/features/transactions/presentation/notifiers/transaction_list_notifier.dart';

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
      const transaction = Transaction(
        id: 'transaction-1',
        type: TransactionType.expense,
        status: TransactionStatus.posted,
        transactionDate: 1000,
        currencyCode: 'IDR',
        amountMinor: 50000,
        accountId: 'account-bca',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Makan',
        relatedTransactionId: null,
        recurringTransactionId: null,
        createdAt: 1000,
        updatedAt: 1000,
        voidedAt: null,
      );

      await tester.pumpWidget(
        _buildTestWidget(const TransactionListLoaded([transaction])),
      );

      expect(find.text('transaction-1'), findsOneWidget);
      expect(find.text('IDR'), findsOneWidget);
      expect(find.text('50000'), findsOneWidget);
    });
  });
}

Widget _buildTestWidget(TransactionListState state) {
  return ProviderScope(
    overrides: [
      transactionListNotifierProvider.overrideWith(
        () => _FakeTransactionListNotifier(state),
      ),
    ],
    child: const MaterialApp(home: TransactionListScreen()),
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
