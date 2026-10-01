import '../../domain/entities/bill_payment.dart';
import 'bill_payment_list_item.dart';

class BillPaymentListItemMapper {
  const BillPaymentListItemMapper();

  BillPaymentListItem map(BillPayment payment) {
    return BillPaymentListItem(
      paymentId: payment.id,
      amountMinor: payment.amountMinor,
      paidAt: payment.paidAt,
    );
  }

  List<BillPaymentListItem> mapList(List<BillPayment> payments) {
    return payments.map(map).toList();
  }
}
