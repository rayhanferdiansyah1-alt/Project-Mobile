import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../widgets/app_user_menu.dart';
import '../../widgets/staggered_fade_in.dart';
import 'widgets/sparepart_update_sheet.dart';
import 'widgets/spk_update_sheet.dart';
import 'widgets/status_pill.dart';

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
    final changed = await showSparepartUpdateSheet(context, unit: unit, repo: _repo);
    if (changed == true && mounted) _showSuccessSnackbar();
  }

  Future<void> _ubahSpk(UnitWip unit) async {
    final changed = await showSpkUpdateSheet(context, unit: unit, repo: _repo);
    if (changed == true && mounted) _showSuccessSnackbar();
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1D23),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF34D399), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Status berhasil diperbarui. Ranking dihitung ulang.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F4),
      body: StreamBuilder<List<UnitWip>>(
        stream: _repo.watchUnitWip(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allUnits = snapshot.data!;
          final perluUpdateCount = allUnits.where(_perluUpdate).length;
          final filtered = _filter == _FilterMode.perluUpdate
              ? allUnits.where(_perluUpdate).toList()
              : allUnits;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ClipPath(
                  clipper: _HeaderCurveClipper(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 46),
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
                                'PARTMAN / STAF ASURANSI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const AppUserMenu(),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Status Unit WIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: _FilterTabs(
                    current: _filter,
                    perluUpdateCount: perluUpdateCount,
                    semuaCount: allUnits.length,
                    onChanged: (f) => setState(() => _filter = f),
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
                        final unit = filtered[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _UnitCard(
                              unit: unit,
                              onUbahSparepart: () => _ubahSparepart(unit),
                              onUbahSpk: () => _ubahSpk(unit),
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.current,
    required this.perluUpdateCount,
    required this.semuaCount,
    required this.onChanged,
  });

  final _FilterMode current;
  final int perluUpdateCount;
  final int semuaCount;
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          tab(_FilterMode.perluUpdate, 'Perlu update $perluUpdateCount'),
          tab(_FilterMode.semua, 'Semua $semuaCount'),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unit,
    required this.onUbahSparepart,
    required this.onUbahSpk,
  });

  final UnitWip unit;
  final VoidCallback onUbahSparepart;
  final VoidCallback onUbahSpk;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(unit.tipeKendaraan,
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
          Text(unit.noWO, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          _StatusRow(
            label: 'Sparepart',
            pill: StatusPill.sparepart(unit.statusSparepart),
            primary: primary,
            onUbah: onUbahSparepart,
          ),
          const SizedBox(height: 8),
          _StatusRow(
            label: 'SPK Asuransi',
            pill: StatusPill.spk(unit.statusSpkAsuransi),
            primary: primary,
            onUbah: onUbahSpk,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.pill,
    required this.primary,
    required this.onUbah,
  });

  final String label;
  final StatusPill pill;
  final Color primary;
  final VoidCallback onUbah;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 92, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
        pill,
        const Spacer(),
        OutlinedButton(
          onPressed: onUbah,
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: BorderSide(color: primary),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Ubah', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 32);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 32);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}