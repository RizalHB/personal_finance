import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/features/bills/data/repositories/drift_bill_payment_repository.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';
import 'package:personal_finance/features/bills/domain/entities/bill_payment.dart';

void main() {
  late db.AppDatabase database;
  late DriftBillPaymentRepository repository;

  setUp(() async {
    database = db.AppDatabase.test();
    repository = DriftBillPaymentRepository(database);

    await database
        .into(database.bills)
        .insert(
          db.BillsCompanion.insert(
            id: 'bill-1',
            name: 'Internet',
            amountMinor: const Value<int?>(500_000),
            currencyCode: 'IDR',
            dueDate: 2_000,
            status: BillStatus.active.code,
            accountId: const Value(null),
            categoryId: const Value(null),
            merchantId: const Value(null),
            notes: const Value(null),
            createdAt: 1_000,
            updatedAt: 1_000,
            cancelledAt: const Value(null),
          ),
        );

    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: 'transaction-1',
            transactionType: 2,
            status: 1,
            transactionDate: 2_000,
            currencyCode: 'IDR',
            amountMinor: 500_000,
            accountId: const Value(null),
            categoryId: const Value(null),
            merchantId: const Value(null),
            notes: const Value(null),
            relatedTransactionId: const Value(null),
            recurringTransactionId: const Value(null),
            createdAt: 1_000,
            updatedAt: 1_000,
            voidedAt: const Value(null),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and reads a bill payment', () async {
    const payment = BillPayment(
      id: 'payment-1',
      billId: 'bill-1',
      transactionId: 'transaction-1',
      amountMinor: 500_000,
      paidAt: 2_000,
      createdAt: 2_000,
    );

    final created = await repository.create(billPayment: payment);

    expect(created.id, 'payment-1');

    final result = await repository.getById(' payment-1 ');

    expect(result, isNotNull);
    expect(result!.id, 'payment-1');
    expect(result.billId, 'bill-1');
    expect(result.transactionId, 'transaction-1');
    expect(result.amountMinor, 500_000);
    expect(result.paidAt, 2_000);
    expect(result.createdAt, 2_000);
  });

  test('returns payments for a bill ordered by paid date', () async {
    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: 'transaction-2',
            transactionType: 2,
            status: 1,
            transactionDate: 3_000,
            currencyCode: 'IDR',
            amountMinor: 100_000,
            accountId: const Value(null),
            categoryId: const Value(null),
            merchantId: const Value(null),
            notes: const Value(null),
            relatedTransactionId: const Value(null),
            recurringTransactionId: const Value(null),
            createdAt: 1_000,
            updatedAt: 1_000,
            voidedAt: const Value(null),
          ),
        );

    await repository.create(
      billPayment: const BillPayment(
        id: 'payment-later',
        billId: 'bill-1',
        transactionId: 'transaction-2',
        amountMinor: 100_000,
        paidAt: 3_000,
        createdAt: 3_000,
      ),
    );

    await repository.create(
      billPayment: const BillPayment(
        id: 'payment-sooner',
        billId: 'bill-1',
        transactionId: 'transaction-1',
        amountMinor: 200_000,
        paidAt: 2_000,
        createdAt: 2_000,
      ),
    );

    final result = await repository.getByBillId(' bill-1 ');

    expect(result, hasLength(2));
    expect(result.map((payment) => payment.id), [
      'payment-sooner',
      'payment-later',
    ]);
  });

  test('does not return payments belonging to another bill', () async {
    await database
        .into(database.bills)
        .insert(
          db.BillsCompanion.insert(
            id: 'bill-2',
            name: 'Water',
            amountMinor: const Value<int?>(250_000),
            currencyCode: 'IDR',
            dueDate: 3_000,
            status: BillStatus.active.code,
            accountId: const Value(null),
            categoryId: const Value(null),
            merchantId: const Value(null),
            notes: const Value(null),
            createdAt: 1_000,
            updatedAt: 1_000,
            cancelledAt: const Value(null),
          ),
        );

    await repository.create(
      billPayment: const BillPayment(
        id: 'payment-bill-1',
        billId: 'bill-1',
        transactionId: 'transaction-1',
        amountMinor: 500_000,
        paidAt: 2_000,
        createdAt: 2_000,
      ),
    );

    final result = await repository.getByBillId('bill-2');

    expect(result, isEmpty);
  });

  test('deletes a bill payment', () async {
    await repository.create(
      billPayment: const BillPayment(
        id: 'payment-1',
        billId: 'bill-1',
        transactionId: 'transaction-1',
        amountMinor: 500_000,
        paidAt: 2_000,
        createdAt: 2_000,
      ),
    );

    await repository.delete(' payment-1 ');

    expect(await repository.getById('payment-1'), isNull);
  });

  test('rejects empty IDs', () async {
    expect(() => repository.getById('   '), throwsA(isA<ArgumentError>()));

    expect(() => repository.delete('   '), throwsA(isA<ArgumentError>()));

    expect(() => repository.getByBillId('   '), throwsA(isA<ArgumentError>()));
  });
}
