import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/transaction_detail_notifier.dart';
import '../state/transaction_detail_state.dart';

final transactionDetailNotifierProvider =
    NotifierProvider<TransactionDetailNotifier, TransactionDetailState>(
      TransactionDetailNotifier.new,
    );
