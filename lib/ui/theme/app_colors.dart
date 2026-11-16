import 'package:flutter/material.dart';

/// Tingkat status: hijau = siap, kuning = proses, merah = bermasalah,
/// info = sedang dikerjakan.
enum StatusLevel { good, warn, bad, info }

/// Satu set warna untuk satu tingkat status.
/// [fill] untuk titik/ikon/bar, [fg] untuk teks, [bg] untuk latar chip.
/// Semua [fg] di atas [bg] sudah dicek >= 4,5 : 1 (WCAG AA).
class StatusPalette {
  const StatusPalette({required this.fill, required this.fg, required this.bg});

  final Color fill;
  final Color fg;
  final Color bg;
}

/// Satu-satunya tempat warna aplikasi didefinisikan.
///
/// Konsep 60-30-10 (palet "sage dan oatmeal"):
///  - 60%  dominan : [canvas] (oatmeal) + [card]
///  - 30%  kedua   : [sage] / [sageSoft] (header, fill lembut)
///  - 10%  aksen   : [brand] (teal laut) untuk tombol & fokus
class AppColors {
  AppColors._();

  // --- Dasar ---
  static const canvas = Color(0xFFECEAE1); // latar layar (oatmeal)
  static const card = Color(0xFFF7F6F0); // permukaan kartu / field
  static const line = Color(0xFFDAD8CC); // garis tipis (hairline)
  static const lineSoft = Color(0xFFE4E1D6); // pemisah lembut, track, skeleton
  static const sage = Color(0xFFC8D5C2); // header, fill lembut
  static const sageSoft = Color(0xFFDDE6D6); // kartu prioritas utama

  // --- Aksen ---
  static const brand = Color(0xFF3A7684); // teal laut: aksi utama, fokus
  static const brandDeep = Color(0xFF2C5C67); // ikon/teks di atas sage

  // --- Teks ---
  static const ink = Color(0xFF1F2A2B); // teks utama
  static const muted = Color(0xFF566265); // teks sekunder
  static const hint = Color(0xFF8A9394); // placeholder, status nonaktif

  // --- Status ---
  static const success = Color(0xFF3E7B57);
  static const successText = Color(0xFF2F6B48);
  static const successBg = Color(0xFFDDE5D5);

  static const warning = Color(0xFFC28A2C);
  static const warningText = Color(0xFF7A4E00);
  static const warningBg = Color(0xFFEBDFC7);

  static const danger = Color(0xFFB5483A);
  static const dangerText = Color(0xFF9A3A27);
  static const dangerBg = Color(0xFFEBD9D0);

  static const info = Color(0xFF3A7684);
  static const infoText = Color(0xFF2A5C68);
  static const infoBg = Color(0xFFD6E4E6);

  static StatusPalette status(StatusLevel level) {
    switch (level) {
      case StatusLevel.good:
        return const StatusPalette(fill: success, fg: successText, bg: successBg);
      case StatusLevel.warn:
        return const StatusPalette(fill: warning, fg: warningText, bg: warningBg);
      case StatusLevel.bad:
        return const StatusPalette(fill: danger, fg: dangerText, bg: dangerBg);
      case StatusLevel.info:
        return const StatusPalette(fill: info, fg: infoText, bg: infoBg);
    }
  }

  /// Warna cincin skor Ui di kartu dashboard Kepala Bengkel.
  static Color scoreColor(double ui) {
    if (ui >= 0.75) return success;
    if (ui >= 0.5) return warning;
    return danger;
  }

  /// Tingkat status untuk nilai database sparepart / SPK.
  static StatusLevel levelOfValue(String value) {
    switch (value) {
      case 'ready':
      case 'disetujui':
        return StatusLevel.good;
      case 'back_order':
      case 'bermasalah':
        return StatusLevel.bad;
      default:
        return StatusLevel.warn; // order_eo, proses_klaim, tidak dikenal
    }
  }
}
