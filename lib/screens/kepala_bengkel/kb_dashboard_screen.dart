import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';
import '../../utils/wip_format.dart';
import 'kb_unit_detail_screen.dart';

/// Urutan enum = urutan tab pada navigasi bawah:
/// Semua, Dikerjakan, Selesai, Siap, Ditahan.
enum _FilterMode { semua, dikerjakan, selesai, siap, ditahan }

/// Dialog konfirmasi sebelum unit ditandai selesai. Dipakai juga oleh
/// layar detail. Mengembalikan true kalau Kepala Bengkel menekan "Selesai".
Future<bool?> confirmSelesai(BuildContext context, String noWO) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tandai unit selesai?'),
      content: Text(
        'WO $noWO akan dikeluarkan dari daftar prioritas dan ranking unit '
        'lain dihitung ulang.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Selesai'),
        ),
      ],
    ),
  );
}

class KbDashboardScreen extends StatefulWidget {
  const KbDashboardScreen({super.key});

  @override
  State<KbDashboardScreen> createState() => _KbDashboardScreenState();
}

class _KbDashboardScreenState extends State<KbDashboardScreen> {
  final _repo = UnitWipRepository();
  final _scrollController = ScrollController();
  String? _processingUnitId;
  bool _isRecomputing = false;
  _FilterMode _filter = _FilterMode.semua;

  late final Stream<List<UnitWip>> _unitStream = _repo.watchUnitWip();
  late final Stream<List<RankingEntry>> _rankingStream = _repo
      .watchHasilRanking();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeFilter(_FilterMode f) {
    if (f == _filter) return;
    setState(() => _filter = f);
    // Pindah tab selalu mulai dari atas daftar.
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  String get _sectionLabel {
    switch (_filter) {
      case _FilterMode.semua:
        return 'Urutan prioritas';
      case _FilterMode.dikerjakan:
        return 'Sedang dikerjakan';
      case _FilterMode.selesai:
        return 'Riwayat selesai';
      case _FilterMode.siap:
        return 'Siap dikerjakan';
      case _FilterMode.ditahan:
        return 'Ditahan';
    }
  }

  Future<void> _manualRecompute() async {
    if (_isRecomputing) return;
    setState(() => _isRecomputing = true);
    try {
      await _repo.recomputeAndSaveRanking();
      if (mounted) {
        showAppSnackbar(context, 'Ranking berhasil dihitung ulang.');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(context, 'Gagal recompute: $e', kind: SnackKind.error);
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
        showAppSnackbar(context, 'Instruksi diterbitkan untuk ${unit.noWO}');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Gagal menerbitkan instruksi: $e',
          kind: SnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _processingUnitId = null);
    }
  }

  Future<void> _selesaikanUnit(UnitWip unit) async {
    final ok = await confirmSelesai(context, unit.noWO);
    if (ok != true || !mounted) return;

    setState(() => _processingUnitId = unit.id);
    try {
      await _repo.selesaikanUnit(unit.id);
      if (mounted) {
        showAppSnackbar(context, '${unit.noWO} selesai, ranking diperbarui.');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Gagal menandai selesai: $e',
          kind: SnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _processingUnitId = null);
    }
  }

  void _openDetail(UnitWip unit, RankingEntry entry, int totalUnit) {
    // Transisi halaman diatur oleh AppTheme (fade + naik tipis).
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            KbUnitDetailScreen(unit: unit, entry: entry, totalUnit: totalUnit),
      ),
    );
  }

  /// Kerangka layar untuk kondisi tanpa data (memuat / error): tanpa
  /// navigasi bawah karena hitungannya belum ada.
  Widget _plainScaffold(Widget body) {
    return Scaffold(backgroundColor: AppColors.canvas, body: body);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UnitWip>>(
      stream: _unitStream,
      builder: (context, unitSnapshot) {
        if (unitSnapshot.hasError) {
          return _plainScaffold(
            EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Terjadi kesalahan',
              message: '${unitSnapshot.error}',
            ),
          );
        }
        if (!unitSnapshot.hasData) return _plainScaffold(const PageSkeleton());
        final unitById = {for (final u in unitSnapshot.data!) u.id: u};

        return StreamBuilder<List<RankingEntry>>(
          stream: _rankingStream,
          builder: (context, rankingSnapshot) {
            if (rankingSnapshot.hasError) {
              return _plainScaffold(
                EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Terjadi kesalahan',
                  message: '${rankingSnapshot.error}',
                ),
              );
            }
            if (!rankingSnapshot.hasData) {
              return _plainScaffold(const PageSkeleton());
            }

            // Hanya unit aktif. Unit `selesai` tidak masuk ranking; entri
            // basi (sebelum recompute selesai) ikut disaring di sini.
            final ranking = rankingSnapshot.data!.where((e) {
              final u = unitById[e.unitId];
              return u != null && u.statusPengerjaan != 'selesai';
            }).toList();
            final totalUnit = ranking.length;

            // Riwayat: unit selesai, yang paling baru selesai di atas.
            final selesaiUnits =
                unitSnapshot.data!
                    .where((u) => u.statusPengerjaan == 'selesai')
                    .toList()
                  ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            final showSelesai = _filter == _FilterMode.selesai;
            final listCount = showSelesai
                ? selesaiUnits.length
                : null; // diisi setelah `filtered` dihitung
            bool isMenunggu(UnitWip u) => u.statusPengerjaan == 'menunggu';
            bool isSiap(UnitWip u) => isSiapDikerjakan(
              statusSparepart: u.statusSparepart,
              statusSpkAsuransi: u.statusSpkAsuransi,
            );

            var siapCount = 0;
            var ditahanCount = 0;
            var dikerjakanCount = 0;
            String? heroUnitId; // unit 'menunggu' dengan peringkat tertinggi
            DateTime? dihitungPada;
            for (final e in ranking) {
              if (dihitungPada == null || e.dihitungPada.isAfter(dihitungPada)) {
                dihitungPada = e.dihitungPada;
              }
              final u = unitById[e.unitId];
              if (u == null) continue;
              if (!isMenunggu(u)) {
                dikerjakanCount++;
                continue;
              }
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
                case _FilterMode.selesai:
                  return false; // daftar selesai dibangun dari selesaiUnits
              }
            }).toList();
            final itemCount = listCount ?? filtered.length;

            return Scaffold(
              backgroundColor: AppColors.canvas,
              bottomNavigationBar: AppBottomNav<_FilterMode>(
                current: _filter,
                onChanged: _changeFilter,
                items: [
                  BottomNavItem(
                    value: _FilterMode.semua,
                    label: 'Semua',
                    icon: Icons.view_list_outlined,
                    activeIcon: Icons.view_list_rounded,
                    count: totalUnit,
                  ),
                  BottomNavItem(
                    value: _FilterMode.dikerjakan,
                    label: 'Dikerjakan',
                    icon: Icons.handyman_outlined,
                    activeIcon: Icons.handyman_rounded,
                    count: dikerjakanCount,
                  ),
                  BottomNavItem(
                    value: _FilterMode.selesai,
                    label: 'Selesai',
                    icon: Icons.check_circle_outline_rounded,
                    activeIcon: Icons.check_circle_rounded,
                    count: selesaiUnits.length,
                  ),
                  BottomNavItem(
                    value: _FilterMode.siap,
                    label: 'Siap',
                    icon: Icons.play_circle_outline_rounded,
                    activeIcon: Icons.play_circle_rounded,
                    count: siapCount,
                    badgeColor: AppColors.success,
                  ),
                  BottomNavItem(
                    value: _FilterMode.ditahan,
                    label: 'Ditahan',
                    icon: Icons.pause_circle_outline_rounded,
                    activeIcon: Icons.pause_circle_rounded,
                    count: ditahanCount,
                    badgeColor: AppColors.warningText,
                  ),
                ],
              ),
              body: RefreshIndicator(
                color: AppColors.brand,
                backgroundColor: AppColors.card,
                onRefresh: _manualRecompute,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
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
                    if (itemCount > 0)
                      SliverToBoxAdapter(
                        child: AppContent(
                          maxWidth: 900,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(22, 22, 20, 10),
                            child: Text(_sectionLabel, style: AppText.label),
                          ),
                        ),
                      ),
                    if (itemCount == 0)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'Tidak ada unit',
                          message: 'Belum ada unit pada kategori ini.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (showSelesai) {
                              return StaggeredFadeIn(
                                key: ValueKey('selesai-${selesaiUnits[index].id}'),
                                index: index,
                                child: AppContent(
                                  maxWidth: 900,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: FinishedUnitCard(
                                      unit: selesaiUnits[index],
                                    ),
                                  ),
                                ),
                              );
                            }
                            final entry = filtered[index];
                            final unit = unitById[entry.unitId];
                            if (unit == null) return const SizedBox.shrink();

                            final siap = isSiapDikerjakan(
                              statusSparepart: unit.statusSparepart,
                              statusSpkAsuransi: unit.statusSpkAsuransi,
                            );
                            final isHero = unit.id == heroUnitId;

                            // Key memuat filter: daftar muncul ulang
                            // bertahap setiap tab diganti.
                            return StaggeredFadeIn(
                              key: ValueKey('${_filter.name}-${unit.id}'),
                              index: index,
                              child: AppContent(
                                maxWidth: 900,
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
                                    onSelesai:
                                        unit.statusPengerjaan ==
                                            'sedang_dikerjakan'
                                        ? () => _selesaikanUnit(unit)
                                        : null,
                                    statusPengerjaan: unit.statusPengerjaan,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: itemCount),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}