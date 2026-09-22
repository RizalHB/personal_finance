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

  @override
  String get transactionsSearchHint => 'Cari transaksi';

  @override
  String get transactionUntitled => 'Transaksi';

  @override
  String get transactionFilterAll => 'Semua';

  @override
  String get transactionFilterIncome => 'Pemasukan';

  @override
  String get transactionFilterExpense => 'Pengeluaran';

  @override
  String get transactionFilterTransfer => 'Transfer';

  @override
  String get transactionFilterDateRange => 'Rentang tanggal';

  @override
  String transactionFilterDateRangeSelected(Object start, Object end) {
    return '$start – $end';
  }

  @override
  String get transactionFilterMinAmount => 'Nominal minimum';

  @override
  String get transactionFilterMaxAmount => 'Nominal maksimum';

  @override
  String get transactionFilterReset => 'Reset filter';

  @override
  String get transactionDetailId => 'ID transaksi';

  @override
  String get transactionDetailType => 'Jenis';

  @override
  String get transactionDetailStatus => 'Status';

  @override
  String get transactionStatusPosted => 'Tercatat';

  @override
  String get transactionStatusVoided => 'Dibatalkan';

  @override
  String get transactionDetailMerchant => 'Merchant';

  @override
  String get transactionDetailCategory => 'Kategori';

  @override
  String get transactionDetailAccount => 'Akun';

  @override
  String get transactionDetailNotes => 'Catatan';
}
