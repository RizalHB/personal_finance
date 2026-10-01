import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/bills/application/use_cases/record_bill_payment.dart';
import 'package:personal_finance/features/bills/data/repositories/bill_payment_repository.dart';
import 'package:personal_finance/features/bills/data/repositories/bill_repository.dart';
import 'package:personal_finance/features/bills/data/writers/bill_payment_writer.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';
import 'package:personal_finance/features/bills/domain/entities/bill_payment.dart';

void main() {
  late FakeBillRepository billRepository;
  late FakeBillPaymentRepository paymentRepository;
  late FakeBillPaymentWriter paymentWriter;
  late FakeIdGenerator idGenerator;
  late RecordBillPayment useCase;

  setUp(() {
    billRepository = FakeBillRepository();
    paymentRepository = FakeBillPaymentRepository();
    paymentWriter = FakeBillPaymentWriter();
    idGenerator = FakeIdGenerator();

    useCase = RecordBillPayment(
      billRepository,
      paymentRepository,
      paymentWriter,
      idGenerator,
    );
  });

  test(
    'creates a payment for an active bill within the remaining amount',
    () async {
      billRepository.bills.add(
        const Bill(
          id: 'bill-1',
          name: 'Internet',
          amountMinor: 500_000,
          currencyCode: 'IDR',
          dueDate: 2_000,
          status: BillStatus.active,
          accountId: 'account-cash',
          categoryId: 'category-bills',
          merchantId: null,
          notes: null,
          createdAt: 1_000,
          updatedAt: 1_000,
          cancelledAt: null,
        ),
      );

      paymentRepository.payments.add(
        const BillPayment(
          id: 'payment-existing',
          billId: 'bill-1',
          transactionId: 'transaction-existing',
          amountMinor: 100_000,
          paidAt: 1_500,
          createdAt: 1_500,
        ),
      );

      final payment = await useCase.execute(
        billId: ' bill-1 ',
        amountMinor: 200_000,
        paidAt: 3_000,
      );

      expect(payment.id, 'payment-1');
      expect(payment.billId, 'bill-1');
      expect(payment.transactionId, 'transaction-1');
      expect(payment.amountMinor, 200_000);
      expect(payment.paidAt, 3_000);

      expect(paymentWriter.calls, hasLength(1));
      expect(paymentWriter.calls.single.markBillAsPaid, isFalse);
    },
  );

  test('rejects payment that exceeds the remaining bill amount', () async {
    billRepository.bills.add(
      const Bill(
        id: 'bill-1',
        name: 'Internet',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: 'account-cash',
        categoryId: 'category-bills',
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    );

    paymentRepository.payments.add(
      const BillPayment(
        id: 'payment-existing',
        billId: 'bill-1',
        transactionId: 'transaction-existing',
        amountMinor: 400_000,
        paidAt: 1_500,
        createdAt: 1_500,
      ),
    );

    expect(
      () => useCase.execute(
        billId: 'bill-1',
        amountMinor: 200_000,
        paidAt: 3_000,
      ),
      throwsA(isA<StateError>()),
    );

    expect(paymentWriter.calls, isEmpty);
  });

  test('rejects payment for a cancelled bill', () async {
    billRepository.bills.add(
      const Bill(
        id: 'bill-1',
        name: 'Internet',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.cancelled,
        accountId: 'account-cash',
        categoryId: 'category-bills',
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: 2_500,
      ),
    );

    expect(
      () => useCase.execute(
        billId: 'bill-1',
        amountMinor: 100_000,
        paidAt: 3_000,
      ),
      throwsA(isA<StateError>()),
    );

    expect(paymentWriter.calls, isEmpty);
  });

  test('rejects payment when bill category is missing', () async {
    billRepository.bills.add(
      const Bill(
        id: 'bill-1',
        name: 'Internet',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: 'account-cash',
        categoryId: null,
        merchantId: null,
        notes: null,
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    );

    expect(
      () => useCase.execute(
        billId: 'bill-1',
        amountMinor: 100_000,
        paidAt: 3_000,
      ),
      throwsA(isA<StateError>()),
    );

    expect(paymentWriter.calls, isEmpty);
  });
}

class FakeIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() {
    _counter++;

    return _counter.isOdd
        ? 'payment-${(_counter + 1) ~/ 2}'
        : 'transaction-${_counter ~/ 2}';
  }
}

class FakeBillRepository implements BillRepository {
  final List<Bill> bills = [];

  @override
  Future<Bill?> getById(String id) async {
    for (final bill in bills) {
      if (bill.id == id) {
        return bill;
      }
    }

    return null;
  }

  @override
  Future<List<Bill>> getAll() async {
    return List.unmodifiable(bills);
  }

  @override
  Future<Bill> create({required Bill bill}) async {
    bills.add(bill);
    return bill;
  }

  @override
  Future<Bill> update({required Bill bill}) async {
    final index = bills.indexWhere((existing) => existing.id == bill.id);

    if (index == -1) {
      throw StateError('Bill not found.');
    }

    bills[index] = bill;
    return bill;
  }

  @override
  Future<void> delete(String id) async {
    bills.removeWhere((bill) => bill.id == id);
  }
}

class FakeBillPaymentRepository implements BillPaymentRepository {
  final List<BillPayment> payments = [];

  @override
  Future<BillPayment?> getById(String id) async {
    for (final payment in payments) {
      if (payment.id == id) {
        return payment;
      }
    }

    return null;
  }

  @override
  Future<List<BillPayment>> getByBillId(String billId) async {
    return payments.where((payment) => payment.billId == billId).toList();
  }

  @override
  Future<BillPayment> create({required BillPayment billPayment}) async {
    payments.add(billPayment);
    return billPayment;
  }

  @override
  Future<void> delete(String id) async {
    payments.removeWhere((payment) => payment.id == id);
  }
}

class FakeBillPaymentWriter implements BillPaymentWriter {
  final List<BillPaymentWriteCall> calls = [];

  @override
  Future<void> write({
    required Bill bill,
    required BillPayment billPayment,
    required bool markBillAsPaid,
  }) async {
    calls.add(
      BillPaymentWriteCall(
        bill: bill,
        billPayment: billPayment,
        markBillAsPaid: markBillAsPaid,
      ),
    );
  }
}

class BillPaymentWriteCall {
  BillPaymentWriteCall({
    required this.bill,
    required this.billPayment,
    required this.markBillAsPaid,
  });

  final Bill bill;
  final BillPayment billPayment;
  final bool markBillAsPaid;
}
