import 'package:flutter/material.dart';

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
        bg = const Color(0xFF1F9D6B).withValues(alpha: 0.12);
        fg = const Color(0xFF1F9D6B);
        break;
      case _PillLevel.warn:
        bg = const Color(0xFFFF8A00).withValues(alpha: 0.12);
        fg = const Color(0xFFB36B00);
        break;
      case _PillLevel.bad:
        bg = const Color(0xFFE74C3C).withValues(alpha: 0.12);
        fg = const Color(0xFFC0392B);
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