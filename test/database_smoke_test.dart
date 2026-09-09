import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_database.dart';

void main() {
  test('database opens successfully', () async {
    final database = createTestDatabase();

    await database.close();
  });
}