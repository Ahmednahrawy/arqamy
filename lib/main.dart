import 'package:arqamy/app/auth_gate.dart';
import 'package:arqamy/app/bootstrap/app_bootstrap.dart';
import 'package:arqamy/config/routes/app_router.dart';
import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/features/auth/data/firebase_auth_repository.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/settingscreen/providers/invoice_setting_provider.dart';
import 'package:arqamy/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Make sure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // await Future.delayed(const Duration(milliseconds: 300));
  // Prevent duplicate Firebase initialization
  // Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  final themeProvider = ThemeProvider();
  try {
    await themeProvider.loadTheme();
  } catch (error) {
    debugPrint('Theme preference loading error: $error');
  }

  final invoiceProvider = InvoiceProvider();
  final invoiceSettings = InvoiceSettingsProvider();
  try {
    await invoiceSettings.loadSettings();
  } catch (error) {
    debugPrint('Could not load invoice settings: $error');
  }

  final authProvider = AuthProvider(FirebaseAuthRepository());
  try {
    await authProvider.loadSkipPreference();
  } catch (error) {
    debugPrint('Could not load sign-in skip preference: $error');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Language()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: invoiceProvider),
        ChangeNotifierProvider.value(value: invoiceSettings),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: AuthGate(
        child: AppBootstrap(
          invoiceProvider: invoiceProvider,
          child: MyApp(appRouter: AppRouter()),
        ),
      ),
    ),
  );
}
