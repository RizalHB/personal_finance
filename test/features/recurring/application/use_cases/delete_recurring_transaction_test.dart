import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/recurring/application/use_cases/delete_recurring_transaction.dart';
import 'package:personal_finance/features/recurring/data/repositories/recurring_transaction_repository.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';

void main() {
  late FakeRecurringTransactionRepository repository;
  late DeleteRecurringTransaction useCase;

  setUp(() {
    repository = FakeRecurringTransactionRepository();
    useCase = DeleteRecurringTransaction(repository);
  });

  test('deletes an existing recurring transaction', () async {
    repository.transactions.add(
      const RecurringTransaction(
        id: 'recurring-1',
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
        createdAt: 1_000,
        updatedAt: 1_000,
      ),
    );

    await useCase.execute(' recurring-1 ');

    expect(repository.transactions, isEmpty);
    expect(repository.deleted, ['recurring-1']);
  });

  test('rejects deletion when recurring transaction does not exist', () async {
    expect(
      () => useCase.execute('missing-recurring'),
      throwsA(isA<StateError>()),
    );

    expect(repository.deleted, isEmpty);
  });
}

class FakeRecurringTransactionRepository
    implements RecurringTransactionRepository {
  final List<RecurringTransaction> transactions = [];
  final List<String> deleted = [];

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
    return recurringTransaction;
  }

  @override
  Future<void> delete(String id) async {
    deleted.add(id);

    transactions.removeWhere((transaction) => transaction.id == id);
  }
}
