import '../../domain/entities/bill_payment.dart';

abstract interface class BillPaymentRepository {
  Future<BillPayment?> getById(String id);

  Future<List<BillPayment>> getByBillId(String billId);

  Future<BillPayment> create({required BillPayment billPayment});

  Future<void> delete(String id);
}
