import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/drawer/ui/side_nav.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = FakeAuthRepository();
    addTearDown(repository.dispose);
  });

  Future<void> pumpDrawer(WidgetTester tester) async {
    // Skip the Android in-app-update channel check in SideNav.initState.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    provider = AuthProvider(repository);
    addTearDown(provider.dispose);
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: provider),
          ChangeNotifierProvider(create: (_) => Language()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: Scaffold(
              key: scaffoldKey,
              body: const Center(child: Text('app')),
              drawer: const SideNav(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
  }

  Finder authTile() => find.byKey(const ValueKey('side-nav-auth'));

  testWidgets('guest sees Log in and it opens sign-in', (tester) async {
    await pumpDrawer(tester);

    expect(find.widgetWithText(ListTile, 'Log in'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Log out'), findsNothing);

    await tester.tap(authTile());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-email')), findsOneWidget);
  });

  testWidgets('a skipped guest can sign in from the drawer', (tester) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await repository.signOut();
    await pumpDrawer(tester);
    await provider.skipSignIn();
    await tester.pumpAndSettle();

    expect(provider.isSkipped, isTrue);
    await tester.tap(authTile());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('login-email')), 'a@b.co');
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'password1',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(provider.isSignedIn, isTrue);
    expect(provider.isSkipped, isFalse);
  });

  testWidgets('signed-in user sees Log out and it signs out', (tester) async {
    await repository.signUp(email: 'a@b.co', password: 'password1');
    await pumpDrawer(tester);

    expect(find.widgetWithText(ListTile, 'Log out'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Log in'), findsNothing);

    await tester.tap(authTile());
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(provider.isSignedIn, isFalse);
    expect(tester.takeException(), isNull);
  });
}
