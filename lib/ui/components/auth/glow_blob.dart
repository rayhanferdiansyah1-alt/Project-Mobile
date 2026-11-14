import 'dart:ui';

import 'package:flutter/material.dart';

/// Lingkaran glow blur lembut -- efek glassmorphism dekoratif di header,
/// dibuat dari warna solid yang di-blur, bukan gambar/asset.
class GlowBlob extends StatelessWidget {
  const GlowBlob({
    super.key,
    required this.color,
    required this.size,
    this.opacity = 0.35,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
