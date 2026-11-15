import 'package:flutter/material.dart';

import '../models/unit_wip.dart';
import '../services/unit_wip_repository.dart';
import '../utils/wip_format.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

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
  final bool siap, isHero, isProcessing;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onTerbitkanInstruksi;
  final String statusPengerjaan;
  @override
  Widget build(BuildContext context) {
    final active = statusPengerjaan != 'menunggu';
    final statusColor = active
        ? AppColors.info
        : siap
        ? AppColors.success
        : AppColors.warningText;
    final label = active
        ? labelPengerjaan(statusPengerjaan)
        : siap
        ? 'Siap dikerjakan'
        : 'Menunggu kesiapan';
    final recommendation = rekomendasiText(
      peringkat: entry.peringkat,
      totalUnit: totalUnit,
      statusSparepart: unit.statusSparepart,
      statusSpkAsuransi: unit.statusSpkAsuransi,
      jumlahPanel: unit.jumlahPanel,
      agingHari: unit.agingHari,
      statusPengerjaan: statusPengerjaan,
    );

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isHero ? AppColors.accent : AppColors.border,
              width: isHero ? 1.25 : 1,
            ),
            boxShadow: isHero ? AppShadows.card : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'PRIORITAS ${entry.peringkat.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isHero
                                    ? AppColors.accentDark
                                    : AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.15,
                              ),
                            ),
                            if (isHero) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          unit.tipeKendaraan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'WO  ${unit.noWO}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScoreRing(
                    value: entry.nilaiUi,
                    color: color,
                    textColor: AppColors.textPrimary,
                    size: 48,
                    strokeWidth: 4,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                recommendation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MetaChip(
                    icon: Icons.build_outlined,
                    text: '${unit.jumlahPanel} panel',
                  ),
                  _MetaChip(
                    icon: Icons.inventory_2_outlined,
                    text: labelSparepart(unit.statusSparepart),
                  ),
                  _MetaChip(
                    icon: Icons.description_outlined,
                    text: labelSpk(unit.statusSpkAsuransi),
                  ),
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    text: '${unit.agingHari} hari',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.border.withValues(alpha: .8)),
              const SizedBox(height: 5),
              Row(
                children: [
                  PulsingStatusDot(color: statusColor, pulse: false, size: 7),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!active)
                    TextButton.icon(
                      onPressed: siap && !isProcessing
                          ? onTerbitkanInstruksi
                          : null,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: Text(
                        isProcessing ? 'Memproses' : 'Terbitkan',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accentDark,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class MiniChip extends StatelessWidget {
  const MiniChip(this.text, this.isHero, {super.key});
  final String text;
  final bool isHero;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.textMuted,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class PartmanUnitCard extends StatelessWidget {
  const PartmanUnitCard({
    super.key,
    required this.unit,
    required this.onUbahSparepart,
    required this.onUbahSpk,
  });
  final UnitWip unit;
  final VoidCallback onUbahSparepart, onUbahSpk;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.card,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UnitHeading(unit: unit),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 13),
          child: Divider(height: 1),
        ),
        _StatusRow(
          label: 'Sparepart',
          statusKey: unit.statusSparepart,
          pill: StatusPill.sparepart(unit.statusSparepart),
          onUbah: onUbahSparepart,
        ),
        const SizedBox(height: 10),
        _StatusRow(
          label: 'SPK Asuransi',
          statusKey: unit.statusSpkAsuransi,
          pill: StatusPill.spk(unit.statusSpkAsuransi),
          onUbah: onUbahSpk,
        ),
      ],
    ),
  );
}

class _UnitHeading extends StatelessWidget {
  const _UnitHeading({required this.unit});
  final UnitWip unit;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.directions_car_outlined,
          color: AppColors.accentDark,
          size: 19,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit.tipeKendaraan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              unit.noWO,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.statusKey,
    required this.pill,
    required this.onUbah,
  });
  final String label, statusKey;
  final StatusPill pill;
  final VoidCallback onUbah;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        flex: 3,
        child: Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
      ),
      Expanded(
        flex: 4,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(key: ValueKey(statusKey), child: pill),
          ),
        ),
      ),
      TextButton(
        onPressed: onUbah,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentDark,
          minimumSize: const Size(48, 36),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text(
          'Ubah',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class SaUnitCard extends StatelessWidget {
  const SaUnitCard({
    super.key,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
  });
  final UnitWip unit;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.card,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _UnitHeading(unit: unit)),
            IconButton(
              tooltip: 'Edit unit',
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.edit_outlined,
                size: 19,
                color: AppColors.textMuted,
              ),
            ),
            IconButton(
              tooltip: 'Hapus unit',
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 19,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1),
        ),
        Row(
          children: [
            Expanded(
              child: _InfoPair(
                label: 'Tanggal masuk',
                value:
                    '${unit.tanggalMasuk.day}/${unit.tanggalMasuk.month}/${unit.tanggalMasuk.year}',
              ),
            ),
            Expanded(
              child: _InfoPair(
                label: 'Panel',
                value: '${unit.jumlahPanel} panel',
              ),
            ),
            Expanded(
              child: _InfoPair(label: 'Aging', value: '${unit.agingHari} hari'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _InfoPair(
          label: 'Estimasi biaya',
          value: 'Rp ${formatRupiah(unit.estimasiBiaya)}',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 6,
          children: [
            _StatusWithUsername(
              status: StatusPill.sparepart(unit.statusSparepart),
              username: unit.statusSparepartUpdatedBy,
            ),
            _StatusWithUsername(
              status: StatusPill.spk(unit.statusSpkAsuransi),
              username: unit.statusSpkAsuransiUpdatedBy,
            ),
          ],
        ),
      ],
    ),
  );
}

class _StatusWithUsername extends StatelessWidget {
  const _StatusWithUsername({required this.status, required this.username});

  final Widget status;
  final String? username;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      status,
      const SizedBox(width: 5),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 105),
        child: Text(
          username?.isNotEmpty == true ? username! : '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontSize: 11.5,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
