import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as database;
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/core/utils/id_generator.dart';

import '../../domain/entities/account.dart';
import '../mappers/account_mapper.dart';
import 'account_repository.dart';

class DriftAccountRepository implements AccountRepository {
  DriftAccountRepository(this._database, this._idGenerator);

  final database.AppDatabase _database;
  final IdGenerator _idGenerator;

  static const int _postedStatus = 1;
  static const int _activeStatus = 1;
  static const int _archivedStatus = 2;

  static const int _assetFinancialClass = 1;

  static const int _debitSide = 1;
  static const int _creditSide = 2;

  static const String _openingBalanceEquityCode = 'opening_balance_equity';

  static const String _openingBalanceEquityName = 'Opening Balance Equity';

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
    final now = DateTime.now().millisecondsSinceEpoch;
    final accountId = _idGenerator.generate();
    final ledgerAccountId = _idGenerator.generate();

    await _database.transaction(() async {
      await _database
          .into(_database.ledgerAccounts)
          .insert(
            database.LedgerAccountsCompanion.insert(
              id: ledgerAccountId,
              kind: financialClass,
              code: accountId,
              name: name,
              isSystem: false,
              status: _activeStatus,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _database
          .into(_database.accounts)
          .insert(
            database.AccountsCompanion.insert(
              id: accountId,
              ledgerAccountId: ledgerAccountId,
              name: name,
              financialClass: financialClass,
              accountType: accountType,
              institutionName: Value(institutionName),
              currencyCode: currencyCode,
              iconCode: Value(iconCode),
              colorCode: Value(colorCode),
              notes: Value(notes),
              status: _activeStatus,
              createdAt: now,
              updatedAt: now,
            ),
          );

      if (openingBalanceMinor > 0) {
        final equityLedgerAccountId = await _ensureOpeningBalanceEquityAccount(
          now: now,
        );

        final transactionId = _idGenerator.generate();

        await _database
            .into(_database.transactions)
            .insert(
              database.TransactionsCompanion.insert(
                id: transactionId,
                transactionType: TransactionType.openingBalance.code,
                status: _postedStatus,
                transactionDate: now,
                currencyCode: currencyCode,
                amountMinor: openingBalanceMinor,
                accountId: Value(accountId),
                categoryId: const Value(null),
                merchantId: const Value(null),
                notes: const Value('Opening balance'),
                relatedTransactionId: const Value(null),
                recurringTransactionId: const Value(null),
                createdAt: now,
                updatedAt: now,
                voidedAt: const Value(null),
              ),
            );

        final accountIsDebit = financialClass == _assetFinancialClass;

        await _database
            .into(_database.ledgerEntries)
            .insert(
              database.LedgerEntriesCompanion.insert(
                id: _idGenerator.generate(),
                transactionId: transactionId,
                ledgerAccountId: accountIsDebit
                    ? ledgerAccountId
                    : equityLedgerAccountId,
                entrySide: accountIsDebit ? _debitSide : _debitSide,
                amountMinor: openingBalanceMinor,
                currencyCode: currencyCode,
                createdAt: now,
              ),
            );

        await _database
            .into(_database.ledgerEntries)
            .insert(
              database.LedgerEntriesCompanion.insert(
                id: _idGenerator.generate(),
                transactionId: transactionId,
                ledgerAccountId: accountIsDebit
                    ? equityLedgerAccountId
                    : ledgerAccountId,
                entrySide: _creditSide,
                amountMinor: openingBalanceMinor,
                currencyCode: currencyCode,
                createdAt: now,
              ),
            );
      }
    });

    final account = await getAccountById(accountId);

    if (account == null) {
      throw StateError('Account was created but could not be loaded.');
    }

    return account;
  }

  Future<String> _ensureOpeningBalanceEquityAccount({required int now}) async {
    final existing =
        await (_database.select(_database.ledgerAccounts)
              ..where((tbl) => tbl.code.equals(_openingBalanceEquityCode)))
            .getSingleOrNull();

    if (existing != null) {
      if (!existing.isSystem ||
          existing.kind != 5 ||
          existing.status != _activeStatus) {
        throw StateError('Opening Balance Equity system account is invalid.');
      }

      return existing.id;
    }

    final id = _idGenerator.generate();

    await _database
        .into(_database.ledgerAccounts)
        .insert(
          database.LedgerAccountsCompanion.insert(
            id: id,
            kind: 5,
            code: _openingBalanceEquityCode,
            name: _openingBalanceEquityName,
            isSystem: true,
            status: _activeStatus,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }

  @override
  Stream<List<Account>> watchActiveAccounts() {
    return (_database.select(_database.accounts)
          ..where((tbl) => tbl.status.equals(_activeStatus))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch()
        .map(
          (accounts) => accounts.map((account) => account.toDomain()).toList(),
        );
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final account = await (_database.select(
      _database.accounts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    return account?.toDomain();
  }

  @override
  Future<void> archiveAccount(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _database.transaction(() async {
      final accountRow = await (_database.select(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (accountRow == null) {
        throw StateError('Account not found: $id');
      }

      await (_database.update(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(id))).write(
        database.AccountsCompanion(
          status: const Value(_archivedStatus),
          archivedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await (_database.update(
        _database.ledgerAccounts,
      )..where((tbl) => tbl.id.equals(accountRow.ledgerAccountId))).write(
        database.LedgerAccountsCompanion(
          status: const Value(_archivedStatus),
          archivedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  @override
  Future<void> restoreAccount(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _database.transaction(() async {
      final accountRow = await (_database.select(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (accountRow == null) {
        throw StateError('Account not found: $id');
      }

      await (_database.update(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(id))).write(
        database.AccountsCompanion(
          status: const Value(_activeStatus),
          archivedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );

      await (_database.update(
        _database.ledgerAccounts,
      )..where((tbl) => tbl.id.equals(accountRow.ledgerAccountId))).write(
        database.LedgerAccountsCompanion(
          status: const Value(_activeStatus),
          archivedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    });
  }
}
