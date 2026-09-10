import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/features/accounts/application/use_cases/create_account.dart';
import 'package:personal_finance/features/accounts/data/repositories/account_repository.dart';
import 'package:personal_finance/features/accounts/domain/entities/account.dart';
import 'package:personal_finance/features/accounts/domain/services/account_validator.dart';

class FakeAccountRepository implements AccountRepository {
  Map<String, dynamic>? lastCreateCall;
  bool createAccountCalled = false;

  @override
  Future<Account> createAccount({
    required String name,
    required int financialClass,
    required int accountType,
    required String currencyCode,
    required int openingBalanceMinor,
    String? institutionName,
    String? iconCode,
    String? colorCode,
    String? notes,
  }) async {
    createAccountCalled = true;

    lastCreateCall = {
      'name': name,
      'financialClass': financialClass,
      'accountType': accountType,
      'currencyCode': currencyCode,
      'institutionName': institutionName,
      'iconCode': iconCode,
      'colorCode': colorCode,
      'notes': notes,
    };

    return Account(
      id: 'test-account-id',
      name: name,
      financialClass: financialClass,
      accountType: accountType,
      currencyCode: currencyCode,
      institutionName: institutionName,
      iconCode: iconCode,
      colorCode: colorCode,
      notes: notes,
      status: 1,
      createdAt: 0,
      updatedAt: 0,
      archivedAt: null,
    );
  }

  @override
  Stream<List<Account>> watchActiveAccounts() {
    return const Stream.empty();
  }

  @override
  Future<Account?> getAccountById(String id) async {
    return null;
  }

  @override
  Future<void> archiveAccount(String id) async {}

  @override
  Future<void> restoreAccount(String id) async {}
}

void main() {
  late FakeAccountRepository repository;
  late CreateAccount createAccount;

  setUp(() {
    repository = FakeAccountRepository();

    createAccount = CreateAccount(repository, const AccountValidator());
  });

  group('CreateAccount', () {
    test('normalizes account name and currency code', () async {
      await createAccount.execute(
        name: '  My Bank  ',
        financialClass: 1,
        accountType: 1,
        openingBalanceMinor: 0,
        currencyCode: ' idr ',
      );

      expect(repository.createAccountCalled, isTrue);
      expect(repository.lastCreateCall?['name'], 'My Bank');
      expect(repository.lastCreateCall?['currencyCode'], 'IDR');
    });

    test('normalizes optional text fields', () async {
      await createAccount.execute(
        name: 'Cash',
        financialClass: 1,
        accountType: 1,
        openingBalanceMinor: 0,
        currencyCode: 'IDR',
        institutionName: '  My Bank  ',
        notes: '  Emergency cash  ',
      );

      expect(repository.lastCreateCall?['institutionName'], 'My Bank');
      expect(repository.lastCreateCall?['notes'], 'Emergency cash');
    });

    test('passes valid account data to repository', () async {
      await createAccount.execute(
        name: 'Cash',
        financialClass: 1,
        accountType: 2,
        openingBalanceMinor: 0,
        currencyCode: 'IDR',
        iconCode: 'wallet',
        colorCode: '#123456',
      );

      expect(repository.createAccountCalled, isTrue);
      expect(repository.lastCreateCall?['name'], 'Cash');
      expect(repository.lastCreateCall?['financialClass'], 1);
      expect(repository.lastCreateCall?['accountType'], 2);
      expect(repository.lastCreateCall?['currencyCode'], 'IDR');
      expect(repository.lastCreateCall?['iconCode'], 'wallet');
      expect(repository.lastCreateCall?['colorCode'], '#123456');
    });

    test('rejects invalid input before calling repository', () {
      expect(
        () => createAccount.execute(
          name: '   ',
          financialClass: 1,
          accountType: 1,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        throwsArgumentError,
      );

      expect(repository.createAccountCalled, isFalse);
    });

    test('rejects invalid financial class before calling repository', () {
      expect(
        () => createAccount.execute(
          name: 'Cash',
          financialClass: 99,
          accountType: 1,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        throwsArgumentError,
      );

      expect(repository.createAccountCalled, isFalse);
    });

    test('rejects invalid account type before calling repository', () {
      expect(
        () => createAccount.execute(
          name: 'Cash',
          financialClass: 1,
          accountType: 99,
          openingBalanceMinor: 0,
          currencyCode: 'IDR',
        ),
        throwsArgumentError,
      );

      expect(repository.createAccountCalled, isFalse);
    });
  });
}
