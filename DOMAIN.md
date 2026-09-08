Personal Finance — Financial Domain Specification

1. Purpose

This document defines the financial concepts, semantics, invariants, and business rules used by the Personal Finance application.

Financial correctness is a core product requirement.

The application is not a simple expense tracker. It is a personal financial management system whose financial state is represented through transactions and their resulting ledger effects.

2. Core Financial Model

The fundamental model is:

Business Transaction
        ↓
Financial Ledger Effects
        ↓
Accounts / Financial Positions
        ↓
Balances / Cash Flow / Net Worth / Reports

A transaction describes an economic event.

Ledger entries describe the financial consequences of that event.

The ledger is the authoritative financial representation.

3. Financial Classes

Financial accounts and ledger targets belong to one of these conceptual classes:

ASSET
LIABILITY
INCOME
EXPENSE
EQUITY / OPENING_BALANCE

Asset

Represents something owned or controlled financially.

Examples:

bank account;

cash;

savings account;

e-wallet;

investment account.

An increase in an asset is positive to the user's owned financial position.

Liability

Represents something owed.

Examples:

credit card balance;

personal loan;

payable debt.

An increase in liability increases the amount owed.

Income

Represents economic inflow that increases financial position.

Examples:

salary;

freelance income;

interest income.

Expense

Represents consumption or cost that reduces financial position.

Examples:

food;

transportation;

utilities;

bank fees.

Equity / Opening Balance

Represents initial financial position or balancing equity used to establish starting balances.

Opening balances are not treated as income.

4. User Accounts

An Account represents a financial location or position visible to the user.

Examples:

BCA;

Mandiri;

Cash;

Savings;

GoPay;

OVO;

Credit Card.

An account has a financial class.

Typical asset account:

BCA
class = ASSET

Typical liability account:

Credit Card
class = LIABILITY

Accounts have lifecycle states:

ACTIVE
ARCHIVED

Archived accounts remain available for historical records but should not normally be selectable for new transactions.

5. Opening Balance

Opening balance establishes the user's financial position when an account is created or initialized.

Example:

BCA opening balance = Rp2,000,000

This is not income.

Conceptually:

BCA Asset       +Rp2,000,000
Opening Equity  +Rp2,000,000

For an opening liability:

Credit Card Liability  +Rp2,000,000
Opening Equity         -Rp2,000,000

Changing an established opening balance should not silently rewrite financial history.

Corrections should use an explicit adjustment or reconciliation mechanism.

6. Money Representation

Money is represented as an integer amount in the smallest applicable currency unit.

For IDR:

Rp125.000 → 125000

Binary floating-point values must not be used for authoritative financial calculations.

Transaction amounts are stored as positive magnitudes.

Example:

amount = 500000
type = EXPENSE

Direction is represented by the transaction type and ledger effects.

Invalid conceptual state:

amount = -500000
type = EXPENSE

7. Currency

Every monetary value has an explicit currency context.

V1 defaults to:

IDR

The architecture must remain capable of supporting additional currencies in the future.

Cross-currency operations must never silently assume equality.

A future cross-currency transfer requires explicit exchange-rate/converted-amount information.

8. Transaction

A Transaction represents a business or economic event.

Core transaction types:

INCOME
EXPENSE
TRANSFER

A transaction should distinguish:

transaction_date
created_at
updated_at

transaction_date

The date/time at which the financial event occurred.

Used for:

reports;

budgets;

cash flow;

filtering;

historical ordering.

created_at

When the record was created in the application.

updated_at

When the record was last modified.

Reports should use the financial transaction date rather than the database creation timestamp.

9. Income

Income increases the user's financial position.

Example:

Salary = Rp10,000,000
Account = BCA

Financial effects:

BCA Asset       +Rp10,000,000
Salary Income   +Rp10,000,000

Income must not be represented as an expense or transfer.

10. Expense

Expense represents consumption or cost.

Example:

Food = Rp500,000
Account = BCA

Financial effects:

BCA Asset       -Rp500,000
Food Expense    +Rp500,000

The expense reduces available money and contributes to:

expense reports;

category totals;

budgets;

cash-flow calculations.

11. Transfer

A transfer moves money between owned accounts.

Example:

BCA → Savings
Rp1,000,000

Financial effects:

BCA Asset       -Rp1,000,000
Savings Asset   +Rp1,000,000

Transfers:

are not income;

are not expenses;

do not distort expense reports;

do not change total owned money.

Invariant:

Total owned money before transfer
=
Total owned money after transfer

Source and destination accounts must be different.

12. Transfer Atomicity

Transfers are atomic operations.

Conceptually:

BEGIN

Validate source
Validate destination
Validate amount
Create transfer transaction
Create source effect
Create destination effect

COMMIT

If any step fails:

ROLLBACK

The database must never contain a transfer with only one side persisted.

13. Account Balance

For a normal asset account:

Balance =
Opening Balance
+ Income
+ Transfers In
+ Refund Effects
+ Adjustments
- Expenses
- Transfers Out

The authoritative implementation should derive account balance from financial effects rather than maintaining unrelated manually updated balances.

Liability accounts use liability semantics rather than normal asset semantics.

14. Categories

Categories classify income and expenses.

Categories are hierarchical.

Example:

Food
├── Groceries
├── Restaurants
└── Delivery

Categories have a classification:

INCOME
EXPENSE

Transfers do not require normal income/expense categories.

Categories may be archived.

Historical transactions continue to reference archived categories.

15. Transaction Splits

An expense may contain multiple category splits.

Example:

Supermarket transaction = Rp500,000

Groceries       Rp400,000
Household       Rp100,000
-------------------------
Total           Rp500,000

Invariant:

sum(split amounts) = transaction amount

A split transaction must never persist with an incorrect total.

The UI should expose the remaining unallocated amount while the user is editing splits.

16. Merchant / Payee

Merchant or payee is a first-class domain entity.

Examples:

Tokopedia;

Indomaret;

PLN;

local restaurant;

employer.

A merchant may be:

created;

edited;

archived;

searched;

suggested during transaction entry.

Merchant history supports:

search;

reporting;

recurring transaction templates;

future automation.

17. Tags

Tags provide flexible many-to-many classification.

Examples:

work
vacation
family
reimbursement
important

One transaction may have many tags.

One tag may belong to many transactions.

Tags can be archived without destroying historical relationships.

18. Refunds

A refund reverses or reduces a previous expense.

Example:

Original expense:
Food = Rp200,000

Refund:
Rp50,000

The refund should reduce the effective expense by Rp50,000.

Where possible, the refund references the original transaction.

Refunds should not become unrelated income merely because money returns to an account.

19. Voiding and Deletion

Effective financial transactions should normally not be physically deleted.

Instead, they can be:

VOIDED

Voiding preserves history and provides an auditable state transition.

Permanent deletion may be permitted only for safe non-financial records or records that have never participated in financial history.

The distinction is:

Delete
=
Remove a record where safe.

Void
=
Preserve the record but remove its effective financial impact.

20. Transaction Editing

Editing a financial transaction must preserve financial correctness.

The system must not simply create a second financial effect while leaving the original effect active.

The operation must atomically:

reverse/correct the previous financial effect;

validate the new values;

apply the new financial effect;

update metadata.

Past generated recurring transactions are independent financial records and must not be rewritten when the recurring template changes.

21. Search and Filtering

Transaction history supports:

Keyword

merchant;

notes;

category names;

tags.

Filters

transaction type;

date range;

account;

category;

merchant;

tag;

amount range;

status.

Sorting

newest;

oldest;

highest amount;

lowest amount.

Filtering and sorting must be performed at the database/query layer for scalability.

22. Cash Flow

Cash flow describes movement of money during a period.

A simplified V1 view is:

Net Cash Flow =
Income
- Expenses

Transfers between owned accounts are excluded from net cash flow because they only relocate money.

More detailed future cash-flow reporting may distinguish operating, financing, and other categories where useful.

23. Net Worth

Net worth represents:

Net Worth = Total Assets - Total Liabilities

Examples:

Assets:
BCA          Rp5,000,000
Savings      Rp3,000,000

Liabilities:
Credit Card  Rp1,000,000

Net Worth = Rp7,000,000

A transfer between two asset accounts does not change net worth.

A credit-card purchase reduces net worth because an expense occurs while the liability increases.

24. Credit Cards

A credit card is modeled as a liability account.

A purchase:

Purchase = Rp500,000

creates:

Expense          +Rp500,000
Credit Liability +Rp500,000

The user's net worth decreases.

A credit-card payment:

BCA → Credit Card
Rp500,000

creates:

BCA Asset           -Rp500,000
Credit Liability    -Rp500,000

The payment is not another expense.

Credit-card domain concepts include:

credit limit;

outstanding balance;

available credit;

statement period;

due date;

minimum payment.

Advanced installment functionality may be added later.

25. E-Wallets

An e-wallet with a stored monetary balance is treated as an asset account.

Top-up:

BCA → E-Wallet
Rp500,000

is a transfer, not an expense.

Spending from the e-wallet:

E-Wallet → Food Expense
Rp100,000

is an expense.

This distinction prevents wallet top-ups from inflating expense reports.

26. Bank Fees

Bank fees are expenses.

Example:

BCA bank fee = Rp6,500

Financial effect:

BCA Asset       -Rp6,500
Bank Fee Expense +Rp6,500

27. Interest Income

Interest received is income.

Example:

Savings interest = Rp25,000

Financial effects:

Savings Asset       +Rp25,000
Interest Income     +Rp25,000

28. Debt and Receivables

Debt has two directional concepts:

PAYABLE
=
Money the user owes someone else.

RECEIVABLE
=
Money someone else owes the user.

A debt record is not an independent financial truth.

Its financial effects must be connected to actual transactions.

Money borrowed

If the user receives Rp5,000,000 as a loan:

Asset       +Rp5,000,000
Liability   +Rp5,000,000

It is not income.

Loan repayment

Suppose:

Principal = Rp900,000
Interest  = Rp100,000
Payment   = Rp1,000,000

Financial effects:

Bank Asset          -Rp1,000,000
Loan Liability      -Rp900,000
Interest Expense    +Rp100,000

Partial payments must be supported.

29. Goals

A financial goal represents an intended allocation or target.

Example:

Emergency Fund
Target = Rp20,000,000
Current = Rp8,000,000

Goals do not independently create money.

A virtual goal is therefore not itself an asset.

A contribution can optionally be linked to an actual transfer or transaction.

Goals may have:

ACTIVE
PAUSED
COMPLETED
CANCELLED

Important calculations:

Remaining = Target - Current
Progress = Current / Target

Required monthly contribution may be calculated from:

Remaining amount
÷
Remaining months

The exact behavior for overdue deadlines must be explicitly defined in implementation.

30. Budgets

V1 budgets are monthly.

A budget defines a planned spending amount for a category or category allocation.

Example:

Food budget = Rp2,000,000

Actual spending is based on qualifying expenses during the budget period.

Excluded from normal expense budget actuals:

transfers;

income;

opening balances;

unrelated adjustments.

Refunds reduce effective expense.

Budget calculations

Remaining =
Planned - Actual

and:

Usage % =
Actual / Planned × 100

Overspending occurs when:

Actual > Planned

V1 does not automatically roll unused budget into the following month.

Parent and child category allocations should not overlap unless the product explicitly supports that budgeting model.

31. Recurring Transactions

A recurring transaction is a schedule/template, not itself a financial transaction.

Example:

Monthly salary
Amount = Rp10,000,000
Day = 25

The schedule generates normal transactions.

Supported conceptual frequencies:

DAILY
WEEKLY
MONTHLY
YEARLY
CUSTOM

A schedule contains:

type;

amount;

account;

category;

merchant;

tags;

notes;

frequency;

start date;

optional end date;

next occurrence;

active state;

generation history.

Monthly day 31

If a monthly schedule targets day 31 and a month has fewer than 31 days, the occurrence uses the last valid day of that month.

Duplicate prevention

Generation must be idempotent.

The same schedule must not generate duplicate financial transactions for the same occurrence.

A schedule/occurrence identity should be used for duplicate prevention.

Editing schedules

Changing a recurring template affects future occurrences only.

Past generated transactions remain unchanged.

Editing a generated transaction does not modify the recurring template.

32. Bills

Bills represent obligations with due dates.

Bills are distinct from recurring transaction schedules.

Possible states:

UPCOMING
DUE
OVERDUE
PARTIALLY_PAID
PAID
CANCELLED

A bill may have:

fixed amount;

unknown/variable amount;

due date;

counterparty;

notes;

payment history.

Marking a bill as paid must not silently modify an account balance.

Payment must be connected to an actual financial transaction.

Partial payments are supported.

33. Assets

Not every asset needs to be an account.

Financial accounts represent directly tracked monetary balances.

Manual assets may represent:

vehicle;

property;

gold;

equipment;

other valuable property.

A manual asset may have:

estimated value;

valuation date;

notes.

V1 does not automatically calculate depreciation.

Future valuation snapshots can support historical net-worth reporting.

34. Adjustments and Reconciliation

Financial adjustments are explicit events.

The application must not silently overwrite an account balance.

Example:

Actual bank balance:

Rp2,050,000

Recorded balance:

Rp2,000,000

Difference:

Rp50,000

A reconciliation/adjustment event may record the difference explicitly.

This preserves the financial history and makes the correction explainable.

35. Financial Health

The application should avoid an opaque financial "score".

Instead it can expose transparent metrics such as:

savings rate;

expense ratio;

budget adherence;

emergency-fund coverage;

debt burden;

cash-flow consistency;

net-worth trend.

Each metric must have an understandable calculation.

36. Date and Time Semantics

Financial reporting is based on the user's financial calendar.

The application distinguishes:

transaction_date
created_at
updated_at

Transaction dates must not unexpectedly move to another calendar day because of UTC conversion.

Date filtering must respect the intended local financial date.

Standard monthly periods use:

first day of month
through
last day of month

Supported reporting periods include:

today;

this week;

this month;

last month;

this year;

custom range.

37. Data Integrity Invariants

The following invariants are mandatory.

Amount

amount > 0

for financial transaction magnitudes.

Split

sum(split amounts) = transaction amount

Transfer

source_account != destination_account

Transfer conservation

For a transfer between owned asset accounts:

Δ total owned money = 0

Atomicity

Multi-record financial operations must either fully succeed or fully fail.

Historical references

Historical transactions must remain understandable after related entities are archived.

Archived accounts

Archived accounts must not normally be used for new standard transactions.

Currency

Cross-currency financial operations require explicit currency conversion semantics.

Ledger integrity

Each financial transaction must produce valid and internally consistent ledger effects.

38. Reporting Rules

Reports must derive from financial effects rather than naïvely summing transaction rows.

Examples:

Expense report

Includes effective expense effects.

Excludes:

transfers;

income.

Refunds reduce effective expense.

Income report

Includes income effects.

Excludes transfers between owned accounts.

Net worth

Assets - Liabilities

Cash flow

Tracks actual inflow/outflow while avoiding double-counting internal transfers.

39. Daily User Flow

The primary expense-entry flow is optimized for speed:

+
↓
Pengeluaran
↓
Jumlah
↓
Kategori
↓
Rekening
↓
Merchant (optional)
↓
Tags (optional)
↓
Catatan (optional)
↓
Tanggal
↓
Simpan

Required information:

amount;

category;

account;

transaction date.

Optional information:

merchant;

tags;

notes.

The interface should prioritize one-handed Android usage and fast entry.

40. V1 Domain Scope

The portfolio V1 prioritizes:

financial ledger;

accounts;

income;

expenses;

transfers;

transaction splits;

refunds;

adjustments;

transaction voiding;

categories;

merchants;

tags;

transaction search/filtering;

monthly budgets;

recurring transactions;

dashboard;

reports;

cash flow;

net worth;

localization;

themes;

offline operation;

database migrations;

backup/restore;

automated testing.

41. Deferred Domain Scope

The following concepts remain architecturally considered but are not blockers for the initial portfolio implementation:

cloud synchronization;

user accounts;

multi-device synchronization;

Go backend;

PostgreSQL;

bank/open-banking integrations;

advanced credit-card installments;

advanced debt amortization;

automatic asset valuation;

advanced financial-health analysis;

web dashboard.

Bills, goals, debts, receivables, credit cards, and notifications may be implemented after the core financial system is stable.

42. Core Financial Examples

Expense

Initial BCA balance:
Rp1,000,000

Food expense:
Rp100,000

Final BCA balance:
Rp900,000

Transfer

BCA:
Rp2,000,000

Savings:
Rp0

Transfer:
Rp500,000

Final BCA:
Rp1,500,000

Final Savings:
Rp500,000

Total owned money:
Rp2,000,000

Income

BCA:
Rp1,000,000

Salary:
Rp5,000,000

Final BCA:
Rp6,000,000

Credit-card purchase

Credit card purchase:
Rp500,000

Expense:
+Rp500,000

Credit-card liability:
+Rp500,000

The purchase reduces net worth.

Credit-card payment

BCA → Credit Card:
Rp500,000

BCA:
-Rp500,000

Credit-card liability:
-Rp500,000

No additional expense is created.

43. Domain Design Goal

The domain model must make incorrect financial states difficult to create.

The system should favor:

explicit semantics
+
strong validation
+
atomic operations
+
historical preservation
+
reproducible calculations

over shortcuts that may make the UI or database simpler but introduce financial inconsistencies.