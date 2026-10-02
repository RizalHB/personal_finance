import '../../data/repositories/dashboard_repository.dart';
import '../../domain/models/dashboard_summary.dart';

class GetDashboardSummary {
  const GetDashboardSummary(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSummary> execute({required int year, required int month}) {
    if (year < 1) {
      throw ArgumentError('Year must be greater than zero.');
    }

    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12.');
    }

    return _repository.getSummary(year: year, month: month);
  }
}
