import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/pages/sign_up_screen.dart';
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
  var signedUp = 0;
  var haveAccount = 0;

  setUp(() {
    repository = FakeAuthRepository();
    provider = AuthProvider(repository);
    signedUp = 0;
    haveAccount = 0;
    addTearDown(provider.dispose);
    addTearDown(repository.dispose);
  });

  Future<void> pumpSignUp(
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
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: SignUpScreen(
            onSignedUp: () => signedUp++,
            onHaveAccount: () => haveAccount++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(
    WidgetTester tester, {
    required String email,
    required String password,
    required String confirm,
  }) async {
    await tester.enterText(find.byKey(const ValueKey('signup-email')), email);
    await tester.enterText(
      find.byKey(const ValueKey('signup-password')),
      password,
    );
    await tester.enterText(
      find.byKey(const ValueKey('signup-confirm')),
      confirm,
    );
    await tester.tap(find.byKey(const ValueKey('signup-submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows required-field errors and does not sign up', (
    WidgetTester tester,
  ) async {
    await pumpSignUp(tester);

    await tester.tap(find.byKey(const ValueKey('signup-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Confirm your password'), findsOneWidget);
    expect(signedUp, 0);
    expect(provider.isSignedIn, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects a password shorter than the minimum', (
    WidgetTester tester,
  ) async {
    await pumpSignUp(tester);

    await submit(
      tester,
      email: 'a@b.co',
      password: '1234567',
      confirm: '1234567',
    );

    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(signedUp, 0);
  });

  testWidgets('rejects a confirmation that does not match', (
    WidgetTester tester,
  ) async {
    await pumpSignUp(tester);

    await submit(
      tester,
      email: 'a@b.co',
      password: 'password1',
      confirm: 'password2',
    );

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(signedUp, 0);
    expect(provider.isSignedIn, isFalse);
  });

  testWidgets('creates the account and reports success', (
    WidgetTester tester,
  ) async {
    await pumpSignUp(tester);

    await submit(
      tester,
      email: ' A@B.co ',
      password: 'password1',
      confirm: 'password1',
    );

    expect(signedUp, 1);
    expect(provider.isSignedIn, isTrue);
    expect(repository.currentUser?.email, 'a@b.co');
    expect(find.byKey(const ValueKey('signup-error')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an error when the email is already registered', (
    WidgetTester tester,
  ) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await repository.signOut();
    await pumpSignUp(tester);

    await submit(
      tester,
      email: 'a@b.co',
      password: 'password2',
      confirm: 'password2',
    );

    expect(find.byKey(const ValueKey('signup-error')), findsOneWidget);
    expect(
      find.text('An account with this email already exists'),
      findsOneWidget,
    );
    expect(signedUp, 0);
  });

  testWidgets('shows a network error from the backend', (
    WidgetTester tester,
  ) async {
    repository.failNextWith = AuthFailureCode.networkUnavailable;
    await pumpSignUp(tester);

    await submit(
      tester,
      email: 'a@b.co',
      password: 'password1',
      confirm: 'password1',
    );

    expect(
      find.text('No internet connection. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(signedUp, 0);
  });

  testWidgets('editing a field hides the previous error', (
    WidgetTester tester,
  ) async {
    repository.failNextWith = AuthFailureCode.unknown;
    await pumpSignUp(tester);
    await submit(
      tester,
      email: 'a@b.co',
      password: 'password1',
      confirm: 'password1',
    );
    expect(find.byKey(const ValueKey('signup-error')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('signup-email')),
      'a@b.com',
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('signup-error')), findsNothing);
  });

  testWidgets('the eye button shows and hides both password fields', (
    WidgetTester tester,
  ) async {
    await pumpSignUp(tester);
    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );

    expect(tester.widget<TextField>(field('signup-password')).obscureText,
        isTrue);
    expect(
        tester.widget<TextField>(field('signup-confirm')).obscureText, isTrue);

    await tester.tap(find.byKey(const ValueKey('signup-toggle-password')));
    await tester.pump();

    expect(tester.widget<TextField>(field('signup-password')).obscureText,
        isFalse);
    expect(
        tester.widget<TextField>(field('signup-confirm')).obscureText, isFalse);
  });

  testWidgets('the sign-in button calls back', (WidgetTester tester) async {
    await pumpSignUp(tester);

    await tester.tap(find.byKey(const ValueKey('signup-have-account')));

    expect(haveAccount, 1);
  });

  testWidgets('renders in Arabic', (WidgetTester tester) async {
    await pumpSignUp(tester, locale: const Locale('ar'));

    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('تأكيد كلمة المرور'), findsOneWidget);
    expect(find.text('إنشاء حساب'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}