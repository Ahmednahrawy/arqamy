import 'package:arqamy/config/theme/dark_theme.dart';
import 'package:arqamy/config/theme/light_theme.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('light and dark themes define Material 3 color systems', () {
    expect(lightTheme.useMaterial3, isTrue);
    expect(darkTheme.useMaterial3, isTrue);
    expect(lightTheme.colorScheme.brightness, Brightness.light);
    expect(darkTheme.colorScheme.brightness, Brightness.dark);
    expect(lightTheme.colorScheme.error, isNot(darkTheme.colorScheme.error));
    expect(lightTheme.inputDecorationTheme.focusedBorder, isNotNull);
    expect(darkTheme.inputDecorationTheme.focusedBorder, isNotNull);
    expect(
      lightTheme.extension<AppSemanticColors>()?.success,
      LightColors.success,
    );
    expect(
      darkTheme.extension<AppSemanticColors>()?.success,
      DarkColors.success,
    );
  });

  test('legacy true is restored as dark without rewriting the legacy key',
      () async {
    SharedPreferences.setMockInitialValues({'isDarkMode': true});
    final provider = ThemeProvider();

    await provider.loadTheme();

    expect(provider.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isDarkMode'), isTrue);
    expect(prefs.getString('themeMode'), isNull);
  });

  test('legacy false is restored as light without rewriting the legacy key',
      () async {
    SharedPreferences.setMockInitialValues({'isDarkMode': false});
    final provider = ThemeProvider();

    await provider.loadTheme();

    expect(provider.themeMode, ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isDarkMode'), isFalse);
    expect(prefs.getString('themeMode'), isNull);
  });

  test('system mode persists and preserves the last explicit legacy setting',
      () async {
    SharedPreferences.setMockInitialValues({'isDarkMode': true});
    final provider = ThemeProvider();

    await provider.setThemeMode(ThemeMode.system);

    expect(provider.themeMode, ThemeMode.system);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'system');
    expect(prefs.getBool('isDarkMode'), isTrue);

    final restored = ThemeProvider();
    await restored.loadTheme();
    expect(restored.themeMode, ThemeMode.system);
  });

  testWidgets('theme changes dynamically and system mode follows brightness',
      (tester) async {
    final provider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: Builder(
              builder: (context) => Scaffold(
                body: Text(Theme.of(context).brightness.name),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('light'), findsOneWidget);

    await provider.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(find.text('dark'), findsOneWidget);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await provider.setThemeMode(ThemeMode.system);
    await tester.pumpAndSettle();
    expect(find.text('dark'), findsOneWidget);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(find.text('light'), findsOneWidget);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  });
}
