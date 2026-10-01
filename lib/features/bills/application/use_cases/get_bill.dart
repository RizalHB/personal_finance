import '../../data/repositories/bill_repository.dart';
import '../../domain/entities/bill.dart';

class GetBill {
  const GetBill(this._repository);

  final BillRepository _repository;

  Future<Bill> execute(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Bill ID cannot be empty.');
    }

    final bill = await _repository.getById(normalizedId);

    if (bill == null) {
      throw StateError('Bill not found: $normalizedId');
    }

    return bill;
  }
}
