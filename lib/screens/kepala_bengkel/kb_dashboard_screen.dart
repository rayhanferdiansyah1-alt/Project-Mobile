import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';
import '../../utils/page_transitions.dart';
import '../../utils/wip_format.dart';
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

  late final Stream<List<UnitWip>> _unitStream = _repo.watchUnitWip();
  late final Stream<List<RankingEntry>> _rankingStream = _repo
      .watchHasilRanking();

  Future<void> _manualRecompute() async {
    setState(() => _isRecomputing = true);
    try {
      await _repo.recomputeAndSaveRanking();
      if (mounted) {
        showSuccessSnackbar(context, 'Ranking berhasil dihitung ulang.');
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
        showSuccessSnackbar(
          context,
          'Instruksi diterbitkan untuk ${unit.noWO}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menerbitkan instruksi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processingUnitId = null);
    }
  }

  void _openDetail(UnitWip unit, RankingEntry entry, int totalUnit) {
    Navigator.push(
      context,
      fadeSlideRoute<void>(
        child: KbUnitDetailScreen(
          unit: unit,
          entry: entry,
          totalUnit: totalUnit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: UnitWipStreamView(
        stream: _unitStream,
        builder: (context, units) {
          final unitById = {for (final u in units) u.id: u};

          return StreamBuilder<List<RankingEntry>>(
            stream: _rankingStream,
            builder: (context, rankingSnapshot) {
              if (rankingSnapshot.hasError) {
                return Center(
                  child: Text('Terjadi kesalahan: ${rankingSnapshot.error}'),
                );
              }
              if (!rankingSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              final ranking = rankingSnapshot.data!;
              final totalUnit = ranking.length;
              bool isMenunggu(UnitWip u) => u.statusPengerjaan == 'menunggu';
              bool isSiap(UnitWip u) => isSiapDikerjakan(
                statusSparepart: u.statusSparepart,
                statusSpkAsuransi: u.statusSpkAsuransi,
              );

              var siapCount = 0;
              var ditahanCount = 0;
              String? heroUnitId;
              DateTime? dihitungPada;
              for (final e in ranking) {
                if (dihitungPada == null ||
                    e.dihitungPada.isAfter(dihitungPada)) {
                  dihitungPada = e.dihitungPada;
                }
                final u = unitById[e.unitId];
                if (u == null || !isMenunggu(u)) continue;
                heroUnitId ??= u.id;
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
                      padding: const EdgeInsets.fromLTRB(20, 21, 20, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Text(
                              'Daftar unit',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.5,
                              ),
                            ),
                          ),
                          Text(
                            '${filtered.length} UNIT',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
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
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Text(
                          'DIURUTKAN BERDASARKAN PRIORITAS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 360),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 28,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _filter == _FilterMode.semua
                                      ? Icons.directions_car_outlined
                                      : Icons.filter_alt_off_outlined,
                                  color: AppColors.accentDark,
                                  size: 25,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _filter == _FilterMode.semua
                                      ? 'Belum ada unit WIP'
                                      : 'Tidak ada unit pada kategori ini',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Unit akan muncul di sini setelah data tersedia.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                                onTap: () =>
                                    _openDetail(unit, entry, totalUnit),
                                onTerbitkanInstruksi:
                                    unit.statusPengerjaan == 'menunggu'
                                    ? () => _terbitkanInstruksi(unit)
                                    : null,
                                statusPengerjaan: unit.statusPengerjaan,
                              ),
                            ),
                          );
                        }, childCount: filtered.length),
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
