import '../../data/repositories/account_repository.dart';
import '../../domain/entities/account.dart';
import '../../domain/services/account_validator.dart';

class CreateAccount {
  const CreateAccount(this._repository, this._validator);

  final AccountRepository _repository;
  final AccountValidator _validator;

  Future<Account> execute({
    required String name,
    required int financialClass,
    required int accountType,
    required String currencyCode,
    required int openingBalanceMinor,
    String? institutionName,
    String? iconCode,
    String? colorCode,
    String? notes,
  }) {
    _validator.validateCreate(
      name: name,
      financialClass: financialClass,
      accountType: accountType,
      currencyCode: currencyCode,
      openingBalanceMinor: openingBalanceMinor,
    );

    return _repository.createAccount(
      name: name.trim(),
      financialClass: financialClass,
      accountType: accountType,
      currencyCode: currencyCode.trim().toUpperCase(),
      openingBalanceMinor: openingBalanceMinor,
      institutionName: institutionName?.trim(),
      iconCode: iconCode,
      colorCode: colorCode,
      notes: notes?.trim(),
    );
  }
}
