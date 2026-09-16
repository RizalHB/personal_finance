Personal Finance — Application Architecture

1. Purpose

Personal Finance is an offline-first personal financial management application for Android, built with Flutter and Dart.

The application is designed as a portfolio-quality software project with emphasis on:

financial correctness;

maintainable architecture;

clear separation of responsibilities;

local-first data ownership;

testability;

database integrity;

accessibility;

localization;

future extensibility.

Version 1 does not require a backend, authentication service, cloud synchronization, or internet connectivity for core functionality.

The local SQLite database is the authoritative source of financial data.

2. Architecture Principles

The application follows these principles:

Financial correctness takes priority over implementation convenience.

UI code must not contain financial business rules.

Domain logic must be independently testable.

Database access must be isolated behind repositories/data sources.

Local SQLite data is the source of truth in V1.

Derived balances and reports must be reproducible from authoritative financial records.

Financial operations that modify multiple records must be atomic.

Historical financial records must be preserved.

User-facing strings must be localized.

Dependencies must be introduced only when they provide meaningful value.

Features should be independently maintainable.

Future synchronization/backend integration must not require rewriting the financial domain.

3. High-Level Architecture

The application follows a feature-oriented layered architecture.

                    Flutter UI
                       │
                       ▼
              Presentation Layer
                       │
                 Riverpod State
                       │
                       ▼
              Application / Domain
                       │
          ┌────────────┴────────────┐
          │                         │
   Domain Services             Repositories
          │                         │
          └────────────┬────────────┘
                       │
                       ▼
                  Data Layer
                       │
                 Drift / SQLite
                       │
                       ▼
                 Local Database

The dependency direction is:

Presentation
     ↓
Application / Domain
     ↓
Data abstractions
     ↓
Data implementations
     ↓
SQLite

Lower layers must not depend on Flutter UI widgets.

4. Project Structure

The application source code is organized by responsibility and feature.

lib/
├── app/
│   ├── app.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── core/
│   ├── database/
│   ├── errors/
│   ├── localization/
│   ├── security/
│   └── utilities/
│
├── features/
│   ├── dashboard/
│   ├── accounts/
│   ├── transactions/
│   ├── categories/
│   ├── budgets/
│   ├── recurring/
│   ├── reports/
│   ├── backup/
│   └── settings/
│
└── shared/
    ├── models/
    └── widgets/

Substantial features use internal layers:

feature/
├── data/
├── domain/
└── presentation/

Example:

features/
└── transactions/
    ├── data/
    │   ├── datasources/
    │   └── repositories/
    │
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── services/
    │
    └── presentation/
        ├── providers/
        ├── screens/
        └── widgets/

5. Presentation Layer

The presentation layer is responsible for:

screens;

widgets;

user interaction;

displaying state;

form validation feedback;

navigation;

accessibility;

localized presentation.

The presentation layer must not directly perform financial calculations or manipulate Drift tables.

For example, an expense screen should not calculate account balances directly.

Instead:

Expense Screen
      ↓
Riverpod Controller / Provider
      ↓
Transaction Application Service
      ↓
Repository
      ↓
Drift

6. Riverpod

Riverpod is responsible for application state and dependency injection.

Riverpod providers may expose:

repositories;

services;

database dependencies;

screen state;

filtered transaction queries;

dashboard summaries;

budget calculations;

settings.

Financial business rules belong in domain/application services rather than directly inside providers.

Providers should coordinate state and dependencies rather than become large business-logic containers.

7. Navigation

GoRouter is responsible for application navigation.

Primary navigation:

Beranda
Transaksi
Anggaran
Laporan
Pengaturan

The global quick-action button provides:

Pengeluaran
Pemasukan
Transfer

Navigation decisions must remain separate from financial domain logic.

8. Domain Layer

The domain layer contains financial concepts and rules that are independent of Flutter and SQLite.

Important domain concepts include:

Account;

Transaction;

Ledger Entry;

Transaction Split;

Category;

Merchant;

Tag;

Budget;

Recurring Transaction;

Bill;

Goal;

Debt;

Asset;

Liability.

Important domain services include operations such as:

create income;

create expense;

create transfer;

edit transaction;

void transaction;

create split transaction;

calculate budget status;

calculate net worth;

calculate cash flow;

generate recurring transactions.

The domain layer must enforce financial invariants.

9. Financial Ledger

The financial ledger is the authoritative representation of financial effects.

A business transaction describes what happened.

Ledger entries describe the financial consequences.

Example:

Transaction:
Expense — Food — Rp500,000

Ledger effects:
BCA Account       -Rp500,000
Food Expense      +Rp500,000

Transfer:

Transaction:
Transfer — BCA → Savings — Rp1,000,000

Ledger effects:
BCA Account       -Rp1,000,000
Savings Account   +Rp1,000,000

Transfers therefore do not become expenses or income.

The ledger model is intentionally double-entry-inspired while remaining user-friendly. Accounting terminology does not need to be exposed in the UI.

10. Money Representation

Money must never be represented internally using binary floating-point values.

For IDR:

Rp125.000 → 125000

Amounts are stored as integer minor units where appropriate.

Transactions store positive magnitudes:

amount = 500000
type = EXPENSE

The transaction type and ledger direction determine the financial effect.

This avoids contradictory states such as:

amount = -500000
type = EXPENSE

Currency is always explicit in the financial model.

11. Database Layer

Drift is used as the type-safe SQLite abstraction.

Responsibilities include:

table definitions;

queries;

indexes;

constraints;

transactions;

migrations;

generated database code.

The database layer must not become the location for application-level financial rules.

Complex financial operations are coordinated by application/domain services and persisted atomically through Drift transactions.

12. Repository Pattern

Repositories provide domain-facing access to persisted data.

Example:

TransactionRepository
AccountRepository
CategoryRepository
BudgetRepository
RecurringTransactionRepository

The domain/application layer depends on repository abstractions.

The data layer provides concrete implementations.

This creates a boundary that allows the future application to add:

Local SQLite
      ↓
Future synchronization layer
      ↓
Future Go API
      ↓
PostgreSQL

without coupling the financial domain directly to the backend.

13. Database Transactions and Atomicity

Any operation that changes multiple financial records must be atomic.

For example, a transfer must behave conceptually as:

BEGIN

Validate source account
Validate destination account
Validate amount
Create transfer transaction
Create source ledger effect
Create destination ledger effect

COMMIT

If any operation fails:

ROLLBACK

The database must never contain only half of a financial operation.

The same principle applies to:

transaction edits;

refunds;

split transactions;

debt payments;

bill payments;

goal-linked transfers;

recurring transaction generation.

14. Derived Data

Balances, reports, budget percentages, cash-flow summaries, and net worth are derived from authoritative financial records.

Derived caches may be introduced for performance, but they must be rebuildable.

The system should avoid multiple independent sources of truth for the same financial value.

For example:

Ledger
   ↓
Account Balance
   ↓
Dashboard
   ↓
Reports

rather than maintaining unrelated manually updated balance values.

15. Historical Data

Financial history is preserved.

Entities that have historical references should normally be archived rather than deleted.

Examples:

archived accounts remain available in historical transactions;

archived categories remain available to historical records;

archived merchants remain available in transaction history;

archived tags remain associated with historical transactions.

Permanent deletion is restricted to records where it is safe and explicitly supported.

Effective financial transactions should normally be voided rather than physically deleted.

16. Editing Financial Transactions

Editing a financial transaction is a financial correction.

The application must not accidentally apply the new transaction effect on top of the old one.

The correction must be performed atomically.

Conceptually:

BEGIN

Reverse previous financial effect
Validate new transaction
Apply new financial effect
Update transaction metadata

COMMIT

The exact implementation may use correction/reversal records depending on the final database design.

17. Search and Query Strategy

Transaction history must be database-driven.

Search/filtering must not load the entire transaction history into memory.

Supported filters include:

keyword;

transaction type;

date range;

account;

category;

merchant;

tag;

amount range;

status.

Indexes will be added according to actual query patterns.

Pagination or lazy loading should be used for large transaction histories.

The application should remain usable with:

10,000+
50,000+
100,000+

transactions.

18. Localization

The application supports:

Indonesian (id_ID) as the default;

English (en) as an additional language.

No user-facing string should be hard-coded directly into widgets.

Localization also covers:

dates;

currency;

number formatting;

validation messages;

notifications;

empty states;

error messages.

19. Theme

The application supports:

Light;

Dark;

System.

Material 3 is used as the design foundation.

Financial meaning must never depend exclusively on color.

For example, expense/income status should use combinations of:

labels;

icons;

typography;

numbers;

color.

20. Accessibility

The UI must support:

sufficiently large touch targets;

readable typography;

adequate contrast;

semantic labels;

screen-reader compatibility;

clear validation errors;

non-color-only status communication;

one-handed Android usage.

21. Offline-First Principle

Core financial operations must work without an internet connection.

The application must not require:

login;

cloud connectivity;

remote API access;

backend availability

for basic financial management.

Local SQLite is the V1 source of truth.

Future synchronization is an extension rather than a prerequisite.

22. Security Architecture

Security-sensitive functionality is isolated under:

lib/core/security/

Planned security capabilities include:

application PIN;

biometric authentication;

automatic locking;

Android Keystore integration;

secure credential storage;

encrypted backup.

Sensitive financial information should not be written to logs unnecessarily.

Secrets must never be committed to source control or embedded in the APK.

Encryption design will be documented before implementation.

23. Error Handling

The application distinguishes between:

validation errors;

domain rule violations;

database errors;

unexpected application errors;

recoverable user-facing errors.

Financial operations should fail safely.

A failed operation must not leave partially persisted financial effects.

User-facing error messages must be localized and understandable.

Technical exceptions should not be displayed directly to users.

24. Testing Architecture

Financial correctness is a high-priority testing area.

Tests should cover:

Domain tests

account balance;

income;

expenses;

transfers;

refunds;

voiding;

split transactions;

budget calculations;

recurring schedules;

net worth;

cash flow.

Database tests

foreign-key relationships;

constraints;

migrations;

atomic transactions;

query correctness;

indexes/query behavior where practical.

Widget tests

transaction forms;

validation;

dashboard states;

filtering;

budget presentation.

Integration tests

Critical end-to-end flows should be tested where practical.

25. Dependency Management

Dependencies are introduced conservatively.

Primary planned dependencies:

Dependency

Responsibility

Flutter/Dart

Application platform

Riverpod

State management and dependency injection

GoRouter

Navigation

Drift

SQLite persistence

fl_chart

Financial charts

Local notification package

Offline reminders

Before adding a dependency, the project should consider:

What problem does it solve?

Is it actually necessary?

Is there a simpler native solution?

What maintenance burden does it introduce?

What storage/build impact does it have?

Is it actively maintained and compatible with the current Flutter/Dart ecosystem?

26. Future Backend Boundary

V1 does not contain a backend.

The future architecture may support:

Flutter Application
        │
        ├── Local SQLite
        │
        └── Sync/API Layer
                │
                ▼
             Go API
                │
                ▼
           PostgreSQL

Future functionality may include:

user accounts;

authentication;

cloud backup;

multi-device synchronization;

conflict resolution;

web dashboard.

The local financial domain must remain independent of the backend implementation.

27. Architectural Quality Goals

The project should demonstrate:

separation of concerns;

domain-driven financial semantics;

dependency inversion;

repository abstraction;

type-safe persistence;

transactional integrity;

testability;

localization;

accessibility;

offline-first design;

future extensibility.

The goal is not to maximize architectural complexity.

The goal is to make the complexity that exists in financial software explicit, controlled, and testable.    