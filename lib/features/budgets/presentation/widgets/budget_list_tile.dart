import 'package:flutter/material.dart';

import '../../domain/entities/budget.dart';

class BudgetListTile extends StatelessWidget {
  const BudgetListTile({required this.budget, required this.onTap, super.key});

  final Budget budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.account_balance_wallet_outlined),
      ),
      title: Text(budget.name),
      subtitle: Text(
        '${budget.year}-${budget.month.toString().padLeft(2, '0')}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
