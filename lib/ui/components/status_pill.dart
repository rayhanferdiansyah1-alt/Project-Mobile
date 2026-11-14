import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pill berwarna untuk status sparepart/SPK, skema warna konsisten
/// dengan KB dashboard: hijau = siap, oranye = proses, merah = bermasalah.
class StatusPill extends StatelessWidget {
  const StatusPill._({required this.label, required this._level});

  final String label;
  final _PillLevel _level;

  static StatusPill sparepart(String status) {
    switch (status) {
      case 'ready':
        return const StatusPill._(label: 'Ready', level: _PillLevel.good);
      case 'order_eo':
        return const StatusPill._(label: 'Order EO', level: _PillLevel.warn);
      case 'back_order':
        return const StatusPill._(label: 'Back Order', level: _PillLevel.bad);
      default:
        return StatusPill._(label: status, level: _PillLevel.warn);
    }
  }

  static StatusPill spk(String status) {
    switch (status) {
      case 'disetujui':
        return const StatusPill._(label: 'Disetujui', level: _PillLevel.good);
      case 'proses_klaim':
        return const StatusPill._(label: 'Proses Klaim', level: _PillLevel.warn);
      case 'bermasalah':
        return const StatusPill._(label: 'Bermasalah', level: _PillLevel.bad);
      default:
        return StatusPill._(label: status, level: _PillLevel.warn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (_level) {
      case _PillLevel.good:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        break;
      case _PillLevel.warn:
        bg = AppColors.warning.withValues(alpha: 0.12);
        fg = AppColors.warningText;
        break;
      case _PillLevel.bad:
        bg = AppColors.danger.withValues(alpha: 0.12);
        fg = AppColors.dangerText;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

enum _PillLevel { good, warn, bad }