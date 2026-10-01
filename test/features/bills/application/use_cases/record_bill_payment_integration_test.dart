import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/bills/application/use_cases/record_bill_payment.dart';
import 'package:personal_finance/features/bills/data/repositories/drift_bill_payment_repository.dart';
import 'package:personal_finance/features/bills/data/repositories/drift_bill_repository.dart';
import 'package:personal_finance/features/bills/data/writers/drift_bill_payment_writer.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';

void main() {
  late db.AppDatabase database;
  late DriftBillRepository billRepository;
  late DriftBillPaymentRepository billPaymentRepository;
  late RecordBillPayment useCase;

  setUp(() async {
    database = db.AppDatabase.test();

    billRepository = DriftBillRepository(database);
    billPaymentRepository = DriftBillPaymentRepository(database);

    await _insertLedgerAccount(
      database,
      id: 'ledger-food',
      kind: 4,
      code: 'food',
      name: 'Food',
    );

    await _insertLedgerAccount(
      database,
      id: 'ledger-cash',
      kind: 1,
      code: 'cash',
      name: 'Cash',
    );

    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: 'category-food',
            ledgerAccountId: 'ledger-food',
            name: 'Food',
            categoryType: 2,
            status: 1,
            sortOrder: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.accounts)
        .insert(
          db.AccountsCompanion.insert(
            id: 'account-cash',
            ledgerAccountId: 'ledger-cash',
            name: 'Cash',
            financialClass: 1,
            accountType: 1,
            currencyCode: 'IDR',
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    useCase = RecordBillPayment(
      billRepository,
      billPaymentRepository,
      DriftBillPaymentWriter(database),
      FakeIdGenerator(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('records payment through the real repository and writer path', () async {
    await billRepository.create(
      bill: const Bill(
        id: 'bill-1',
        name: 'Food Bill',
        amountMinor: 500_000,
        currencyCode: 'IDR',
        dueDate: 2_000,
        status: BillStatus.active,
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Monthly food bill',
        createdAt: 1_000,
        updatedAt: 1_000,
        cancelledAt: null,
      ),
    );

    final paidAt = DateTime(2026, 9, 15).millisecondsSinceEpoch;

    final payment = await useCase.execute(
      billId: ' bill-1 ',
      amountMinor: 500_000,
      paidAt: paidAt,
    );

    expect(payment.id, 'payment-1');
    expect(payment.billId, 'bill-1');
    expect(payment.transactionId, 'transaction-1');
    expect(payment.amountMinor, 500_000);
    expect(payment.paidAt, paidAt);

    final persistedPayment = await billPaymentRepository.getById('payment-1');

    expect(persistedPayment, isNotNull);
    expect(persistedPayment!.transactionId, 'transaction-1');

    final transactions = await database.select(database.transactions).get();

    expect(transactions, hasLength(1));

    final transaction = transactions.single;

    expect(transaction.id, 'transaction-1');
    expect(transaction.transactionType, TransactionType.expense.code);
    expect(transaction.amountMinor, 500_000);
    expect(transaction.currencyCode, 'IDR');
    expect(transaction.accountId, 'account-cash');
    expect(transaction.categoryId, 'category-food');
    expect(transaction.recurringTransactionId, isNull);

    final persistedBill = await billRepository.getById('bill-1');

    expect(persistedBill, isNotNull);
    expect(persistedBill!.status, BillStatus.paid);
  });
}

Future<void> _insertLedgerAccount(
  db.AppDatabase database, {
  required String id,
  required int kind,
  required String code,
  required String name,
}) async {
  await database
      .into(database.ledgerAccounts)
      .insert(
        db.LedgerAccountsCompanion.insert(
          id: id,
          kind: kind,
          code: code,
          name: name,
          isSystem: false,
          status: 1,
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );
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
