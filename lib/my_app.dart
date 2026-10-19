import 'package:arqamy/config/routes/app_router.dart';
import 'package:arqamy/config/routes/routes.dart';
import 'package:arqamy/config/theme/dark_theme.dart';
import 'package:arqamy/config/theme/light_theme.dart';
import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    final languageManager = Provider.of<Language>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        // to show performance while using app
        // showPerformanceOverlay: true,
        debugShowCheckedModeBanner: false,
        title: 'Arqamy',
        themeMode: themeProvider.themeMode,
        theme: lightTheme,
        darkTheme:darkTheme,
         // app respects the provider's locale direction (RTL for Arabic).
        builder: (BuildContext context, Widget? child) {
          final dir = languageManager.isArabic ? TextDirection.rtl : TextDirection.ltr;
          return Directionality(
            textDirection: dir,
            child: child ?? const SizedBox.shrink(),
          );
        },
        locale: languageManager.currentLocale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        initialRoute: Routes.orderScreen,
        onGenerateRoute: appRouter.generateRoute,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                S.of(context).page_not_found,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
