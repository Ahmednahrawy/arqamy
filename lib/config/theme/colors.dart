import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.onSuccess,
    required this.onWarning,
  });

  final Color success;
  final Color warning;
  final Color onSuccess;
  final Color onWarning;

  static AppSemanticColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppSemanticColors>() ??
        (theme.brightness == Brightness.dark
            ? const AppSemanticColors(
                success: DarkColors.success,
                warning: DarkColors.warning,
                onSuccess: Color(0xFF003919),
                onWarning: Color(0xFF3D2600),
              )
            : const AppSemanticColors(
                success: LightColors.success,
                warning: LightColors.warning,
                onSuccess: Colors.white,
                onWarning: Colors.white,
              ));
  }

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? onSuccess,
    Color? onWarning,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      onSuccess: onSuccess ?? this.onSuccess,
      onWarning: onWarning ?? this.onWarning,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}

class ColorsManager {
  static const Color mainBlue = Color(0xFF247CFF);
  static const Color blue = Colors.blueAccent;
  static const Color lavander = Color.fromARGB(255, 59, 33, 114);
  static const Color lightBlue = Color(0xFFF4F8FF);
  static const Color darkBlue = Color(0xFF242424);
  static const Color gray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFC2C2C2);
  static const Color lighterGray = Color(0xFFEDEDED);
  static const Color moreLightGray = Color(0xFFFDFDFF);
  static const Color moreLighterGray = Color(0xFFF5F5F5);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color red = Colors.red;
}

class LightColors {
  static const Color primary = Color(0xFF1769AA);
  static const Color secondary = Color(0xFF087F8C);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEBF0F5);
  static const Color outline = Color(0xFF737D88);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF4F5B66);
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF287A45);
  static const Color warning = Color(0xFF8A5700);
  static const Color onPrimary = Colors.white;
}

/// Dark Theme Colors
class DarkColors {
  static const Color primary = Color(0xFF8BC7FF);
  static const Color secondary = Color(0xFF70D2D7);
  static const Color background = Color(0xFF111820);
  static const Color surface = Color(0xFF1A252F);
  static const Color surfaceContainer = Color(0xFF26333E);
  static const Color outline = Color(0xFF8997A3);
  static const Color textPrimary = Color(0xFFE5EDF4);
  static const Color textSecondary = Color(0xFFB8C5D0);
  static const Color error = Color(0xFFFFB4AB);
  static const Color success = Color(0xFF8AD5A0);
  static const Color warning = Color(0xFFFFC875);
  static const Color onPrimary = Color(0xFF003258);
}
