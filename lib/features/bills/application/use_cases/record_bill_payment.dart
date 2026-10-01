import 'package:personal_finance/core/utils/id_generator.dart';

import '../../data/repositories/bill_payment_repository.dart';
import '../../data/repositories/bill_repository.dart';
import '../../data/writers/bill_payment_writer.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/bill_payment.dart';

class RecordBillPayment {
  const RecordBillPayment(
    this._billRepository,
    this._billPaymentRepository,
    this._writer,
    this._idGenerator,
  );

  final BillRepository _billRepository;
  final BillPaymentRepository _billPaymentRepository;
  final BillPaymentWriter _writer;
  final IdGenerator _idGenerator;

  Future<BillPayment> execute({
    required String billId,
    required int amountMinor,
    required int paidAt,
  }) async {
    final normalizedBillId = billId.trim();

    if (normalizedBillId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    if (amountMinor <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    if (paidAt <= 0) {
      throw ArgumentError('Payment date must be a valid timestamp.');
    }

    final bill = await _billRepository.getById(normalizedBillId);

    if (bill == null) {
      throw StateError('Bill not found: $normalizedBillId');
    }

    if (bill.status != BillStatus.active) {
      throw StateError('Only active bills can be paid.');
    }

    final accountId = bill.accountId?.trim();

    if (accountId == null || accountId.isEmpty) {
      throw StateError('Bill account is required before payment.');
    }

    final categoryId = bill.categoryId?.trim();

    if (categoryId == null || categoryId.isEmpty) {
      throw StateError('Bill category is required before payment.');
    }

    final existingPayments = await _billPaymentRepository.getByBillId(
      normalizedBillId,
    );

    final totalPaidMinor = existingPayments.fold<int>(
      0,
      (total, payment) => total + payment.amountMinor,
    );

    if (bill.amountMinor != null) {
      final remainingMinor = bill.amountMinor! - totalPaidMinor;

      if (remainingMinor <= 0) {
        throw StateError('Bill has already been fully paid.');
      }

      if (amountMinor > remainingMinor) {
        throw StateError('Payment exceeds the remaining bill amount.');
      }
    }

    final paymentId = _idGenerator.generate();
    final transactionId = _idGenerator.generate();

    final billPayment = BillPayment(
      id: paymentId,
      billId: bill.id,
      transactionId: transactionId,
      amountMinor: amountMinor,
      paidAt: paidAt,
      createdAt: paidAt,
    );

    final markBillAsPaid =
        bill.amountMinor != null &&
        totalPaidMinor + amountMinor >= bill.amountMinor!;

    await _writer.write(
      bill: bill,
      billPayment: billPayment,
      markBillAsPaid: markBillAsPaid,
    );

    return billPayment;
  }
}
