import 'package:cloud_firestore/cloud_firestore.dart';

/// Ambil role ('service_advisor' | 'partman' | 'kepala_bengkel') milik
/// user yang sedang login, dari dokumen users/{uid}.
///
/// Dipisah jadi service kecil sendiri (bukan ditumpuk di UnitWipRepository)
/// karena ini baca koleksi 'users', bukan 'unitWip'/'hasilRanking' --
/// tanggung jawabnya beda.
class UserRoleService {
  UserRoleService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<String?> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return data['level'] as String?;
  }
}