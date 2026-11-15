import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Skala tipografi. Satu keluarga font (Plus Jakarta Sans), ukuran
/// terkecil 11,5 supaya tetap terbaca di bengkel yang terang.
class AppText {
  AppText._();

  /// TextTheme bawaan Flutter + keluarga font Plus Jakarta Sans.
  /// Sengaja tidak memakai GoogleFonts.plusJakartaSansTextTheme(): di
  /// beberapa versi google_fonts fungsi itu mengembalikan TextTheme dari
  /// paket lain sehingga tidak cocok dengan TextTheme milik Flutter.
  static TextTheme textTheme(TextTheme base) {
    final family = GoogleFonts.plusJakartaSans().fontFamily;
    return base.apply(
      fontFamily: family,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
  }

  static TextStyle _s(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get display =>
      _s(30, FontWeight.w600, AppColors.ink, height: 1.12, letterSpacing: -0.9);
  static TextStyle get title =>
      _s(24, FontWeight.w600, AppColors.ink, height: 1.15, letterSpacing: -0.6);
  static TextStyle get heading =>
      _s(16, FontWeight.w600, AppColors.ink, letterSpacing: -0.2);
  static TextStyle get subheading => _s(13.5, FontWeight.w600, AppColors.ink);
  static TextStyle get body =>
      _s(13.5, FontWeight.w400, AppColors.ink, height: 1.4);
  static TextStyle get bodyMuted =>
      _s(13, FontWeight.w400, AppColors.muted, height: 1.4);
  static TextStyle get label => _s(12, FontWeight.w500, AppColors.muted);
  static TextStyle get caption => _s(11.5, FontWeight.w500, AppColors.muted);
  static TextStyle get button =>
      _s(14, FontWeight.w600, Colors.white, letterSpacing: 0.1);

  /// Untuk No. WO dan angka teknis.
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      );
}
