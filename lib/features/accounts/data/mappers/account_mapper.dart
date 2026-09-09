import 'package:personal_finance/core/database/app_database.dart' as database;

import '../../domain/entities/account.dart';

extension AccountMapper on database.Account {
  Account toDomain() {
    return Account(
      id: id,
      name: name,
      financialClass: financialClass,
      accountType: accountType,
      currencyCode: currencyCode,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      institutionName: institutionName,
      iconCode: iconCode,
      colorCode: colorCode,
      notes: notes,
      archivedAt: archivedAt,
    );
  }
}
