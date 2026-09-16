// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get transactionTypeIncome => 'Pemasukan';

  @override
  String get transactionTypeExpense => 'Pengeluaran';

  @override
  String get transactionTypeTransfer => 'Transfer';

  @override
  String get transactionTypeAdjustment => 'Penyesuaian';

  @override
  String get transactionTypeOpeningBalance => 'Saldo awal';

  @override
  String get transactionsTitle => 'Transaksi';

  @override
  String get transactionsInitialEmpty => 'Belum ada transaksi.';

  @override
  String get transactionsSearchEmpty => 'Tidak ada transaksi yang ditemukan.';
}
