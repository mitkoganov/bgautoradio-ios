import 'package:flutter/material.dart';

class AppColors {
  static const brandTeal = Color(0xFF00BCD4);
  static const brandDark = Color(0xFF0D1B2A);
  static const surfaceCard = Color(0xFF1A2A3A);
  static const surfaceElevated = Color(0xFF243447);
  static const textPrimary = Color(0xFFE8EDF2);
  static const textSecondary = Color(0xFF8899AA);
  static const favoriteRed = Color(0xFFE53935);
  static const playingGreen = Color(0xFF43A047);
}

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brandTeal,
      surface: AppColors.surfaceCard,
      onPrimary: Colors.black,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.brandDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.brandDark,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      selectedItemColor: AppColors.brandTeal,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 2,
    ),
    useMaterial3: true,
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.brandTeal,
      surface: Colors.grey[100]!,
      onPrimary: Colors.white,
    ),
    useMaterial3: true,
  );
}
