import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';
import 'widgets/sparepart_update_sheet.dart';
import 'widgets/spk_update_sheet.dart';

enum _FilterMode { perluUpdate, semua }

class PartmanDashboardScreen extends StatefulWidget {
  const PartmanDashboardScreen({super.key});

  @override
  State<PartmanDashboardScreen> createState() => _PartmanDashboardScreenState();
}

class _PartmanDashboardScreenState extends State<PartmanDashboardScreen> {
  final _repo = UnitWipRepository();
  _FilterMode _filter = _FilterMode.perluUpdate;

  // Stream dibuat sekali supaya tidak berlangganan ulang saat filter diganti.
  late final Stream<List<UnitWip>> _unitStream = _repo.watchUnitWip();

  bool _perluUpdate(UnitWip u) {
    return u.statusSparepart != 'ready' || u.statusSpkAsuransi != 'disetujui';
  }

  Future<void> _ubahSparepart(UnitWip unit) async {
    final changed = await showSparepartUpdateSheet(
      context,
      unit: unit,
      repo: _repo,
    );
    _notifyStatusChanged(changed);
  }

  Future<void> _ubahSpk(UnitWip unit) async {
    final changed = await showSpkUpdateSheet(context, unit: unit, repo: _repo);
    _notifyStatusChanged(changed);
  }

  void _notifyStatusChanged(bool? changed) {
    if (changed == true && mounted) {
      showAppSnackbar(
        context,
        'Status berhasil diperbarui. Ranking dihitung ulang.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: StreamBuilder<List<UnitWip>>(
        stream: _unitStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Terjadi kesalahan',
              message: '${snapshot.error}',
            );
          }
          if (!snapshot.hasData) return const PageSkeleton();

          final allUnits = snapshot.data!;
          final perluUpdateCount = allUnits.where(_perluUpdate).length;
          final filtered = _filter == _FilterMode.perluUpdate
              ? allUnits.where(_perluUpdate).toList()
              : allUnits;

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: PartmanHeader()),
              SliverToBoxAdapter(
                child: AppContent(
                  maxWidth: 860,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: SegmentFilter<_FilterMode>(
                      current: _filter,
                      items: [
                        SegmentItem(
                          _FilterMode.perluUpdate,
                          'Perlu update',
                          count: perluUpdateCount,
                        ),
                        SegmentItem(
                          _FilterMode.semua,
                          'Semua',
                          count: allUnits.length,
                        ),
                      ],
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: _filter == _FilterMode.perluUpdate
                        ? Icons.task_alt_rounded
                        : Icons.inbox_outlined,
                    title: _filter == _FilterMode.perluUpdate
                        ? 'Semua status sudah lengkap'
                        : 'Belum ada unit',
                    message: _filter == _FilterMode.perluUpdate
                        ? 'Tidak ada unit yang perlu diperbarui saat ini.'
                        : 'Unit yang dibuat Service Advisor akan muncul di sini.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final unit = filtered[index];
                      return StaggeredFadeIn(
                        key: ValueKey('${_filter.name}-${unit.id}'),
                        index: index,
                        child: AppContent(
                          maxWidth: 860,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PartmanUnitCard(
                              unit: unit,
                              onUbahSparepart: () => _ubahSparepart(unit),
                              onUbahSpk: () => _ubahSpk(unit),
                            ),
                          ),
                        ),
                      );
                    }, childCount: filtered.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
