import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/pages/account_screen.dart';
import 'package:arqamy/features/settingscreen/ui/pages/settings_screen.dart';
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

  Future<void> pumpSettings(
    WidgetTester tester, {
    required bool signedIn,
  }) async {
    if (signedIn) {
      await repository.signUp(email: 'a@b.co', password: 'password1');
    }
    provider = AuthProvider(repository);
    addTearDown(provider.dispose);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: provider),
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder tile(String title) => find.widgetWithText(ListTile, title);

  testWidgets('signed out: no email and no Log out entry', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester, signedIn: false);

    expect(tile('Profile'), findsOneWidget);
    expect(tile('Log out'), findsNothing);
    expect(find.text('a@b.co'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signed out: Profile opens the login screen', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester, signedIn: false);

    await tester.tap(tile('Profile'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);
  });

  testWidgets('signed in: shows the email and a Log out entry', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester, signedIn: true);

    expect(find.text('a@b.co'), findsOneWidget);
    expect(tile('Log out'), findsOneWidget);
  });

  testWidgets('signed in: Profile opens the account screen', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester, signedIn: true);

    await tester.tap(tile('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountScreen), findsOneWidget);
  });

  testWidgets('signed in: Log out asks, then signs out and hides itself', (
    WidgetTester tester,
  ) async {
    await pumpSettings(tester, signedIn: true);

    await tester.tap(tile('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(provider.isSignedIn, isFalse);
    expect(tile('Log out'), findsNothing);
    expect(find.text('a@b.co'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}