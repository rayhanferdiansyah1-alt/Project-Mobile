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

  bool _perluUpdate(UnitWip u) {
    return u.statusSparepart != 'ready' || u.statusSpkAsuransi != 'disetujui';
  }

  Future<void> _ubahSparepart(UnitWip unit) async {
    final changed = await showSparepartUpdateSheet(
      context,
      unit: unit,
      repo: _repo,
    );
    if (changed == true && mounted) _showSuccessSnackbar();
  }

  Future<void> _ubahSpk(UnitWip unit) async {
    final changed = await showSpkUpdateSheet(context, unit: unit, repo: _repo);
    if (changed == true && mounted) _showSuccessSnackbar();
  }

  void _showSuccessSnackbar() {
    showSuccessSnackbar(
      context,
      'Status berhasil diperbarui. Ranking dihitung ulang.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: UnitWipStreamView(
        stream: _repo.watchUnitWip(),
        builder: (context, allUnits) {
          final perluUpdateCount = allUnits.where(_perluUpdate).length;
          final filtered = _filter == _FilterMode.perluUpdate
              ? allUnits.where(_perluUpdate).toList()
              : allUnits;

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: PartmanHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: PillTabs<_FilterMode>(
                    current: _filter,
                    items: [
                      PillTabItem(
                        _FilterMode.perluUpdate,
                        'Perlu update $perluUpdateCount',
                      ),
                      PillTabItem(
                        _FilterMode.semua,
                        'Semua ${allUnits.length}',
                      ),
                    ],
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Tidak ada unit pada kategori ini.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final unit = filtered[index];
                      return StaggeredFadeIn(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PartmanUnitCard(
                            unit: unit,
                            onUbahSparepart: () => _ubahSparepart(unit),
                            onUbahSpk: () => _ubahSpk(unit),
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
