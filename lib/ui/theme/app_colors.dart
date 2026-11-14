import 'package:flutter/material.dart';

/// Satu-satunya tempat warna kustom aplikasi didefinisikan.
/// Nilainya sama persis dengan warna yang dulu ditulis langsung di tiap layar.
class AppColors {
  AppColors._();

  // --- Brand ---
  static const brand = Color(0xFF0D47A1); // biru tua, seed ColorScheme
  static const accent = Color(0xFFFFB300); // amber, avatar & FAB

  // --- Latar & teks ---
  static const canvas = Color(0xFFF0F1F4); // latar layar (Partman, KB, login)
  static const canvasBlue = Color(0xFFF2F5FB); // latar layar SA & form
  static const fieldFill = Color(0xFFF2F3F5); // isi field password
  static const ink = Color(0xFF14181F); // teks gelap utama
  static const muted = Color(0xFF8A8F98); // teks/ikon redup
  static const snackbar = Color(0xFF1A1D23);

  // --- Status: hijau = siap, oranye = proses, merah = bermasalah ---
  static const success = Color(0xFF1F9D6B);
  static const successBright = Color(0xFF34D399);
  static const warning = Color(0xFFFF8A00);
  static const warningText = Color(0xFFB36B00);
  static const amberBright = Color(0xFFFFB020);
  static const danger = Color(0xFFE74C3C);
  static const dangerText = Color(0xFFC0392B);
  static const dangerDeep = Color(0xFFB23B1E);
  static const info = Color(0xFF3B82F6);
  static const infoText = Color(0xFF1D4ED8);

  /// Warna cincin skor Ui di kartu dashboard Kepala Bengkel.
  static Color scoreColor(double ui) {
    if (ui >= 0.75) return success;
    if (ui >= 0.5) return warning;
    return dangerDeep;
  }

  /// Warna chip status sparepart / SPK di dashboard Service Advisor.
  static Color wipStatusColor(String value) {
    const siapValues = {'ready', 'disetujui'};
    const prosesValues = {'order_eo', 'proses_klaim'};
    if (siapValues.contains(value)) return success;
    if (prosesValues.contains(value)) return warningText;
    return dangerDeep;
  }
}
