import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_role_service.dart';

/// Pengganti tombol logout polos -- avatar inisial di kanan AppBar,
/// tap membuka dropdown berisi nama, role, dan tombol Logout.
/// Dipasang sama di ketiga dashboard (SA, Partman, Kepala Bengkel).
class AppUserMenu extends StatelessWidget {
  const AppUserMenu({super.key});

  String _labelRole(String level) {
    switch (level) {
      case 'service_advisor':
        return 'Service Advisor';
      case 'partman':
        return 'Partman / Staf Asuransi';
      case 'kepala_bengkel':
        return 'Kepala Bengkel';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<UserProfile?>(
      future: UserRoleService().getProfile(user.uid),
      builder: (context, snapshot) {
        final nama = snapshot.data?.nama ?? '...';
        final level = snapshot.data?.level ?? '';
        final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          icon: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            child: Text(inisial),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _labelRole(level),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              FirebaseAuth.instance.signOut();
            }
          },
        );
      },
    );
  }
}