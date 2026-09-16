import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/localization/generated/app_localizations_en.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_localizer.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_presentation.dart';

void main() {
  test('resolves English transaction type labels', () {
    const localizer = TransactionTypeLocalizer();

    final localizations = AppLocalizationsEn();

    expect(
      localizer.label(TransactionTypePresentation.income, localizations),
      'Income',
    );

    expect(
      localizer.label(TransactionTypePresentation.expense, localizations),
      'Expense',
    );
  });
}
