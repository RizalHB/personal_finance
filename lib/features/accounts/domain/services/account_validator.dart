class AccountValidator {
  const AccountValidator();

  void validateCreate({
    required String name,
    required int financialClass,
    required int accountType,
    required String currencyCode,
    required int openingBalanceMinor,
  }) {
    final normalizedName = name.trim();
    final normalizedCurrencyCode = currencyCode.trim().toUpperCase();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Account name cannot be empty.');
    }

    if (normalizedName.length > 100) {
      throw ArgumentError('Account name cannot exceed 100 characters.');
    }

    if (financialClass != 1 && financialClass != 2) {
      throw ArgumentError('Invalid financial class.');
    }

    if (accountType < 1 || accountType > 7) {
      throw ArgumentError('Invalid account type.');
    }

    if (normalizedCurrencyCode.length != 3) {
      throw ArgumentError('Currency code must contain exactly 3 characters.');
    }

    if (openingBalanceMinor < 0) {
      throw ArgumentError('Opening balance cannot be negative.');
    }
  }
}
