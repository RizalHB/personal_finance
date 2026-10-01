import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/entities/bill.dart';
import '../../domain/entities/bill_payment.dart';
import '../../../transactions/data/writers/drift_transaction_writer.dart';
import 'bill_payment_writer.dart';

class DriftBillPaymentWriter implements BillPaymentWriter {
  const DriftBillPaymentWriter(this._database);

  final db.AppDatabase _database;

  @override
  Future<void> write({
    required Bill bill,
    required BillPayment billPayment,
    required bool markBillAsPaid,
  }) async {
    await _database.transaction(() async {
      await DriftTransactionWriter(_database).write(
        id: billPayment.transactionId,
        type: TransactionType.expense,
        amountMinor: billPayment.amountMinor,
        transactionDate: billPayment.paidAt,
        currencyCode: bill.currencyCode,
        accountId: bill.accountId!,
        categoryId: bill.categoryId!,
        merchantId: bill.merchantId,
        notes: bill.notes,
        recurringTransactionId: null,
        createdAt: billPayment.createdAt,
      );

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

      if (markBillAsPaid) {
        await (_database.update(
          _database.bills,
        )..where((row) => row.id.equals(bill.id))).write(
          db.BillsCompanion(
            status: Value(BillStatus.paid.code),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
      }
    });
  }
}
