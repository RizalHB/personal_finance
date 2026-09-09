import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as database;
import 'package:personal_finance/core/utils/id_generator.dart';

import '../../domain/entities/account.dart';
import '../mappers/account_mapper.dart';
import 'account_repository.dart';

class DriftAccountRepository implements AccountRepository {
  DriftAccountRepository(this._database, this._idGenerator);

  final database.AppDatabase _database;
  final IdGenerator _idGenerator;

  @override
  Future<Account> createAccount({
    required String name,
    required int financialClass,
    required int accountType,
    required String currencyCode,
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
              status: 1,
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
              status: 1,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    final account = await getAccountById(accountId);

    if (account == null) {
      throw StateError('Account was created but could not be loaded.');
    }

    return account;
  }

  @override
  Stream<List<Account>> watchActiveAccounts() {
    return (_database.select(_database.accounts)
          ..where((tbl) => tbl.status.equals(1))
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
          status: const Value(2),
          archivedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await (_database.update(
        _database.ledgerAccounts,
      )..where((tbl) => tbl.id.equals(accountRow.ledgerAccountId))).write(
        database.LedgerAccountsCompanion(
          status: const Value(2),
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
          status: const Value(1),
          archivedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );

      await (_database.update(
        _database.ledgerAccounts,
      )..where((tbl) => tbl.id.equals(accountRow.ledgerAccountId))).write(
        database.LedgerAccountsCompanion(
          status: const Value(1),
          archivedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    });
  }
}
