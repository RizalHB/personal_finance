import '../../domain/entities/bill.dart';
import '../../domain/entities/bill_payment.dart';

abstract interface class BillPaymentWriter {
  Future<void> write({
    required Bill bill,
    required BillPayment billPayment,
    required bool markBillAsPaid,
  });
}
