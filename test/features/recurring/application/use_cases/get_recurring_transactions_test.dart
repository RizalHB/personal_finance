import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/recurring/application/use_cases/get_recurring_transactions.dart';
import 'package:personal_finance/features/recurring/data/repositories/recurring_transaction_repository.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';

void main() {
  late FakeRecurringTransactionRepository repository;
  late GetRecurringTransactions useCase;

  setUp(() {
    repository = FakeRecurringTransactionRepository();
    useCase = GetRecurringTransactions(repository);
  });

  test('returns active recurring transactions from the repository', () async {
    repository.transactions.addAll([
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
      const RecurringTransaction(
        id: 'recurring-2',
        transactionType: TransactionType.expense,
        amountMinor: 200_000,
        currencyCode: 'IDR',
        accountId: 'account-cash',
        categoryId: 'category-transport',
        merchantId: null,
        notes: null,
        frequency: RecurringFrequency.weekly,
        interval: 1,
        startDate: 1_000,
        endDate: null,
        nextOccurrenceDate: 3_000,
        isActive: true,
        createdAt: 1_000,
        updatedAt: 1_000,
      ),
    ]);

    final result = await useCase.execute();

    expect(result, hasLength(2));
    expect(result.map((transaction) => transaction.id), [
      'recurring-1',
      'recurring-2',
    ]);
    expect(repository.getAllActiveCalled, isTrue);
  });
}

class FakeRecurringTransactionRepository
    implements RecurringTransactionRepository {
  final List<RecurringTransaction> transactions = [];
  bool getAllActiveCalled = false;

  @override
  Future<RecurringTransaction?> getById(String id) async {
    return null;
  }

  @override
  Future<List<RecurringTransaction>> getAllActive() async {
    getAllActiveCalled = true;

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
    return recurringTransaction;
  }

  @override
  Future<void> delete(String id) async {}
}
