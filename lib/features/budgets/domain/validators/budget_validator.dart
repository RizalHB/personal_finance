class BudgetValidator {
  const BudgetValidator();

  void validateCreate({
    required int year,
    required int month,
    required String name,
  }) {
    if (year < 2000 || year > 2100) {
      throw ArgumentError('Year must be between 2000 and 2100.');
    }

    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12.');
    }

    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Budget name cannot be empty.');
    }

    if (normalizedName.length > 100) {
      throw ArgumentError('Budget name cannot exceed 100 characters.');
    }
  }
}
