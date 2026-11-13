import 'package:flutter/material.dart';

import '../../../models/unit_wip.dart';
import '../../../services/unit_wip_repository.dart';

class _Option {
  final String value;
  final String title;
  final String desc;
  final int skala;
  const _Option(this.value, this.title, this.desc, this.skala);
}

const _options = [
  _Option('ready', 'Ready', 'Suku cadang lengkap / tersedia', 5),
  _Option('order_eo', 'Order EO', 'Suku cadang dalam proses pemesanan', 3),
  _Option('back_order', 'Back Order', 'Suku cadang kosong dari pabrik', 1),
];

/// Bottom sheet khusus ubah statusSparepart. Pilihan radio tidak langsung
/// commit ke Firestore -- baru ditulis saat tombol Simpan ditekan.
/// Mengembalikan true kalau berhasil disimpan, null/false kalau dibatalkan.
Future<bool?> showSparepartUpdateSheet(
  BuildContext context, {
  required UnitWip unit,
  required UnitWipRepository repo,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SparepartSheet(unit: unit, repo: repo),
  );
}

class _SparepartSheet extends StatefulWidget {
  const _SparepartSheet({required this.unit, required this.repo});
  final UnitWip unit;
  final UnitWipRepository repo;

  @override
  State<_SparepartSheet> createState() => _SparepartSheetState();
}

class _SparepartSheetState extends State<_SparepartSheet> {
  late String _selected = widget.unit.statusSparepart;
  bool _isSaving = false;

  Future<void> _simpan() async {
    setState(() => _isSaving = true);
    try {
      await widget.repo.updateUnitFields(widget.unit.id, {'statusSparepart': _selected});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ubah Status Sparepart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              '${widget.unit.tipeKendaraan} · ${widget.unit.noWO} · saat ini: '
              '${_labelOf(widget.unit.statusSparepart)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ..._options.map((o) => _OptionTile(
                  option: o,
                  selected: _selected == o.value,
                  primary: primary,
                  onTap: () => setState(() => _selected = o.value),
                )),
            const SizedBox(height: 8),
            Text(
              'Setelah disimpan, ranking dihitung ulang otomatis.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelOf(String v) => _options.firstWhere((o) => o.value == v).title;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  final _Option option;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.06) : Colors.white,
          border: Border.all(color: selected ? primary : Colors.grey.shade300, width: selected ? 1.6 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? primary : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(option.desc, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Skala ${option.skala}', style: const TextStyle(fontSize: 10.5)),
            ),
          ],
        ),
      ),
    );
  }
}