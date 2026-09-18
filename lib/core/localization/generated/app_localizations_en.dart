// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeTransfer => 'Transfer';

  @override
  String get transactionTypeAdjustment => 'Adjustment';

  @override
  String get transactionTypeOpeningBalance => 'Opening balance';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsInitialEmpty => 'No transactions yet.';

  @override
  String get transactionsSearchEmpty => 'No transactions found.';

  @override
  String get transactionsSearchHint => 'Search transactions';

  @override
  String get transactionUntitled => 'Transaction';

  @override
  String get transactionFilterAll => 'All';

  @override
  String get transactionFilterIncome => 'Income';

  @override
  String get transactionFilterExpense => 'Expense';

  @override
  String get transactionFilterTransfer => 'Transfer';

  @override
  String get transactionFilterDateRange => 'Date range';

  @override
  String transactionFilterDateRangeSelected(Object start, Object end) {
    return '$start – $end';
  }

  @override
  String get transactionFilterMinAmount => 'Minimum amount';

  @override
  String get transactionFilterMaxAmount => 'Maximum amount';

  @override
  String get transactionFilterReset => 'Reset filters';
}
