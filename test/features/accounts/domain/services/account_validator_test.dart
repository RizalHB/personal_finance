import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/accounts/domain/services/account_validator.dart';

void main() {
  const validator = AccountValidator();

  group('AccountValidator.validateCreate', () {
    test('accepts valid account data', () {
      expect(
        () => validator.validateCreate(
          name: 'Cash',
          financialClass: 1,
          accountType: 1,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        returnsNormally,
      );
    });

    test('rejects empty account name', () {
      expect(
        () => validator.validateCreate(
          name: '   ',
          financialClass: 1,
          accountType: 1,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        throwsArgumentError,
      );
    });

    test('rejects account name longer than 100 characters', () {
      expect(
        () => validator.validateCreate(
          name: 'A' * 101,
          financialClass: 1,
          accountType: 1,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid financial class', () {
      expect(
        () => validator.validateCreate(
          name: 'Cash',
          financialClass: 99,
          accountType: 1,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid account type', () {
      expect(
        () => validator.validateCreate(
          name: 'Cash',
          financialClass: 1,
          accountType: 99,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        throwsArgumentError,
      );
    });

    test('rejects currency code with incorrect length', () {
      expect(
        () => validator.validateCreate(
          name: 'Cash',
          financialClass: 1,
          accountType: 1,
          openingBalanceMinor: 0,
          currencyCode: 'ID',
        ),
        throwsArgumentError,
      );
    });
  });
  test('rejects negative opening balance', () {
    expect(
      () => validator.validateCreate(
        name: 'BCA',
        financialClass: 1,
        accountType: 2,
        currencyCode: 'IDR',
        openingBalanceMinor: -1,
      ),
      throwsArgumentError,
    );
  });
}
