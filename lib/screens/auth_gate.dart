import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_role_service.dart';
import '../ui/ui.dart';
import 'login_screen.dart';
import 'kepala_bengkel/kb_dashboard_screen.dart';
import 'partman/partman_dashboard_screen.dart';
import 'service_advisor/sa_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: PageSkeleton());
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String?>(
          future: UserRoleService().getRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: PageSkeleton());
            }

            switch (roleSnapshot.data) {
              case 'service_advisor':
                return const SaDashboardScreen();
              case 'partman':
                return const PartmanDashboardScreen();
              case 'kepala_bengkel':
                return const KbDashboardScreen();
              default:
                return Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const EmptyState(
                        icon: Icons.lock_outline_rounded,
                        title: 'Akun belum memiliki peran',
                        message: 'Hubungi admin untuk mendaftarkan akun ini '
                            'dengan peran (role) tertentu.',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: AppButton(
                          label: 'Keluar',
                          variant: AppButtonVariant.outline,
                          onPressed: () => FirebaseAuth.instance.signOut(),
                        ),
                      ),
                    ],
                  ),
                );
            }
          },
        );
      },
    );
  }
}