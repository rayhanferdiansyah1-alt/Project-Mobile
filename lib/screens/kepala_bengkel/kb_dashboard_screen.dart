import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../utils/wip_format.dart';
import '../../ui/components/cards/priority_card.dart';
import '../../ui/components/headers/kb_header.dart';
import '../../ui/components/pill_tabs.dart';
import '../../ui/components/staggered_fade_in.dart';
import '../../ui/theme/app_colors.dart';
import 'kb_unit_detail_screen.dart';

enum _FilterMode { semua, siap, ditahan, dikerjakan }

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

  // Stream dibuat sekali, bukan tiap build, supaya tidak berlangganan ulang
  // setiap kali filter diganti.
  late final Stream<List<UnitWip>> _unitStream = _repo.watchUnitWip();
  late final Stream<List<RankingEntry>> _rankingStream = _repo.watchHasilRanking();

  Future<void> _manualRecompute() async {
    setState(() => _isRecomputing = true);
    try {
      await _repo.recomputeAndSaveRanking();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ranking berhasil dihitung ulang.')),
        );
      }
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
      await _repo.terbitkanInstruksi(unit.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: StreamBuilder<List<UnitWip>>(
        stream: _unitStream,
        builder: (context, unitSnapshot) {
          if (unitSnapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${unitSnapshot.error}'));
          }
          if (!unitSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final unitById = {for (final u in unitSnapshot.data!) u.id: u};

          return StreamBuilder<List<RankingEntry>>(
            stream: _rankingStream,
            builder: (context, rankingSnapshot) {
              if (rankingSnapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${rankingSnapshot.error}'));
              }
              if (!rankingSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final ranking = rankingSnapshot.data!;
              final totalUnit = ranking.length;
              // Hanya unit yang masih 'menunggu' yang dihitung siap/ditahan.
              // Unit yang sudah diinstruksikan tetap tampil di ranking, tapi
              // dipisah lewat tab "Dikerjakan".
              bool isMenunggu(UnitWip u) => u.statusPengerjaan == 'menunggu';
              bool isSiap(UnitWip u) => isSiapDikerjakan(
                    statusSparepart: u.statusSparepart,
                    statusSpkAsuransi: u.statusSpkAsuransi,
                  );

              var siapCount = 0;
              var ditahanCount = 0;
              String? heroUnitId; // unit 'menunggu' dengan peringkat tertinggi
              DateTime? dihitungPada;
              for (final e in ranking) {
                if (dihitungPada == null || e.dihitungPada.isAfter(dihitungPada)) {
                  dihitungPada = e.dihitungPada;
                }
                final u = unitById[e.unitId];
                if (u == null || !isMenunggu(u)) continue;
                heroUnitId ??= u.id; // ranking sudah terurut per peringkat
                if (isSiap(u)) {
                  siapCount++;
                } else {
                  ditahanCount++;
                }
              }

              final filtered = ranking.where((e) {
                final u = unitById[e.unitId];
                if (u == null) return false;
                switch (_filter) {
                  case _FilterMode.semua:
                    return true;
                  case _FilterMode.siap:
                    return isMenunggu(u) && isSiap(u);
                  case _FilterMode.ditahan:
                    return isMenunggu(u) && !isSiap(u);
                  case _FilterMode.dikerjakan:
                    return !isMenunggu(u);
                }
              }).toList();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: KbHeader(
                      totalUnit: totalUnit,
                      siapCount: siapCount,
                      ditahanCount: ditahanCount,
                      dihitungPada: dihitungPada,
                      isRecomputing: _isRecomputing,
                      onRefresh: _manualRecompute,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: PillTabs<_FilterMode>(
                        current: _filter,
                        fitLabels: true,
                        items: const [
                          PillTabItem(_FilterMode.semua, 'Semua'),
                          PillTabItem(_FilterMode.siap, 'Siap'),
                          PillTabItem(_FilterMode.ditahan, 'Ditahan'),
                          PillTabItem(_FilterMode.dikerjakan, 'Dikerjakan'),
                        ],
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
                            final isHero = unit.id == heroUnitId;

                            return StaggeredFadeIn(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: PriorityCard(
                                  entry: entry,
                                  unit: unit,
                                  totalUnit: totalUnit,
                                  siap: siap,
                                  isHero: isHero,
                                  color: AppColors.scoreColor(entry.nilaiUi),
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
