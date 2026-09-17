import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/transaction_filter_notifier.dart';
import '../state/transaction_filter_state.dart';
import '../notifiers/transaction_list_notifier.dart';
import '../state/transaction_list_state.dart';

final transactionListNotifierProvider =
    NotifierProvider<TransactionListNotifier, TransactionListState>(
      TransactionListNotifier.new,
    );
final transactionFilterNotifierProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
      TransactionFilterNotifier.new,
    );
