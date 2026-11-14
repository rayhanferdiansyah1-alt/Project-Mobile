import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../theme/app_effects.dart';
import '../status_pill.dart';

/// Kartu unit di dashboard Partman: status sparepart & SPK + tombol Ubah.
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
    final primary = Theme.of(context).colorScheme.primary;

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
          Text(unit.tipeKendaraan,
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
          Text(unit.noWO, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          _StatusRow(
            label: 'Sparepart',
            pill: StatusPill.sparepart(unit.statusSparepart),
            primary: primary,
            onUbah: onUbahSparepart,
          ),
          const SizedBox(height: 8),
          _StatusRow(
            label: 'SPK Asuransi',
            pill: StatusPill.spk(unit.statusSpkAsuransi),
            primary: primary,
            onUbah: onUbahSpk,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.pill,
    required this.primary,
    required this.onUbah,
  });

  final String label;
  final StatusPill pill;
  final Color primary;
  final VoidCallback onUbah;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 92, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
        pill,
        const Spacer(),
        OutlinedButton(
          onPressed: onUbah,
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: BorderSide(color: primary),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Ubah', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
