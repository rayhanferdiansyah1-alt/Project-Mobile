import 'package:flutter/material.dart';

import '../utils/wip_format.dart';

/// Lingkaran skor Ui dengan animasi mengisi dari 0 ke nilai aslinya,
/// dipakai di kartu dashboard (ukuran kecil) dan halaman detail (ukuran besar).
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.value,
    this.size = 56,
    this.strokeWidth = 5,
    required this.color,
    this.textColor,
    this.decimals = 3,
  });

  final double value; // 0.0 - 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? textColor;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: strokeWidth,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                idDecimal(animatedValue, decimals: decimals),
                style: TextStyle(
                  fontSize: size * 0.21,
                  fontWeight: FontWeight.w800,
                  color: textColor ?? color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}