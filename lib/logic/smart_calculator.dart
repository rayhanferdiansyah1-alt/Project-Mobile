import '../models/unit_wip.dart';

/// Hasil perhitungan SMART untuk satu unit:
/// nilai utility per kriteria + nilai preferensi akhir (Ui).
class HasilSmart {
  final UnitWip unit;
  final double uC1;
  final double uC2;
  final double uC3;
  final double uC4;
  final double uC5;
  final double ui; // nilai preferensi akhir

  const HasilSmart({
    required this.unit,
    required this.uC1,
    required this.uC2,
    required this.uC3,
    required this.uC4,
    required this.uC5,
    required this.ui,
  });
}

/// Bobot kriteria, persis tabel 4.1.2 BAB IV.
/// Sengaja hardcoded sesuai keputusan kita -- bukan dari Firestore.
class BobotKriteria {
  static const double c1 = 0.20; // Jumlah Panel (Cost)
  static const double c2 = 0.25; // Status Sparepart (Benefit)
  static const double c3 = 0.25; // Status SPK Asuransi (Benefit)
  static const double c4 = 0.15; // Durasi Aging (Benefit)
  static const double c5 = 0.15; // Estimasi Biaya (Cost)

  /// Validasi sum(wj) harus 1.00 -- dicek sekali saat development,
  /// bukan dicek tiap kali hitung (biar tidak boros).
  static bool get isValid {
    const sum = c1 + c2 + c3 + c4 + c5;
    return (sum - 1.0).abs() < 0.0001;
  }
}

/// Hitung nilai utility (u_ij) untuk satu kriteria benefit.
/// Rumus: u_ij = (x_ij - x_min) / (x_max - x_min)
/// Fallback: kalau x_max == x_min, semua alternatif setara -> u_ij = 1.
double _utilityBenefit(num xij, num xMin, num xMax) {
  if (xMax == xMin) return 1.0;
  return (xij - xMin) / (xMax - xMin);
}

/// Hitung nilai utility (u_ij) untuk satu kriteria cost.
/// Rumus: u_ij = (x_max - x_ij) / (x_max - x_min)
/// Fallback: kalau x_max == x_min, semua alternatif setara -> u_ij = 1.
double _utilityCost(num xij, num xMin, num xMax) {
  if (xMax == xMin) return 1.0;
  return (xMax - xij) / (xMax - xMin);
}

/// Fungsi utama: hitung SMART untuk seluruh unit WIP sekaligus,
/// karena x_max/x_min dicari dari keseluruhan dataset yang aktif
/// (sesuai BAB II & BAB IV -- bukan skala absolut tetap).
///
/// Mengembalikan List yang SUDAH terurut dari Ui
/// tertinggi ke terendah (Peringkat 1 di index 0).
List<HasilSmart> hitungSmart(List<UnitWip> units) {
  assert(
    BobotKriteria.isValid,
    'Total bobot kriteria harus 1.00, cek BobotKriteria.',
  );

  if (units.isEmpty) return [];

  // Langkah 2 (BAB IV): cari x_max dan x_min untuk tiap kriteria
  // dari SELURUH unit yang aktif saat ini.
  final panelValues = units.map((u) => u.jumlahPanel).toList();
  final c2Values = units.map((u) => u.nilaiC2).toList();
  final c3Values = units.map((u) => u.nilaiC3).toList();
  final agingValues = units.map((u) => u.agingHari).toList();
  final biayaValues = units.map((u) => u.estimasiBiaya).toList();

  final c1Min = panelValues.reduce((a, b) => a < b ? a : b);
  final c1Max = panelValues.reduce((a, b) => a > b ? a : b);

  final c2Min = c2Values.reduce((a, b) => a < b ? a : b);
  final c2Max = c2Values.reduce((a, b) => a > b ? a : b);

  final c3Min = c3Values.reduce((a, b) => a < b ? a : b);
  final c3Max = c3Values.reduce((a, b) => a > b ? a : b);

  final c4Min = agingValues.reduce((a, b) => a < b ? a : b);
  final c4Max = agingValues.reduce((a, b) => a > b ? a : b);

  final c5Min = biayaValues.reduce((a, b) => a < b ? a : b);
  final c5Max = biayaValues.reduce((a, b) => a > b ? a : b);

  // Langkah 3 & 4 (BAB IV): hitung utility per kriteria, lalu Ui.
  final hasil = units.map((unit) {
    final uC1 = _utilityCost(unit.jumlahPanel, c1Min, c1Max);
    final uC2 = _utilityBenefit(unit.nilaiC2, c2Min, c2Max);
    final uC3 = _utilityBenefit(unit.nilaiC3, c3Min, c3Max);
    final uC4 = _utilityBenefit(unit.agingHari, c4Min, c4Max);
    final uC5 = _utilityCost(unit.estimasiBiaya, c5Min, c5Max);

    final ui = (BobotKriteria.c1 * uC1) +
        (BobotKriteria.c2 * uC2) +
        (BobotKriteria.c3 * uC3) +
        (BobotKriteria.c4 * uC4) +
        (BobotKriteria.c5 * uC5);

    return HasilSmart(
      unit: unit,
      uC1: uC1,
      uC2: uC2,
      uC3: uC3,
      uC4: uC4,
      uC5: uC5,
      ui: ui,
    );
  }).toList();

  // Urutkan dari Ui tertinggi -> terendah (Peringkat 1 = index 0).
  hasil.sort((a, b) => b.ui.compareTo(a.ui));

  return hasil;
}