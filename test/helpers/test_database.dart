import 'package:drift/native.dart';

import 'package:personal_finance/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}