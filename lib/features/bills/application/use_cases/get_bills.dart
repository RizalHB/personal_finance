import '../../data/repositories/bill_repository.dart';
import '../../domain/entities/bill.dart';

class GetBills {
  const GetBills(this._repository);

  final BillRepository _repository;

  Future<List<Bill>> execute() {
    return _repository.getAll();
  }
}
