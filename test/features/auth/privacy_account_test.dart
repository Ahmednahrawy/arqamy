import 'package:arqamy/features/settingscreen/ui/pages/privacy_screen.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpPrivacy(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const PrivacyScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('English privacy screen explains the optional account', (
    WidgetTester tester,
  ) async {
    await pumpPrivacy(tester, const Locale('en'));

    expect(find.text('Optional account'), findsOneWidget);
    expect(find.textContaining('without an account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic privacy screen explains the optional account', (
    WidgetTester tester,
  ) async {
    await pumpPrivacy(tester, const Locale('ar'));

    expect(find.text('حساب اختياري'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}