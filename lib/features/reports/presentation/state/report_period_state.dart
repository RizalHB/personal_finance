class ReportPeriodState {
  const ReportPeriodState({required this.year, required this.month});

  final int year;
  final int month;

  ReportPeriodState copyWith({int? year, int? month}) {
    return ReportPeriodState(
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }
}
