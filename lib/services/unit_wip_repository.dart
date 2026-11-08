import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit_wip.dart';

class UnitWipRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Ambil seluruh unit WIP satu kali (tidak real-time).
  /// Dipakai untuk versi awal yang sederhana dulu.
  Future<List<UnitWip>> getAllUnits() async {
    final snapshot = await _db.collection('unitWip').get();
    return snapshot.docs.map((doc) => UnitWip.fromFirestore(doc)).toList();
  }

  Stream<List<UnitWip>> watchAllUnits() {
    return _db.collection('unitWip').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => UnitWip.fromFirestore(doc)).toList(),
        );
  }
}