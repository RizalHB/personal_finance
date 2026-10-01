import '../../data/repositories/recurring_transaction_repository.dart';

class DeleteRecurringTransaction {
  const DeleteRecurringTransaction(this._repository);

  final RecurringTransactionRepository _repository;

  Future<void> execute(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Recurring transaction ID cannot be empty.');
    }

    final existing = await _repository.getById(normalizedId);

    if (existing == null) {
      throw StateError('Recurring transaction not found: $normalizedId');
    }

    await _repository.delete(normalizedId);
  }
}
