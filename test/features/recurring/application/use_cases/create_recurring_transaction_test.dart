import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/recurring/application/use_cases/create_recurring_transaction.dart';
import 'package:personal_finance/features/recurring/data/repositories/recurring_transaction_repository.dart';
import 'package:personal_finance/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:personal_finance/features/recurring/domain/validators/recurring_transaction_validator.dart';

void main() {
  late FakeRecurringTransactionRepository repository;
  late FakeIdGenerator idGenerator;
  late CreateRecurringTransaction useCase;

  setUp(() {
    repository = FakeRecurringTransactionRepository();
    idGenerator = FakeIdGenerator();

    useCase = CreateRecurringTransaction(
      repository,
      const RecurringTransactionValidator(),
      idGenerator,
    );
  });

  test('creates recurring transaction with normalized values', () async {
    final result = await useCase.execute(
      transactionType: TransactionType.expense,
      amountMinor: 250_000,
      currencyCode: ' idr ',
      accountId: ' account-cash ',
      categoryId: ' category-food ',
      merchantId: ' merchant-1 ',
      notes: '  Monthly groceries  ',
      frequency: RecurringFrequency.monthly,
      interval: 1,
      startDate: 1_000,
      endDate: null,
      nextOccurrenceDate: 2_000,
    );

    expect(result.id, 'recurring-1');
    expect(result.transactionType, TransactionType.expense);
    expect(result.amountMinor, 250_000);
    expect(result.currencyCode, 'IDR');
    expect(result.accountId, 'account-cash');
    expect(result.categoryId, 'category-food');
    expect(result.merchantId, 'merchant-1');
    expect(result.notes, 'Monthly groceries');
    expect(result.frequency, RecurringFrequency.monthly);
    expect(result.interval, 1);
    expect(result.startDate, 1_000);
    expect(result.nextOccurrenceDate, 2_000);
    expect(result.isActive, isTrue);
    expect(result.createdAt, greaterThan(0));
    expect(result.updatedAt, result.createdAt);

    expect(repository.created, hasLength(1));
    expect(repository.created.single.id, 'recurring-1');
  });

  test('rejects invalid amount before creating', () async {
    expect(
      () => useCase.execute(
        transactionType: TransactionType.expense,
        amountMinor: 0,
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
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(repository.created, isEmpty);
  });

  test('creates income recurring transaction without category', () async {
    final result = await useCase.execute(
      transactionType: TransactionType.income,
      amountMinor: 10_000_000,
      currencyCode: 'IDR',
      accountId: 'account-bank',
      categoryId: null,
      merchantId: null,
      notes: null,
      frequency: RecurringFrequency.monthly,
      interval: 1,
      startDate: 1_000,
      endDate: null,
      nextOccurrenceDate: 2_000,
    );

    expect(result.transactionType, TransactionType.income);
    expect(result.categoryId, isNull);
    expect(result.isActive, isTrue);
    expect(repository.created, hasLength(1));
  });
}

class FakeIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() {
    _counter++;
    return 'recurring-$_counter';
  }
}

class FakeRecurringTransactionRepository
    implements RecurringTransactionRepository {
  final List<RecurringTransaction> created = [];

  @override
  Future<RecurringTransaction?> getById(String id) async {
    return null;
  }

  @override
  Future<List<RecurringTransaction>> getAllActive() async {
    return List.unmodifiable(created);
  }

  @override
  Future<RecurringTransaction> create({
    required RecurringTransaction recurringTransaction,
  }) async {
    created.add(recurringTransaction);
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
