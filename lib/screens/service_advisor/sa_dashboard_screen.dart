import 'package:flutter/material.dart';

import '../../models/unit_wip.dart';
import '../../services/unit_wip_repository.dart';
import '../../utils/wip_format.dart';
import '../../widgets/app_user_menu.dart';
import '../../widgets/staggered_fade_in.dart';
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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SaUnitFormScreen(existingUnit: existingUnit)),
    );
    if (context.mounted && existingUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data unit berhasil disimpan, ranking dihitung ulang.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, UnitWip unit) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(
        unit: unit,
        onConfirm: () async {
          Navigator.pop(ctx);
          await _repo.deleteUnit(unit.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
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
              SliverToBoxAdapter(child: _Header(primary: primary)),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SearchBar(
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
                            child: _UnitCard(
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

/// ===== Header curved navy, sama pola dengan Kepala Bengkel =====
class _Header extends StatelessWidget {
  const _Header({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderCurveClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 48),
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
                    'SERVICE ADVISOR',
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
              'Data Unit WIP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola data unit kendaraan masuk bengkel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5),
            ),
          ],
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari No. WO atau tipe kendaraan',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// ===== Kartu unit WIP =====
class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit, required this.onEdit, required this.onDelete});

  final UnitWip unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _chipColor(String key, String value) {
    // key: 'sparepart' atau 'spk' -- warna status: siap (hijau), proses (amber), bermasalah (merah)
    const siapValues = {'ready', 'disetujui'};
    const prosesValues = {'order_eo', 'proses_klaim'};
    if (siapValues.contains(value)) return const Color(0xFF1F9D6B);
    if (prosesValues.contains(value)) return const Color(0xFFB36B00);
    return const Color(0xFFB23B1E);
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = '${unit.tanggalMasuk.day}/${unit.tanggalMasuk.month}/${unit.tanggalMasuk.year}';
    final sparepartColor = _chipColor('sparepart', unit.statusSparepart);
    final spkColor = _chipColor('spk', unit.statusSpkAsuransi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.tipeKendaraan,
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      unit.noWO,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _InfoPair(label: 'MASUK', value: tanggal)),
              Expanded(child: _InfoPair(label: 'AGING', value: '${unit.agingHari} hari')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _InfoPair(label: 'PANEL', value: '${unit.jumlahPanel} panel')),
              Expanded(
                child: _InfoPair(label: 'BIAYA', value: 'Rp ${formatRupiah(unit.estimasiBiaya)}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusChip(
                label: 'Part ${labelSparepart(unit.statusSparepart)}',
                color: sparepartColor,
              ),
              _StatusChip(
                label: 'SPK ${labelSpk(unit.statusSpkAsuransi)}',
                color: spkColor,
              ),
              Text(
                'diisi Partman',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// ===== Dialog konfirmasi hapus, sesuai mockup =====
class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({required this.unit, required this.onConfirm});

  final UnitWip unit;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 26),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus unit ini?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '${unit.noWO} (${unit.tipeKendaraan}) akan dihapus dari daftar WIP, lalu ranking dihitung ulang. Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}