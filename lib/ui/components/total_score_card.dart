import 'package:flutter/material.dart';

import '../../utils/wip_format.dart';
import '../theme/app_effects.dart';

/// Kartu "Total Ui" dengan bar progres animasi di halaman detail.
class TotalScoreCard extends StatelessWidget {
  const TotalScoreCard({super.key, required this.nilaiUi});

  final double nilaiUi;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Ui',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(
                idDecimal(nilaiUi),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: nilaiUi.clamp(0, 1)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Utility dihitung dari nilai maksimum dan minimum seluruh unit WIP aktif.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
