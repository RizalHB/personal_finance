import '../../data/repositories/bill_repository.dart';

class DeleteBill {
  const DeleteBill(this._repository);

  final BillRepository _repository;

  Future<void> execute(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    final existing = await _repository.getById(normalizedId);

    if (existing == null) {
      throw StateError('Bill not found: $normalizedId');
    }

    await _repository.delete(normalizedId);
  }
}
