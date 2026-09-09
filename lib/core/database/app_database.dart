import 'package:drift/drift.dart';
import 'tables/accounts.dart';
import 'tables/bill_payments.dart';
import 'tables/bills.dart';
import 'tables/budget_allocations.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/goals.dart';
import 'tables/ledger_accounts.dart';
import 'tables/ledger_entries.dart';
import 'tables/merchants.dart';
import 'tables/recurring_transaction_occurrences.dart';
import 'tables/recurring_transactions.dart';
import 'tables/tags.dart';
import 'tables/transaction_splits.dart';
import 'tables/transaction_tags.dart';
import 'tables/transactions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LedgerAccounts,
    Accounts,
    Categories,
    Transactions,
    LedgerEntries,
    TransactionSplits,
    Merchants,
    Tags,
    TransactionTags,
    RecurringTransactions,
    RecurringTransactionOccurrences,
    Budgets,
    BudgetAllocations,
    Bills,
    BillPayments,
    Goals,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}