import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Almarai',
  primaryColor: LightColors.primary,
  scaffoldBackgroundColor: LightColors.background,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
    labelLarge: TextStyle(fontWeight: FontWeight.w600),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: LightColors.primary,
    foregroundColor: LightColors.onPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontFamily: 'Almarai',
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LightColors.primary,
      foregroundColor: LightColors.onPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: LightColors.surface,
    hintStyle: TextStyle(color: LightColors.textSecondary),
    labelStyle: TextStyle(color: LightColors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: LightColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: LightColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: LightColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: LightColors.error),
    ),
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: LightColors.primary,
    secondary: LightColors.secondary,
    surface: LightColors.surface,
    surfaceContainerHighest: LightColors.surfaceContainer,
    outline: LightColors.outline,
    error: LightColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: LightColors.textPrimary,
    onSurfaceVariant: LightColors.textSecondary,
    onError: Colors.white,
    primaryContainer: Color(0xFFD4E8FF),
    onPrimaryContainer: Color(0xFF001D35),
    secondaryContainer: Color(0xFFB7EEF0),
    onSecondaryContainer: Color(0xFF002022),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    tertiary: Color(0xFF65558F),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEADDFF),
    onTertiaryContainer: Color(0xFF21005D),
    surfaceTint: LightColors.primary,
    inverseSurface: Color(0xFF2D3135),
    onInverseSurface: Color(0xFFF0F0F0),
    inversePrimary: Color(0xFF9ECAFF),
    shadow: Colors.black,
    scrim: Colors.black,
  ),
  dividerTheme:
      const DividerThemeData(color: LightColors.outline, thickness: 0.6),
  cardTheme: const CardThemeData(
    color: LightColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 1,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: LightColors.surface,
    surfaceTintColor: Colors.transparent,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: LightColors.surface,
    surfaceTintColor: Colors.transparent,
    showDragHandle: true,
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Color(0xFF2D3135),
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: LightColors.textSecondary),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: LightColors.primary,
      side: const BorderSide(color: LightColors.outline),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: LightColors.primary),
  ),
  dataTableTheme: const DataTableThemeData(
    headingRowColor: WidgetStatePropertyAll(LightColors.surfaceContainer),
    headingTextStyle: TextStyle(
      color: LightColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    dataTextStyle: TextStyle(color: LightColors.textPrimary),
    dividerThickness: 0.6,
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: LightColors.surface,
    textStyle: TextStyle(color: LightColors.textPrimary),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: LightColors.primary,
    linearTrackColor: LightColors.surfaceContainer,
  ),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: LightColors.surface,
    headerBackgroundColor: LightColors.primary,
    headerForegroundColor: LightColors.onPrimary,
  ),
  disabledColor: const Color(0xFF9AA3AB),
  extensions: const [
    AppSemanticColors(
      success: LightColors.success,
      warning: LightColors.warning,
      onSuccess: Colors.white,
      onWarning: Colors.white,
    ),
  ],
);
