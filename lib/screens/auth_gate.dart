import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

/// Widget ini "mendengarkan" status login secara real-time.
/// Kalau belum login -> tampilkan LoginScreen.
/// Kalau sudah login -> tampilkan DashboardScreen.
/// Tidak perlu navigasi manual (Navigator.push) sama sekali --
/// begitu status auth berubah, StreamBuilder otomatis ganti layar.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}