import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as database;

import '../../domain/entities/transaction_split.dart';
import '../mappers/transaction_split_mapper.dart';
import 'transaction_split_repository.dart';

class DriftTransactionSplitRepository implements TransactionSplitRepository {
  DriftTransactionSplitRepository(this._database);

  final database.AppDatabase _database;

  static const int _postedStatus = 1;
  static const int _activeStatus = 1;
  static const int _expenseTransactionType = 2;
  static const int _expenseCategoryType = 2;

  @override
  Future<List<TransactionSplit>> getByTransactionId(
    String transactionId,
  ) async {
    final normalizedTransactionId = transactionId.trim();

    if (normalizedTransactionId.isEmpty) {
      throw ArgumentError.value(
        transactionId,
        'transactionId',
        'Transaction ID must not be empty.',
      );
    }

    final rows =
        await (_database.select(_database.transactionSplits)
              ..where(
                (tbl) => tbl.transactionId.equals(normalizedTransactionId),
              )
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<List<TransactionSplit>> replaceSplits({
    required String transactionId,
    required List<TransactionSplit> splits,
  }) async {
    final normalizedTransactionId = transactionId.trim();

    if (normalizedTransactionId.isEmpty) {
      throw ArgumentError.value(
        transactionId,
        'transactionId',
        'Transaction ID must not be empty.',
      );
    }

    await _database.transaction(() async {
      final transaction =
          await (_database.select(_database.transactions)
                ..where((tbl) => tbl.id.equals(normalizedTransactionId)))
              .getSingleOrNull();

      if (transaction == null) {
        throw StateError('Transaction not found: $normalizedTransactionId');
      }

      if (transaction.status != _postedStatus) {
        throw StateError(
          'Cannot modify splits of a voided transaction: '
          '$normalizedTransactionId',
        );
      }

      if (transaction.transactionType != _expenseTransactionType) {
        throw StateError('Only expense transactions can have splits.');
      }

      var totalMinor = 0;

      for (final split in splits) {
        if (split.transactionId != normalizedTransactionId) {
          throw StateError(
            'Split transaction ID does not match parent transaction.',
          );
        }

        if (split.amountMinor <= 0) {
          throw StateError('Split amount must be greater than zero.');
        }

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
          throw StateError('Split category must be an expense category.');
        }

        totalMinor += split.amountMinor;
      }

      if (splits.isEmpty) {
        throw StateError('At least one split is required.');
      }

      if (totalMinor != transaction.amountMinor) {
        throw StateError('Split total must equal the transaction amount.');
      }

      await (_database.delete(_database.transactionSplits)
            ..where((tbl) => tbl.transactionId.equals(normalizedTransactionId)))
          .go();

      for (final split in splits) {
        await _database
            .into(_database.transactionSplits)
            .insert(
              database.TransactionSplitsCompanion.insert(
                id: split.id,
                transactionId: normalizedTransactionId,
                categoryId: split.categoryId,
                amountMinor: split.amountMinor,
                notes: Value(split.notes),
                createdAt: split.createdAt,
                updatedAt: split.updatedAt,
              ),
            );
      }
    });

    return getByTransactionId(normalizedTransactionId);
  }
}
