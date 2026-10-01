import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/presentation/providers/account_providers.dart';
import '../data/repositories/bill_payment_repository.dart';
import '../data/repositories/bill_repository.dart';
import '../data/repositories/drift_bill_payment_repository.dart';
import '../data/repositories/drift_bill_repository.dart';
import 'use_cases/create_bill.dart';
import 'use_cases/delete_bill.dart';
import 'use_cases/get_bills.dart';
import 'use_cases/update_bill.dart';
import '../data/writers/bill_payment_writer.dart';
import '../data/writers/drift_bill_payment_writer.dart';
import 'use_cases/record_bill_payment.dart';
import 'use_cases/get_bill_payments.dart';
import 'use_cases/get_bill.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftBillRepository(database);
});

final createBillProvider = Provider<CreateBill>((ref) {
  return CreateBill(
    ref.watch(billRepositoryProvider),
    ref.watch(idGeneratorProvider),
  );
});

final getBillsProvider = Provider<GetBills>((ref) {
  return GetBills(ref.watch(billRepositoryProvider));
});

final updateBillProvider = Provider<UpdateBill>((ref) {
  return UpdateBill(ref.watch(billRepositoryProvider));
});

final deleteBillProvider = Provider<DeleteBill>((ref) {
  return DeleteBill(ref.watch(billRepositoryProvider));
});

final billPaymentRepositoryProvider = Provider<BillPaymentRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftBillPaymentRepository(database);
});

final billPaymentWriterProvider = Provider<BillPaymentWriter>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return DriftBillPaymentWriter(database);
});

final recordBillPaymentProvider = Provider<RecordBillPayment>((ref) {
  return RecordBillPayment(
    ref.watch(billRepositoryProvider),
    ref.watch(billPaymentRepositoryProvider),
    ref.watch(billPaymentWriterProvider),
    ref.watch(idGeneratorProvider),
  );
});
final getBillPaymentsProvider = Provider<GetBillPayments>((ref) {
  return GetBillPayments(ref.watch(billPaymentRepositoryProvider));
});
final getBillProvider = Provider<GetBill>((ref) {
  return GetBill(ref.watch(billRepositoryProvider));
});
