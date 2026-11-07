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
}

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
    appBarTheme: const AppBarTheme(
      backgroundColor: MuyuColors.background,
      foregroundColor: MuyuColors.forest,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: MuyuFonts.fredoka,
        fontWeight: FontWeight.w600,
        fontSize: 24,
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
