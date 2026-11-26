import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/pages/forgot_password_screen.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'fake_auth_repository.dart';

void main() {
  const sentMessage =
      'If an account exists for this email, a reset link has been sent.';

  late FakeAuthRepository repository;
  late AuthProvider provider;
  var backToSignIn = 0;

  setUp(() {
    repository = FakeAuthRepository();
    provider = AuthProvider(repository);
    backToSignIn = 0;
    addTearDown(provider.dispose);
    addTearDown(repository.dispose);
  });

  Future<void> pumpScreen(
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
          home: ForgotPasswordScreen(onBackToSignIn: () => backToSignIn++),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, String email) async {
    await tester.enterText(find.byKey(const ValueKey('reset-email')), email);
    await tester.tap(find.byKey(const ValueKey('reset-submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('requires an email', (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('reset-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(repository.passwordResetRequests, isEmpty);
    expect(find.byKey(const ValueKey('reset-sent')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects a malformed email', (WidgetTester tester) async {
    await pumpScreen(tester);

    await submit(tester, 'not-an-email');

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(repository.passwordResetRequests, isEmpty);
  });

  testWidgets('requests a reset link and shows the confirmation', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await submit(tester, ' A@B.co ');

    expect(repository.passwordResetRequests, ['a@b.co']);
    expect(find.byKey(const ValueKey('reset-sent')), findsOneWidget);
    expect(find.text(sentMessage), findsOneWidget);
    expect(find.byKey(const ValueKey('reset-error')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the same confirmation for an unknown account', (
    WidgetTester tester,
  ) async {
    await repository.signUp(email: 'known@b.co', password: 'password1');
    await repository.signOut();
    await pumpScreen(tester);

    await submit(tester, 'known@b.co');
    expect(find.text(sentMessage), findsOneWidget);

    await submit(tester, 'nobody@b.co');
    expect(find.text(sentMessage), findsOneWidget);
    expect(repository.passwordResetRequests, ['known@b.co', 'nobody@b.co']);
  });

  testWidgets('editing the email hides the confirmation', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);
    await submit(tester, 'a@b.co');
    expect(find.byKey(const ValueKey('reset-sent')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('reset-email')),
      'a@b.com',
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('reset-sent')), findsNothing);
  });

  testWidgets('shows an error and no confirmation when the request fails', (
    WidgetTester tester,
  ) async {
    repository.failNextWith = AuthFailureCode.networkUnavailable;
    await pumpScreen(tester);

    await submit(tester, 'a@b.co');

    expect(find.byKey(const ValueKey('reset-error')), findsOneWidget);
    expect(
      find.text('No internet connection. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('reset-sent')), findsNothing);
  });

  testWidgets('a retry after a failure succeeds and clears the error', (
    WidgetTester tester,
  ) async {
    repository.failNextWith = AuthFailureCode.tooManyRequests;
    await pumpScreen(tester);
    await submit(tester, 'a@b.co');
    expect(find.byKey(const ValueKey('reset-error')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reset-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reset-error')), findsNothing);
    expect(find.byKey(const ValueKey('reset-sent')), findsOneWidget);
  });

  testWidgets('the back button calls back', (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('reset-back')));

    expect(backToSignIn, 1);
  });

  testWidgets('renders in Arabic', (WidgetTester tester) async {
    await pumpScreen(tester, locale: const Locale('ar'));

    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('إرسال رابط إعادة التعيين'), findsOneWidget);
    expect(find.text('إعادة تعيين كلمة المرور'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}