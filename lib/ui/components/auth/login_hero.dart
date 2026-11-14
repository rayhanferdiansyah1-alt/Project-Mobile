import 'package:flutter/material.dart';

import '../headers/curved_header.dart';
import 'glow_blob.dart';

/// Header gelap premium di halaman login: gradien 3 warna, blob blur,
/// aksen oranye, judul aplikasi.
class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return ClipPath(
      clipper: const CurveClipper(60),
      child: Container(
        height: 320,
        padding: const EdgeInsets.fromLTRB(28, 56, 28, 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(primary, Colors.black, 0.15)!,
              Color.lerp(primary, Colors.black, 0.45)!,
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Blob blur oranye (glow lembut, bukan solid)
            Positioned(
              right: -30,
              top: 20,
              child: GlowBlob(color: secondary, size: 170),
            ),
            // Blob blur biru muda
            Positioned(
              left: -50,
              bottom: -20,
              child: GlowBlob(
                color: Colors.lightBlueAccent,
                size: 150,
                opacity: 0.18,
              ),
            ),
            // Aksen bentuk oranye tegas (solid, bukan blur) -- focal point
            Positioned(
              right: 8,
              top: 64,
              child: Transform.rotate(
                angle: 0.45,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        secondary,
                        Color.lerp(secondary, Colors.white, 0.25)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: secondary.withValues(alpha: 0.5),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Konten teks
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RoleBadge.hero('PT PRABU PURA MOTOR KARAWANG'),
                const SizedBox(height: 22),
                const Text(
                  'SPK WIP\nBodi & Cat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Workshop Decision Support System',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
