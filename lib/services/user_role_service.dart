import 'package:cloud_firestore/cloud_firestore.dart';

/// Profil ringkas user yang sedang login, dibaca dari users/{uid}.
class UserProfile {
  final String nama;
  final String level;

  const UserProfile({required this.nama, required this.level});
}

class UserRoleService {
  UserRoleService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Dipakai AuthGate untuk percabangan role.
  Future<String?> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return data['level'] as String?;
  }

  /// Dipakai AppUserMenu untuk tampilkan nama+role di dropdown.
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return UserProfile(
      nama: (data['nama'] as String?) ?? '(tanpa nama)',
      level: (data['level'] as String?) ?? '(tanpa role)',
    );
  }
}