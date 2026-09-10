import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/accounts/data/repositories/drift_account_repository.dart';

class _FakeIdGenerator implements IdGenerator {
  int _counter = 0;

  @override
  String generate() {
    _counter++;
    return 'id-$_counter';
  }
}

void main() {
  late AppDatabase database;
  late DriftAccountRepository repository;

  setUp(() {
    database = AppDatabase.test();
    repository = DriftAccountRepository(database, _FakeIdGenerator());
  });

  tearDown(() async {
    await database.close();
  });

  test('creates account with balanced opening balance ledger event', () async {
    final account = await repository.createAccount(
      name: 'BCA',
      financialClass: 1,
      accountType: 2,
      currencyCode: 'IDR',
      openingBalanceMinor: 5000000,
    );

    expect(account.name, 'BCA');

    final transactions = await database.select(database.transactions).get();
    expect(transactions, hasLength(1));
    expect(transactions.single.amountMinor, 5000000);
    expect(transactions.single.transactionType, 5);
    expect(transactions.single.accountId, account.id);

    final entries = await database.select(database.ledgerEntries).get();
    expect(entries, hasLength(2));

    final debit = entries.singleWhere((entry) => entry.entrySide == 1);
    final credit = entries.singleWhere((entry) => entry.entrySide == 2);

    expect(debit.amountMinor, 5000000);
    expect(credit.amountMinor, 5000000);
    expect(debit.transactionId, transactions.single.id);
    expect(credit.transactionId, transactions.single.id);

    final ledgerAccounts = await database.select(database.ledgerAccounts).get();

    expect(
      ledgerAccounts.any(
        (ledgerAccount) =>
            ledgerAccount.code == 'opening_balance_equity' &&
            ledgerAccount.isSystem &&
            ledgerAccount.kind == 5,
      ),
      isTrue,
    );
  });

  test(
    'creates account without ledger event when opening balance is zero',
    () async {
      final account = await repository.createAccount(
        name: 'Cash',
        financialClass: 1,
        accountType: 1,
        currencyCode: 'IDR',
        openingBalanceMinor: 0,
      );

      expect(account.name, 'Cash');

      final transactions = await database.select(database.transactions).get();
      final entries = await database.select(database.ledgerEntries).get();

      expect(transactions, isEmpty);
      expect(entries, isEmpty);
    },
  );
}
