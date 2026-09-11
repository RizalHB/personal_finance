import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/services/transaction_validator.dart';

class VoidTransaction {
  const VoidTransaction(this._repository, this._validator);

  final TransactionRepository _repository;
  final TransactionValidator _validator;

  Future<Transaction> execute({
    required String id,
    required int voidedAt,
  }) async {
    final normalizedId = id.trim();

    _validator.validateVoid(id: normalizedId, voidedAt: voidedAt);

    return _repository.voidTransaction(id: normalizedId, voidedAt: voidedAt);
  }
}
