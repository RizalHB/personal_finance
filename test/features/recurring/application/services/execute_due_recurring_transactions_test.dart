import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/recurring/application/services/execute_due_recurring_transactions.dart';
import 'package:personal_finance/features/recurring/data/repositories/drift_recurring_transaction_repository.dart';
import 'package:personal_finance/features/transactions/data/writers/drift_transaction_writer.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/features/recurring/domain/services/recurring_occurrence_calculator.dart';

void main() {
  late db.AppDatabase database;
  late DriftRecurringTransactionRepository recurringRepository;
  late ExecuteDueRecurringTransactions useCase;

  setUp(() async {
    database = db.AppDatabase.test();

    recurringRepository = DriftRecurringTransactionRepository(database);

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

    useCase = ExecuteDueRecurringTransactions(
      database: database,
      recurringTransactionRepository: recurringRepository,
      transactionWriter: DriftTransactionWriter(database),
      occurrenceCalculator: const RecurringOccurrenceCalculator(),
      idGenerator: FakeIdGenerator(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('generates all missed occurrences up to execution date', () async {
    final occurrence1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;

    final occurrence2 = DateTime(2026, 9, 8).millisecondsSinceEpoch;

    final occurrence3 = DateTime(2026, 9, 15).millisecondsSinceEpoch;

    final executionDate = DateTime(2026, 9, 15).millisecondsSinceEpoch;

    await recurringRepository.create(
      recurringTransaction: RecurringTransaction(
        id: 'recurring-food',
        transactionType: TransactionType.expense,
        amountMinor: 100_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Weekly food budget',
        frequency: RecurringFrequency.weekly,
        interval: 1,
        startDate: occurrence1,
        endDate: null,
        nextOccurrenceDate: occurrence1,
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final generatedCount = await useCase.execute(executionDate: executionDate);

    expect(generatedCount, 3);

    final transactions = await database.select(database.transactions).get();

    expect(transactions, hasLength(3));

    expect(transactions.map((transaction) => transaction.transactionDate), [
      occurrence1,
      occurrence2,
      occurrence3,
    ]);

    expect(
      transactions.every(
        (transaction) => transaction.recurringTransactionId == 'recurring-food',
      ),
      isTrue,
    );

    expect(
      transactions.every(
        (transaction) =>
            transaction.transactionType == TransactionType.expense.code,
      ),
      isTrue,
    );

    expect(
      transactions.every((transaction) => transaction.amountMinor == 100_000),
      isTrue,
    );

    final occurrences = await database
        .select(database.recurringTransactionOccurrences)
        .get();

    expect(occurrences, hasLength(3));

    expect(occurrences.map((occurrence) => occurrence.occurrenceDate), [
      occurrence1,
      occurrence2,
      occurrence3,
    ]);

    final recurringTransaction = await recurringRepository.getById(
      'recurring-food',
    );

    expect(recurringTransaction, isNotNull);

    expect(
      recurringTransaction!.nextOccurrenceDate,
      DateTime(2026, 9, 22).millisecondsSinceEpoch,
    );
  });

  test('does not generate duplicate occurrences when executed twice', () async {
    final occurrence1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;

    final executionDate = DateTime(2026, 9, 15).millisecondsSinceEpoch;

    await recurringRepository.create(
      recurringTransaction: RecurringTransaction(
        id: 'recurring-food',
        transactionType: TransactionType.expense,
        amountMinor: 100_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Weekly food budget',
        frequency: RecurringFrequency.weekly,
        interval: 1,
        startDate: occurrence1,
        endDate: null,
        nextOccurrenceDate: occurrence1,
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final firstRunCount = await useCase.execute(executionDate: executionDate);

    final secondRunCount = await useCase.execute(executionDate: executionDate);

    expect(firstRunCount, 3);
    expect(secondRunCount, 0);

    final transactions = await database.select(database.transactions).get();

    expect(transactions, hasLength(3));

    final occurrences = await database
        .select(database.recurringTransactionOccurrences)
        .get();

    expect(occurrences, hasLength(3));

    final recurringTransaction = await recurringRepository.getById(
      'recurring-food',
    );

    expect(recurringTransaction, isNotNull);

    expect(
      recurringTransaction!.nextOccurrenceDate,
      DateTime(2026, 9, 22).millisecondsSinceEpoch,
    );
  });
  test('does not generate occurrences after the recurring end date', () async {
    final occurrence1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;

    final occurrence2 = DateTime(2026, 9, 8).millisecondsSinceEpoch;

    final endDate = DateTime(2026, 9, 10).millisecondsSinceEpoch;

    final executionDate = DateTime(2026, 9, 30).millisecondsSinceEpoch;

    await recurringRepository.create(
      recurringTransaction: RecurringTransaction(
        id: 'recurring-food',
        transactionType: TransactionType.expense,
        amountMinor: 100_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Weekly food budget',
        frequency: RecurringFrequency.weekly,
        interval: 1,
        startDate: occurrence1,
        endDate: endDate,
        nextOccurrenceDate: occurrence1,
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final generatedCount = await useCase.execute(executionDate: executionDate);

    expect(generatedCount, 2);

    final transactions = await database.select(database.transactions).get();

    expect(transactions, hasLength(2));

    expect(transactions.map((transaction) => transaction.transactionDate), [
      occurrence1,
      occurrence2,
    ]);

    final occurrences = await database
        .select(database.recurringTransactionOccurrences)
        .get();

    expect(occurrences, hasLength(2));

    final recurringTransaction = await recurringRepository.getById(
      'recurring-food',
    );

    expect(recurringTransaction, isNotNull);

    expect(
      recurringTransaction!.nextOccurrenceDate,
      DateTime(2026, 9, 15).millisecondsSinceEpoch,
    );
  });
  test(
    'rolls back the entire schedule when transaction generation fails',
    () async {
      final occurrence1 = DateTime(2026, 9, 1).millisecondsSinceEpoch;

      final executionDate = DateTime(2026, 9, 8).millisecondsSinceEpoch;

      await recurringRepository.create(
        recurringTransaction: RecurringTransaction(
          id: 'recurring-invalid',
          transactionType: TransactionType.expense,
          amountMinor: 100_000,
          currencyCode: 'IDR',
          accountId: 'account-cash',
          categoryId: 'missing-category',
          merchantId: null,
          notes: 'This should fail',
          frequency: RecurringFrequency.weekly,
          interval: 1,
          startDate: occurrence1,
          endDate: null,
          nextOccurrenceDate: occurrence1,
          isActive: true,
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );

      expect(
        () => useCase.execute(executionDate: executionDate),
        throwsA(isA<StateError>()),
      );

      final transactions = await database.select(database.transactions).get();

      expect(transactions, isEmpty);

      final occurrences = await database
          .select(database.recurringTransactionOccurrences)
          .get();

      expect(occurrences, isEmpty);

      final recurringTransaction = await recurringRepository.getById(
        'recurring-invalid',
      );

      expect(recurringTransaction, isNotNull);

      expect(recurringTransaction!.nextOccurrenceDate, occurrence1);
    },
  );
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
    return 'generated-transaction-$_counter';
  }
}
