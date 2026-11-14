import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../logic/smart_calculator.dart';
import '../models/unit_wip.dart';

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
      dihitungPada:
          (data['dihitungPada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class UnitWipRepository {
  UnitWipRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _unitWipCol =>
      _db.collection('unitWip');

  CollectionReference<Map<String, dynamic>> get _hasilRankingCol =>
      _db.collection('hasilRanking');

  Stream<List<UnitWip>> watchUnitWip() {
    return _unitWipCol
        .orderBy('tanggalMasuk', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UnitWip.fromFirestore(doc)).toList());
  }

  Stream<List<RankingEntry>> watchHasilRanking() {
    return _hasilRankingCol
        .orderBy('peringkat')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => RankingEntry.fromFirestore(doc)).toList());
  }

  Map<String, dynamic> _withServerUpdatedAt(Map<String, dynamic> data) {
    return {...data, 'updatedAt': FieldValue.serverTimestamp()};
  }

  Future<void> createUnit(UnitWip unit) async {
    await _unitWipCol
        .doc(unit.id.isEmpty ? null : unit.id)
        .set(_withServerUpdatedAt(unit.toFirestore()));
    await recomputeAndSaveRanking();
  }

  Future<void> updateUnitFields(String unitId, Map<String, dynamic> fields) async {
    await _unitWipCol.doc(unitId).update(_withServerUpdatedAt(fields));
    await recomputeAndSaveRanking();
  }

  Future<void> terbitkanInstruksi(String unitId) {
    return updateUnitFields(unitId, {'statusPengerjaan': 'sedang_dikerjakan'});
  }

  Future<void> deleteUnit(String unitId) async {
    await _unitWipCol.doc(unitId).delete();
    await recomputeAndSaveRanking();
  }


  Future<void> recomputeAndSaveRanking() async {
    final unitSnapshot = await _unitWipCol
        .where('statusPengerjaan', isNotEqualTo: 'selesai')
        .get();

    final units = <UnitWip>[];
    for (final doc in unitSnapshot.docs) {
      try {
        final unit = UnitWip.fromFirestore(doc);
        unit.nilaiC2; // memicu validasi statusSparepart
        unit.nilaiC3; // memicu validasi statusSpkAsuransi
        units.add(unit);
      } catch (e) {
        debugPrint('recompute: unit ${doc.id} dilewati, data tidak valid: $e');
      }
    }

    final hasil = hitungSmart(units);
    final activeIds = hasil.map((h) => h.unit.id).toSet();

    // Ranking lama yang unitnya sudah tidak aktif -> hapus.
    final existingRanking = await _hasilRankingCol.get();

    final batch = _db.batch();
    final now = Timestamp.now();

    for (final doc in existingRanking.docs) {
      if (!activeIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (var i = 0; i < hasil.length; i++) {
      final h = hasil[i];
      batch.set(_hasilRankingCol.doc(h.unit.id), {
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