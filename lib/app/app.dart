import 'package:flutter/material.dart';
import 'package:personal_finance/core/localization/generated/app_localizations.dart';
import 'package:personal_finance/features/accounts/presentation/pages/accounts_page.dart';

class PersonalFinanceApp extends StatelessWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AccountsPage(),
    );
  }
}
