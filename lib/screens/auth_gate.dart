import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_role_service.dart';
import '../ui/ui.dart';
import 'kepala_bengkel/kb_dashboard_screen.dart';
import 'login_screen.dart';
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
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String?>(
          future: UserRoleService().getRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              );
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
                  backgroundColor: AppColors.background,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Akun belum terdaftar dengan peran (role) tertentu.\n'
                              'Hubungi admin untuk mendaftarkan akun ini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => FirebaseAuth.instance.signOut(),
                              child: const Text('Keluar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}
