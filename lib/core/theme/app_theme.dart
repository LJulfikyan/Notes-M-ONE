import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkSurface,
      primary: AppColors.notePurple,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
