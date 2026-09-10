import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_finance/core/database/app_database.dart' as database;
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/core/utils/uuid_id_generator.dart';
import 'package:personal_finance/features/accounts/application/use_cases/create_account.dart';
import 'package:personal_finance/features/accounts/data/repositories/account_repository.dart';
import 'package:personal_finance/features/accounts/data/repositories/drift_account_repository.dart';
import 'package:personal_finance/features/accounts/domain/entities/account.dart';
import 'package:personal_finance/features/accounts/domain/services/account_validator.dart';
import 'package:personal_finance/core/database/database_connection.dart';

final appDatabaseProvider = Provider<database.AppDatabase>((ref) {
  final databaseInstance = database.AppDatabase(openConnection());

  ref.onDispose(databaseInstance.close);

  return databaseInstance;
});

final idGeneratorProvider = Provider<IdGenerator>((ref) {
  return UuidIdGenerator();
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final databaseInstance = ref.watch(appDatabaseProvider);
  final idGenerator = ref.watch(idGeneratorProvider);

  return DriftAccountRepository(databaseInstance, idGenerator);
});

final accountValidatorProvider = Provider<AccountValidator>((ref) {
  return const AccountValidator();
});

final createAccountProvider = Provider<CreateAccount>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  final validator = ref.watch(accountValidatorProvider);

  return CreateAccount(repository, validator);
});

final activeAccountsProvider = StreamProvider<List<Account>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);

  return repository.watchActiveAccounts();
});
