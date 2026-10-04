import 'package:flutter/material.dart';

import '../features/accounts/presentation/pages/accounts_page.dart';
import '../features/bills/presentation/pages/bills_page.dart';
import '../features/budgets/presentation/pages/budgets_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/recurring/presentation/pages/recurring_transactions_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({this.pages, super.key});

  final List<Widget>? pages;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  List<Widget> get _pages {
    return widget.pages ??
        const [
          DashboardPage(),
          TransactionListScreen(),
          BudgetsPage(),
          BillsPage(),
          MorePage(),
        ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_outlined),
            selectedIcon: Icon(Icons.receipt),
            label: 'Bills',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Accounts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AccountsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Recurring Transactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RecurringTransactionsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Reports'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ReportsPage()));
            },
          ),
        ],
      ),
    );
  }
}
