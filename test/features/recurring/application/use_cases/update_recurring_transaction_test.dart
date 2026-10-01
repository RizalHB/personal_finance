import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/recurring/application/use_cases/update_recurring_transaction.dart';
import 'package:personal_finance/features/recurring/data/repositories/recurring_transaction_repository.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/features/recurring/domain/validators/recurring_transaction_validator.dart';

void main() {
  late FakeRecurringTransactionRepository repository;
  late UpdateRecurringTransaction useCase;

  setUp(() {
    repository = FakeRecurringTransactionRepository();

    useCase = UpdateRecurringTransaction(
      repository,
      const RecurringTransactionValidator(),
    );
  });

  test('updates recurring transaction while preserving identity', () async {
    repository.transactions.add(
      const RecurringTransaction(
        id: 'recurring-1',
        transactionType: TransactionType.expense,
        amountMinor: 100_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: 'Old note',
        frequency: RecurringFrequency.monthly,
        interval: 1,
        startDate: 1_000,
        endDate: null,
        nextOccurrenceDate: 2_000,
        isActive: true,
        createdAt: 1_000,
        updatedAt: 1_000,
      ),
    );

    final updated = await useCase.execute(
      id: ' recurring-1 ',
      transactionType: TransactionType.expense,
      amountMinor: 250_000,
      currencyCode: ' idr ',
      accountId: ' account-cash ',
      categoryId: ' category-transport ',
      merchantId: null,
      notes: '  Updated note  ',
      frequency: RecurringFrequency.weekly,
      interval: 2,
      startDate: 1_000,
      endDate: null,
      nextOccurrenceDate: 3_000,
      isActive: false,
    );

    expect(updated.id, 'recurring-1');
    expect(updated.amountMinor, 250_000);
    expect(updated.currencyCode, 'IDR');
    expect(updated.categoryId, 'category-transport');
    expect(updated.notes, 'Updated note');
    expect(updated.frequency, RecurringFrequency.weekly);
    expect(updated.interval, 2);
    expect(updated.nextOccurrenceDate, 3_000);
    expect(updated.isActive, isFalse);
    expect(updated.createdAt, 1_000);
    expect(updated.updatedAt, greaterThan(1_000));

    expect(repository.updated, hasLength(1));
    expect(repository.updated.single.id, 'recurring-1');
  });

  test('rejects update when recurring transaction does not exist', () async {
    expect(
      () => useCase.execute(
        id: 'missing-recurring',
        transactionType: TransactionType.expense,
        amountMinor: 100_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-food',
        merchantId: null,
        notes: null,
        frequency: RecurringFrequency.monthly,
        interval: 1,
        startDate: 1_000,
        endDate: null,
        nextOccurrenceDate: 2_000,
        isActive: true,
      ),
      throwsA(isA<StateError>()),
    );

    expect(repository.updated, isEmpty);
  });
}

class FakeRecurringTransactionRepository
    implements RecurringTransactionRepository {
  final List<RecurringTransaction> transactions = [];
  final List<RecurringTransaction> updated = [];

  @override
  Future<RecurringTransaction?> getById(String id) async {
    for (final transaction in transactions) {
      if (transaction.id == id) {
        return transaction;
      }
    }

    return null;
  }

  @override
  Future<List<RecurringTransaction>> getAllActive() async {
    return transactions.where((transaction) => transaction.isActive).toList();
  }

  @override
  Future<RecurringTransaction> create({
    required RecurringTransaction recurringTransaction,
  }) async {
    transactions.add(recurringTransaction);
    return recurringTransaction;
  }

  @override
  Future<RecurringTransaction> update({
    required RecurringTransaction recurringTransaction,
  }) async {
    final index = transactions.indexWhere(
      (existing) => existing.id == recurringTransaction.id,
    );

    if (index == -1) {
      throw StateError('Recurring transaction not found.');
    }

    transactions[index] = recurringTransaction;
    updated.add(recurringTransaction);
    return recurringTransaction;
  }

  @override
  Future<void> delete(String id) async {
    transactions.removeWhere((transaction) => transaction.id == id);
  }
}
