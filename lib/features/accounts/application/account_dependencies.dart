import 'package:personal_finance/core/database/app_database.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/accounts/application/use_cases/create_account.dart';
import 'package:personal_finance/features/accounts/data/repositories/drift_account_repository.dart';
import 'package:personal_finance/features/accounts/domain/services/account_validator.dart';

class AccountDependencies {
  const AccountDependencies._();

  static CreateAccount createAccount({
    required AppDatabase database,
    required IdGenerator idGenerator,
  }) {
    final repository = DriftAccountRepository(database, idGenerator);

    const validator = AccountValidator();

    return CreateAccount(repository, validator);
  }
}
