import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as database;
import 'package:personal_finance/core/domain/transaction_type.dart';

import '../../domain/models/transaction_filter.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_split.dart';
import '../mappers/transaction_mapper.dart';
import 'transaction_repository.dart';

class DriftTransactionRepository implements TransactionRepository {
  DriftTransactionRepository(this._database);

  final database.AppDatabase _database;

  static const int _postedStatus = 1;
  static const int _activeStatus = 1;
  static const int _voidedStatus = 2;

  static const int _debitSide = 1;
  static const int _creditSide = 2;

  static const int _expenseTransactionType = 2;
  static const int _transferTransactionType = 3;

  static const int _assetFinancialClass = 1;

  static const int _incomeCategoryType = 1;
  static const int _expenseCategoryType = 2;

  String _escapeLikePattern(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

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
  Future<Transaction> createSplitExpense({
    required String id,
    required int amountMinor,
    required int transactionDate,
    required String currencyCode,
    required String accountId,
    required List<TransactionSplit> splits,
    String? merchantId,
    String? notes,
  }) async {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be greater than zero.',
      );
    }

    if (transactionDate <= 0) {
      throw ArgumentError.value(
        transactionDate,
        'transactionDate',
        'Must be greater than zero.',
      );
    }

    final normalizedAccountId = accountId.trim();
    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();

    if (normalizedAccountId.isEmpty) {
      throw ArgumentError.value(
        accountId,
        'accountId',
        'Account ID must not be empty.',
      );
    }

    if (normalizedCurrencyCode.length != 3) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Currency code must contain exactly 3 characters.',
      );
    }

    if (splits.isEmpty) {
      throw ArgumentError('At least one split is required.');
    }

    var splitTotalMinor = 0;

    for (final split in splits) {
      if (split.amountMinor <= 0) {
        throw ArgumentError('Split amount must be greater than zero.');
      }

      if (split.transactionId != id) {
        throw ArgumentError(
          'Split transaction ID does not match transaction ID.',
        );
      }

      final normalizedCategoryId = split.categoryId.trim();

      if (normalizedCategoryId.isEmpty) {
        throw ArgumentError('Split category ID must not be empty.');
      }

      splitTotalMinor += split.amountMinor;
    }

    if (splitTotalMinor != amountMinor) {
      throw ArgumentError('Split total must equal the transaction amount.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await _database.transaction(() async {
      final account = await (_database.select(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(normalizedAccountId))).getSingleOrNull();

      if (account == null) {
        throw StateError('Account not found: $normalizedAccountId');
      }

      if (account.status != _activeStatus) {
        throw StateError('Account is not active: $normalizedAccountId');
      }

      if (account.currencyCode != normalizedCurrencyCode) {
        throw StateError(
          'Account currency does not match transaction currency.',
        );
      }

      final accountLedger =
          await (_database.select(_database.ledgerAccounts)
                ..where((tbl) => tbl.id.equals(account.ledgerAccountId)))
              .getSingleOrNull();

      if (accountLedger == null) {
        throw StateError(
          'Ledger account not found: ${account.ledgerAccountId}',
        );
      }

      await _validateSplitCategories(splits: splits);

      await _database
          .into(_database.transactions)
          .insert(
            database.TransactionsCompanion.insert(
              id: id,
              transactionType: _expenseTransactionType,
              status: _postedStatus,
              transactionDate: transactionDate,
              currencyCode: normalizedCurrencyCode,
              amountMinor: amountMinor,
              accountId: Value(normalizedAccountId),
              categoryId: const Value(null),
              merchantId: Value(merchantId),
              notes: Value(notes),
              relatedTransactionId: const Value(null),
              recurringTransactionId: const Value(null),
              createdAt: now,
              updatedAt: now,
              voidedAt: const Value(null),
            ),
          );

      for (final split in splits) {
        final category = await (_database.select(
          _database.categories,
        )..where((tbl) => tbl.id.equals(split.categoryId))).getSingle();

        await _database
            .into(_database.transactionSplits)
            .insert(
              database.TransactionSplitsCompanion.insert(
                id: split.id,
                transactionId: id,
                categoryId: split.categoryId,
                amountMinor: split.amountMinor,
                notes: Value(split.notes),
                createdAt: split.createdAt,
                updatedAt: split.updatedAt,
              ),
            );

        await _database
            .into(_database.ledgerEntries)
            .insert(
              database.LedgerEntriesCompanion.insert(
                id: _generateLedgerEntryId(id, 'split-${split.id}'),
                transactionId: id,
                ledgerAccountId: category.ledgerAccountId,
                entrySide: _debitSide,
                amountMinor: split.amountMinor,
                currencyCode: normalizedCurrencyCode,
                createdAt: now,
              ),
            );
      }

      await _database
          .into(_database.ledgerEntries)
          .insert(
            database.LedgerEntriesCompanion.insert(
              id: _generateLedgerEntryId(id, 'account'),
              transactionId: id,
              ledgerAccountId: account.ledgerAccountId,
              entrySide: _creditSide,
              amountMinor: amountMinor,
              currencyCode: normalizedCurrencyCode,
              createdAt: now,
            ),
          );
    });

    final created = await (_database.select(
      _database.transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingle();

    return created.toDomain();
  }

  Future<void> _validateSplitCategories({
    required List<TransactionSplit> splits,
  }) async {
    for (final split in splits) {
      final category = await (_database.select(
        _database.categories,
      )..where((tbl) => tbl.id.equals(split.categoryId))).getSingleOrNull();

      if (category == null) {
        throw StateError('Split category not found: ${split.categoryId}');
      }

      if (category.status != _activeStatus) {
        throw StateError('Split category is not active: ${split.categoryId}');
      }

      if (category.categoryType != _expenseCategoryType) {
        throw StateError(
          'Split category must be an expense category: '
          '${split.categoryId}',
        );
      }

      final ledgerAccount =
          await (_database.select(_database.ledgerAccounts)
                ..where((tbl) => tbl.id.equals(category.ledgerAccountId)))
              .getSingleOrNull();

      if (ledgerAccount == null) {
        throw StateError(
          'Split category ledger account not found: '
          '${category.ledgerAccountId}',
        );
      }
    }
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
          status: const Value(_voidedStatus),
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
      )..where((tbl) => tbl.id.equals(fromAccountId))).getSingleOrNull();

      if (fromAccount == null) {
        throw StateError('Source account not found: $fromAccountId');
      }

      if (fromAccount.status != _activeStatus) {
        throw StateError('Source account is not active: $fromAccountId');
      }

      if (fromAccount.financialClass != _assetFinancialClass) {
        throw StateError('Source account must be an asset account.');
      }

      final toAccount = await (_database.select(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(toAccountId))).getSingleOrNull();

      if (toAccount == null) {
        throw StateError('Destination account not found: $toAccountId');
      }

      if (toAccount.status != _activeStatus) {
        throw StateError('Destination account is not active: $toAccountId');
      }

      if (toAccount.financialClass != _assetFinancialClass) {
        throw StateError('Destination account must be an asset account.');
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
              id: _generateLedgerEntryId(transactionId, 'from-account'),
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
              id: _generateLedgerEntryId(transactionId, 'to-account'),
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
    )..where((tbl) => tbl.id.equals(transactionId))).getSingle();

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

  @override
  Future<List<Transaction>> search(TransactionFilter filter) async {
    if (filter.limit <= 0) {
      throw ArgumentError.value(
        filter.limit,
        'limit',
        'Must be greater than zero.',
      );
    }

    if (filter.minAmountMinor != null && filter.minAmountMinor! < 0) {
      throw ArgumentError.value(
        filter.minAmountMinor,
        'minAmountMinor',
        'Must not be negative.',
      );
    }

    if (filter.maxAmountMinor != null && filter.maxAmountMinor! < 0) {
      throw ArgumentError.value(
        filter.maxAmountMinor,
        'maxAmountMinor',
        'Must not be negative.',
      );
    }

    if (filter.minAmountMinor != null &&
        filter.maxAmountMinor != null &&
        filter.minAmountMinor! > filter.maxAmountMinor!) {
      throw ArgumentError(
        'Minimum amount must not be greater than maximum amount.',
      );
    }

    if (filter.fromDate != null && filter.fromDate! <= 0) {
      throw ArgumentError.value(
        filter.fromDate,
        'fromDate',
        'Must be greater than zero.',
      );
    }

    if (filter.toDate != null && filter.toDate! <= 0) {
      throw ArgumentError.value(
        filter.toDate,
        'toDate',
        'Must be greater than zero.',
      );
    }

    if (filter.fromDate != null &&
        filter.toDate != null &&
        filter.fromDate! > filter.toDate!) {
      throw ArgumentError('fromDate must not be greater than toDate.');
    }

    final normalizedAccountId = filter.accountId?.trim();
    final normalizedCategoryId = filter.categoryId?.trim();
    final normalizedMerchantId = filter.merchantId?.trim();
    final normalizedSearchQuery = filter.searchQuery?.trim();

    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
      leftOuterJoin(
        _database.merchants,
        _database.merchants.id.equalsExp(_database.transactions.merchantId),
      ),
    ]);

    if (filter.fromDate != null) {
      query.where(
        _database.transactions.transactionDate.isBiggerOrEqualValue(
          filter.fromDate!,
        ),
      );
    }

    if (filter.toDate != null) {
      query.where(
        _database.transactions.transactionDate.isSmallerOrEqualValue(
          filter.toDate!,
        ),
      );
    }

    if (filter.type != null) {
      query.where(
        _database.transactions.transactionType.equals(filter.type!.code),
      );
    }

    if (filter.status != null) {
      query.where(_database.transactions.status.equals(filter.status!.code));
    }

    if (normalizedAccountId != null && normalizedAccountId.isNotEmpty) {
      query.where(_database.transactions.accountId.equals(normalizedAccountId));
    }

    if (normalizedCategoryId != null && normalizedCategoryId.isNotEmpty) {
      query.where(
        _database.transactions.categoryId.equals(normalizedCategoryId) |
            _hasSplitCategory(categoryId: normalizedCategoryId),
      );
    }

    if (normalizedMerchantId != null && normalizedMerchantId.isNotEmpty) {
      query.where(
        _database.transactions.merchantId.equals(normalizedMerchantId),
      );
    }

    if (filter.minAmountMinor != null) {
      query.where(
        _database.transactions.amountMinor.isBiggerOrEqualValue(
          filter.minAmountMinor!,
        ),
      );
    }

    if (filter.maxAmountMinor != null) {
      query.where(
        _database.transactions.amountMinor.isSmallerOrEqualValue(
          filter.maxAmountMinor!,
        ),
      );
    }

    if (normalizedSearchQuery != null && normalizedSearchQuery.isNotEmpty) {
      final searchPattern = '%${_escapeLikePattern(normalizedSearchQuery)}%';

      query.where(
        _database.transactions.notes.like(searchPattern, escapeChar: r'\') |
            _database.merchants.name.like(searchPattern, escapeChar: r'\') |
            _database.categories.name.like(searchPattern, escapeChar: r'\') |
            _hasSplitCategory(categoryNameSearchPattern: searchPattern),
      );
    }

    query
      ..orderBy([
        OrderingTerm(
          expression: _database.transactions.transactionDate,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: _database.transactions.createdAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(filter.limit);

    final rows = await query.get();

    return rows
        .map((row) => row.readTable(_database.transactions).toDomain())
        .toList();
  }

  Expression<bool> _hasSplitCategory({
    String? categoryId,
    String? categoryNameSearchPattern,
  }) {
    final splitCategories = _database.transactionSplits;
    final categories = _database.categories;

    final splitQuery = _database.select(splitCategories).join([
      innerJoin(
        categories,
        categories.id.equalsExp(splitCategories.categoryId),
      ),
    ]);

    splitQuery.where(
      splitCategories.transactionId.equalsExp(_database.transactions.id),
    );

    if (categoryId != null) {
      splitQuery.where(splitCategories.categoryId.equals(categoryId));
    }

    if (categoryNameSearchPattern != null) {
      splitQuery.where(
        categories.name.like(categoryNameSearchPattern, escapeChar: r'\'),
      );
    }

    return existsQuery(splitQuery);
  }
}
