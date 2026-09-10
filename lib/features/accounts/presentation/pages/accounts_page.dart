import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'create_account_page.dart';
import '../providers/account_providers.dart';
import '../widgets/account_list_tile.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(activeAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No accounts yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: accounts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return AccountListTile(account: accounts[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load accounts.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateAccountPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
