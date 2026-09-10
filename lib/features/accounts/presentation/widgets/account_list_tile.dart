import 'package:flutter/material.dart';

import '../../domain/entities/account.dart';

class AccountListTile extends StatelessWidget {
  const AccountListTile({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.account_balance_wallet_outlined),
      ),
      title: Text(account.name),
      subtitle: Text(account.currencyCode),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
