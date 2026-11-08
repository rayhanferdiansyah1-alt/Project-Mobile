import 'package:flutter_test/flutter_test.dart';
import 'package:mitsubishi/logic/smart_calculator.dart';
import 'package:mitsubishi/models/unit_wip.dart';

/// Helper: bikin UnitWip palsu di memori, dengan tanggalMasuk dihitung
/// mundur sesuai jumlah hari aging yang kita mau (supaya agingHari
/// pas sama tabel BAB IV, tanpa tergantung tanggal hari ini berubah-ubah).
UnitWip buatUnit({
  required String noWO,
  required String tipe,
  required int panel,
  required String sparepart,
  required String spk,
  required int agingHari,
  required double biaya,
}) {
  final tanggalMasuk = DateTime.now().subtract(Duration(days: agingHari));
  return UnitWip(
    id: noWO,
    noWO: noWO,
    tipeKendaraan: tipe,
    tanggalMasuk: tanggalMasuk,
    jumlahPanel: panel,
    statusSparepart: sparepart,
    statusSpkAsuransi: spk,
    estimasiBiaya: biaya,
    statusPengerjaan: 'menunggu',
    createdBy: 'test-uid',
    updatedAt: tanggalMasuk,
  );
}

void main() {
  // 14 data persis dari tabel BAB IV (4.2.1), dengan aging dipakai
  // apa adanya dari laporan (bukan dihitung ulang dari tanggal kalender,
  // supaya test ini stabil dijalankan kapan saja, tidak bergantung
  // pada tanggal hari ini).
  final units = [
    buatUnit(noWO: 'Unit1-CanterFE', tipe: 'Mitsubishi Canter FE', panel: 1, sparepart: 'ready', spk: 'disetujui', agingHari: 83, biaya: 850000),
    buatUnit(noWO: 'Unit2-Grandmax', tipe: 'Daihatsu Grandmax', panel: 25, sparepart: 'order_eo', spk: 'disetujui', agingHari: 65, biaya: 12500000),
    buatUnit(noWO: 'Unit3-Citroen', tipe: 'Citroen', panel: 6, sparepart: 'ready', spk: 'disetujui', agingHari: 49, biaya: 4200000),
    buatUnit(noWO: 'Unit4-Grandmax', tipe: 'Daihatsu Grandmax', panel: 23, sparepart: 'order_eo', spk: 'disetujui', agingHari: 37, biaya: 11500000),
    buatUnit(noWO: 'Unit5-Destinator', tipe: 'Destinator', panel: 5, sparepart: 'ready', spk: 'disetujui', agingHari: 33, biaya: 3500000),
    buatUnit(noWO: 'Unit6-PajeroSport', tipe: 'Mitsubishi Pajero Sport', panel: 3, sparepart: 'ready', spk: 'disetujui', agingHari: 32, biaya: 2200000),
    buatUnit(noWO: 'Unit7-Destinator', tipe: 'Destinator', panel: 4, sparepart: 'ready', spk: 'disetujui', agingHari: 32, biaya: 2800000),
    buatUnit(noWO: 'Unit8-L300', tipe: 'Mitsubishi L300', panel: 40, sparepart: 'back_order', spk: 'disetujui', agingHari: 32, biaya: 18000000),
    buatUnit(noWO: 'Unit9-XpanderUltimate', tipe: 'Xpander Ultimate', panel: 4, sparepart: 'ready', spk: 'disetujui', agingHari: 30, biaya: 3200000),
    buatUnit(noWO: 'Unit10-XpanderCross', tipe: 'Xpander Cross', panel: 3, sparepart: 'ready', spk: 'disetujui', agingHari: 28, biaya: 2100000),
    buatUnit(noWO: 'Unit11-PajeroDakar', tipe: 'Pajero Sport 2.4L Dakar', panel: 6, sparepart: 'ready', spk: 'disetujui', agingHari: 27, biaya: 4800000),
    buatUnit(noWO: 'Unit12-Wuling', tipe: 'Wuling', panel: 6, sparepart: 'order_eo', spk: 'disetujui', agingHari: 25, biaya: 4500000),
    buatUnit(noWO: 'Unit13-XpanderCross', tipe: 'Xpander Cross', panel: 11, sparepart: 'ready', spk: 'proses', agingHari: 25, biaya: 8200000),
    buatUnit(noWO: 'Unit14-Destinator', tipe: 'Destinator', panel: 3, sparepart: 'ready', spk: 'disetujui', agingHari: 18, biaya: 2500000),
  ];

  test('Bobot kriteria harus berjumlah 1.00', () {
    expect(BobotKriteria.isValid, true);
  });

  test('Ranking harus terurut dari Ui tertinggi ke terendah', () {
    final hasil = hitungSmart(units);
    for (var i = 0; i < hasil.length - 1; i++) {
      expect(hasil[i].ui >= hasil[i + 1].ui, true);
    }
  });

  test('Mitsubishi Canter FE (Unit 1) harus jadi Peringkat 1 dengan Ui = 1.0000', () {
    final hasil = hitungSmart(units);
    final peringkat1 = hasil.first;
    expect(peringkat1.unit.noWO, 'Unit1-CanterFE');
    expect(peringkat1.ui, closeTo(1.0000, 0.001));
  });

  test('Citroen (Unit 3) harus Ui mendekati 0.8666 (Peringkat 2)', () {
    final hasil = hitungSmart(units);
    final citroen = hasil.firstWhere((h) => h.unit.noWO == 'Unit3-Citroen');
    expect(citroen.ui, closeTo(0.8666, 0.001));
  });

  test('Mitsubishi Pajero Sport (Unit 6) harus Ui mendekati 0.8602', () {
    final hasil = hitungSmart(units);
    final pajero = hasil.firstWhere((h) => h.unit.noWO == 'Unit6-PajeroSport');
    expect(pajero.ui, closeTo(0.8602, 0.001));
  });

  test('Mitsubishi L300 (Unit 8) harus jadi Peringkat terakhir dengan Ui mendekati 0.2823', () {
    final hasil = hitungSmart(units);
    final peringkatTerakhir = hasil.last;
    expect(peringkatTerakhir.unit.noWO, 'Unit8-L300');
    expect(peringkatTerakhir.ui, closeTo(0.2823, 0.001));
  });

  test('Xpander Cross dengan SPK "proses" (Unit 13) harus Ui mendekati 0.5006', () {
    final hasil = hitungSmart(units);
    final unit13 = hasil.firstWhere((h) => h.unit.noWO == 'Unit13-XpanderCross');
    expect(unit13.ui, closeTo(0.5006, 0.001));
  });

  test('List kosong tidak boleh error, hasil harus list kosong', () {
    final hasil = hitungSmart([]);
    expect(hasil, isEmpty);
  });
}