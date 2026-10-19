
import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: DarkColors.primary,
  scaffoldBackgroundColor: DarkColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkColors.surface,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DarkColors.textPrimary),
    bodyLarge: TextStyle(fontSize: 16, color: DarkColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: DarkColors.textSecondary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkColors.primary,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DarkColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: DarkColors.primary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: DarkColors.secondary, width: 2),
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: DarkColors.primary,
    secondary: DarkColors.secondary,
    surface: DarkColors.surface,
    error: DarkColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: DarkColors.textPrimary,
    onError: Colors.black,
  ),
);
