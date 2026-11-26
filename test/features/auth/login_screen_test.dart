import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/pages/login_screen.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthProvider provider;
  var signedIn = 0;
  var createAccount = 0;
  var forgotPassword = 0;

  setUp(() {
    repository = FakeAuthRepository();
    provider = AuthProvider(repository);
    signedIn = 0;
    createAccount = 0;
    forgotPassword = 0;
    addTearDown(provider.dispose);
    addTearDown(repository.dispose);
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: provider,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            cupertino.GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: LoginScreen(
            onSignedIn: () => signedIn++,
            onCreateAccount: () => createAccount++,
            onForgotPassword: () => forgotPassword++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, String email, String password) async {
    await tester.enterText(find.byKey(const ValueKey('login-email')), email);
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      password,
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows required-field errors and does not sign in', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(signedIn, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects a malformed email', (WidgetTester tester) async {
    await pumpLogin(tester);

    await submit(tester, 'not-an-email', 'password1');

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(signedIn, 0);
  });

  testWidgets('signs in and reports success', (WidgetTester tester) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await repository.signOut();
    await pumpLogin(tester);

    await submit(tester, ' A@B.co ', 'password1');

    expect(signedIn, 1);
    expect(provider.isSignedIn, isTrue);
    expect(find.byKey(const ValueKey('login-error')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an error for wrong credentials', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    await submit(tester, 'nobody@b.co', 'password1');

    expect(find.byKey(const ValueKey('login-error')), findsOneWidget);
    expect(find.text('Incorrect email or password'), findsOneWidget);
    expect(signedIn, 0);
  });

  testWidgets('editing a field hides the previous error', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);
    await submit(tester, 'nobody@b.co', 'password1');
    expect(find.byKey(const ValueKey('login-error')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'nobody@b.com',
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('login-error')), findsNothing);
  });

  testWidgets('the eye button shows and hides the password', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);
    final field = find.descendant(
      of: find.byKey(const ValueKey('login-password')),
      matching: find.byType(TextField),
    );

    expect(tester.widget<TextField>(field).obscureText, isTrue);

    await tester.tap(find.byKey(const ValueKey('login-toggle-password')));
    await tester.pump();

    expect(tester.widget<TextField>(field).obscureText, isFalse);
  });

  testWidgets('forgot-password and create-account buttons call back', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.byKey(const ValueKey('login-forgot')));
    await tester.tap(find.byKey(const ValueKey('login-create-account')));

    expect(forgotPassword, 1);
    expect(createAccount, 1);
  });

  testWidgets('renders in Arabic', (WidgetTester tester) async {
    await pumpLogin(tester, locale: const Locale('ar'));

    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}