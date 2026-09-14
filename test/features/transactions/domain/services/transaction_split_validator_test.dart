import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/transactions/domain/services/transaction_split_validator.dart';

void main() {
  const validator = TransactionSplitValidator();

  group('validate', () {
    test('accepts a valid split', () {
      expect(
        () => validator.validate(
          transactionId: 'transaction-1',
          categoryId: 'category-food',
          amountMinor: 350000,
          notes: 'Food portion',
        ),
        returnsNormally,
      );
    });

    test('rejects non-positive amount', () {
      expect(
        () => validator.validate(
          transactionId: 'transaction-1',
          categoryId: 'category-food',
          amountMinor: 0,
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty transaction ID', () {
      expect(
        () => validator.validate(
          transactionId: ' ',
          categoryId: 'category-food',
          amountMinor: 100000,
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty category ID', () {
      expect(
        () => validator.validate(
          transactionId: 'transaction-1',
          categoryId: ' ',
          amountMinor: 100000,
        ),
        throwsArgumentError,
      );
    });

    test('rejects notes longer than 1000 characters', () {
      expect(
        () => validator.validate(
          transactionId: 'transaction-1',
          categoryId: 'category-food',
          amountMinor: 100000,
          notes: 'x' * 1001,
        ),
        throwsArgumentError,
      );
    });
  });

  group('validateTotal', () {
    test('accepts split total equal to transaction amount', () {
      expect(
        () => validator.validateTotal(
          transactionAmountMinor: 500000,
          splitTotalMinor: 500000,
        ),
        returnsNormally,
      );
    });

    test('rejects split total below transaction amount', () {
      expect(
        () => validator.validateTotal(
          transactionAmountMinor: 500000,
          splitTotalMinor: 450000,
        ),
        throwsArgumentError,
      );
    });

    test('rejects split total above transaction amount', () {
      expect(
        () => validator.validateTotal(
          transactionAmountMinor: 500000,
          splitTotalMinor: 550000,
        ),
        throwsArgumentError,
      );
    });
  });
}
