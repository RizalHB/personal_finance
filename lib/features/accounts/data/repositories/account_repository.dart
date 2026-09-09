import '../../domain/entities/account.dart';

abstract interface class AccountRepository {
  Future<Account> createAccount({
    required String name,
    required int financialClass,
    required int accountType,
    required String currencyCode,
    String? institutionName,
    String? iconCode,
    String? colorCode,
    String? notes,
  });

  Stream<List<Account>> watchActiveAccounts();

  Future<Account?> getAccountById(String id);

  Future<void> archiveAccount(String id);

  Future<void> restoreAccount(String id);
}
