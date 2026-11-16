import 'package:flutter/material.dart';

import '../models/unit_wip.dart';
import '../services/unit_wip_repository.dart';
import '../utils/wip_format.dart';
import 'forms.dart';
import 'motion.dart';
import 'scoring.dart';
import 'status.dart';
import 'theme/app_colors.dart';
import 'theme/app_effects.dart';
import 'theme/app_text.dart';

/// Pasangan label kecil + nilai (mis. "Aging" / "14 hari").
class InfoPair extends StatelessWidget {
  const InfoPair({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.subheading,
        ),
      ],
    );
  }
}

class _VehicleBadge extends StatelessWidget {
  const _VehicleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.sageSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.directions_car_filled_rounded,
        size: 21,
        color: AppColors.brandDeep,
      ),
    );
  }
}

/// Kartu prioritas unit di dashboard Kepala Bengkel. Peringkat teratas
/// ([isHero]) memakai isi sage lembut dan garis aksen.
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
    final dikerjakan = statusPengerjaan != 'menunggu';
    final StatusLevel level = dikerjakan
        ? StatusLevel.info
        : (siap ? StatusLevel.good : StatusLevel.warn);
    final pal = AppColors.status(level);
    final statusLabel = dikerjakan
        ? labelPengerjaan(statusPengerjaan)
        : (siap ? 'Siap dikerjakan' : 'Ditahan');

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.out,
        padding: const EdgeInsets.all(16),
        decoration: appCardDecoration(
          color: isHero ? AppColors.sageSoft : AppColors.card,
          border: isHero ? AppColors.brand : AppColors.line,
          borderWidth: isHero ? 1.4 : 1,
          shadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RankTag(rank: entry.peringkat, hero: isHero),
                      const SizedBox(height: 10),
                      Text(
                        unit.tipeKendaraan,
                        style: AppText.heading.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(unit.noWO, style: AppText.mono),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ScoreRing(
                  value: entry.nilaiUi,
                  color: color,
                  size: 60,
                  strokeWidth: 5,
                ),
              ],
            ),
            const SizedBox(height: 12),
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
              style: AppText.bodyMuted.copyWith(fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: InfoPair(label: 'Panel', value: '${unit.jumlahPanel}'),
                ),
                Expanded(
                  child: InfoPair(
                    label: 'Aging',
                    value: '${unit.agingHari} hari',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InfoPair(
                    label: 'Estimasi biaya',
                    value: 'Rp ${formatRupiah(unit.estimasiBiaya)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                StatusChip.sparepart(unit.statusSparepart, prefix: 'Part '),
                StatusChip.spk(unit.statusSpkAsuransi, prefix: 'SPK '),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                PulsingDot(
                  color: pal.fill,
                  size: 7,
                  pulse: !dikerjakan && siap,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: AppText.label.copyWith(
                      color: pal.fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!dikerjakan)
                  AppButton(
                    label: 'Terbitkan',
                    icon: Icons.arrow_forward_rounded,
                    height: 42,
                    expand: false,
                    isLoading: isProcessing,
                    onPressed: (siap && !isProcessing)
                        ? onTerbitkanInstruksi
                        : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankTag extends StatelessWidget {
  const _RankTag({required this.rank, required this.hero});

  final int rank;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hero ? AppColors.brand : AppColors.sage,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hero ? 'Prioritas utama · #$rank' : 'Peringkat $rank',
        style: AppText.caption.copyWith(
          color: hero ? Colors.white : AppColors.brandDeep,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Kartu unit di dashboard Service Advisor: info unit, edit, hapus.
class SaUnitCard extends StatelessWidget {
  const SaUnitCard({
    super.key,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
  });

  final UnitWip unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = unit.tanggalMasuk;
    final tanggal = '${d.day}/${d.month}/${d.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(shadow: AppShadows.soft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const _VehicleBadge(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.tipeKendaraan,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.heading.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            unit.noWO,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.mono,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _IconAction(
                icon: Icons.edit_outlined,
                color: AppColors.brand,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _IconAction(
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                onTap: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.lineSoft),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InfoPair(label: 'Masuk', value: tanggal),
              ),
              Expanded(
                child: InfoPair(
                  label: 'Aging',
                  value: '${unit.agingHari} hari',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InfoPair(
                  label: 'Panel',
                  value: '${unit.jumlahPanel} panel',
                ),
              ),
              Expanded(
                child: InfoPair(
                  label: 'Estimasi biaya',
                  value: 'Rp ${formatRupiah(unit.estimasiBiaya)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip.sparepart(unit.statusSparepart, prefix: 'Part '),
              StatusChip.spk(unit.statusSpkAsuransi, prefix: 'SPK '),
              Text('diisi Partman', style: AppText.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.88,
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}

/// Kartu unit di dashboard Partman. Chip status bisa diketuk langsung
/// untuk mengubah (tidak ada tombol "Ubah" terpisah).
class PartmanUnitCard extends StatelessWidget {
  const PartmanUnitCard({
    super.key,
    required this.unit,
    required this.onUbahSparepart,
    required this.onUbahSpk,
  });

  final UnitWip unit;
  final VoidCallback onUbahSparepart;
  final VoidCallback onUbahSpk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(shadow: AppShadows.soft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _VehicleBadge(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.tipeKendaraan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.heading.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      unit.noWO,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.mono,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.lineSoft),
          const SizedBox(height: 12),
          _StatusRow(
            label: 'Sparepart',
            chip: StatusChip.sparepart(
              unit.statusSparepart,
              onTap: onUbahSparepart,
            ),
          ),
          const SizedBox(height: 10),
          _StatusRow(
            label: 'SPK asuransi',
            chip: StatusChip.spk(unit.statusSpkAsuransi, onTap: onUbahSpk),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.chip});

  final String label;
  final Widget chip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.bodyMuted),
        chip,
      ],
    );
  }
}
