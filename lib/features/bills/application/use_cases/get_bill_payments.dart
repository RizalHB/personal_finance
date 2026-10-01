import '../../data/repositories/bill_payment_repository.dart';
import '../../domain/entities/bill_payment.dart';

class GetBillPayments {
  const GetBillPayments(this._repository);

  final BillPaymentRepository _repository;

  Future<List<BillPayment>> execute({required String billId}) {
    final normalizedBillId = billId.trim();

    if (normalizedBillId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    return _repository.getByBillId(normalizedBillId);
  }
}
