import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../ui/ui.dart';
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

  // Tombol "Tambah unit" menyembunyikan diri saat daftar di-scroll ke bawah.
  bool _fabVisible = true;

  // Stream dibuat sekali supaya tidak berlangganan ulang saat mengetik.
  late final Stream<List<UnitWip>> _unitStream = _repo.watchUnitWip();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _onScroll(UserScrollNotification n) {
    if (n.direction == ScrollDirection.reverse && _fabVisible) {
      setState(() => _fabVisible = false);
    } else if (n.direction == ScrollDirection.forward && !_fabVisible) {
      setState(() => _fabVisible = true);
    }
    return false;
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
      showAppSnackbar(
        context,
        existingUnit == null
            ? 'Unit baru berhasil disimpan, ranking dihitung ulang.'
            : 'Perubahan unit berhasil disimpan, ranking dihitung ulang.',
      );
    }
  }

  void _confirmDelete(BuildContext context, UnitWip unit) {
    showDeleteConfirmDialog(
      context,
      unit: unit,
      onConfirm: () async {
        Navigator.pop(context);
        try {
          await _repo.deleteUnit(unit.id);
          if (context.mounted) {
            showAppSnackbar(
              context,
              'Unit ${unit.noWO} dihapus, ranking dihitung ulang.',
            );
          }
        } catch (e) {
          if (context.mounted) {
            final ditolak = e.toString().contains('permission-denied');
            showAppSnackbar(
              context,
              ditolak
                  ? 'Hanya unit yang Anda buat sendiri yang dapat dihapus.'
                  : 'Gagal menghapus unit: $e',
              kind: SnackKind.error,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      floatingActionButton: AppFab(
        icon: Icons.add_rounded,
        label: 'Tambah unit',
        visible: _fabVisible,
        onPressed: () => _openForm(context),
      ),
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

          final all = snapshot.data!;
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? all
              : all
                  .where((u) =>
                      u.noWO.toLowerCase().contains(q) ||
                      u.tipeKendaraan.toLowerCase().contains(q))
                  .toList();

          return NotificationListener<UserScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
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
                    child: EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'Belum ada unit WIP',
                      message: 'Tekan "Tambah unit" untuk memasukkan unit pertama.',
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Unit tidak ditemukan',
                      message: 'Coba kata kunci No. WO atau tipe kendaraan lain.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final unit = filtered[index];
                          return StaggeredFadeIn(
                            key: ValueKey(unit.id),
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
            ),
          );
        },
      ),
    );
  }
}
