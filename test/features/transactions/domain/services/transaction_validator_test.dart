import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/domain/entities/transaction.dart';
import 'package:personal_finance/features/transactions/domain/services/transaction_validator.dart';

void main() {
  const validator = TransactionValidator();

  group('validateCreate', () {
    test('accepts a valid expense', () {
      expect(
        () => validator.validateCreate(
          type: TransactionType.expense,
          amountMinor: 50000,
          transactionDate: 1757548800000,
          currencyCode: 'IDR',
          accountId: 'account-1',
          categoryId: 'category-1',
        ),
        returnsNormally,
      );
    });

    test('rejects zero amount', () {
      expect(
        () => validator.validateCreate(
          type: TransactionType.expense,
          amountMinor: 0,
          transactionDate: 1757548800000,
          currencyCode: 'IDR',
          accountId: 'account-1',
          categoryId: 'category-1',
        ),
        throwsArgumentError,
      );
    });

    test('rejects missing account', () {
      expect(
        () => validator.validateCreate(
          type: TransactionType.expense,
          amountMinor: 50000,
          transactionDate: 1757548800000,
          currencyCode: 'IDR',
          accountId: null,
          categoryId: 'category-1',
        ),
        throwsArgumentError,
      );
    });

    test('rejects missing category for expense', () {
      expect(
        () => validator.validateCreate(
          type: TransactionType.expense,
          amountMinor: 50000,
          transactionDate: 1757548800000,
          currencyCode: 'IDR',
          accountId: 'account-1',
          categoryId: null,
        ),
        throwsArgumentError,
      );
    });

    test('accepts uppercase-normalized currency input', () {
      expect(
        () => validator.validateCreate(
          type: TransactionType.income,
          amountMinor: 1000000,
          transactionDate: 1757548800000,
          currencyCode: ' idr ',
          accountId: 'account-1',
          categoryId: 'category-1',
        ),
        returnsNormally,
      );
    });

    test('rejects invalid currency code length', () {
      expect(
        () => validator.validateCreate(
          type: TransactionType.income,
          amountMinor: 1000000,
          transactionDate: 1757548800000,
          currencyCode: 'ID',
          accountId: 'account-1',
          categoryId: 'category-1',
        ),
        throwsArgumentError,
      );
    });

    test('rejects notes longer than 1000 characters', () {
      expect(
        () => validator.validateCreate(
          type: TransactionType.expense,
          amountMinor: 50000,
          transactionDate: 1757548800000,
          currencyCode: 'IDR',
          accountId: 'account-1',
          categoryId: 'category-1',
          notes: 'x' * 1001,
        ),
        throwsArgumentError,
      );
    });
  });

  group('validateStatus', () {
    test('accepts posted transaction without voided timestamp', () {
      expect(
        () => validator.validateStatus(
          status: TransactionStatus.posted,
          voidedAt: null,
        ),
        returnsNormally,
      );
    });

    test('rejects posted transaction with voided timestamp', () {
      expect(
        () => validator.validateStatus(
          status: TransactionStatus.posted,
          voidedAt: 1757548800000,
        ),
        throwsArgumentError,
      );
    });

    test('accepts voided transaction with timestamp', () {
      expect(
        () => validator.validateStatus(
          status: TransactionStatus.voided,
          voidedAt: 1757548800000,
        ),
        returnsNormally,
      );
    });

    test('rejects voided transaction without timestamp', () {
      expect(
        () => validator.validateStatus(
          status: TransactionStatus.voided,
          voidedAt: null,
        ),
        throwsArgumentError,
      );
    });
  });
  test('accepts a valid void request', () {
    const validator = TransactionValidator();

    expect(
      () =>
          validator.validateVoid(id: 'transaction-1', voidedAt: 1757548900000),
      returnsNormally,
    );
  });

  test('rejects an empty void transaction id', () {
    const validator = TransactionValidator();

    expect(
      () => validator.validateVoid(id: '   ', voidedAt: 1757548900000),
      throwsArgumentError,
    );
  });

  test('rejects an invalid void timestamp', () {
    const validator = TransactionValidator();

    expect(
      () => validator.validateVoid(id: 'transaction-1', voidedAt: 0),
      throwsArgumentError,
    );
  });
    test('accepts a valid transfer', () {
    const validator = TransactionValidator();

    expect(
      () => validator.validateTransfer(
        amountMinor: 1000000,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        fromAccountId: 'account-bca',
        toAccountId: 'account-savings',
      ),
      returnsNormally,
    );
  });

  test('rejects transfer between the same account', () {
    const validator = TransactionValidator();

    expect(
      () => validator.validateTransfer(
        amountMinor: 1000000,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        fromAccountId: 'account-bca',
        toAccountId: 'account-bca',
      ),
      throwsArgumentError,
    );
  });

  test('rejects an empty transfer account id', () {
    const validator = TransactionValidator();

    expect(
      () => validator.validateTransfer(
        amountMinor: 1000000,
        transactionDate: 1757548800000,
        currencyCode: 'IDR',
        fromAccountId: ' ',
        toAccountId: 'account-savings',
      ),
      throwsArgumentError,
    );
  });
}
