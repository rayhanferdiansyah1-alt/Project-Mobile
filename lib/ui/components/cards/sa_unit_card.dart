import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../utils/wip_format.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_effects.dart';

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
    final tanggal = '${unit.tanggalMasuk.day}/${unit.tanggalMasuk.month}/${unit.tanggalMasuk.year}';
    final sparepartColor = AppColors.wipStatusColor(unit.statusSparepart);
    final spkColor = AppColors.wipStatusColor(unit.statusSpkAsuransi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
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
                    Text(
                      unit.tipeKendaraan,
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      unit.noWO,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _InfoPair(label: 'MASUK', value: tanggal)),
              Expanded(child: _InfoPair(label: 'AGING', value: '${unit.agingHari} hari')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _InfoPair(label: 'PANEL', value: '${unit.jumlahPanel} panel')),
              Expanded(
                child: _InfoPair(label: 'BIAYA', value: 'Rp ${formatRupiah(unit.estimasiBiaya)}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusChip(
                label: 'Part ${labelSparepart(unit.statusSparepart)}',
                color: sparepartColor,
              ),
              _StatusChip(
                label: 'SPK ${labelSpk(unit.statusSpkAsuransi)}',
                color: spkColor,
              ),
              Text(
                'diisi Partman',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
