import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../app_user_menu.dart';
import '../stat_card.dart';
import 'curved_header.dart';

/// Header dashboard Kepala Bengkel: judul, tombol hitung ulang, 3 stat card.
class KbHeader extends StatelessWidget {
  const KbHeader({
    super.key,
    required this.totalUnit,
    required this.siapCount,
    required this.ditahanCount,
    required this.dihitungPada,
    required this.isRecomputing,
    required this.onRefresh,
  });

  final int totalUnit;
  final int siapCount;
  final int ditahanCount;
  final DateTime? dihitungPada;
  final bool isRecomputing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tanggal = '${now.day} ${_bulan(now.month)} ${now.year}';

    return CurvedHeader(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 50),
      curveDepth: 36,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const RoleBadge('KEPALA BENGKEL'),
              Row(
                children: [
                  IconButton(
                    icon: isRecomputing
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                    onPressed: isRecomputing ? null : onRefresh,
                  ),
                  const AppUserMenu(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const HeaderTitle('Dashboard Prioritas'),
          const SizedBox(height: 4),
          Text(
            'Unit WIP Bodi dan Cat, $tanggal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12.5,
            ),
          ),
          if (dihitungPada != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Ranking dihitung ${_waktu(dihitungPada!)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.inventory_2_outlined,
                  value: '$totalUnit',
                  label: 'Unit WIP',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle_outline,
                  value: '$siapCount',
                  label: 'Siap dikerjakan',
                  color: AppColors.successBright,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.pause_circle_outline,
                  value: '$ditahanCount',
                  label: 'Ditahan',
                  color: AppColors.amberBright,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _waktu(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_bulan(d.month)} ${d.year}, $hh:$mm';
  }

  String _bulan(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return names[m - 1];
  }
}
