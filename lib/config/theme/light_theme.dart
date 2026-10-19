import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: ColorsManager.mainBlue,
  scaffoldBackgroundColor: LightColors.background,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LightColors.textPrimary),
    bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: LightColors.textSecondary),
    titleLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 16, color: LightColors.textPrimary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: LightColors.primary,
    foregroundColor: LightColors.background,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: LightColors.surface, // A good choice for text on a primary background
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LightColors.primary,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LightColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LightColors.primary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LightColors.secondary, width: 2),
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: LightColors.primary,
    secondary: LightColors.secondary,
    surface: LightColors.surface,
    error: LightColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: LightColors.textPrimary,
    onError: Colors.white,
  ),
);
