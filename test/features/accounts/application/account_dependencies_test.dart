import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/core/database/app_database.dart';
import 'package:personal_finance/core/utils/id_generator.dart';
import 'package:personal_finance/features/accounts/application/account_dependencies.dart';

class FakeIdGenerator implements IdGenerator {
  @override
  String generate() => 'test-id';
}

void main() {
  test('creates CreateAccount use case', () {
    final database = AppDatabase.test();
    final idGenerator = FakeIdGenerator();

    final useCase = AccountDependencies.createAccount(
      database: database,
      idGenerator: idGenerator,
    );

    expect(useCase, isNotNull);

    database.close();
  });
}
