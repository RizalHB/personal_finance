import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/transaction_dependencies.dart';
import '../state/transaction_detail_state.dart';

class TransactionDetailNotifier extends Notifier<TransactionDetailState> {
  @override
  TransactionDetailState build() {
    return const TransactionDetailInitial();
  }

  Future<void> load(String transactionId) async {
    state = const TransactionDetailLoading();

    try {
      final getTransactionByIdWithDetails = ref.read(
        getTransactionByIdWithDetailsProvider,
      );

      final result = await getTransactionByIdWithDetails.execute(transactionId);

      if (result == null) {
        state = const TransactionDetailNotFound();
        return;
      }

      state = TransactionDetailLoaded(result);
    } catch (error) {
      state = TransactionDetailError(error.toString());
    }
  }
}
