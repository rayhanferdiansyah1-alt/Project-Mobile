import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ThemeData aplikasi. Dulu ditulis langsung di main.dart.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand, // biru tua, kontras jelas vs putih
        secondary: AppColors.accent, // amber, kontras vs biru -- dipakai avatar & FAB
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
