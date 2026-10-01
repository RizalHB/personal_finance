import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/recurring/application/services/execute_due_recurring_transactions.dart';
import 'package:personal_finance/features/recurring/application/services/run_due_recurring_transactions.dart';
import 'package:personal_finance/features/recurring/data/repositories/drift_recurring_transaction_repository.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/features/recurring/domain/services/recurring_occurrence_calculator.dart';
import 'package:personal_finance/features/transactions/data/writers/drift_transaction_writer.dart';

void main() {
  late db.AppDatabase database;
  late DriftRecurringTransactionRepository recurringRepository;
  late RunDueRecurringTransactions runner;

  setUp(() async {
    database = db.AppDatabase.test();

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

    recurringRepository = DriftRecurringTransactionRepository(database);

    final executor = ExecuteDueRecurringTransactions(
      database: database,
      recurringTransactionRepository: recurringRepository,
      transactionWriter: DriftTransactionWriter(database),
      occurrenceCalculator: const RecurringOccurrenceCalculator(),
      idGenerator: FakeIdGenerator(),
    );

    runner = RunDueRecurringTransactions(executor);
  });

  tearDown(() async {
    await database.close();
  });

  test('generates due transactions and advances the schedule', () async {
    final september1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;

    final november1 = DateTime(2026, 11, 1).millisecondsSinceEpoch;

    await recurringRepository.create(
      recurringTransaction: RecurringTransaction(
        id: 'recurring-food',
        transactionType: TransactionType.expense,
        amountMinor: 250_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Monthly food expense',
        frequency: RecurringFrequency.monthly,
        interval: 1,
        startDate: september1,
        endDate: null,
        nextOccurrenceDate: september1,
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final generatedCount = await runner.execute(executionDate: november1);

    expect(generatedCount, 3);

    final transactions = await database.select(database.transactions).get();

    expect(transactions, hasLength(3));
    expect(transactions.map((transaction) => transaction.transactionDate), [
      DateTime(2026, 9, 1).millisecondsSinceEpoch,
      DateTime(2026, 10, 1).millisecondsSinceEpoch,
      DateTime(2026, 11, 1).millisecondsSinceEpoch,
    ]);

    for (final transaction in transactions) {
      expect(transaction.transactionType, TransactionType.expense.code);
      expect(transaction.status, 1);
      expect(transaction.amountMinor, 250_000);
      expect(transaction.accountId, 'account-cash');
      expect(transaction.categoryId, 'category-food');
      expect(transaction.recurringTransactionId, 'recurring-food');
    }

    final ledgerEntries = await database.select(database.ledgerEntries).get();

    expect(ledgerEntries, hasLength(6));

    final occurrences = await database
        .select(database.recurringTransactionOccurrences)
        .get();

    expect(occurrences, hasLength(3));
    expect(occurrences.map((occurrence) => occurrence.occurrenceDate), [
      DateTime(2026, 9, 1).millisecondsSinceEpoch,
      DateTime(2026, 10, 1).millisecondsSinceEpoch,
      DateTime(2026, 11, 1).millisecondsSinceEpoch,
    ]);

    final persisted = await recurringRepository.getById('recurring-food');

    expect(persisted, isNotNull);
    expect(
      persisted!.nextOccurrenceDate,
      DateTime(2026, 12, 1).millisecondsSinceEpoch,
    );
  });

  test('does not duplicate already generated occurrences', () async {
    final september1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;

    final october1 = DateTime(2026, 10, 1).millisecondsSinceEpoch;

    await recurringRepository.create(
      recurringTransaction: RecurringTransaction(
        id: 'recurring-food',
        transactionType: TransactionType.expense,
        amountMinor: 100_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: null,
        frequency: RecurringFrequency.monthly,
        interval: 1,
        startDate: september1,
        endDate: null,
        nextOccurrenceDate: september1,
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final firstRun = await runner.execute(executionDate: october1);

    final secondRun = await runner.execute(executionDate: october1);

    expect(firstRun, 2);
    expect(secondRun, 0);

    final transactions = await database.select(database.transactions).get();

    expect(transactions, hasLength(2));

    final occurrences = await database
        .select(database.recurringTransactionOccurrences)
        .get();

    expect(occurrences, hasLength(2));
  });
}

class FakeIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() {
    _counter++;
    return 'generated-transaction-$_counter';
  }
}
