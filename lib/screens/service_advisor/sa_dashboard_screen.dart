import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';
import '../../utils/page_transitions.dart';
import 'sa_unit_form_screen.dart';

class SaDashboardScreen extends StatefulWidget {
  const SaDashboardScreen({super.key});

  @override
  State<SaDashboardScreen> createState() => _SaDashboardScreenState();
}

class _SaDashboardScreenState extends State<SaDashboardScreen> {
  final _repo = UnitWipRepository();
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm(BuildContext context, {UnitWip? existingUnit}) async {
    final saved = await Navigator.push<bool>(
      context,
      fadeSlideRoute<bool>(
        duration: const Duration(milliseconds: 340),
        child: SaUnitFormScreen(existingUnit: existingUnit),
      ),
    );
    if (context.mounted && saved == true) {
      showSuccessSnackbar(
        context,
        existingUnit == null
            ? 'Unit baru berhasil disimpan, ranking dihitung ulang.'
            : 'Perubahan unit berhasil disimpan, ranking dihitung ulang.',
      );
    }
  }

  void _confirmDelete(BuildContext context, UnitWip unit) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteConfirmDialog(
        unit: unit,
        onConfirm: () async {
          Navigator.pop(ctx);
          try {
            await _repo.deleteUnit(unit.id);
            if (context.mounted) {
              showSuccessSnackbar(
                context,
                'Unit ${unit.noWO} dihapus, ranking dihitung ulang.',
              );
            }
          } catch (e) {
            if (context.mounted) {
              final ditolak = e.toString().contains('permission-denied');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ditolak
                        ? 'Hanya unit yang Anda buat sendiri yang dapat dihapus.'
                        : 'Gagal menghapus unit: $e',
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.surface,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Unit',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: UnitWipStreamView(
        stream: _repo.watchUnitWip(),
        builder: (context, all) {
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? all
              : all
                    .where(
                      (u) =>
                          u.noWO.toLowerCase().contains(q) ||
                          u.tipeKendaraan.toLowerCase().contains(q),
                    )
                    .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 42),
                      child: SaHeader(),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 12,
                      child: WipSearchBar(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
              ),
              if (all.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Belum ada unit WIP. Tekan + Tambah Unit untuk menambah.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Tidak ditemukan unit yang cocok.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final unit = filtered[index];
                      return StaggeredFadeIn(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SaUnitCard(
                            unit: unit,
                            onEdit: () =>
                                _openForm(context, existingUnit: unit),
                            onDelete: () => _confirmDelete(context, unit),
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
