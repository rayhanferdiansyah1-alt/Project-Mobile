import 'package:flutter/material.dart';

import '../../utils/wip_format.dart';

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

/// Kartu satu kriteria dengan bar utility. Muncul dengan fade + slide-up
/// bertahap sesuai [index].
class CriteriaTile extends StatelessWidget {
  const CriteriaTile({super.key, required this.criteria, required this.index});

  final CriteriaRow criteria;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      ),
      child: _CriteriaCard(criteria: criteria),
    );
  }
}

class _CriteriaCard extends StatelessWidget {
  const _CriteriaCard({required this.criteria});
  final CriteriaRow criteria;

  @override
  Widget build(BuildContext context) {
    final c = criteria;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${c.kode}  ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: '${c.label}: ${c.rawText}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Skor ${idDecimal(c.skor)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Utility ${idDecimal(c.utility, decimals: 3)} · bobot '
            '${idDecimal(c.bobot, decimals: 2)} · ${c.sifat}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: c.utility.clamp(0, 1)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
