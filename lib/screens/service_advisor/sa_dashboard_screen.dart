import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/components/cards/sa_unit_card.dart';
import '../../ui/components/delete_confirm_dialog.dart';
import '../../ui/components/headers/sa_header.dart';
import '../../ui/components/staggered_fade_in.dart';
import '../../ui/components/wip_search_bar.dart';
import '../../ui/theme/app_colors.dart';
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
    // Form mengembalikan true hanya jika data benar-benar tersimpan.
    // Menekan Batal / Back mengembalikan null, jadi tidak ada snackbar.
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => SaUnitFormScreen(existingUnit: existingUnit),
      ),
    );
    if (context.mounted && saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingUnit == null
              ? 'Unit baru berhasil disimpan, ranking dihitung ulang.'
              : 'Perubahan unit berhasil disimpan, ranking dihitung ulang.'),
        ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unit ${unit.noWO} dihapus, ranking dihitung ulang.'),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              final ditolak = e.toString().contains('permission-denied');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ditolak
                      ? 'Hanya unit yang Anda buat sendiri yang dapat dihapus.'
                      : 'Gagal menghapus unit: $e'),
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
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: AppColors.canvasBlue,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: accent,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Unit', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<UnitWip>>(
        stream: _repo.watchUnitWip(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? all
              : all
                  .where((u) =>
                      u.noWO.toLowerCase().contains(q) ||
                      u.tipeKendaraan.toLowerCase().contains(q))
                  .toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SaHeader()),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WipSearchBar(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),
              ),
              if (all.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Belum ada unit WIP. Tekan + Tambah Unit untuk menambah.')),
                )
              else if (filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Tidak ditemukan unit yang cocok.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final unit = filtered[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: SaUnitCard(
                              unit: unit,
                              onEdit: () => _openForm(context, existingUnit: unit),
                              onDelete: () => _confirmDelete(context, unit),
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
      ),
    );
  }
}
