import 'package:flutter/material.dart';

import '../utils/wip_format.dart';
import 'motion.dart';
import 'status.dart';
import 'theme/app_colors.dart';
import 'theme/app_effects.dart';
import 'theme/app_text.dart';

/// Lingkaran skor Ui yang mengisi dari 0 ke nilai aslinya, dengan angka
/// yang ikut berhitung naik. Dipakai di kartu dashboard (kecil) dan
/// halaman detail (besar).
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
      tween: Tween<double>(begin: 0, end: value.clamp(0, 1).toDouble()),
      duration: const Duration(milliseconds: 1000),
      curve: AppMotion.out,
      builder: (context, animatedValue, child) {
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
                  backgroundColor: color.withValues(alpha: 0.16),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                idDecimal(animatedValue, decimals: decimals),
                style: AppText.subheading.copyWith(
                  fontSize: size * 0.21,
                  color: textColor ?? AppColors.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Ring skor besar + chip status ("Siap dikerjakan" / "Ditahan") di halaman
/// detail. Posisinya naik 46px supaya menimpa tepi bawah header.
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
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
              boxShadow: AppShadows.soft,
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
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            dy: 0.2,
            child: StatusChip(
              label: siap ? 'Siap dikerjakan' : 'Ditahan',
              level: siap ? StatusLevel.good : StatusLevel.warn,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu "Total Ui" dengan bar progres animasi di halaman detail.
class TotalScoreCard extends StatelessWidget {
  const TotalScoreCard({super.key, required this.nilaiUi});

  final double nilaiUi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Ui', style: AppText.heading),
              Text(
                idDecimal(nilaiUi),
                style: AppText.heading.copyWith(color: AppColors.brand),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: nilaiUi.clamp(0, 1).toDouble()),
            duration: const Duration(milliseconds: 1000),
            curve: AppMotion.out,
            builder: (context, v, child) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: AppColors.lineSoft,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brand),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Utility dihitung dari nilai maksimum dan minimum seluruh unit WIP aktif.',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}

/// Data satu baris kriteria untuk ditampilkan (C1..C5).
class CriteriaRow {
  final String kode;
  final String label;
  final String rawText;
  final String sifat;
  final double bobot;
  final double utility;

  CriteriaRow({
    required this.kode,
    required this.label,
    required this.rawText,
    required this.sifat,
    required this.bobot,
    required this.utility,
  });

  double get skor => bobot * utility;
}

/// Kartu satu kriteria dengan bar utility. Muncul bertahap sesuai [index].
class CriteriaTile extends StatelessWidget {
  const CriteriaTile({super.key, required this.criteria, required this.index});

  final CriteriaRow criteria;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = criteria;
    return FadeSlideIn(
      delay: Duration(milliseconds: 90 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: appCardDecoration(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sageSoft,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    c.kode,
                    style: AppText.caption.copyWith(
                      color: AppColors.brandDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${c.label}: ${c.rawText}',
                    style: AppText.subheading,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Skor ${idDecimal(c.skor)}',
                  style: AppText.label.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Utility ${idDecimal(c.utility, decimals: 3)} · bobot '
              '${idDecimal(c.bobot, decimals: 2)} · ${c.sifat}',
              style: AppText.caption,
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: c.utility.clamp(0, 1).toDouble(),
              ),
              duration: const Duration(milliseconds: 800),
              curve: AppMotion.out,
              builder: (context, v, child) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: AppColors.lineSoft,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.brand),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
