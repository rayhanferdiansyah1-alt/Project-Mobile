import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';
import '../../../utils/wip_format.dart';
import '../../theme/app_colors.dart';
import '../score_ring.dart';

/// Kartu prioritas unit di dashboard Kepala Bengkel (kartu "hero" untuk peringkat teratas).
class PriorityCard extends StatelessWidget {
  const PriorityCard({
    super.key,
    required this.entry,
    required this.unit,
    required this.totalUnit,
    required this.siap,
    required this.isHero,
    required this.color,
    required this.isProcessing,
    required this.onTap,
    required this.onTerbitkanInstruksi,
    required this.statusPengerjaan,
  });

  final RankingEntry entry;
  final UnitWip unit;
  final int totalUnit;
  final bool siap;
  final bool isHero;
  final Color color;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback? onTerbitkanInstruksi;
  final String statusPengerjaan;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = isHero ? primary : Colors.white;
    final fgColor = isHero ? Colors.white : AppColors.ink;
    final mutedColor = isHero
        ? Colors.white.withValues(alpha: 0.75)
        : Colors.grey.shade600;
    final ringColor = isHero ? Colors.amber : color;
    final dikerjakan = statusPengerjaan != 'menunggu';
    final dotColor = dikerjakan
        ? AppColors.info
        : (siap ? AppColors.successBright : AppColors.amberBright);
    final statusLabel = dikerjakan
        ? labelPengerjaan(statusPengerjaan)
        : (siap ? 'Siap dikerjakan' : 'Ditahan');
    final statusColor = dikerjakan
        ? (isHero ? Colors.lightBlueAccent.shade100 : AppColors.infoText)
        : (siap
              ? (isHero ? Colors.greenAccent.shade100 : AppColors.success)
              : (isHero ? Colors.amber.shade100 : AppColors.warningText));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: (isHero ? primary : Colors.black).withValues(
                  alpha: isHero ? 0.25 : 0.05,
                ),
                blurRadius: isHero ? 20 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge peringkat
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isHero ? Colors.amber : primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${entry.peringkat}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isHero ? Colors.black87 : primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.tipeKendaraan,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: fgColor,
                      ),
                    ),
                    Text(
                      unit.noWO,
                      style: TextStyle(fontSize: 11.5, color: mutedColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rekomendasiText(
                        peringkat: entry.peringkat,
                        totalUnit: totalUnit,
                        statusSparepart: unit.statusSparepart,
                        statusSpkAsuransi: unit.statusSpkAsuransi,
                        jumlahPanel: unit.jumlahPanel,
                        agingHari: unit.agingHari,
                        statusPengerjaan: statusPengerjaan,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MiniChip('${unit.jumlahPanel} panel', isHero),
                        MiniChip(
                          'Part: ${labelSparepart(unit.statusSparepart)}',
                          isHero,
                        ),
                        MiniChip(
                          'SPK: ${labelSpk(unit.statusSpkAsuransi)}',
                          isHero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aging ${unit.agingHari} hari',
                      style: TextStyle(fontSize: 11, color: mutedColor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!dikerjakan) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isHero ? Colors.amber : primary,
                            foregroundColor: isHero
                                ? Colors.black87
                                : Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                          onPressed: (siap && !isProcessing)
                              ? onTerbitkanInstruksi
                              : null,
                          child: isProcessing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Terbitkan Instruksi',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ScoreRing(
                value: entry.nilaiUi,
                color: ringColor,
                textColor: fgColor,
                size: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniChip extends StatelessWidget {
  const MiniChip(this.text, this.isHero, {super.key});
  final String text;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHero
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          color: isHero ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
