import 'package:personal_finance/core/localization/generated/app_localizations.dart';

import 'transaction_type_presentation.dart';

class TransactionTypeLocalizer {
  const TransactionTypeLocalizer();

  String label(
    TransactionTypePresentation type,
    AppLocalizations localizations,
  ) {
    switch (type) {
      case TransactionTypePresentation.income:
        return localizations.transactionTypeIncome;
      case TransactionTypePresentation.expense:
        return localizations.transactionTypeExpense;
      case TransactionTypePresentation.transfer:
        return localizations.transactionTypeTransfer;
      case TransactionTypePresentation.adjustment:
        return localizations.transactionTypeAdjustment;
      case TransactionTypePresentation.openingBalance:
        return localizations.transactionTypeOpeningBalance;
    }
  }
}
