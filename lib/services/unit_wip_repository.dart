import 'package:cloud_firestore/cloud_firestore.dart';

import '../logic/smart_calculator.dart';
import '../models/unit_wip.dart';

/// Satu baris hasil ranking yang sudah tersimpan di Firestore,
/// dibaca ulang oleh dashboard (Kepala Bengkel) tanpa perlu hitung sendiri.
class RankingEntry {
  final String unitId;
  final int peringkat;
  final double nilaiUi;
  final double uC1;
  final double uC2;
  final double uC3;
  final double uC4;
  final double uC5;
  final DateTime dihitungPada;

  const RankingEntry({
    required this.unitId,
    required this.peringkat,
    required this.nilaiUi,
    required this.uC1,
    required this.uC2,
    required this.uC3,
    required this.uC4,
    required this.uC5,
    required this.dihitungPada,
  });

  factory RankingEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Dokumen hasilRanking ${doc.id} kosong/tidak ada data.');
    }
    return RankingEntry(
      unitId: data['unitId'] as String,
      peringkat: (data['peringkat'] as num).toInt(),
      nilaiUi: (data['nilaiUi'] as num).toDouble(),
      uC1: (data['uC1'] as num).toDouble(),
      uC2: (data['uC2'] as num).toDouble(),
      uC3: (data['uC3'] as num).toDouble(),
      uC4: (data['uC4'] as num).toDouble(),
      uC5: (data['uC5'] as num).toDouble(),
      dihitungPada: (data['dihitungPada'] as Timestamp).toDate(),
    );
  }
}

/// Repository tunggal untuk semua operasi Firestore terkait unit WIP
/// dan hasil ranking SMART-nya.
///
/// Pola yang dipakai: UI (dashboard/screen) hanya memanggil method di sini
/// dan mendengarkan stream -- tidak ada logic Firestore atau hitungSmart()
/// yang ditulis langsung di widget.
class UnitWipRepository {
  UnitWipRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _unitWipCol =>
      _db.collection('unitWip');

  CollectionReference<Map<String, dynamic>> get _hasilRankingCol =>
      _db.collection('hasilRanking');

  // ===== READ: unit WIP =====

  /// Stream real-time seluruh unit WIP, diurutkan berdasarkan tanggal masuk
  /// terbaru dulu (urutan tampilan daftar, BUKAN urutan prioritas SMART).
  Stream<List<UnitWip>> watchUnitWip() {
    return _unitWipCol
        .orderBy('tanggalMasuk', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UnitWip.fromFirestore(doc)).toList());
  }

  // ===== READ: hasil ranking (untuk dashboard) =====

  /// Stream real-time hasil ranking yang SUDAH tersimpan, diurutkan
  /// peringkat 1 (Ui tertinggi) di paling atas. Dashboard Kepala Bengkel
  /// pakai ini -- tidak menghitung ulang di sisi UI.
  Stream<List<RankingEntry>> watchHasilRanking() {
    return _hasilRankingCol
        .orderBy('peringkat')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => RankingEntry.fromFirestore(doc)).toList());
  }

  // ===== WRITE: unit WIP =====

  /// Service Advisor membuat unit WIP baru.
  /// Setelah berhasil, otomatis memicu recompute ranking seluruh dataset.
  Future<void> createUnit(UnitWip unit) async {
    await _unitWipCol.doc(unit.id.isEmpty ? null : unit.id).set(unit.toFirestore());
    await recomputeAndSaveRanking();
  }

  /// Update sebagian field unit WIP (dipakai Service Advisor/Partman/
  /// Kepala Bengkel sesuai field yang jadi wewenangnya -- field mana yang
  /// boleh tetap divalidasi lagi oleh firestore.rules, ini cuma kirim data).
  /// Setelah berhasil, otomatis memicu recompute ranking seluruh dataset
  /// karena perubahan satu unit (mis. statusSparepart) mengubah x_max/x_min
  /// sehingga utility unit LAIN juga ikut berubah (lihat catatan BAB IV).
  Future<void> updateUnitFields(String unitId, Map<String, dynamic> fields) async {
    await _unitWipCol.doc(unitId).update({
      ...fields,
      'updatedAt': Timestamp.now(),
    });
    await recomputeAndSaveRanking();
  }

  /// Hapus unit WIP. Setelah berhasil, recompute ranking karena
  /// x_max/x_min dataset berubah begitu satu unit hilang dari populasi.
  Future<void> deleteUnit(String unitId) async {
    await _unitWipCol.doc(unitId).delete();
    await _hasilRankingCol.doc(unitId).delete();
    await recomputeAndSaveRanking();
  }

  // ===== RECOMPUTE: jantung sinkronisasi SMART =====

  /// Ambil snapshot SEKALI (bukan stream) seluruh unit WIP yang masih aktif
  /// (statusPengerjaan != 'selesai'), hitung SMART lewat hitungSmart(),
  /// lalu tulis seluruh hasil ke koleksi hasilRanking dalam SATU WriteBatch.
  ///
  /// Kenapa WriteBatch dan bukan loop .set() satu-satu:
  /// kalau ditulis satu per satu, dan dua user memicu recompute hampir
  /// bersamaan (mis. Partman update unit A, Kepala Bengkel update status unit
  /// B di saat yang sama), hasil akhir di Firestore bisa jadi campuran --
  /// sebagian dokumen dari hitungan proses pertama, sebagian dari proses
  /// kedua, karena antar write tidak atomic. WriteBatch menjamin SEMUA
  /// dokumen hasilRanking ter-commit sekaligus atau tidak sama sekali,
  /// sehingga tabel ranking yang dibaca dashboard selalu konsisten --
  /// berasal dari satu hitungan yang sama, bukan hasil campuran.
  ///
  /// CATATAN KETERBATASAN (lihat juga komentar di firestore.rules):
  /// recompute ini dipanggil dari client setelah tiap operasi tulis,
  /// idealnya ini jadi tanggung jawab Cloud Function trigger di server.
  Future<void> recomputeAndSaveRanking() async {
    final snapshot = await _unitWipCol
        .where('statusPengerjaan', isNotEqualTo: 'selesai')
        .get();

    final units = snapshot.docs.map((doc) => UnitWip.fromFirestore(doc)).toList();

    final hasil = hitungSmart(units);

    final batch = _db.batch();
    final now = Timestamp.now();

    for (var i = 0; i < hasil.length; i++) {
      final h = hasil[i];
      final docRef = _hasilRankingCol.doc(h.unit.id);
      batch.set(docRef, {
        'unitId': h.unit.id,
        'peringkat': i + 1, // index 0 = peringkat 1 (Ui tertinggi)
        'nilaiUi': h.ui,
        'uC1': h.uC1,
        'uC2': h.uC2,
        'uC3': h.uC3,
        'uC4': h.uC4,
        'uC5': h.uC5,
        'dihitungPada': now,
      });
    }

    await batch.commit();
  }
}