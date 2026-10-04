import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/app/app_shell.dart';

void main() {
  testWidgets('displays primary navigation destinations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          pages: const [
            _TestPage(title: 'Dashboard Page'),
            _TestPage(title: 'Transactions Page'),
            _TestPage(title: 'Budgets Page'),
            _TestPage(title: 'Bills Page'),
            _TestPage(title: 'More Page'),
          ],
        ),
      ),
    );

    await tester.pump();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 0);
    expect(navigationBar.destinations, hasLength(5));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    expect(find.text('Dashboard Page'), findsOneWidget);
  });

  testWidgets('switches primary destinations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          pages: const [
            _TestPage(title: 'Dashboard Page'),
            _TestPage(title: 'Transactions Page'),
            _TestPage(title: 'Budgets Page'),
            _TestPage(title: 'Bills Page'),
            _TestPage(title: 'More Page'),
          ],
        ),
      ),
    );

    await tester.pump();

    Future<void> expectSelectedIndex(int expectedIndex) async {
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      expect(navigationBar.selectedIndex, expectedIndex);
    }

    await expectSelectedIndex(0);

    await tester.tap(find.text('Transactions'));
    await tester.pump();

    await expectSelectedIndex(1);
    expect(find.text('Transactions Page'), findsOneWidget);

    await tester.tap(find.text('Budgets'));
    await tester.pump();

    await expectSelectedIndex(2);
    expect(find.text('Budgets Page'), findsOneWidget);

    await tester.tap(find.text('Bills'));
    await tester.pump();

    await expectSelectedIndex(3);
    expect(find.text('Bills Page'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pump();

    await expectSelectedIndex(4);
    expect(find.text('More Page'), findsOneWidget);
  });

  testWidgets('More page contains secondary navigation entries', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MorePage()));

    await tester.pump();

    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Recurring Transactions'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}

class _TestPage extends StatelessWidget {
  const _TestPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
