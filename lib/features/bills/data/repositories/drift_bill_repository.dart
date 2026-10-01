import 'package:drift/drift.dart';
import 'package:personal_finance/core/database/app_database.dart' as db;

import '../../domain/entities/bill.dart';
import 'bill_repository.dart';

class DriftBillRepository implements BillRepository {
  const DriftBillRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<Bill?> getById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    final row = await (_database.select(
      _database.bills,
    )..where((bill) => bill.id.equals(normalizedId))).getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<List<Bill>> getAll() async {
    final rows =
        await (_database.select(_database.bills)..orderBy([
              (bill) => OrderingTerm.asc(bill.dueDate),
              (bill) => OrderingTerm.asc(bill.id),
            ]))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<Bill> create({required Bill bill}) async {
    await _database
        .into(_database.bills)
        .insert(
          db.BillsCompanion.insert(
            id: bill.id,
            name: bill.name,
            amountMinor: Value(bill.amountMinor),
            currencyCode: bill.currencyCode,
            dueDate: bill.dueDate,
            status: bill.status.code,
            accountId: Value(bill.accountId),
            categoryId: Value(bill.categoryId),
            merchantId: Value(bill.merchantId),
            notes: Value(bill.notes),
            createdAt: bill.createdAt,
            updatedAt: bill.updatedAt,
            cancelledAt: Value(bill.cancelledAt),
          ),
        );

    return bill;
  }

  @override
  Future<Bill> update({required Bill bill}) async {
    await (_database.update(
      _database.bills,
    )..where((row) => row.id.equals(bill.id))).write(
      db.BillsCompanion(
        name: Value(bill.name),
        amountMinor: Value(bill.amountMinor),
        currencyCode: Value(bill.currencyCode),
        dueDate: Value(bill.dueDate),
        status: Value(bill.status.code),
        accountId: Value(bill.accountId),
        categoryId: Value(bill.categoryId),
        merchantId: Value(bill.merchantId),
        notes: Value(bill.notes),
        updatedAt: Value(bill.updatedAt),
        cancelledAt: Value(bill.cancelledAt),
      ),
    );

    return bill;
  }

  @override
  Future<void> delete(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    await (_database.delete(
      _database.bills,
    )..where((bill) => bill.id.equals(normalizedId))).go();
  }
}

extension on db.Bill {
  Bill toDomain() {
    return Bill(
      id: id,
      name: name,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      dueDate: dueDate,
      status: BillStatus.fromCode(status),
      accountId: accountId,
      categoryId: categoryId,
      merchantId: merchantId,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cancelledAt: cancelledAt,
    );
  }
}
