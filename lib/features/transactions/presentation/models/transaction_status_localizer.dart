import 'package:personal_finance/core/localization/generated/app_localizations.dart';

import '../../domain/entities/transaction.dart';

class TransactionStatusLocalizer {
  const TransactionStatusLocalizer();

  String label(TransactionStatus status, AppLocalizations localizations) {
    switch (status) {
      case TransactionStatus.posted:
        return localizations.transactionStatusPosted;
      case TransactionStatus.voided:
        return localizations.transactionStatusVoided;
    }
  }
}
