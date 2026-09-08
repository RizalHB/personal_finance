DATABASE.md

Personal Finance — Database Specification

1. Purpose

This document defines the persistent database contract for the Personal Finance application.

The database is designed for:

offline-first operation

financial correctness

historical data preservation

deterministic reporting

atomic financial operations

schema evolution through migrations

future synchronization without rewriting the domain model

SQLite is the local source of truth.

Drift is the persistence and query layer used by the Flutter application.

2. Database Principles

2.1 Source of truth

Financial truth is represented by:

Transactions
    ↓
Ledger Entries
    ↓
Financial Positions
    ↓
Balances / Reports / Budgets / Net Worth / Cash Flow

Account balances, net worth, cash flow, and reporting values must not depend on manually maintained balance fields.

Derived values may be cached for performance, but every derived value must be rebuildable from authoritative records.

2.2 Money representation

All authoritative financial amounts use integer smallest currency units.

For IDR:

Rp125.000
      ↓
125000

Never use floating-point numbers for authoritative monetary values.

Database column:

INTEGER

Typical invariant:

CHECK (amount_minor > 0)

For non-negative derived/value fields:

CHECK (amount_minor >= 0)

2.3 Currency

Currency is explicitly stored using an ISO-style currency code.

V1:

IDR

Examples:

IDR
USD
EUR

V1 does not support cross-currency financial transactions.

Currency precision must not be hard-coded globally because currencies do not universally share the same decimal precision.

2.4 IDs

Application-generated IDs use text identifiers.

Recommended format:

UUID

or another collision-resistant stable identifier.

IDs must not depend on database insertion order.

2.5 Timestamps

System timestamps use:

INTEGER

representing Unix epoch milliseconds.

Examples:

created_at
updated_at
archived_at
voided_at

Financial event dates require special handling and must preserve the user's financial calendar date.

The application must not accidentally move a transaction to another calendar day because of UTC conversion.

3. Enum Storage Strategy

Enums are stored as stable integer codes.

Do not use Dart enum ordinal positions.

Example:

enum TransactionType {
  income(1),
  expense(2),
  transfer(3),
  adjustment(4);

  const TransactionType(this.code);

  final int code;
}

The integer code becomes part of the database contract.

Never reuse an old code for a different semantic meaning.

If an enum value is removed in the future, its old code remains reserved.

Unknown enum codes must be treated as unsupported/corrupt data rather than silently mapped by index.

4. Enum Registry

4.1 TransactionType

Code

Value

1

INCOME

2

EXPENSE

3

TRANSFER

4

ADJUSTMENT

4.2 TransactionStatus

Code

Value

1

POSTED

2

VOIDED

4.3 FinancialClass

Code

Value

1

ASSET

2

LIABILITY

4.4 AccountType

Code

Value

1

CASH

2

BANK

3

E_WALLET

4

SAVINGS

5

CREDIT_CARD

6

INVESTMENT

7

OTHER

4.5 LedgerAccountKind

Code

Value

1

ASSET

2

LIABILITY

3

INCOME

4

EXPENSE

5

EQUITY

4.6 EntrySide

Code

Value

1

DEBIT

2

CREDIT

4.7 CategoryType

Code

Value

1

INCOME

2

EXPENSE

4.8 EntityStatus

Code

Value

1

ACTIVE

2

ARCHIVED

Individual domains may define more specific lifecycle enums where necessary.

5. Core Ledger Architecture

The application uses a unified internal ledger account model.

                    ledger_accounts
                         |
          +--------------+--------------+
          |              |              |
       accounts       categories      system

Examples:

BCA
→ ASSET ledger account

Food
→ EXPENSE ledger account

Salary
→ INCOME ledger account

Opening Balance Equity
→ EQUITY ledger account

This allows financial effects to use one consistent ledger mechanism.

6. Table: ledger_accounts

Internal financial ledger accounts.

Columns

Column

Type

Null

Description

id

TEXT

NO

Primary key

kind

INTEGER

NO

LedgerAccountKind

code

TEXT

NO

Stable internal code

name

TEXT

NO

Internal display name

is_system

INTEGER

NO

0 or 1

status

INTEGER

NO

Lifecycle status

created_at

INTEGER

NO

Creation timestamp

updated_at

INTEGER

NO

Last update timestamp

archived_at

INTEGER

YES

Archive timestamp

Constraints

PRIMARY KEY (id)
UNIQUE (code)
CHECK (is_system IN (0, 1))

System ledger accounts cannot be removed by normal application operations.

7. Table: accounts

User-facing financial accounts.

Examples:

BCA
Mandiri
GoPay
OVO
Savings
BCA Credit Card

Columns

Column

Type

Null

Description

id

TEXT

NO

Primary key

ledger_account_id

TEXT

NO

Related ledger account

name

TEXT

NO

Account name

account_type

INTEGER

NO

AccountType

financial_class

INTEGER

NO

ASSET or LIABILITY

institution_name

TEXT

YES

Bank/institution

currency_code

TEXT

NO

Currency

icon_code

TEXT

YES

UI icon identifier

color_code

TEXT

YES

UI color identifier

notes

TEXT

YES

User notes

status

INTEGER

NO

ACTIVE/ARCHIVED

created_at

INTEGER

NO

Creation timestamp

updated_at

INTEGER

NO

Update timestamp

archived_at

INTEGER

YES

Archive timestamp

Constraints

PRIMARY KEY (id)
UNIQUE (ledger_account_id)

Foreign key:

ledger_account_id → ledger_accounts.id

One user account maps to exactly one internal ledger account.

8. Opening Balance

There is intentionally no:

accounts.opening_balance_minor

Opening balance is represented as a financial event.

Example:

BCA
+ Rp5.000.000

Ledger effect:

BCA Asset              DEBIT   5.000.000
Opening Balance Equity CREDIT  5.000.000

This ensures opening balances participate in the same financial history as all other financial events.

Changing an opening balance must be performed through an explicit adjustment/reconciliation process.

It must never silently overwrite historical data.

9. Table: categories

Hierarchical income and expense categories.

Columns

Column

Type

Null

Description

id

TEXT

NO

Primary key

ledger_account_id

TEXT

NO

Related ledger account

parent_id

TEXT

YES

Parent category

name

TEXT

NO

Category name

category_type

INTEGER

NO

INCOME/EXPENSE

icon_code

TEXT

YES

UI icon

color_code

TEXT

YES

UI color

sort_order

INTEGER

NO

Display order

status

INTEGER

NO

ACTIVE/ARCHIVED

created_at

INTEGER

NO

Creation timestamp

updated_at

INTEGER

NO

Update timestamp

archived_at

INTEGER

YES

Archive timestamp

Constraints

PRIMARY KEY (id)
UNIQUE (ledger_account_id)

Foreign keys:

ledger_account_id → ledger_accounts.id
parent_id → categories.id

A category can have children.

Category cycles are prohibited.

Example:

Food
├── Restaurant
├── Groceries
├── Delivery
└── Other

Every major seeded category should have an Other child category.

Other is a normal persisted category and may be renamed, archived, or supplemented with additional categories.

10. Default Category Taxonomy

V1 should provide a practical Indonesian-oriented starting taxonomy.

Expense categories

Food
├── Restaurant
├── Groceries
├── Delivery
└── Other

Transportation
├── Fuel
├── Public Transport
├── Ride Hailing
├── Parking
├── Maintenance
└── Other

Shopping
├── Clothing
├── Electronics
├── Household
├── Personal Care
└── Other

Bills & Utilities
├── Electricity
├── Water
├── Internet
├── Phone
└── Other

Health
├── Medicine
├── Doctor
├── Hospital
├── Dental
└── Other

Entertainment
├── Movies
├── Games
├── Streaming
├── Events
└── Other

Education
├── Tuition
├── Books
├── Courses
└── Other

Housing
├── Rent
├── Maintenance
├── Furniture
└── Other

Financial
├── Bank Fees
├── Interest
├── Taxes
└── Other

Personal
├── Gifts
├── Donations
├── Family
└── Other

Other Expenses
└── Other

Income categories

Salary
├── Main Salary
├── Bonus
└── Other

Business
├── Sales
├── Services
└── Other

Investment Income
├── Dividends
├── Interest
├── Capital Gain
└── Other

Other Income
└── Other

Transfers do not require expense categories.

The application must allow users to create their own categories.

11. Table: merchants

Payees/merchants.

Columns

Column

Type

Null

id

TEXT

NO

name

TEXT

NO

status

INTEGER

NO

created_at

INTEGER

NO

updated_at

INTEGER

NO

archived_at

INTEGER

YES

Constraints:

PRIMARY KEY (id)

Indexes:

(name)
(status)

Merchants should normally be archived rather than deleted when referenced by historical transactions.

12. Table: tags

Flexible user-defined labels.

Columns

Column

Type

Null

id

TEXT

NO

name

TEXT

NO

status

INTEGER

NO

created_at

INTEGER

NO

updated_at

INTEGER

NO

archived_at

INTEGER

YES

Constraints:

PRIMARY KEY (id)
UNIQUE (name)

13. Table: transactions

Represents a business/economic event.

Columns

Column

Type

Null

Description

id

TEXT

NO

Primary key

type

INTEGER

NO

TransactionType

status

INTEGER

NO

TransactionStatus

transaction_date

INTEGER

NO

Financial event date

amount_minor

INTEGER

NO

Positive magnitude

currency_code

TEXT

NO

Transaction currency

merchant_id

TEXT

YES

Merchant

description

TEXT

YES

Notes/description

recurring_transaction_id

TEXT

YES

Generating schedule

related_transaction_id

TEXT

YES

Related/reversal transaction

created_at

INTEGER

NO

System creation time

updated_at

INTEGER

NO

Last update

voided_at

INTEGER

YES

Void timestamp

Constraints:

PRIMARY KEY (id)
CHECK (amount_minor > 0)

Foreign keys:

merchant_id → merchants.id
recurring_transaction_id → recurring_transactions.id
related_transaction_id → transactions.id

related_transaction_id is intentionally generic enough to support relationships such as refunds and reversals while preserving explicit domain semantics in application logic.

14. Transaction Date vs System Timestamps

These fields have different meanings:

transaction_date
created_at
updated_at

transaction_date answers:

When did this financial event occur?

created_at answers:

When did the application create this record?

updated_at answers:

When was this record last changed?

Reports use transaction_date.

System auditing uses created_at and updated_at.

15. Table: transaction_splits

Allows one financial transaction to contain multiple categories.

Example:

Supermarket transaction
Rp500.000

Food/Groceries       Rp350.000
Household/Other      Rp150.000

Columns

Column

Type

Null

id

TEXT

NO

transaction_id

TEXT

NO

category_id

TEXT

NO

amount_minor

INTEGER

NO

note

TEXT

YES

sort_order

INTEGER

NO

created_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
CHECK (amount_minor > 0)

Foreign keys:

transaction_id → transactions.id
category_id → categories.id

Indexes:

(transaction_id)
(category_id)

Domain invariant:

SUM(split amounts) == transaction.amount_minor

A transaction cannot be posted while its split total differs from the transaction amount.

16. Table: transaction_tags

Many-to-many transaction/tag relationship.

Columns

Column

Type

transaction_id

TEXT

tag_id

TEXT

Primary key:

(transaction_id, tag_id)

Foreign keys:

transaction_id → transactions.id
tag_id → tags.id

Junction records may be deleted when the parent transaction is removed from a transient/unposted workflow.

Posted transaction history remains protected by application rules.

17. Table: ledger_entries

Represents the actual financial effect of a transaction.

Columns

Column

Type

Null

id

TEXT

NO

transaction_id

TEXT

NO

ledger_account_id

TEXT

NO

entry_side

INTEGER

NO

amount_minor

INTEGER

NO

currency_code

TEXT

NO

created_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
CHECK (amount_minor > 0)

Foreign keys:

transaction_id → transactions.id
ledger_account_id → ledger_accounts.id

Indexes:

(transaction_id)
(ledger_account_id)
(ledger_account_id, created_at)

18. Ledger Invariants

Every POSTED transaction must satisfy:

number of ledger entries >= 2

and:

SUM(DEBIT) == SUM(CREDIT)

Examples:

Expense

Food Expense       DEBIT   50.000
BCA Asset          CREDIT  50.000

Income

BCA Asset          DEBIT   10.000.000
Salary Income      CREDIT  10.000.000

Transfer

Savings Asset      DEBIT   1.000.000
BCA Asset          CREDIT  1.000.000

Credit-card purchase

Food Expense       DEBIT   100.000
Credit Card        CREDIT  100.000

Loan payment

Loan Liability     DEBIT   1.000.000
Interest Expense   DEBIT     100.000
Bank Asset         CREDIT  1.100.000

These rules are fundamental financial invariants.

19. Transaction Status and Deletion

Posted transactions must not normally be physically deleted.

Instead:

POSTED → VOIDED

Voiding preserves historical information.

Physical deletion is only appropriate for invalid/transient records before they become part of the posted financial history.

The UI must distinguish:

Delete

from:

Void / Reverse

20. Refunds and Reversals

Refunds should be represented as explicit financial events linked to the original transaction.

Example:

Original:
Food Expense Rp100.000

Refund:
Food Expense reduction Rp100.000

The application should preserve:

original transaction
↕
refund/reversal transaction

A refund must not silently become unrelated income.

Refund amount cannot exceed the refundable amount of the original expense.

21. Editing Posted Transactions

Editing a posted financial transaction must not simply overwrite ledger entries in a way that changes historical effects without trace.

The application should perform an atomic operation equivalent to:

reverse old financial effect
        +
apply corrected financial effect

Both operations must succeed together or fail together.

22. Transfer Atomicity

A transfer consists of:

source account
destination account
amount
transaction
ledger entries

Required invariants:

source != destination
amount > 0
source account is valid
destination account is valid

Operation must be atomic:

BEGIN
  validate
  create transaction
  create source ledger entry
  create destination ledger entry
COMMIT

Any failure:

ROLLBACK

A partially-created transfer must never exist.

23. Table: budgets

V1 monthly budget container.

Columns

Column

Type

Null

id

TEXT

NO

year

INTEGER

NO

month

INTEGER

NO

name

TEXT

YES

status

INTEGER

NO

created_at

INTEGER

NO

updated_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
UNIQUE (year, month)
CHECK (month BETWEEN 1 AND 12)

V1 supports one primary budget per month.

No automatic rollover.

24. Table: budget_allocations

Category-level budget targets.

Columns

Column

Type

Null

id

TEXT

NO

budget_id

TEXT

NO

category_id

TEXT

NO

planned_amount_minor

INTEGER

NO

created_at

INTEGER

NO

updated_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
UNIQUE (budget_id, category_id)
CHECK (planned_amount_minor > 0)

Budget rules:

Actual = qualifying expenses - refunds
Remaining = planned - actual
Percentage = actual / planned * 100

Excluded:

transfers
income
opening balances
normal adjustments

V1 does not allow simultaneous parent and child allocations unless explicit aggregation semantics are later introduced.

25. Recurring Transactions

Recurring schedules are templates.

They are not themselves financial transactions.

26. Table: recurring_transactions

Columns

Column

Type

Null

id

TEXT

NO

type

INTEGER

NO

amount_minor

INTEGER

NO

currency_code

TEXT

NO

account_id

TEXT

NO

category_id

TEXT

YES

merchant_id

TEXT

YES

description

TEXT

YES

frequency

INTEGER

NO

start_date

INTEGER

NO

end_date

INTEGER

YES

next_occurrence_date

INTEGER

NO

amount_mode

INTEGER

NO

status

INTEGER

NO

created_at

INTEGER

NO

updated_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
CHECK (amount_minor > 0)

Foreign keys:

account_id → accounts.id
category_id → categories.id
merchant_id → merchants.id

27. Recurring Frequency Registry

Code

Value

1

DAILY

2

WEEKLY

3

MONTHLY

4

YEARLY

5

CUSTOM

Amount mode:

Code

Value

1

FIXED

2

USER_ENTERED

Monthly schedules must handle invalid calendar dates.

Example:

31 January
→ 28/29 February

depending on the year.

28. Table: recurring_transaction_occurrences

Provides idempotency and generation history.

Columns

Column

Type

Null

id

TEXT

NO

recurring_transaction_id

TEXT

NO

occurrence_date

INTEGER

NO

transaction_id

TEXT

NO

created_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
UNIQUE (recurring_transaction_id, occurrence_date)

Foreign keys:

recurring_transaction_id → recurring_transactions.id
transaction_id → transactions.id

The unique occurrence constraint prevents duplicate generation.

Editing a recurring template does not rewrite past generated transactions.

29. Bills

Bills represent obligations.

They are separate from recurring transactions.

A recurring transaction answers:

What financial transaction should be generated?

A bill answers:

What obligation is currently due?

30. Table: bills

Columns

Column

Type

Null

id

TEXT

NO

name

TEXT

NO

amount_minor

INTEGER

YES

currency_code

TEXT

NO

due_date

INTEGER

NO

status

INTEGER

NO

notes

TEXT

YES

created_at

INTEGER

NO

updated_at

INTEGER

NO

cancelled_at

INTEGER

YES

Amount may be NULL when the bill amount is unknown or variable.

31. Bill Status Registry

Code

Value

1

UPCOMING

2

DUE

3

OVERDUE

4

PARTIALLY_PAID

5

PAID

6

CANCELLED

32. Table: bill_payments

Payments link bills to actual financial transactions.

Columns

Column

Type

Null

id

TEXT

NO

bill_id

TEXT

NO

transaction_id

TEXT

NO

amount_minor

INTEGER

NO

paid_at

INTEGER

NO

created_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
CHECK (amount_minor > 0)

Foreign keys:

bill_id → bills.id
transaction_id → transactions.id

Payment status is derived from actual payments.

Marking a bill as paid must not silently modify an account balance.

The actual transaction is responsible for the financial effect.

33. Debts and Receivables

Debt records describe obligations.

They are not independent sources of financial truth.

Actual financial effects must still be represented through transactions and ledger entries.

34. Table: debts

Columns

Column

Type

Null

id

TEXT

NO

debt_type

INTEGER

NO

counterparty_name

TEXT

NO

principal_minor

INTEGER

NO

currency_code

TEXT

NO

interest_minor

INTEGER

NO

fee_minor

INTEGER

NO

outstanding_minor

INTEGER

NO

start_date

INTEGER

NO

due_date

INTEGER

YES

status

INTEGER

NO

notes

TEXT

YES

created_at

INTEGER

NO

updated_at

INTEGER

NO

Debt type:

Code

Value

1

PAYABLE

2

RECEIVABLE

Status:

Code

Value

1

ACTIVE

2

PARTIALLY_SETTLED

3

SETTLED

4

CANCELLED

outstanding_minor is treated as a derived/cache field and must be rebuildable from authoritative payment records.

35. Table: debt_payments

Columns

Column

Type

Null

id

TEXT

NO

debt_id

TEXT

NO

transaction_id

TEXT

NO

principal_minor

INTEGER

NO

interest_minor

INTEGER

NO

fee_minor

INTEGER

NO

paid_at

INTEGER

NO

created_at

INTEGER

NO

Constraints:

CHECK (principal_minor >= 0)
CHECK (interest_minor >= 0)
CHECK (fee_minor >= 0)
CHECK (
  principal_minor +
  interest_minor +
  fee_minor > 0
)

Loan payment example:

Bank                  CREDIT  1.100.000
Loan Liability        DEBIT   1.000.000
Interest Expense      DEBIT     100.000

36. Goals

Goals are planning entities.

They do not independently increase or decrease net worth.

37. Table: goals

Columns

Column

Type

Null

id

TEXT

NO

name

TEXT

NO

target_amount_minor

INTEGER

NO

current_amount_minor

INTEGER

NO

currency_code

TEXT

NO

deadline

INTEGER

YES

status

INTEGER

NO

created_at

INTEGER

NO

updated_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
CHECK (target_amount_minor > 0)
CHECK (current_amount_minor >= 0)

Status:

Code

Value

1

ACTIVE

2

PAUSED

3

COMPLETED

4

CANCELLED

38. Table: goal_contributions

Columns

Column

Type

Null

id

TEXT

NO

goal_id

TEXT

NO

transaction_id

TEXT

YES

amount_minor

INTEGER

NO

contribution_type

INTEGER

NO

contributed_at

INTEGER

NO

created_at

INTEGER

NO

Contribution type:

Code

Value

1

CONTRIBUTION

2

WITHDRAWAL

A goal may be virtual or connected to actual financial transactions.

39. Assets

Manual assets represent non-account assets whose value is estimated separately.

Examples:

House
Motorcycle
Gold
Property
Other asset

40. Table: assets

Columns

Column

Type

Null

id

TEXT

NO

name

TEXT

NO

asset_type

INTEGER

NO

currency_code

TEXT

NO

current_value_minor

INTEGER

NO

valuation_date

INTEGER

NO

status

INTEGER

NO

notes

TEXT

YES

created_at

INTEGER

NO

updated_at

INTEGER

NO

Asset type:

Code

Value

1

PROPERTY

2

VEHICLE

3

GOLD

4

INVESTMENT

5

OTHER

Value must be:

>= 0

41. Table: asset_valuations

Historical valuation snapshots.

Columns

Column

Type

Null

id

TEXT

NO

asset_id

TEXT

NO

value_minor

INTEGER

NO

valuation_date

INTEGER

NO

created_at

INTEGER

NO

Constraints:

PRIMARY KEY (id)
CHECK (value_minor >= 0)

Index:

(asset_id, valuation_date)

This allows historical net-worth reporting later.

42. Table: app_settings

Simple application configuration.

Columns

Column

Type

Null

key

TEXT

NO

value

TEXT

NO

updated_at

INTEGER

NO

Primary key:

(key)

Example values:

locale = id_ID
theme = system
default_currency = IDR

User-facing settings must never be hard-coded into business logic.

43. Foreign Key Policy

SQLite foreign keys must be enabled.

Conceptually:

PRAGMA foreign_keys = ON;

Recommended behavior:

Transaction → ledger entries

Cascade may be used for transient invalid transactions.

Application logic prohibits deletion of posted transactions.

Transaction → splits

Cascade is appropriate.

Transaction → transaction_tags

Cascade is appropriate.

Category parent

Restrict deletion.

Category cycles are additionally prevented by domain logic.

Merchant references

Prefer archive rather than deletion.

Related transaction

Restrict deletion.

Historical relationships must not disappear unexpectedly.

44. Indexing Strategy

Indexes must support actual application queries.

Initial important indexes:

accounts(status)

categories(category_type, status)
categories(parent_id)

merchants(name)
merchants(status)

tags(name)

transactions(transaction_date)
transactions(status)
transactions(type)
transactions(account-related ledger lookup)
transactions(merchant_id)
transactions(recurring_transaction_id)
transactions(related_transaction_id)

transaction_splits(transaction_id)
transaction_splits(category_id)

ledger_entries(transaction_id)
ledger_entries(ledger_account_id)
ledger_entries(ledger_account_id, created_at)

transaction_tags(tag_id)

budget_allocations(budget_id)
budget_allocations(category_id)

recurring_transactions(status)
recurring_transactions(next_occurrence_date)

recurring_transaction_occurrences(
    recurring_transaction_id,
    occurrence_date
)

bill_payments(bill_id)
debt_payments(debt_id)
goal_contributions(goal_id)

asset_valuations(asset_id, valuation_date)

Indexes should be added based on real query patterns rather than indiscriminately applied to every column.

45. Database-Level vs Domain-Level Rules

SQLite/Drift should enforce structural constraints wherever practical.

Database responsibilities

PRIMARY KEY
FOREIGN KEY
NOT NULL
UNIQUE
CHECK
INDEX

Domain/application responsibilities

posted transaction has >= 2 ledger entries
debit == credit
split total == transaction amount
transfer source != destination
transfer atomicity
refund <= refundable original amount
category hierarchy has no cycles
parent/child budget overlap rules
posted transaction cannot be physically deleted
opening balance semantics
financial class semantics
currency compatibility
valid transaction/category combinations

The database must not become the only place where business rules exist.

Business rules must remain testable in Dart.

46. Account Balance Calculation

For an asset account:

Balance =
    Debits
  - Credits

For a liability account, presentation semantics must reflect the amount owed rather than simply exposing raw debit/credit arithmetic.

The domain layer owns the final account-balance interpretation.

The UI must not independently calculate financial balances.

47. Net Worth

Basic net worth:

Total Assets - Total Liabilities

Example:

Assets       Rp20.000.000
Liabilities   Rp5.000.000
-------------------------
Net Worth    Rp15.000.000

Transfers do not change net worth.

48. Cash Flow

Cash flow measures movement during a selected period.

Transfers between owned accounts are not income or expense.

Reports must distinguish:

Income
Expense
Transfer
Net Cash Flow

from:

Net Worth

They are different financial concepts.

49. Budget Actual Calculation

For an expense category:

Actual =
    qualifying posted expenses
  - qualifying refunds

Exclude:

VOIDED transactions
TRANSFERS
INCOME
OPENING BALANCE
normal adjustments

The exact query logic belongs to the repository/domain reporting layer and must be covered by tests.

50. Category Lifecycle

Categories are historical financial dimensions.

If a category has historical transactions:

ARCHIVE

rather than:

DELETE

Archived categories:

remain visible in historical records

are excluded from normal new-transaction selection

may be restored

A category may only be permanently deleted when it has no dependent historical data and domain rules permit deletion.

51. Account Lifecycle

Accounts follow:

ACTIVE
    ↓
ARCHIVED
    ↓
RESTORED

Archived accounts:

remain in historical records

do not appear in normal new transaction selection

can be restored

Used accounts must not be permanently deleted.

52. Merchant and Tag Lifecycle

Merchants and tags use archive semantics when historical relationships exist.

Historical transactions retain their original relationships.

53. Migration Policy

Database schema version starts at:

1

Every structural schema change requires a migration.

Example:

v1 → v2
v2 → v3
v3 → v4

Never replace an existing production database with destructive:

DROP TABLE
CREATE TABLE

unless the migration explicitly preserves all required data.

Each migration must be:

deterministic

testable

reversible where practical

documented

compatible with existing stored data

Schema version and backup format version are separate concepts.

54. Migration Testing

Every migration should have automated coverage for:

old schema
    ↓
migration
    ↓
new schema
    ↓
data preserved

Important test cases:

existing accounts remain valid

existing transactions remain valid

ledger entries remain balanced

archived entities remain archived

enum codes retain their meaning

indexes/constraints exist

newly introduced fields receive valid values

55. Seed Data

The application may seed initial system data on first database creation.

Seed data includes:

System ledger accounts

Examples:

Opening Balance Equity

Additional system accounts may be introduced if required by domain behavior.

Default categories

Indonesian-friendly categories should be supplied.

Every major category should include:

Other

Example:

Food
├── Restaurant
├── Groceries
├── Delivery
└── Other

Seed data must be idempotent.

Running initialization twice must not create duplicate categories or system ledger accounts.

56. Localization of Seeded Categories

Database records should use stable identifiers.

User-facing category names must support localization.

The application should avoid making English or Indonesian display text the permanent semantic identity of a category.

Recommended future-friendly approach:

stable category code
        ↓
localized display name

Example conceptual value:

food
food.restaurant
food.groceries
food.delivery
food.other

The database can then preserve stable semantic identity while the UI displays:

Food
Makanan

depending on locale.

57. Backup Compatibility

Backup format is independent from SQLite schema version.

Example:

Database schema: v4
Backup format: v1

A future database schema may still export to an older compatible backup format where supported.

Backups should contain:

format_version
exported_at
app_version
currency metadata
application settings
accounts
categories
merchants
tags
transactions
splits
tags relationships
ledger entries
budgets
recurring schedules
occurrences
bills
payments
debts
goals
assets

Backup restoration must validate:

IDs
foreign keys
enum codes
money values
currencies
ledger balance
transaction/split totals
required relationships

A corrupt backup must not partially overwrite the existing database.

Restore should occur through a controlled import transaction or isolated temporary database followed by validation.

58. Financial Integrity Verification

The application should provide an internal integrity-check mechanism.

It should detect conditions such as:

unbalanced transaction
missing ledger entry
invalid category relationship
split total mismatch
invalid foreign key
negative amount where prohibited
unknown enum code
invalid transfer
broken recurring occurrence

This is particularly valuable for a portfolio project because it demonstrates defensive financial software engineering.

59. Atomicity

Any operation that modifies multiple financial records must be atomic.

Examples:

Create expense
Create income
Create transfer
Create refund
Edit posted transaction
Void transaction
Generate recurring transaction
Pay bill
Record debt payment
Restore backup

Conceptual pattern:

BEGIN TRANSACTION

validate domain
write records
verify invariants

COMMIT

Failure:

ROLLBACK

60. Repository Boundary

The application architecture must not expose raw Drift tables throughout the UI.

Preferred flow:

Presentation
      ↓
Application / Use Case
      ↓
Repository Interface
      ↓
Drift Repository
      ↓
SQLite

Example:

CreateTransferUseCase
        ↓
TransactionRepository
        ↓
LedgerRepository
        ↓
Database transaction

This keeps financial behavior testable and allows future data sources.

61. Future Synchronization Compatibility

V1 is local-only.

Future architecture may introduce:

Flutter App
    ↓
Repository
    ↓
Local SQLite
    ↓
Sync Engine
    ↓
API
    ↓
Go Backend
    ↓
PostgreSQL

The V1 database therefore uses stable IDs and explicit timestamps.

Do not design V1 around assumptions that require a server-generated integer ID.

62. Security Considerations

Sensitive financial data remains local in V1.

The application should:

minimize unnecessary logging

never log financial records in production

never log secrets

validate imported backup files

protect backup handling

avoid exposing database paths unnecessarily

prepare for optional app lock/biometric protection

Database encryption may be considered later if justified by the final product requirements.

63. Testing Requirements

Database/domain implementation must include tests for:

Ledger

expense balances
income balances
transfer conservation
credit-card purchase
loan payment
opening balance
refund
void

Transactions

positive amount
valid dates
status transitions
editing
duplicate prevention

Splits

sum == transaction amount
zero/negative rejection
category compatibility

Categories

parent-child relationship
cycle prevention
archive behavior
Other category

Budgets

actual calculation
refund handling
transfer exclusion
parent/child overlap
monthly uniqueness

Recurring

daily
weekly
monthly
yearly
31st-day handling
missed occurrences
idempotency

Database

foreign keys
unique constraints
CHECK constraints
migrations
backup restore

64. Core Invariants Summary

The following invariants are mandatory:

amount_minor > 0

for positive financial amounts.

posted transaction
→ >= 2 ledger entries

SUM(DEBIT) == SUM(CREDIT)

for every posted transaction.

SUM(transaction splits) == transaction amount

for split transactions.

transfer source != destination

posted financial history is not physically deleted

historically referenced entities are archived rather than deleted

recurring schedule + occurrence date
→ unique

one budget per month in V1

parent/child budget overlap
→ prohibited in V1

category hierarchy
→ acyclic

derived values
→ rebuildable

65. Final Database Philosophy

The database should make the following statement true:

The application can reconstruct the user's financial position from historical financial events without relying on manually maintained balances.

The most important chain is:

Business Event
      ↓
Transaction
      ↓
Ledger Entries
      ↓
Financial Position
      ↓
Reports / Budgets / Net Worth / Cash Flow

This architecture deliberately favors correctness and auditability over shortcuts.

The UI is a presentation of financial state.

The ledger is the financial source of truth.

The domain layer protects financial invariants.

SQLite provides durable local persistence.

Drift provides typed queries and migration management.

The architecture remains suitable for future synchronization without requiring a rewrite of the core financial model.