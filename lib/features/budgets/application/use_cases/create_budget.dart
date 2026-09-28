import 'package:personal_finance/core/utils/id_generator.dart';

import '../../data/repositories/budget_repository.dart';
import '../../domain/entities/budget.dart';
import '../../domain/validators/budget_validator.dart';

class CreateBudget {
  const CreateBudget(this._repository, this._validator, this._idGenerator);

  final BudgetRepository _repository;
  final BudgetValidator _validator;
  final IdGenerator _idGenerator;

  Future<Budget> execute({
    required int year,
    required int month,
    required String name,
  }) async {
    _validator.validateCreate(year: year, month: month, name: name);

    final existing = await _repository.getByYearMonth(year: year, month: month);

    if (existing != null) {
      throw StateError('A budget already exists for $year-$month.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final budget = Budget(
      id: _idGenerator.generate(),
      year: year,
      month: month,
      name: name.trim(),
      status: BudgetStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.create(budget: budget);
  }
}
