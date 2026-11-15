import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Radius sudut yang dipakai berulang.
class AppRadius {
  AppRadius._();

  static const double card = 20;
  static const double field = 14;
  static const double chip = 10;
  static const double sheet = 28;
  static const double header = 28;
}

/// Durasi dan kurva animasi, satu tempat supaya geraknya seragam.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 480);

  static const Curve out = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}

/// Bayangan lembut. Gaya utama tetap garis tipis; bayangan hanya untuk
/// elemen yang perlu terasa melayang (kartu utama, FAB, search bar).
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.brand.withValues(alpha: 0.28),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}

/// Dekorasi kartu standar: permukaan [AppColors.card] + garis tipis.
BoxDecoration appCardDecoration({
  Color color = AppColors.card,
  Color border = AppColors.line,
  double borderWidth = 1,
  double radius = AppRadius.card,
  List<BoxShadow>? shadow,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border, width: borderWidth),
    boxShadow: shadow,
  );
}
