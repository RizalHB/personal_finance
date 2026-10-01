import 'execute_due_recurring_transactions.dart';

class RunDueRecurringTransactions {
  const RunDueRecurringTransactions(this._executor);

  final ExecuteDueRecurringTransactions _executor;

  Future<int> execute({required int executionDate}) {
    return _executor.execute(executionDate: executionDate);
  }
}
