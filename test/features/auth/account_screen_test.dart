import 'package:arqamy/features/auth/ui/pages/account_screen.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> openAccount(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const ValueKey('open-account'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-account')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows demo profile settings and no auth controls', (
    WidgetTester tester,
  ) async {
    await openAccount(tester);

    expect(find.byType(AccountScreen), findsOneWidget);
    expect(
      find.text(
        'Demo profile — these rows are placeholders for future settings.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ListTile, 'Name'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Notifications'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Privacy'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Help'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Log out'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Log in'), findsNothing);
    expect(find.text('@'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a demo row explains it is a placeholder', (
    WidgetTester tester,
  ) async {
    await openAccount(tester);

    const note =
        'Demo profile — these rows are placeholders for future settings.';
    await tester.tap(find.widgetWithText(ListTile, 'Name'));
    await tester.pumpAndSettle();

    expect(find.text(note), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
