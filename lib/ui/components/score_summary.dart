import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'score_ring.dart';

/// Ring skor besar + pill status ("Siap dikerjakan" / "Ditahan") di halaman
/// detail. Posisinya naik 46px supaya menimpa lengkungan header.
class ScoreSummary extends StatelessWidget {
  const ScoreSummary({super.key, required this.value, required this.siap});

  final double value;
  final bool siap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -46),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ScoreRing(
              value: value,
              size: 92,
              strokeWidth: 8,
              color: siap ? AppColors.success : AppColors.warning,
              decimals: 4,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: siap
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: siap ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  siap ? 'Siap dikerjakan' : 'Ditahan',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: siap ? AppColors.success : AppColors.warningText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
