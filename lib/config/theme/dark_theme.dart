import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Almarai',
  primaryColor: DarkColors.primary,
  scaffoldBackgroundColor: DarkColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkColors.surface,
    foregroundColor: DarkColors.textPrimary,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: DarkColors.textPrimary,
      fontFamily: 'Almarai',
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
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
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkColors.primary,
      foregroundColor: DarkColors.onPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: DarkColors.surface,
    hintStyle: TextStyle(color: DarkColors.textSecondary),
    labelStyle: TextStyle(color: DarkColors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: DarkColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: DarkColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: DarkColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: DarkColors.error),
    ),
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: DarkColors.primary,
    secondary: DarkColors.secondary,
    surface: DarkColors.surface,
    surfaceContainerHighest: DarkColors.surfaceContainer,
    outline: DarkColors.outline,
    error: DarkColors.error,
    onPrimary: Color(0xFF003258),
    onSecondary: Color(0xFF003739),
    onSurface: DarkColors.textPrimary,
    onSurfaceVariant: DarkColors.textSecondary,
    onError: Color(0xFF690005),
    primaryContainer: Color(0xFF004A78),
    onPrimaryContainer: Color(0xFFD1E4FF),
    secondaryContainer: Color(0xFF005054),
    onSecondaryContainer: Color(0xFFB7EEF0),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    tertiary: Color(0xFFD0BCFF),
    onTertiary: Color(0xFF381E72),
    tertiaryContainer: Color(0xFF4F378B),
    onTertiaryContainer: Color(0xFFEADDFF),
    surfaceTint: DarkColors.primary,
    inverseSurface: Color(0xFFE1E2E6),
    onInverseSurface: Color(0xFF2D3135),
    inversePrimary: Color(0xFF1769AA),
    shadow: Colors.black,
    scrim: Colors.black,
  ),
  dividerTheme:
      const DividerThemeData(color: DarkColors.outline, thickness: 0.6),
  cardTheme: const CardThemeData(
    color: DarkColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 1,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: DarkColors.surface,
    surfaceTintColor: Colors.transparent,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: DarkColors.surface,
    surfaceTintColor: Colors.transparent,
    showDragHandle: true,
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Color(0xFFE1E2E6),
    contentTextStyle: TextStyle(color: Color(0xFF2D3135)),
  ),
  iconTheme: const IconThemeData(color: DarkColors.textSecondary),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DarkColors.primary,
      side: const BorderSide(color: DarkColors.outline),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: DarkColors.primary),
  ),
  dataTableTheme: const DataTableThemeData(
    headingRowColor: WidgetStatePropertyAll(DarkColors.surfaceContainer),
    headingTextStyle: TextStyle(
      color: DarkColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    dataTextStyle: TextStyle(color: DarkColors.textPrimary),
    dividerThickness: 0.6,
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: DarkColors.surface,
    textStyle: TextStyle(color: DarkColors.textPrimary),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: DarkColors.primary,
    linearTrackColor: DarkColors.surfaceContainer,
  ),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: DarkColors.surface,
    headerBackgroundColor: DarkColors.primary,
    headerForegroundColor: DarkColors.onPrimary,
  ),
  disabledColor: const Color(0xFF66727D),
  extensions: const [
    AppSemanticColors(
      success: DarkColors.success,
      warning: DarkColors.warning,
      onSuccess: Color(0xFF003919),
      onWarning: Color(0xFF3D2600),
    ),
  ],
);
