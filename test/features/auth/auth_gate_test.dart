import 'package:arqamy/app/auth_gate.dart';
import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository repository;
  late AuthProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({'languageCode': 'en'});
    repository = FakeAuthRepository();
    addTearDown(repository.dispose);
  });

  Future<void> pumpGate(
    WidgetTester tester, {
    bool loadSkipPreference = false,
  }) async {
    // Create the provider here so a pre-seeded repository session is picked
    // up from currentUser, just like a real app restart.
    provider = AuthProvider(repository);
    addTearDown(provider.dispose);
    if (loadSkipPreference) await provider.loadSkipPreference();

    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: provider),
          ChangeNotifierProvider(create: (_) => Language()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const AuthGate(
          child: MaterialApp(home: Text('Application ready')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> signInFromLogin(WidgetTester tester) async {
    await tester.enterText(find.byKey(const ValueKey('login-email')), 'a@b.co');
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'password1',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('signed-out app starts on the login screen', (tester) async {
    await pumpGate(tester);

    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-password')), findsOneWidget);
    expect(find.text('Application ready'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signing in opens the app', (tester) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await repository.signOut();
    await pumpGate(tester);

    await signInFromLogin(tester);

    expect(provider.isSignedIn, isTrue);
    expect(find.text('Application ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-email')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signing out returns to the login screen', (tester) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await repository.signOut();
    await pumpGate(tester);
    await signInFromLogin(tester);
    expect(find.text('Application ready'), findsOneWidget);

    await provider.signOut();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);
    expect(find.text('Application ready'), findsNothing);
  });

  testWidgets('an existing session skips the login screen', (tester) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await pumpGate(tester);

    expect(find.text('Application ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-email')), findsNothing);
  });

  testWidgets('create account and password reset are reachable from login', (
    tester,
  ) async {
    await pumpGate(tester);

    await tester.tap(find.byKey(const ValueKey('login-create-account')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('signup-email')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('signup-have-account')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-forgot')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reset-email')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reset-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('language can be switched from the login app bar', (
    tester,
  ) async {
    await pumpGate(tester);
    expect(find.byKey(const ValueKey('language-picker')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('language-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arabic'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('languageCode'), 'ar');
    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skip opens the app as a guest and saves the choice', (
    tester,
  ) async {
    await pumpGate(tester);
    expect(find.byKey(const ValueKey('login-skip')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-skip')));
    await tester.pumpAndSettle();

    expect(provider.isSkipped, isTrue);
    expect(find.text('Application ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-email')), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AuthProvider.skipSignInKey), isTrue);
  });

  testWidgets('a saved skip opens the app without showing login again', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'languageCode': 'en',
      AuthProvider.skipSignInKey: true,
    });
    await pumpGate(tester, loadSkipPreference: true);

    expect(find.text('Application ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-email')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
