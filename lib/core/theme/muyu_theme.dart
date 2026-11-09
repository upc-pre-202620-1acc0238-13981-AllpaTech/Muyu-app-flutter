import 'package:flutter/material.dart';

import 'muyu_colors.dart';

/// Font families declared in pubspec.yaml.
abstract final class MuyuFonts {
  static const urbanist = 'Urbanist';
  static const fredoka = 'Fredoka';
}

/// Text styles reused across the auth flow, matching the Compose screens.
abstract final class MuyuTextStyles {
  static const screenTitle = TextStyle(
    fontFamily: MuyuFonts.fredoka,
    fontWeight: FontWeight.w600,
    fontSize: 32,
    color: MuyuColors.forest,
  );

  static const sheetLabel = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: Colors.white,
  );

  static const field = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.black,
  );

  static const primaryButton = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w700,
    fontSize: 24,
  );

  /// Product screens use Urbanist only; Fredoka is for the access flow titles.
  static const body = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: Colors.black,
  );

  static const bodySemiBold = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.black,
  );

  static const bodyBold = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Colors.black,
  );

  static const headerTitle = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: Colors.white,
  );

  static const welcomeLabel = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w300,
    fontSize: 20,
    color: MuyuColors.field,
  );

  static const welcomeName = TextStyle(
    fontFamily: MuyuFonts.urbanist,
    fontWeight: FontWeight.w900,
    fontSize: 24,
    color: MuyuColors.field,
  );
}

TextStyle _scale(double size, FontWeight weight) =>
    TextStyle(fontFamily: MuyuFonts.urbanist, fontSize: size, fontWeight: weight);

/// Sizes and weights from the Figma "Static" tokens. Line height and tracking
/// stay automatic, like the Muyu/Mobile text styles and the Kotlin app.
final _muyuTextTheme = TextTheme(
  displayLarge: _scale(57, FontWeight.w400),
  displayMedium: _scale(45, FontWeight.w400),
  displaySmall: _scale(36, FontWeight.w400),
  headlineLarge: _scale(32, FontWeight.w400),
  headlineMedium: _scale(28, FontWeight.w400),
  headlineSmall: _scale(24, FontWeight.w400),
  titleLarge: _scale(22, FontWeight.w400),
  titleMedium: _scale(16, FontWeight.w500),
  titleSmall: _scale(14, FontWeight.w500),
  labelLarge: _scale(14, FontWeight.w500),
  labelMedium: _scale(12, FontWeight.w500),
  labelSmall: _scale(11, FontWeight.w500),
  bodyLarge: _scale(16, FontWeight.w400),
  bodyMedium: _scale(14, FontWeight.w400),
  bodySmall: _scale(12, FontWeight.w400),
);

ThemeData buildMuyuTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: MuyuColors.olive,
    primary: MuyuColors.action,
    onPrimary: Colors.white,
    secondary: MuyuColors.lime,
    onSecondary: Colors.black,
    surface: MuyuColors.surface,
    error: MuyuColors.errorBorder,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MuyuColors.background,
    fontFamily: MuyuFonts.urbanist,
    textTheme: _muyuTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: MuyuColors.background,
      foregroundColor: MuyuColors.forest,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: MuyuFonts.urbanist,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: MuyuColors.forest,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: MuyuColors.forest,
    ),
    datePickerTheme: const DatePickerThemeData(
      headerBackgroundColor: MuyuColors.forest,
      headerForegroundColor: Colors.white,
    ),
  );
}
