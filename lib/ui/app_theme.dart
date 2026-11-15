import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Neutral editorial palette for the workshop operations suite.
class AppColors {
  AppColors._();

  static const background = Color(0xFFF5F4F0);
  static const surface = Color(0xFFFFFEFC);
  static const border = Color(0xFFE7E4DC);
  static const textPrimary = Color(0xFF202522);
  static const textMuted = Color(0xFF777C76);
  static const primary = Color(0xFF202522);
  static const primaryDark = Color(0xFF303832);
  static const accent = Color(0xFFB28B54);
  static const accentDark = Color(0xFF8C693A);
  static const accentSoft = Color(0xFFF3EBDD);
  static const softFill = Color(0xFFF3EBDD);
  static const softFillDeep = Color(0xFFE8D5B5);
  static const fieldFill = Color(0xFFFAF9F6);
  static const snackbar = Color(0xFF202522);
  static const onHeaderPrimary = Color(0xFFFFFEFC);
  static const onHeaderMuted = Color(0xFFD0D2CD);
  static const success = Color(0xFF48745C);
  static const successSoft = Color(0xFFE8F0E9);
  static const successBright = Color(0xFF6F997D);
  static const warning = Color(0xFFC38A3B);
  static const warningText = Color(0xFF94611F);
  static const warningSoft = Color(0xFFF7EEDC);
  static const amberBright = Color(0xFFD6AA68);
  static const danger = Color(0xFFB95E55);
  static const dangerText = Color(0xFF91453E);
  static const dangerDeep = Color(0xFF9B514A);
  static const dangerSoft = Color(0xFFF6E8E5);
  static const info = Color(0xFF647C87);
  static const infoText = Color(0xFF49626D);
  static const infoSoft = Color(0xFFE9EFF0);

  static Color scoreColor(double ui) => ui >= 0.75
      ? success
      : ui >= 0.5
      ? warning
      : dangerDeep;

  static Color wipStatusColor(String value) {
    if (const {'ready', 'disetujui'}.contains(value)) return success;
    if (const {'order_eo', 'proses_klaim'}.contains(value)) return warningText;
    return dangerDeep;
  }
}

class AppGradients {
  AppGradients._();
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryDark, AppColors.primary],
  );
  static const accentPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, AppColors.accentDark],
  );
}

class AppShadows {
  AppShadows._();
  static List<BoxShadow> get card => const [
    BoxShadow(color: Color(0x0A202522), blurRadius: 20, offset: Offset(0, 7)),
  ];
  static List<BoxShadow> get elevated => const [
    BoxShadow(color: Color(0x18202522), blurRadius: 30, offset: Offset(0, 12)),
  ];
  static List<BoxShadow> get pill => const [];
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onHeaderPrimary,
      primaryContainer: AppColors.accentSoft,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.accent,
      onSecondary: AppColors.onHeaderPrimary,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.info,
      onTertiary: AppColors.onHeaderPrimary,
      error: AppColors.danger,
      onError: AppColors.onHeaderPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textMuted,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textMuted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: outline,
        enabledBorder: outline,
        focusedBorder: outline.copyWith(
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.snackbar,
        contentTextStyle: const TextStyle(
          color: AppColors.surface,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
