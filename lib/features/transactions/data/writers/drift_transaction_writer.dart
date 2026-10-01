import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;
import 'package:personal_finance/core/domain/transaction_type.dart';

class DriftTransactionWriter {
  const DriftTransactionWriter(this._database);

  static const int _postedStatus = 1;

  static const int _debitSide = 1;
  static const int _creditSide = 2;

  static const int _incomeCategoryType = 1;
  static const int _expenseCategoryType = 2;

  final db.AppDatabase _database;

  Future<void> write({
    required String id,
    required TransactionType type,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required String categoryId,
    String? merchantId,
    String? notes,
    String? recurringTransactionId,
    required int createdAt,
  }) async {
    if (type != TransactionType.income && type != TransactionType.expense) {
      throw ArgumentError(
        'Only income and expense transactions are supported '
        'by this operation.',
      );
    }

    final account = await (_database.select(
      _database.accounts,
    )..where((tbl) => tbl.id.equals(accountId))).getSingleOrNull();

    if (account == null) {
      throw StateError('Account not found: $accountId');
    }

    if (account.status != _postedStatus) {
      throw StateError('Account is not active: $accountId');
    }

    if (account.currencyCode != currencyCode) {
      throw StateError('Transaction currency does not match account currency.');
    }

    final category = await (_database.select(
      _database.categories,
    )..where((tbl) => tbl.id.equals(categoryId))).getSingleOrNull();

    if (category == null) {
      throw StateError('Category not found: $categoryId');
    }

    if (category.status != _postedStatus) {
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
          db.TransactionsCompanion.insert(
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
            recurringTransactionId: Value(recurringTransactionId),
            createdAt: createdAt,
            updatedAt: createdAt,
            voidedAt: const Value(null),
          ),
        );

    final accountIsDebit = type == TransactionType.income;

    await _database
        .into(_database.ledgerEntries)
        .insert(
          db.LedgerEntriesCompanion.insert(
            id: _generateLedgerEntryId(id, 'account'),
            transactionId: id,
            ledgerAccountId: account.ledgerAccountId,
            entrySide: accountIsDebit ? _debitSide : _creditSide,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            createdAt: createdAt,
          ),
        );

    await _database
        .into(_database.ledgerEntries)
        .insert(
          db.LedgerEntriesCompanion.insert(
            id: _generateLedgerEntryId(id, 'category'),
            transactionId: id,
            ledgerAccountId: category.ledgerAccountId,
            entrySide: accountIsDebit ? _creditSide : _debitSide,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            createdAt: createdAt,
          ),
        );
  }

  String _generateLedgerEntryId(String transactionId, String role) {
    return '$transactionId-$role';
  }
}
