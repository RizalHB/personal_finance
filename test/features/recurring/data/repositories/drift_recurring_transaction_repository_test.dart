import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/recurring/data/repositories/drift_recurring_transaction_repository.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';

void main() {
  late db.AppDatabase database;
  late DriftRecurringTransactionRepository repository;

  setUp(() async {
    database = db.AppDatabase.test();
    repository = DriftRecurringTransactionRepository(database);

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
  });

  tearDown(() async {
    await database.close();
  });

  RecurringTransaction createRecurring({
    required String id,
    required int nextOccurrenceDate,
    bool isActive = true,
    int amountMinor = 100_000,
  }) {
    return RecurringTransaction(
      id: id,
      transactionType: TransactionType.expense,
      amountMinor: amountMinor,
      currencyCode: 'IDR',
      accountId: 'account-cash',
      categoryId: null,
      merchantId: null,
      notes: 'Monthly expense',
      frequency: RecurringFrequency.monthly,
      interval: 1,
      startDate: 1000,
      endDate: null,
      nextOccurrenceDate: nextOccurrenceDate,
      isActive: isActive,
      createdAt: 1000,
      updatedAt: 1000,
    );
  }

  test('creates and reads a recurring transaction', () async {
    final recurring = createRecurring(
      id: 'recurring-1',
      nextOccurrenceDate: 2_000,
    );

    final created = await repository.create(recurringTransaction: recurring);

    expect(created.id, 'recurring-1');

    final result = await repository.getById(' recurring-1 ');

    expect(result, isNotNull);
    expect(result!.id, 'recurring-1');
    expect(result.transactionType, TransactionType.expense);
    expect(result.amountMinor, 100_000);
    expect(result.currencyCode, 'IDR');
    expect(result.accountId, 'account-cash');
    expect(result.frequency, RecurringFrequency.monthly);
    expect(result.interval, 1);
    expect(result.nextOccurrenceDate, 2_000);
    expect(result.isActive, isTrue);
  });

  test(
    'returns only active recurring transactions ordered by next occurrence',
    () async {
      await repository.create(
        recurringTransaction: createRecurring(
          id: 'recurring-later',
          nextOccurrenceDate: 3_000,
        ),
      );

      await repository.create(
        recurringTransaction: createRecurring(
          id: 'recurring-sooner',
          nextOccurrenceDate: 2_000,
        ),
      );

      await repository.create(
        recurringTransaction: createRecurring(
          id: 'recurring-inactive',
          nextOccurrenceDate: 1_000,
          isActive: false,
        ),
      );

      final result = await repository.getAllActive();

      expect(result, hasLength(2));
      expect(result.map((item) => item.id), [
        'recurring-sooner',
        'recurring-later',
      ]);
    },
  );

  test('updates a recurring transaction', () async {
    final recurring = createRecurring(
      id: 'recurring-1',
      nextOccurrenceDate: 2_000,
    );

    await repository.create(recurringTransaction: recurring);

    final updated = RecurringTransaction(
      id: recurring.id,
      transactionType: recurring.transactionType,
      amountMinor: 250_000,
      currencyCode: recurring.currencyCode,
      accountId: recurring.accountId,
      categoryId: recurring.categoryId,
      merchantId: recurring.merchantId,
      notes: recurring.notes,
      frequency: recurring.frequency,
      interval: recurring.interval,
      startDate: recurring.startDate,
      endDate: recurring.endDate,
      nextOccurrenceDate: 4_000,
      isActive: false,
      createdAt: recurring.createdAt,
      updatedAt: 3_000,
    );

    final result = await repository.update(recurringTransaction: updated);

    expect(result.amountMinor, 250_000);
    expect(result.nextOccurrenceDate, 4_000);
    expect(result.isActive, isFalse);
    expect(result.updatedAt, 3_000);

    final persisted = await repository.getById('recurring-1');

    expect(persisted, isNotNull);
    expect(persisted!.amountMinor, 250_000);
    expect(persisted.nextOccurrenceDate, 4_000);
    expect(persisted.isActive, isFalse);
  });

  test('deletes a recurring transaction', () async {
    await repository.create(
      recurringTransaction: createRecurring(
        id: 'recurring-1',
        nextOccurrenceDate: 2_000,
      ),
    );

    await repository.delete(' recurring-1 ');

    expect(await repository.getById('recurring-1'), isNull);
  });

  test('rejects empty ID when reading or deleting', () async {
    expect(() => repository.getById('   '), throwsA(isA<ArgumentError>()));

    expect(() => repository.delete('   '), throwsA(isA<ArgumentError>()));
  });
}
