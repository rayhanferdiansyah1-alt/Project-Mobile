import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Kartu putih besar yang menimpa lengkungan header login.
class LoginCard extends StatelessWidget {
  const LoginCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Transform.translate(
        offset: const Offset(0, -40),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Judul + sub-judul "Selamat Datang" di dalam kartu login.
class LoginGreeting extends StatelessWidget {
  const LoginGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Gunakan akun yang diberikan bengkel.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

/// Label kecil huruf kapital dengan spacing, dipakai di atas tiap field.
class CapsLabel extends StatelessWidget {
  const CapsLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
        letterSpacing: 0.7,
      ),
    );
  }
}
