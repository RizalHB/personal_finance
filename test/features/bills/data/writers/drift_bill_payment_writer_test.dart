import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/bills/data/writers/drift_bill_payment_writer.dart';
import 'package:personal_finance/features/bills/domain/entities/bill.dart';
import 'package:personal_finance/features/bills/domain/entities/bill_payment.dart';

void main() {
  late db.AppDatabase database;
  late DriftBillPaymentWriter writer;

  setUp(() async {
    database = db.AppDatabase.test();
    writer = DriftBillPaymentWriter(database);

    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: 'ledger-cash',
            kind: 1,
            code: 'cash',
            name: 'Cash',
            isSystem: false,
            status: 1,
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );

    await database
        .into(database.ledgerAccounts)
        .insert(
          db.LedgerAccountsCompanion.insert(
            id: 'ledger-food',
            kind: 4,
            code: 'food',
            name: 'Food',
            isSystem: false,
            status: 1,
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
  });

  tearDown(() async {
    await database.close();
  });

  Bill createBill({BillStatus status = BillStatus.active}) {
    return Bill(
      id: 'bill-1',
      name: 'Monthly Food Bill',
      amountMinor: 500_000,
      currencyCode: 'IDR',
      dueDate: 2_000,
      status: status,
      accountId: 'account-cash',
      categoryId: 'category-food',
      merchantId: null,
      notes: 'Food bill',
      createdAt: 1_000,
      updatedAt: 1_000,
      cancelledAt: null,
    );
  }

  BillPayment createPayment({
    String id = 'payment-1',
    String transactionId = 'transaction-1',
    int amountMinor = 500_000,
  }) {
    return BillPayment(
      id: id,
      billId: 'bill-1',
      transactionId: transactionId,
      amountMinor: amountMinor,
      paidAt: 3_000,
      createdAt: 3_000,
    );
  }

  test('creates transaction and bill payment atomically', () async {
    await database
        .into(database.bills)
        .insert(
          db.BillsCompanion.insert(
            id: 'bill-1',
            name: 'Monthly Food Bill',
            amountMinor: const Value<int?>(500_000),
            currencyCode: 'IDR',
            dueDate: 2_000,
            status: BillStatus.active.code,
            accountId: const Value('account-cash'),
            categoryId: const Value('category-food'),
            merchantId: const Value(null),
            notes: const Value('Food bill'),
            createdAt: 1_000,
            updatedAt: 1_000,
            cancelledAt: const Value(null),
          ),
        );

    final billPayment = createPayment();

    await writer.write(
      bill: createBill(),
      billPayment: billPayment,
      markBillAsPaid: true,
    );

    final transaction = await (database.select(
      database.transactions,
    )..where((row) => row.id.equals('transaction-1'))).getSingleOrNull();

    expect(transaction, isNotNull);
    expect(transaction!.transactionType, TransactionType.expense.code);
    expect(transaction.amountMinor, 500_000);
    expect(transaction.accountId, 'account-cash');
    expect(transaction.categoryId, 'category-food');

    final persistedPayment = await (database.select(
      database.billPayments,
    )..where((row) => row.id.equals('payment-1'))).getSingleOrNull();

    expect(persistedPayment, isNotNull);
    expect(persistedPayment!.billId, 'bill-1');
    expect(persistedPayment.transactionId, 'transaction-1');
    expect(persistedPayment.amountMinor, 500_000);

    final persistedBill = await (database.select(
      database.bills,
    )..where((row) => row.id.equals('bill-1'))).getSingle();

    expect(persistedBill.status, BillStatus.paid.code);
  });

  test('rolls back transaction when bill payment insert fails', () async {
    await database
        .into(database.bills)
        .insert(
          db.BillsCompanion.insert(
            id: 'bill-1',
            name: 'Monthly Food Bill',
            amountMinor: const Value<int?>(500_000),
            currencyCode: 'IDR',
            dueDate: 2_000,
            status: BillStatus.active.code,
            accountId: const Value('account-cash'),
            categoryId: const Value('category-food'),
            merchantId: const Value(null),
            notes: const Value('Food bill'),
            createdAt: 1_000,
            updatedAt: 1_000,
            cancelledAt: const Value(null),
          ),
        );

    await database
        .into(database.billPayments)
        .insert(
          db.BillPaymentsCompanion.insert(
            id: 'payment-1',
            billId: 'bill-1',
            transactionId: 'existing-transaction',
            amountMinor: 100_000,
            paidAt: 2_500,
            createdAt: 2_500,
          ),
        );

    final billPayment = createPayment(
      id: 'payment-1',
      transactionId: 'transaction-1',
      amountMinor: 400_000,
    );

    expect(
      () => writer.write(
        bill: createBill(),
        billPayment: billPayment,
        markBillAsPaid: true,
      ),
      throwsA(isA<Exception>()),
    );

    final generatedTransaction = await (database.select(
      database.transactions,
    )..where((row) => row.id.equals('transaction-1'))).getSingleOrNull();

    expect(generatedTransaction, isNull);

    final persistedBill = await (database.select(
      database.bills,
    )..where((row) => row.id.equals('bill-1'))).getSingle();

    expect(persistedBill.status, BillStatus.active.code);
  });
}
