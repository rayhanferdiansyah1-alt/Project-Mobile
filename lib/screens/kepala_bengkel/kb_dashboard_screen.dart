import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../utils/wip_format.dart';
import '../../widgets/app_user_menu.dart';
import '../../widgets/score_ring.dart';
import '../../widgets/staggered_fade_in.dart';
import 'kb_unit_detail_screen.dart';

enum _FilterMode { semua, siap, ditahan }

class KbDashboardScreen extends StatefulWidget {
  const KbDashboardScreen({super.key});

  @override
  State<KbDashboardScreen> createState() => _KbDashboardScreenState();
}

class _KbDashboardScreenState extends State<KbDashboardScreen> {
  final _repo = UnitWipRepository();
  String? _processingUnitId;
  bool _isRecomputing = false;
  _FilterMode _filter = _FilterMode.semua;

  Future<void> _manualRecompute() async {
    setState(() => _isRecomputing = true);
    try {
      await _repo.recomputeAndSaveRanking();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal recompute: $e')));
      }
    } finally {
      if (mounted) setState(() => _isRecomputing = false);
    }
  }

  Future<void> _terbitkanInstruksi(UnitWip unit) async {
    setState(() => _processingUnitId = unit.id);
    try {
      await _repo.updateUnitFields(unit.id, {'statusPengerjaan': 'sedang_dikerjakan'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instruksi diterbitkan untuk ${unit.noWO}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menerbitkan instruksi: $e')));
      }
    } finally {
      if (mounted) setState(() => _processingUnitId = null);
    }
  }

  void _openDetail(UnitWip unit, RankingEntry entry, int totalUnit) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => KbUnitDetailScreen(
          unit: unit,
          entry: entry,
          totalUnit: totalUnit,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  Color _scoreColor(double ui) {
    if (ui >= 0.75) return const Color(0xFF1F9D6B);
    if (ui >= 0.5) return const Color(0xFFFF8A00);
    return const Color(0xFFB23B1E);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F4),
      body: StreamBuilder<List<UnitWip>>(
        stream: _repo.watchUnitWip(),
        builder: (context, unitSnapshot) {
          if (unitSnapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${unitSnapshot.error}'));
          }
          if (!unitSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final unitById = {for (final u in unitSnapshot.data!) u.id: u};

          return StreamBuilder<List<RankingEntry>>(
            stream: _repo.watchHasilRanking(),
            builder: (context, rankingSnapshot) {
              if (rankingSnapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${rankingSnapshot.error}'));
              }
              if (!rankingSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final ranking = rankingSnapshot.data!;
              final totalUnit = ranking.length;
              final siapCount = ranking.where((e) {
                final u = unitById[e.unitId];
                if (u == null) return false;
                return isSiapDikerjakan(
                  statusSparepart: u.statusSparepart,
                  statusSpkAsuransi: u.statusSpkAsuransi,
                );
              }).length;
              final ditahanCount = totalUnit - siapCount;

              final filtered = ranking.where((e) {
                final u = unitById[e.unitId];
                if (u == null) return false;
                final siap = isSiapDikerjakan(
                  statusSparepart: u.statusSparepart,
                  statusSpkAsuransi: u.statusSpkAsuransi,
                );
                switch (_filter) {
                  case _FilterMode.semua:
                    return true;
                  case _FilterMode.siap:
                    return siap;
                  case _FilterMode.ditahan:
                    return !siap;
                }
              }).toList();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      primary: primary,
                      totalUnit: totalUnit,
                      siapCount: siapCount,
                      ditahanCount: ditahanCount,
                      isRecomputing: _isRecomputing,
                      onRefresh: _manualRecompute,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: _FilterTabs(
                        current: _filter,
                        onChanged: (f) => setState(() => _filter = f),
                      ),
                    ),
                  ),
                  if (totalUnit > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Text(
                          'PRIORITAS UTAMA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  if (filtered.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Tidak ada unit pada kategori ini.')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = filtered[index];
                            final unit = unitById[entry.unitId];
                            if (unit == null) return const SizedBox.shrink();

                            final siap = isSiapDikerjakan(
                              statusSparepart: unit.statusSparepart,
                              statusSpkAsuransi: unit.statusSpkAsuransi,
                            );
                            final isHero = entry.peringkat == 1;

                            return StaggeredFadeIn(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _PriorityCard(
                                  entry: entry,
                                  unit: unit,
                                  totalUnit: totalUnit,
                                  siap: siap,
                                  isHero: isHero,
                                  color: _scoreColor(entry.nilaiUi),
                                  isProcessing: _processingUnitId == unit.id,
                                  onTap: () => _openDetail(unit, entry, totalUnit),
                                  onTerbitkanInstruksi: unit.statusPengerjaan == 'menunggu'
                                      ? () => _terbitkanInstruksi(unit)
                                      : null,
                                  statusPengerjaan: unit.statusPengerjaan,
                                ),
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// ===== Header gelap dengan stat cards =====
class _Header extends StatelessWidget {
  const _Header({
    required this.primary,
    required this.totalUnit,
    required this.siapCount,
    required this.ditahanCount,
    required this.isRecomputing,
    required this.onRefresh,
  });

  final Color primary;
  final int totalUnit;
  final int siapCount;
  final int ditahanCount;
  final bool isRecomputing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tanggal = '${now.day} ${_bulan(now.month)} ${now.year}';

    return ClipPath(
      clipper: _HeaderCurveClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 50),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(primary, Colors.black, 0.1)!,
              Color.lerp(primary, Colors.black, 0.4)!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'KEPALA BENGKEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
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
            const Text(
              'Dashboard Prioritas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unit WIP Bodi dan Cat, $tanggal',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2_outlined,
                    value: '$totalUnit',
                    label: 'Unit WIP',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    value: '$siapCount',
                    label: 'Siap dikerjakan',
                    color: const Color(0xFF34D399),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.pause_circle_outline,
                    value: '$ditahanCount',
                    label: 'Ditahan',
                    color: const Color(0xFFFFB020),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _bulan(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return names[m - 1];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== Filter tabs pill =====
class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.current, required this.onChanged});

  final _FilterMode current;
  final ValueChanged<_FilterMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget tab(_FilterMode mode, String label) {
      final selected = current == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade600,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          tab(_FilterMode.semua, 'Semua'),
          tab(_FilterMode.siap, 'Siap'),
          tab(_FilterMode.ditahan, 'Ditahan'),
        ],
      ),
    );
  }
}

/// ===== Kartu prioritas unit =====
class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
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
    final fgColor = isHero ? Colors.white : const Color(0xFF14181F);
    final mutedColor = isHero ? Colors.white.withValues(alpha: 0.75) : Colors.grey.shade600;
    final ringColor = isHero ? Colors.amber : color;

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
                color: (isHero ? primary : Colors.black).withValues(alpha: isHero ? 0.25 : 0.05),
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
                  color: isHero
                      ? Colors.amber
                      : (isHero ? primary : primary.withValues(alpha: 0.1)),
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
                      ),
                      style: TextStyle(fontSize: 12, color: mutedColor, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MiniChip('${unit.jumlahPanel} panel', isHero),
                        _MiniChip('Part: ${labelSparepart(unit.statusSparepart)}', isHero),
                        _MiniChip('SPK: ${labelSpk(unit.statusSpkAsuransi)}', isHero),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aging ${unit.agingHari} hari',
                      style: TextStyle(fontSize: 11, color: mutedColor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: siap ? const Color(0xFF34D399) : const Color(0xFFFFB020),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              siap ? 'Siap dikerjakan' : 'Ditahan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: siap
                                    ? (isHero ? Colors.greenAccent.shade100 : const Color(0xFF1F9D6B))
                                    : (isHero ? Colors.amber.shade100 : const Color(0xFFB36B00)),
                              ),
                            ),
                          ],
                        ),
                        if (statusPengerjaan == 'menunggu')
                          SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isHero ? Colors.amber : primary,
                                foregroundColor: isHero ? Colors.black87 : Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              onPressed: (siap && !isProcessing) ? onTerbitkanInstruksi : null,
                              child: isProcessing
                                  ? const SizedBox(
                                      width: 14, height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Terbitkan Instruksi',
                                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                            ),
                          )
                        else
                          Chip(
                            label: Text(statusPengerjaan, style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.blue.shade50,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ScoreRing(value: entry.nilaiUi, color: ringColor, textColor: fgColor, size: 52),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.text, this.isHero);
  final String text;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHero ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade100,
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

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 36);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}