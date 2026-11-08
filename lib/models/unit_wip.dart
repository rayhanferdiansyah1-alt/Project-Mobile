import 'package:cloud_firestore/cloud_firestore.dart';

/// Representasi satu dokumen di koleksi Firestore `unitWip`.
/// Field persis mengikuti skema yang sudah kita buat di Firestore,
/// dan kriteria C1-C5 sesuai BAB IV laporan.
class UnitWip {
  final String id; // Firestore document ID
  final String noWO;
  final String tipeKendaraan;
  final DateTime tanggalMasuk;
  final int jumlahPanel; // C1 (Cost)
  final String statusSparepart; // 'ready' | 'order_eo' | 'back_order' -> C2 (Benefit)
  final String statusSpkAsuransi; // 'disetujui' | 'proses' | 'bermasalah' -> C3 (Benefit)
  final double estimasiBiaya; // C5 (Cost)
  final String statusPengerjaan; // 'menunggu' | 'sedang_dikerjakan' | 'selesai'
  final String createdBy;
  final DateTime updatedAt;

  const UnitWip({
    required this.id,
    required this.noWO,
    required this.tipeKendaraan,
    required this.tanggalMasuk,
    required this.jumlahPanel,
    required this.statusSparepart,
    required this.statusSpkAsuransi,
    required this.estimasiBiaya,
    required this.statusPengerjaan,
    required this.createdBy,
    required this.updatedAt,
  });

  /// C4 (Benefit): durasi antrean/aging dalam hari, dihitung real-time
  /// terhadap waktu sekarang -- bukan field statis di Firestore.
  /// Sesuai BAB II: "menghitung durasi aging secara real-time
  /// berdasarkan tanggal sistem".
  int get agingHari {
    final now = DateTime.now();
    return now.difference(tanggalMasuk).inDays;
  }

  /// Konversi statusSparepart (string kualitatif) -> nilai kuantitatif C2,
  /// persis tabel 4.1.3 di laporan.
  int get nilaiC2 {
    switch (statusSparepart) {
      case 'ready':
        return 5;
      case 'order_eo':
        return 3;
      case 'back_order':
        return 1;
      default:
        throw ArgumentError(
          'statusSparepart tidak dikenali: $statusSparepart (unit: $noWO)',
        );
    }
  }

  /// Konversi statusSpkAsuransi (string kualitatif) -> nilai kuantitatif C3,
  /// persis tabel 4.1.3 di laporan.
  int get nilaiC3 {
    switch (statusSpkAsuransi) {
      case 'disetujui':
        return 5;
      case 'proses':
        return 3;
      case 'bermasalah':
        return 1;
      default:
        throw ArgumentError(
          'statusSpkAsuransi tidak dikenali: $statusSpkAsuransi (unit: $noWO)',
        );
    }
  }

  /// Factory: bikin instance dari dokumen Firestore.
  factory UnitWip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Dokumen unitWip ${doc.id} kosong/tidak ada data.');
    }
    return UnitWip(
      id: doc.id,
      noWO: data['noWO'] as String,
      tipeKendaraan: data['tipeKendaraan'] as String,
      tanggalMasuk: (data['tanggalMasuk'] as Timestamp).toDate(),
      jumlahPanel: (data['jumlahPanel'] as num).toInt(),
      statusSparepart: data['statusSparepart'] as String,
      statusSpkAsuransi: data['statusSpkAsuransi'] as String,
      estimasiBiaya: (data['estimasiBiaya'] as num).toDouble(),
      statusPengerjaan: data['statusPengerjaan'] as String,
      createdBy: data['createdBy'] as String,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Konversi balik ke Map, dipakai saat create/update ke Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'noWO': noWO,
      'tipeKendaraan': tipeKendaraan,
      'tanggalMasuk': Timestamp.fromDate(tanggalMasuk),
      'jumlahPanel': jumlahPanel,
      'statusSparepart': statusSparepart,
      'statusSpkAsuransi': statusSpkAsuransi,
      'estimasiBiaya': estimasiBiaya,
      'statusPengerjaan': statusPengerjaan,
      'createdBy': createdBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}