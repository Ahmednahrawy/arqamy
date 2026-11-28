import 'package:arqamy/config/theme/dark_theme.dart';
import 'package:arqamy/config/theme/light_theme.dart';
import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/pages/forgot_password_screen.dart';
import 'package:arqamy/features/auth/ui/pages/login_screen.dart';
import 'package:arqamy/features/auth/ui/pages/sign_up_screen.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Switches between the sign-in flow and the application.
///
/// The auth screens themselves only report what happened, so this gate is the
/// missing app-level piece: it watches [AuthProvider] and shows the login flow
/// until a user is signed in. Sign-out from Settings then returns here too.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});

  /// The application to show once a user is signed in.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isSignedIn) return child;

    final language = context.watch<Language>();
    final theme = context.watch<ThemeProvider>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Arqamy',
        themeMode: theme.themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        locale: language.currentLocale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) {
          final direction = language.isArabic
              ? TextDirection.rtl
              : TextDirection.ltr;
          return Directionality(
            textDirection: direction,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const _RootAuthFlow(),
      ),
    );
  }
}

/// Login as the root route, with sign-up and reset pushed on top of it.
class _RootAuthFlow extends StatelessWidget {
  const _RootAuthFlow();

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      // The gate swaps to the app as soon as AuthProvider publishes the user.
      onSignedIn: () {},
      onCreateAccount: () {
        Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (signUpContext) => SignUpScreen(
              onSignedUp: () {},
              onHaveAccount: () => Navigator.of(signUpContext).pop(false),
            ),
          ),
        );
      },
      onForgotPassword: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (resetContext) => ForgotPasswordScreen(
              onBackToSignIn: () => Navigator.of(resetContext).pop(),
            ),
          ),
        );
      },
    );
  }
}
