import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;

import '../../domain/entities/bill_payment.dart';
import 'bill_payment_repository.dart';

class DriftBillPaymentRepository implements BillPaymentRepository {
  const DriftBillPaymentRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<BillPayment?> getById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Bill payment ID cannot be empty.');
    }

    final row = await (_database.select(
      _database.billPayments,
    )..where((payment) => payment.id.equals(normalizedId))).getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<List<BillPayment>> getByBillId(String billId) async {
    final normalizedBillId = billId.trim();

    if (normalizedBillId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    final rows =
        await (_database.select(_database.billPayments)
              ..where((payment) => payment.billId.equals(normalizedBillId))
              ..orderBy([
                (payment) => OrderingTerm.asc(payment.paidAt),
                (payment) => OrderingTerm.asc(payment.id),
              ]))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<BillPayment> create({required BillPayment billPayment}) async {
    await _database
        .into(_database.billPayments)
        .insert(
          db.BillPaymentsCompanion.insert(
            id: billPayment.id,
            billId: billPayment.billId,
            transactionId: billPayment.transactionId,
            amountMinor: billPayment.amountMinor,
            paidAt: billPayment.paidAt,
            createdAt: billPayment.createdAt,
          ),
        );

    return billPayment;
  }

  @override
  Future<void> delete(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Bill payment ID cannot be empty.');
    }

    await (_database.delete(
      _database.billPayments,
    )..where((payment) => payment.id.equals(normalizedId))).go();
  }
}

extension on db.BillPayment {
  BillPayment toDomain() {
    return BillPayment(
      id: id,
      billId: billId,
      transactionId: transactionId,
      amountMinor: amountMinor,
      paidAt: paidAt,
      createdAt: createdAt,
    );
  }
}
