import '../models/bill_payment_list_item.dart';

class BillPaymentState {
  const BillPaymentState({this.items = const []});

  final List<BillPaymentListItem> items;
}
