import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/pages/account_screen.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthProvider provider;

  setUp(() {
    repository = FakeAuthRepository();
    addTearDown(repository.dispose);
  });

  /// Signs in, then opens the account screen on top of a home page, so that
  /// popping it after sign-out is possible.
  Future<void> openAccount(WidgetTester tester) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    provider = AuthProvider(repository);
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: MaterialApp(
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
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-account')));
    await tester.pumpAndSettle();
  }

  Future<void> tapSignOut(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('account-sign-out')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the signed-in email', (WidgetTester tester) async {
    await openAccount(tester);

    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.text('a@b.co'), findsOneWidget);
    expect(find.byKey(const ValueKey('account-sign-out')), findsOneWidget);
  });

  testWidgets('confirming sign-out signs out and leaves the screen', (
    WidgetTester tester,
  ) async {
    await openAccount(tester);

    await tapSignOut(tester);
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(provider.isSignedIn, isFalse);
    expect(find.byType(AccountScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling keeps the user signed in', (
    WidgetTester tester,
  ) async {
    await openAccount(tester);

    await tapSignOut(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(provider.isSignedIn, isTrue);
    expect(find.byType(AccountScreen), findsOneWidget);
  });

  testWidgets('a failed sign-out shows a message and stays', (
    WidgetTester tester,
  ) async {
    await openAccount(tester);
    repository.failNextWith = AuthFailureCode.networkUnavailable;

    await tapSignOut(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(
      find.text('No internet connection. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(provider.isSignedIn, isTrue);
    expect(find.byType(AccountScreen), findsOneWidget);
  });
}