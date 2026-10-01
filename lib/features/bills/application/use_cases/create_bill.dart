import 'package:personal_finance/core/utils/id_generator.dart';

import '../../data/repositories/bill_repository.dart';
import '../../domain/entities/bill.dart';

class CreateBill {
  const CreateBill(this._repository, this._idGenerator);

  final BillRepository _repository;
  final IdGenerator _idGenerator;

  Future<Bill> execute({
    required String name,
    required int? amountMinor,
    required String currencyCode,
    required int dueDate,
    String? accountId,
    String? categoryId,
    String? merchantId,
    String? notes,
  }) async {
    final normalizedName = name.trim();
    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();
    final normalizedAccountId = accountId?.trim();
    final normalizedCategoryId = categoryId?.trim();
    final normalizedMerchantId = merchantId?.trim();
    final normalizedNotes = notes?.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Bill name cannot be empty.');
    }

    if (amountMinor != null && amountMinor <= 0) {
      throw ArgumentError('Bill amount must be greater than zero.');
    }

    if (normalizedCurrencyCode.length != 3) {
      throw ArgumentError('Currency code must contain 3 characters.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final bill = Bill(
      id: _idGenerator.generate(),
      name: normalizedName,
      amountMinor: amountMinor,
      currencyCode: normalizedCurrencyCode,
      dueDate: dueDate,
      status: BillStatus.active,
      accountId: normalizedAccountId?.isEmpty == true
          ? null
          : normalizedAccountId,
      categoryId: normalizedCategoryId?.isEmpty == true
          ? null
          : normalizedCategoryId,
      merchantId: normalizedMerchantId?.isEmpty == true
          ? null
          : normalizedMerchantId,
      notes: normalizedNotes?.isEmpty == true ? null : normalizedNotes,
      createdAt: now,
      updatedAt: now,
      cancelledAt: null,
    );

    return _repository.create(bill: bill);
  }
}
