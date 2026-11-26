import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/auth_flow.dart';
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
  bool? result;

  setUp(() {
    repository = FakeAuthRepository();
    provider = AuthProvider(repository);
    result = null;
    addTearDown(provider.dispose);
    addTearDown(repository.dispose);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
                  key: const ValueKey('open-auth'),
                  onPressed: () async {
                    result = await openAuthFlow(context);
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openFlow(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('open-auth')));
    await tester.pumpAndSettle();
  }

  final loginEmail = find.byKey(const ValueKey('login-email'));
  final signUpEmail = find.byKey(const ValueKey('signup-email'));

  testWidgets('signing in closes the flow and returns true', (
    WidgetTester tester,
  ) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await repository.signOut();
    await pumpApp(tester);

    await openFlow(tester);
    expect(loginEmail, findsOneWidget);

    await tester.enterText(loginEmail, 'a@b.co');
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'password1',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(loginEmail, findsNothing);
    expect(provider.isSignedIn, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backing out returns false', (WidgetTester tester) async {
    await pumpApp(tester);
    await openFlow(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(loginEmail, findsNothing);
    expect(provider.isSignedIn, isFalse);
  });

  testWidgets('creating an account closes the whole flow with true', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await openFlow(tester);

    await tester.tap(find.byKey(const ValueKey('login-create-account')));
    await tester.pumpAndSettle();
    expect(signUpEmail, findsOneWidget);

    await tester.enterText(signUpEmail, 'new@b.co');
    await tester.enterText(
      find.byKey(const ValueKey('signup-password')),
      'password1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('signup-confirm')),
      'password1',
    );
    await tester.tap(find.byKey(const ValueKey('signup-submit')));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(signUpEmail, findsNothing);
    expect(loginEmail, findsNothing);
    expect(provider.user?.email, 'new@b.co');
    expect(tester.takeException(), isNull);
  });

  testWidgets('"have an account" returns from sign-up to login', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await openFlow(tester);

    await tester.tap(find.byKey(const ValueKey('login-create-account')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('signup-have-account')));
    await tester.pumpAndSettle();

    expect(signUpEmail, findsNothing);
    expect(loginEmail, findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('forgot password opens the reset screen and returns', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await openFlow(tester);

    await tester.tap(find.byKey(const ValueKey('login-forgot')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reset-email')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reset-back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reset-email')), findsNothing);
    expect(loginEmail, findsOneWidget);
    expect(result, isNull);
  });
}