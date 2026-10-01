import '../../data/repositories/bill_repository.dart';
import '../../domain/entities/bill.dart';

class UpdateBill {
  const UpdateBill(this._repository);

  final BillRepository _repository;

  Future<Bill> execute({
    required String id,
    required String name,
    required int? amountMinor,
    required String currencyCode,
    required int dueDate,
    required BillStatus status,
    String? accountId,
    String? categoryId,
    String? merchantId,
    String? notes,
    int? cancelledAt,
  }) async {
    final normalizedId = id.trim();
    final normalizedName = name.trim();
    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();
    final normalizedAccountId = accountId?.trim();
    final normalizedCategoryId = categoryId?.trim();
    final normalizedMerchantId = merchantId?.trim();
    final normalizedNotes = notes?.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    if (normalizedName.isEmpty) {
      throw ArgumentError('Bill name cannot be empty.');
    }

    if (amountMinor != null && amountMinor <= 0) {
      throw ArgumentError('Bill amount must be greater than zero.');
    }

    if (normalizedCurrencyCode.length != 3) {
      throw ArgumentError('Currency code must contain 3 characters.');
    }

    final existing = await _repository.getById(normalizedId);

    if (existing == null) {
      throw StateError('Bill not found: $normalizedId');
    }

    final updatedBill = Bill(
      id: existing.id,
      name: normalizedName,
      amountMinor: amountMinor,
      currencyCode: normalizedCurrencyCode,
      dueDate: dueDate,
      status: status,
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
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      cancelledAt: cancelledAt,
    );

    return _repository.update(bill: updatedBill);
  }
}
