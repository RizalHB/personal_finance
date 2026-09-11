import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as database;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/entities/transaction.dart';
import '../mappers/transaction_mapper.dart';
import 'transaction_repository.dart';

class DriftTransactionRepository implements TransactionRepository {
  DriftTransactionRepository(this._database);

  final database.AppDatabase _database;

  static const int _postedStatus = 1;
  static const int _activeStatus = 1;
  static const int _debitSide = 1;
  static const int _creditSide = 2;
  static const int _transferTransactionType = 3;
  static const int _assetFinancialClass = 1;
  static const int _incomeCategoryType = 1;
  static const int _expenseCategoryType = 2;

  @override
  Future<Transaction> createTransaction({
    required String id,
    required TransactionType type,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required String categoryId,
    String? merchantId,
    String? notes,
  }) async {
    if (type != TransactionType.income && type != TransactionType.expense) {
      throw ArgumentError(
        'Only income and expense transactions are supported '
        'by this operation.',
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await _database.transaction(() async {
      final account = await (_database.select(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(accountId))).getSingleOrNull();

      if (account == null) {
        throw StateError('Account not found: $accountId');
      }

      if (account.status != _activeStatus) {
        throw StateError('Account is not active: $accountId');
      }

      if (account.currencyCode != currencyCode) {
        throw StateError(
          'Transaction currency does not match account currency.',
        );
      }

      final category = await (_database.select(
        _database.categories,
      )..where((tbl) => tbl.id.equals(categoryId))).getSingleOrNull();

      if (category == null) {
        throw StateError('Category not found: $categoryId');
      }

      if (category.status != _activeStatus) {
        throw StateError('Category is not active: $categoryId');
      }

      final expectedCategoryType = type == TransactionType.income
          ? _incomeCategoryType
          : _expenseCategoryType;

      if (category.categoryType != expectedCategoryType) {
        throw StateError('Category type does not match transaction type.');
      }

      await _database
          .into(_database.transactions)
          .insert(
            database.TransactionsCompanion.insert(
              id: id,
              transactionType: type.code,
              status: _postedStatus,
              transactionDate: transactionDate,
              currencyCode: currencyCode,
              amountMinor: amountMinor,
              accountId: Value(accountId),
              categoryId: Value(categoryId),
              merchantId: Value(merchantId),
              notes: Value(notes),
              relatedTransactionId: const Value(null),
              recurringTransactionId: const Value(null),
              createdAt: now,
              updatedAt: now,
              voidedAt: const Value(null),
            ),
          );

      final accountIsDebit = type == TransactionType.income;

      await _database
          .into(_database.ledgerEntries)
          .insert(
            database.LedgerEntriesCompanion.insert(
              id: _generateLedgerEntryId(id, 'account'),
              transactionId: id,
              ledgerAccountId: account.ledgerAccountId,
              entrySide: accountIsDebit ? _debitSide : _creditSide,
              amountMinor: amountMinor,
              currencyCode: currencyCode,
              createdAt: now,
            ),
          );

      await _database
          .into(_database.ledgerEntries)
          .insert(
            database.LedgerEntriesCompanion.insert(
              id: _generateLedgerEntryId(id, 'category'),
              transactionId: id,
              ledgerAccountId: category.ledgerAccountId,
              entrySide: accountIsDebit ? _creditSide : _debitSide,
              amountMinor: amountMinor,
              currencyCode: currencyCode,
              createdAt: now,
            ),
          );
    });

    final transaction = await (_database.select(
      _database.transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingle();

    return transaction.toDomain();
  }

  @override
  Future<Transaction?> getById(String id) async {
    final row = await (_database.select(
      _database.transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<Transaction> voidTransaction({
    required String id,
    required int voidedAt,
  }) async {
    if (voidedAt <= 0) {
      throw ArgumentError.value(
        voidedAt,
        'voidedAt',
        'Must be greater than zero.',
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await _database.transaction(() async {
      final transaction = await (_database.select(
        _database.transactions,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (transaction == null) {
        throw StateError('Transaction not found: $id');
      }

      if (transaction.status != _postedStatus) {
        throw StateError('Transaction is already voided: $id');
      }

      await (_database.update(
        _database.transactions,
      )..where((tbl) => tbl.id.equals(id))).write(
        database.TransactionsCompanion(
          status: const Value(2),
          updatedAt: Value(now),
          voidedAt: Value(voidedAt),
        ),
      );
    });

    final updatedTransaction = await (_database.select(
      _database.transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingle();

    return updatedTransaction.toDomain();
  }

  @override
  Stream<List<Transaction>> watchRecent({int limit = 50}) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be greater than zero.');
    }

    final query = _database.select(_database.transactions)
      ..orderBy([
        (tbl) => OrderingTerm(
          expression: tbl.transactionDate,
          mode: OrderingMode.desc,
        ),
        (tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }
    @override
  Future<Transaction> createTransfer({
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String fromAccountId,
    required String toAccountId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final transactionId = _generateTransferId(
      fromAccountId,
      toAccountId,
      transactionDate,
      now,
    );

    await _database.transaction(() async {
      final fromAccount = await (_database.select(
        _database.accounts,
      )..where(
          (tbl) => tbl.id.equals(fromAccountId),
        )).getSingleOrNull();

      if (fromAccount == null) {
        throw StateError('Source account not found: $fromAccountId');
      }

      if (fromAccount.status != _activeStatus) {
        throw StateError(
          'Source account is not active: $fromAccountId',
        );
      }

      if (fromAccount.financialClass != _assetFinancialClass) {
        throw StateError(
          'Source account must be an asset account.',
        );
      }

      final toAccount = await (_database.select(
        _database.accounts,
      )..where(
          (tbl) => tbl.id.equals(toAccountId),
        )).getSingleOrNull();

      if (toAccount == null) {
        throw StateError(
          'Destination account not found: $toAccountId',
        );
      }

      if (toAccount.status != _activeStatus) {
        throw StateError(
          'Destination account is not active: $toAccountId',
        );
      }

      if (toAccount.financialClass != _assetFinancialClass) {
        throw StateError(
          'Destination account must be an asset account.',
        );
      }

      if (fromAccount.currencyCode != currencyCode ||
          toAccount.currencyCode != currencyCode) {
        throw StateError(
          'Transfer currency must match both account currencies.',
        );
      }

      await _database
          .into(_database.transactions)
          .insert(
            database.TransactionsCompanion.insert(
              id: transactionId,
              transactionType: _transferTransactionType,
              status: _postedStatus,
              transactionDate: transactionDate,
              currencyCode: currencyCode,
              amountMinor: amountMinor,
              accountId: Value(fromAccountId),
              categoryId: const Value(null),
              merchantId: const Value(null),
              notes: const Value(null),
              relatedTransactionId: const Value(null),
              recurringTransactionId: const Value(null),
              createdAt: now,
              updatedAt: now,
              voidedAt: const Value(null),
            ),
          );

      await _database
          .into(_database.ledgerEntries)
          .insert(
            database.LedgerEntriesCompanion.insert(
              id: _generateLedgerEntryId(
                transactionId,
                'from-account',
              ),
              transactionId: transactionId,
              ledgerAccountId: fromAccount.ledgerAccountId,
              entrySide: _creditSide,
              amountMinor: amountMinor,
              currencyCode: currencyCode,
              createdAt: now,
            ),
          );

      await _database
          .into(_database.ledgerEntries)
          .insert(
            database.LedgerEntriesCompanion.insert(
              id: _generateLedgerEntryId(
                transactionId,
                'to-account',
              ),
              transactionId: transactionId,
              ledgerAccountId: toAccount.ledgerAccountId,
              entrySide: _debitSide,
              amountMinor: amountMinor,
              currencyCode: currencyCode,
              createdAt: now,
            ),
          );
    });

    final transaction = await (_database.select(
      _database.transactions,
    )..where(
        (tbl) => tbl.id.equals(transactionId),
      )).getSingle();

    return transaction.toDomain();
  }

  String _generateLedgerEntryId(String transactionId, String role) {
    return '$transactionId-$role';
  }
    String _generateTransferId(
    String fromAccountId,
    String toAccountId,
    int transactionDate,
    int createdAt,
  ) {
    return 'transfer-$fromAccountId-$toAccountId-$transactionDate-$createdAt';
  }
}
