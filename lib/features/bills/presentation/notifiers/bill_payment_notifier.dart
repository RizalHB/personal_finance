import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/bill_dependencies.dart';
import '../models/bill_payment_list_item_mapper.dart';
import '../state/bill_payment_state.dart';

class BillPaymentNotifier extends AsyncNotifier<BillPaymentState> {
  BillPaymentNotifier(this.billId);

  final String billId;

  @override
  Future<BillPaymentState> build() async {
    return _load(billId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return _load(billId);
    });
  }

  Future<BillPaymentState> _load(String billId) async {
    final useCase = ref.read(getBillPaymentsProvider);
    const mapper = BillPaymentListItemMapper();

    final payments = await useCase.execute(billId: billId);

    return BillPaymentState(items: mapper.mapList(payments));
  }
}

final billPaymentNotifierProvider =
    AsyncNotifierProvider.family<BillPaymentNotifier, BillPaymentState, String>(
      BillPaymentNotifier.new,
    );
