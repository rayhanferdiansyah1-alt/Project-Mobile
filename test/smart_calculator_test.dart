import 'package:flutter_test/flutter_test.dart';
import 'package:mitsubishi/logic/smart_calculator.dart';
import 'package:mitsubishi/models/unit_wip.dart';

UnitWip _buildUnit({
  required String id,
  required String noWO,
  required String tipeKendaraan,
  required int jumlahPanel,
  required int nilaiC2, // 5=ready, 3=order_eo, 1=back_order
  required int nilaiC3, // 5=disetujui, 3=proses_klaim, 1=bermasalah
  required int agingHariTarget,
  required double estimasiBiaya,
}) {
  final statusSparepart = switch (nilaiC2) {
    5 => 'ready',
    3 => 'order_eo',
    1 => 'back_order',
    _ => throw ArgumentError('nilaiC2 tidak valid: $nilaiC2'),
  };
  final statusSpkAsuransi = switch (nilaiC3) {
    5 => 'disetujui',
    3 => 'proses_klaim',
    1 => 'bermasalah',
    _ => throw ArgumentError('nilaiC3 tidak valid: $nilaiC3'),
  };

  return UnitWip(
    id: id,
    noWO: noWO,
    tipeKendaraan: tipeKendaraan,
    tanggalMasuk: DateTime.now().subtract(Duration(days: agingHariTarget)),
    jumlahPanel: jumlahPanel,
    statusSparepart: statusSparepart,
    statusSpkAsuransi: statusSpkAsuransi,
    estimasiBiaya: estimasiBiaya,
    statusPengerjaan: 'menunggu',
    createdBy: 'test-user',
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('hitungSmart - golden test BAB IV (14 unit, data per 2 Nov 2026)', () {
    // Data persis dari tabel "Matriks Keputusan Data Mentah (X)" BAB IV.2.1,
    // Ui target dari tabel "Hasil Akhir & Rekomendasi Operasional" BAB IV.2.4.
    final units = [
      _buildUnit(id: '1', noWO: '2026-08-000024', tipeKendaraan: 'Mitsubishi Canter FE',
          jumlahPanel: 1, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 83, estimasiBiaya: 850000),
      _buildUnit(id: '2', noWO: '2026-08-000050', tipeKendaraan: 'Daihatsu Grandmax',
          jumlahPanel: 25, nilaiC2: 3, nilaiC3: 5, agingHariTarget: 65, estimasiBiaya: 12500000),
      _buildUnit(id: '3', noWO: '2026-09-000014', tipeKendaraan: 'Citroen',
          jumlahPanel: 6, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 49, estimasiBiaya: 4200000),
      _buildUnit(id: '4', noWO: '2026-09-000032', tipeKendaraan: 'Daihatsu Grandmax',
          jumlahPanel: 23, nilaiC2: 3, nilaiC3: 5, agingHariTarget: 37, estimasiBiaya: 11500000),
      _buildUnit(id: '5', noWO: '2026-09-000038', tipeKendaraan: 'Destinator',
          jumlahPanel: 5, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 33, estimasiBiaya: 3500000),
      _buildUnit(id: '6', noWO: '2026-10-000001', tipeKendaraan: 'Mitsubishi Pajero Sport',
          jumlahPanel: 3, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 32, estimasiBiaya: 2200000),
      _buildUnit(id: '7', noWO: '2026-10-000002', tipeKendaraan: 'Destinator',
          jumlahPanel: 4, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 32, estimasiBiaya: 2800000),
      _buildUnit(id: '8', noWO: '2026-10-000003', tipeKendaraan: 'Mitsubishi L300',
          jumlahPanel: 40, nilaiC2: 1, nilaiC3: 5, agingHariTarget: 32, estimasiBiaya: 18000000),
      _buildUnit(id: '9', noWO: '2026-10-000006', tipeKendaraan: 'Xpander Ultimate',
          jumlahPanel: 4, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 30, estimasiBiaya: 3200000),
      _buildUnit(id: '10', noWO: '2026-10-000008', tipeKendaraan: 'Xpander Cross',
          jumlahPanel: 3, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 28, estimasiBiaya: 2100000),
      _buildUnit(id: '11', noWO: '2025-09-000056', tipeKendaraan: 'Pajero Sport 2.4L Dakar',
          jumlahPanel: 6, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 27, estimasiBiaya: 4800000),
      _buildUnit(id: '12', noWO: '2026-10-000013', tipeKendaraan: 'Wuling',
          jumlahPanel: 6, nilaiC2: 3, nilaiC3: 5, agingHariTarget: 25, estimasiBiaya: 4500000),
      _buildUnit(id: '13', noWO: '2025-09-000044', tipeKendaraan: 'Xpander Cross',
          jumlahPanel: 11, nilaiC2: 5, nilaiC3: 3, agingHariTarget: 25, estimasiBiaya: 8200000),
      _buildUnit(id: '14', noWO: '2026-10-000015', tipeKendaraan: 'Destinator',
          jumlahPanel: 3, nilaiC2: 5, nilaiC3: 5, agingHariTarget: 18, estimasiBiaya: 2500000),
    ];

    // Ui target per noWO, dari tabel Peringkat BAB IV.2.4.
    final expectedUi = <String, double>{
      '2026-08-000024': 1.0000,
      '2026-09-000014': 0.8666,
      '2026-10-000001': 0.8602,
      '2026-10-000008': 0.8519,
      '2026-10-000002': 0.8499,
      '2026-10-000006': 0.8418,
      '2026-09-000038': 0.8409,
      '2026-10-000015': 0.8253,
      '2025-09-000056': 0.8106,
      '2026-10-000013': 0.6836,
      '2026-08-000050': 0.6085,
      '2026-09-000032': 0.5629,
      '2025-09-000044': 0.5006,
      '2026-10-000003': 0.2823,
    };

    // Urutan peringkat (noWO), dari tabel yang sama -- Peringkat 1 di index 0.
    final expectedOrder = [
      '2026-08-000024',
      '2026-09-000014',
      '2026-10-000001',
      '2026-10-000008',
      '2026-10-000002',
      '2026-10-000006',
      '2026-09-000038',
      '2026-10-000015',
      '2025-09-000056',
      '2026-10-000013',
      '2026-08-000050',
      '2026-09-000032',
      '2025-09-000044',
      '2026-10-000003',
    ];

    test('nilai Ui tiap unit sesuai perhitungan manual BAB IV (toleransi 0.001)', () {
      final hasil = hitungSmart(units);

      for (final h in hasil) {
        final target = expectedUi[h.unit.noWO];
        expect(
          target,
          isNotNull,
          reason: 'noWO ${h.unit.noWO} tidak ada di data expected -- cek penulisan ulang.',
        );
        expect(
          h.ui,
          closeTo(target!, 0.001),
          reason: 'Ui untuk ${h.unit.noWO} (${h.unit.tipeKendaraan}) meleset dari BAB IV. '
              'Didapat ${h.ui}, seharusnya $target.',
        );
      }
    });

    test('urutan peringkat sesuai tabel BAB IV (Ui tertinggi di index 0)', () {
      final hasil = hitungSmart(units);
      final actualOrder = hasil.map((h) => h.unit.noWO).toList();

      expect(actualOrder, equals(expectedOrder));
    });

    test('dataset kosong tidak error, hasil list kosong', () {
      expect(hitungSmart([]), isEmpty);
    });

    test('satu unit saja (xMax == xMin di semua kriteria) -> Ui = 1.0', () {
      final single = [units.first];
      final hasil = hitungSmart(single);

      expect(hasil, hasLength(1));
      expect(hasil.first.ui, closeTo(1.0, 0.0001));
    });
  });
}