import '../../domain/models/dashboard_summary.dart';

abstract interface class DashboardRepository {
  Future<DashboardSummary> getSummary({required int year, required int month});
}
