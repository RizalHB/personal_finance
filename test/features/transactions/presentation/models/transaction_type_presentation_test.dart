import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/domain/transaction_type.dart';
import 'package:personal_finance/features/transactions/presentation/models/transaction_type_presentation.dart';

void main() {
  group('TransactionTypePresentation', () {
    test('maps every transaction type', () {
      for (final type in TransactionType.values) {
        final presentation = TransactionTypePresentation.fromType(type);

        expect(presentation.type, type);
      }
    });

    test('uses stable localization keys', () {
      expect(
        TransactionTypePresentation.fromType(TransactionType.income)
            .localizationKey,
        'income',
      );

      expect(
        TransactionTypePresentation.fromType(TransactionType.expense)
            .localizationKey,
        'expense',
      );

      expect(
        TransactionTypePresentation.fromType(TransactionType.openingBalance)
            .localizationKey,
        'opening_balance',
      );
    });
  });
}
