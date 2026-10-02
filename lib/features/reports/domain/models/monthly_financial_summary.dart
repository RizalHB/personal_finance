class MonthlyFinancialSummary {
  const MonthlyFinancialSummary({
    required this.year,
    required this.month,
    required this.totalIncomeMinor,
    required this.totalExpenseMinor,
    required this.netAmountMinor,
  });

  final int year;
  final int month;
  final int totalIncomeMinor;
  final int totalExpenseMinor;
  final int netAmountMinor;
}
